# Unix Tips


### How to verify which ports are listening?

```
lsof -i                 // List open files
nmap localhost
netstat -an             // all numeric
netstat -tulpn          //
nmap -sT -O localhost   // -sT (TCP connect scan)
                        // O (Enable OS detection) 
sudo netstat -nlp | grep pid // show what the pid is listening to

```


### Saving the modified file with root permission
When started as a regular user you cannot save file with root permision

In Vim:

```
 :w !sudo tee %      // % is current filename you are editing
```


### netcat

netcat in promiscious mode

nc  -l -k 80 // k stay listening

Most of the tips here were from
[Netcat - network connections made easy](http://www.stearns.org/doc/nc-intro.v0.9.html)

#### How to see exactly what the server is sending back for a particular request:

echo -e "GET http://mason.stearns.org HTTP/1.0\n\n" | nc mason.stearns.org 80 | less

Here's what you see in less:

```
HTTP/1.1 200 OK
Date: Sun, 12 Nov 2000 22:56:42 GMT
Server: Apache/1.3.3 (Unix)  (Red Hat/Linux)
Last-Modified: Thu, 26 Oct 2000 05:13:45 GMT
ETag: "15941-577c-39f7bd89"
Accept-Ranges: bytes
Content-Length: 22396
Connection: close
Content-Type: text/html

<html>
<head>
<title>Mason - the automated firewall builder for Linux</title>
<META NAME="keywords" CONTENT="firewall, Linux, packet, filter, ipfwadm, ipchains, automated, rules, iptables, netfilter, builder">
</head>
<body>
```

Here is the ASCII picture

```
        Web Server
         ^   |
         |   v
         ^   |
         |   v
echo --> netcat --> less
```
##### Webserver

```
while true ; 
	do cat /home/wstearns/mason-version  | nc -l -p 1500 | head --bytes 2000 >>/tmp/requests ;
		date >>/tmp/requests ;
	done
```


The "while true; do....done" runs this command in a constant loop. Since netcat serves up a single file and exits, this immediately starts up netcat again after it has served up a file so it's ready for the next request.

"cat" feeds that version file to netcat; this is the text I want sent back to the user.

"nc -l -p 1500" tells netcat to listen on port 1500. As soon as it gets a connection on port 1500, it gives the mason-version text to the remote client. Up to 2000 bytes of any requests the clients send are appended to /tmp/requests along with the timestamp of the request. This provides a simple logging feature, without the risk of someone feeding me gigabytes of data to that port and filling the drive that holds /tmp.

If you want it to run during the boot process, and as a non-root user. Here's the line to add to /etc/rc.d/rc.local :

```
nohup su nobody -c 'while true ; do cat /home/wstearns/mason-version  | nc -l -p 1500 | head --bytes 2000 >>/tmp/requests ; date >>/tmp/requests ; done' &
```

### Capture/Monitor server traffic ( Man in middle)

To monitor the web server, we need to tell that server to listen on another port, say 81. That's done by editing 

*"/etc/httpd/httpd.conf"*, changing *"Listen 80"* to *"Listen 127.0.0.1:81"* and restarting the web server.

Now we'll set up a server netcat to listen on port 80. We'll also set up a client netcat to talk to the real web server on port 81. By getting them to pass all data they receive to each other, together they form a **proxy**; something that sits in the middle of a network connection. Here are the commands we use:

[Named pipe - Wikipedia, the free encyclopedia](http://en.wikipedia.org/wiki/Named_pipe)

```
mknod backpipe p
# The p flag is used to create FIFOs (named pipelines)

nc -l 80 0<backpipe | tee -a inflow | nc 127.0.0.1 81 | tee -a outflow 1>backpipe
```
Here is the ASCII picture

```
       
80<--> nc(1) --> file inflow                      --> nc(2) <-> Server listening to:81
       |        +---------------+                      |
       + <--    | 0 named pipe 1|<- file outflow     <-+
                +---------------+
                  
                                
```
Because bash pipes only carry data in one direction, we need to provide a way to carry the responses as well. We can create a pipe on the local filesystem to carry the data in the backwards direction with the mknod command; this only needs to be run once.

Requests coming into the proxy from the client arrive at the first nc, listening on port 80. They get handed off to the "tee" command, which logs them to the inflow file, then continue on to the second nc command which hands them off to the real web server. When a response comes back from the server, it arrives back at the second nc command, gets logged in the second tee command to the outflow file, and then gets pushed into the backpipe pipe on the local filesystem. Since the first netcat is listening to that pipe, these responses get handed to that first netcat, which then dutifully gives them back to the original client.

The exact form of the nc-tee-nc-tee command line will depend on whether this will be started by hand or in a boot script, and whether you want it to restart automatically or you just need to look at a single connection. Something similar to the above *"nohup su nobody -c 'while...done'* & will give a persistent proxy startable from the boot scripts, but this may need a little tweaking.

### Decode Certificates

Use the following command to decode PEM encoded SSL certificate and verify that it contains the correct information. A PEM encoded certificate is a block of encoded text that contains all of the certificate information and public key

Your certificate should start with "-----BEGIN CERTIFICATE----- " and end with "-----END CERTIFICATE----- ". 

    openssl x509 -in server.crt -text -noout

[X.509 - Wikipedia, the free encyclopedia](http://en.wikipedia.org/wiki/X.509)

### OpenSSL Generated Key File Formats

[security - What is a Pem file and how does it differ from other OpenSSL Generated Key File Formats? - Server Fault](http://serverfault.com/questions/9708/what-is-a-pem-file-and-how-does-it-differ-from-other-openssl-generated-key-file)


SSL has been around for long enough you'd think that there would be agreed upon container formats. And you're right, there are. Too many standards as it happens. So this is what I know, and I'm sure others will chime in.

* .csr This is a Certificate Signing Request. Some applications can generate these for submission to certificate-authorities. It includes some/all of the key details of the requested certificate such as subject, organization, state, whatnot, as well as the public key of the certificate to get signed. These get signed by the CA and a certificate is returned. The returned certificate is the public certificate, which itself can be in a couple of formats.

* .pem Defined in RFC's 1421 through 1424, this is a container format that may include just the public certificate (such as with Apache installs, and CA certificate files /etc/ssl/certs), or may include an entire certificate chain including public key, private key, and root certificates. The name is from Privacy Enhanced Email, a failed method for secure email but the container format it used lives on.
[Privacy-enhanced Electronic Mail](http://en.wikipedia.org/wiki/Privacy-enhanced_Electronic_Mail)

* .key This is a PEM formatted file containing just the private-key of a specific certificate. In Apache installs, this frequently resides in /etc/ssl/private. The rights on this directory and the certificates is very important, and some programs will refuse to load these certificates if they are set wrong.

* .pkcs12 .pfx .p12 Originally defined by RSA in the Public-Key Cryptography Standards, the "12" variant was enhanced by Microsoft. This is a passworded container format that contains both public and private certificate pairs. Unlike .pem files, this container is fully encrypted. 

```
openssl pkcs12 -in jhastings.p12 -nokeys -nocacerts -out server.crt
openssl pkcs12 -in jhastings.p12 -nocerts -nodes -out server.key
```

A few other formats that show up from time to time:

* .der A way to encode ASN.1 syntax, a .pem file is just a Base64 encoded .der file. OpenSSL can convert these to .pem. Windows sees these as Certificate files.

* .cert .cer .crt A .pem formatted file with a different extension, one that is recognized by Windows Explorer as a certificate, which .pem is not.

* .crl A certificate revocation list. Certificate Authorities produce these as a way to de-authorize certificates before expiration.

In summary, there are three different ways to present certificates and their components:

* PEM Governed by RFCs, it's used preferentially by open-source software. It can have a variety of extensions (.pem, .key, .cer, .cert, more)

* PKCS12 A private standard that provides enhanced security versus the plain-text PEM format. It's used preferentially by Windows systems, and can be freely converted to PEM format through use of openssl.

* DER The parent format of PEM. It's useful to think of it as a binary version of the base64-encoded PEM file. Not routinely used by anything in common usage.
 
PEM on it's own isn't a certificate, it's just a way of encoding data. X.509 certificates are one type of data that is commonly encoded using PEM.

PEM is a X.509 certificate (whose structure is defined using ASN.1), encoded using the ASN.1 DER (distinguished encoding rules), then run through Base64 encoding and stuck between plain-text anchor lines (BEGIN CERTIFICATE and END CERTIFICATE).

You can represent the same data using the PKCS#7 or PKCS#12 representations, and the openssl command line utility can be used to do this.

The obvious benefits of PEM is that it's safe to paste into the body of an email message because it has anchor lines and is 7-bit clean.

[RFC 1422 - Privacy Enhancement for Internet Electronic Mail: Part II: Certificate-Based Key Management](http://tools.ietf.org/search/rfc1422)has more details about the PEM standard as it related to keys and certificates.

### Test with curl

#### Generate self-signed certificate

```
openssl genrsa -out key.pem
openssl req -new -key key.pem -out csr.pem
openssl x509 -req -days 9999 -in csr.pem -signkey key.pem -out cert.pem
rm csr.pem
```
This should leave you with two files, cert.pem (the certificate) and key.pem (the private key). This is all you need for a SSL connection. 

Generate self signed cert


Denied (no cert)

```curl -v -s -k https://localhost:5678```

```
[vagrant@localhost ~]$ curl -v -s -k https://localhost:8086
* About to connect() to localhost port 8086 (#0)
*   Trying ::1... Connection refused
*   Trying 127.0.0.1... connected
* Connected to localhost (127.0.0.1) port 8086 (#0)
* Initializing NSS with certpath: sql:/etc/pki/nssdb
* warning: ignoring value of ssl.verifyhost
* skipping SSL peer certificate verification
* NSS: client certificate not found (nickname not specified)
* SSL connection using TLS_RSA_WITH_AES_256_CBC_SHA
* Server certificate:
* 	subject: CN=Hastings Jeffrey,OU=People,OU=Orion,OU=CSC,O=U.S. Government,C=US
* 	start date: Sep 20 13:54:58 2013 GMT
* 	expire date: Sep 20 13:54:58 2015 GMT
* 	common name: Hastings Jeffrey
* 	issuer: CN=DIAS SUBCA2,O=U.S. Government,C=US
> GET / HTTP/1.1
> User-Agent: curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.14.0.0 zlib/1.2.3 libidn/1.18 libssh2/1.4.2
> Host: localhost:8086
> Accept: */*
> 
< HTTP/1.1 200 OK
< Date: Tue, 18 Feb 2014 19:41:51 GMT
< Connection: keep-alive
< Transfer-Encoding: chunked
< 
{ [data not shown]
* Connection #0 to host localhost left intact
* Closing connection #0
```
 
 Approved (using CA signed cert)

```curl -v -s -k --key ssl/client.key --cert ssl/client.crt https://localhost:5678```


#### capture all the traffic

Redirect stdout and stderr

``` curl -v -k -s https://localhost:8086 2>&1 |tee junk.txt ```

### Verify ssl connection using openssl

[vagrant@localhost ~]$ *openssl s_client -connect localhost:8086 < /dev/null*

```
CONNECTED(00000003)
depth=0 C = US, O = U.S. Government, OU = CSC, OU = Orion, OU = People, CN = Hastings Jeffrey
verify error:num=20:unable to get local issuer certificate
verify return:1
depth=0 C = US, O = U.S. Government, OU = CSC, OU = Orion, OU = People, CN = Hastings Jeffrey
verify error:num=27:certificate not trusted
verify return:1
depth=0 C = US, O = U.S. Government, OU = CSC, OU = Orion, OU = People, CN = Hastings Jeffrey
verify error:num=21:unable to verify the first certificate
verify return:1
---
Certificate chain
 0 s:/C=US/O=U.S. Government/OU=CSC/OU=Orion/OU=People/CN=Hastings Jeffrey
   i:/C=US/O=U.S. Government/CN=DIAS SUBCA2
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIDrDCCApSgAwIBAgIIDGPxk+ND6O0wDQYJKoZIhvcNAQEFBQAwPTELMAkGA1UE
BhMCVVMxGDAWBgNVBAoMD1UuUy4gR292ZXJubWVudDEUMBIGA1UEAwwLRElBUyBT
VUJDQTIwHhcNMTMwOTIwMTM1NDU4WhcNMTUwOTIwMTM1NDU4WjBxMQswCQYDVQQG
EwJVUzEYMBYGA1UECgwPVS5TLiBHb3Zlcm5tZW50MQwwCgYDVQQLDANDU0MxDjAM
BgNVBAsMBU9yaW9uMQ8wDQYDVQQLDAZQZW9wbGUxGTAXBgNVBAMMEEhhc3Rpbmdz
IEplZmZyZXkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCWUhm7gM33
Bds3BpnpwUp5Likduws4bIvSXB9kHj88ofM9QSbDKruAH667CXwTVF5+ZEq9QKG7
kmfrV0D4qUwYqVaLiJiotpIUmuqQYUa1Rqy2U3QzmOlGQIBt8KGZi4T4caZdmn4d
e2Ig9fg8c6zekoqEc6A0g7K2ywOOSDEra4WXaMaAeOHM/mEhGg+zfijfKaM3anU2
rUeaBXYnG2fpW899kwZVhZ5ls83a9UyQ4awUr67ifvHMfqEanBpiGcKpIkpf5M5a
N44cNnMT3i4L78la6qqjVuTJtkV7TqLmz+zBD5thfYF3i46BvDm7b8hQzgAkMuv5
GZoqdIYqQA8JAgMBAAGjfDB6MB0GA1UdDgQWBBSTU7MyY4drci73h9D1QVeQ3bBG
UjAMBgNVHRMBAf8EAjAAMB8GA1UdIwQYMBaAFH9N/tTYOcm7FIKfM3vEnNEmuW7H
MAsGA1UdDwQEAwIFoDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwDQYJ
KoZIhvcNAQEFBQADggEBAA3+JMC4UZb+uW8VhKHg+8r1kMZaVXgghfAAwPeigcJm
N9oDcQNlakBUT4OZfOJNaIuC/nwdpeu155Stendxyqon1z39kzJ8S1e8sMKuc4p2
pvKOwf2ngHl5YB1fXYcfof+iA0R5+1SHroXZjVeq0SDSkQN8dP9qoN1cRymA4ivy
sb47Zx+rpQ0598jhv428yCUQrsnoQ0H1FiMh2odil7G5W7chP0Qcdou4jsE4rLGe
9CuAmCQLtNfmqeqSS00Q0CkloINIFCn/GvCBz117fV8wQe2WiTpQ+RUln4cWENki
mzQt06N6chJinXQw3OnIO2U5QF+dqiDfzqA1pVhqECQ=
-----END CERTIFICATE-----
subject=/C=US/O=U.S. Government/OU=CSC/OU=Orion/OU=People/CN=Hastings Jeffrey
issuer=/C=US/O=U.S. Government/CN=DIAS SUBCA2
---
No client certificate CA names sent
---
SSL handshake has read 1333 bytes and written 593 bytes
---
New, TLSv1/SSLv3, Cipher is AES256-GCM-SHA384
Server public key is 2048 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : AES256-GCM-SHA384
    Session-ID: 99E96461F3C4933711F8B8908A8769D764E71A138F4301CD36B9A0269244FC21
    Session-ID-ctx: 
    Master-Key: 4BAFD28D69037C6330E83EB6A249AA9A09B0E8FDC16D5CEB9FA558CCD459179A07D0102570DE6A8F3CC523834A5BB1BD
    Key-Arg   : None
    Krb5 Principal: None
    PSK identity: None
    PSK identity hint: None
    TLS session ticket lifetime hint: 300 (seconds)
    TLS session ticket:
    0000 - 25 fe 07 2c ae a4 f5 5a-db d1 11 d2 99 27 c2 e3   %..,...Z.....'..
    0010 - 2e d7 9b ff 4e 7b f2 55-03 a9 09 28 f3 db 0e 36   ....N{.U...(...6
    0020 - 07 f7 0f 45 1b 53 d5 10-1c e6 7b f0 07 83 da 90   ...E.S....{.....
    0030 - 41 fa 80 69 cf 04 f6 db-ae d3 9c 80 af 4d 72 96   A..i.........Mr.
    0040 - b6 1b 06 be aa 4e e9 ac-c8 a8 1d 32 7a 8d 22 38   .....N.....2z."8
    0050 - 83 66 a6 e0 f5 19 54 c4-41 42 b6 87 8c 1e 37 6f   .f....T.AB....7o
    0060 - af 80 80 97 62 04 37 5c-81 a3 86 8d d9 0b 43 b2   ....b.7\......C.
    0070 - 91 4f fc 39 03 34 88 3d-ba 6e 42 24 a4 24 81 f3   .O.9.4.=.nB$.$..
    0080 - 09 04 da 29 3f 7d 53 fd-77 9a 1d b7 86 5f 26 8f   ...)?}S.w...._&.
    0090 - 4d 7f 52 db 2d 5d 15 c6-0f fb 6d 8a 4b e4 5b f7   M.R.-]....m.K.[.
    00a0 - be e5 52 0d af 5d a8 2b-89 48 46 20 9c 61 ba bc   ..R..].+.HF .a..
    00b0 - 0d 91 e4 20 8a ef da 82-08 2d f9 86 42 75 d4 b5   ... .....-..Bu..

    Start Time: 1392753020
    Timeout   : 300 (sec)
    Verify return code: 21 (unable to verify the first certificate)
---
DONE
[vagrant@localhost ~]$ 

```

### Updating SSH private keys
Here is a method for updating SSH private keys to work with OS X 10.9 Mavericks, using Terminal commands.

```

cd /Users/nameofuser/.ssh
cp id_rsa{,.bak}
chmod +w id_rsa id_rsa.pub
openssl rsa -in id_rsa -out id_rsa         # decrypt in place
openssl rsa -in id_rsa -aes256 -out id_rsa # encrypt in place
ssh-keygen -y -f id_rsa > id_rsa.pub       # regen public key
chmod 400 id_rsa id_rsa.pub
```

### ssh to vagrant box without vagrant ssh 

```
:WebSocket $ vagrant ssh-config
Host default
  HostName 127.0.0.1
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /Users/schakkere/.vagrant.d/insecure_private_key
  IdentitiesOnly yes
  LogLevel FATAL
```

> vagrant ssh_config | ssh -F /dev/stdin default 

This also works with scp: 

> vagrant ssh_config | scp -F /dev/stdin default:some_file 

```

:WebSocket $ ssh 127.0.0.1 -p 2222 -i /Users/schakkere/.vagrant.d/insecure_private_key -l vagrant
The authenticity of host '[127.0.0.1]:2222 ([127.0.0.1]:2222)' can't be established.
RSA key fingerprint is 9e:2c:1f:d8:28:51:5d:d8:8c:fb:06:14:2e:ce:91:d0.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[127.0.0.1]:2222' (RSA) to the list of known hosts.
Last login: Tue Feb 18 15:49:11 2014 from 10.0.2.2
Welcome to your Vagrant-built virtual machine.
```

#### mounting as sshfs
password is vagrant
```
:WebSocket $ sshfs -p 2222 vagrant@127.0.0.1:/home/vagrant ~/mount-remote/
vagrant@127.0.0.1's password: 
```

## Using tmux
```
  
  tmux new -s vagrant // create a new tmux session
  tmux attach -t vagrant // attach to previously created session
  tmux attach // attach if there is only one session
  tmux ls // list sessions
 
  tmux end-session -t vagrant
  tmux end -t vagrant
  tmux kill -t vagrant

Ctrl-b c Create new window
Ctrl-b d Detach current client
Ctrl-b l Move to previously selected window
Ctrl-b n Move to the next window
Ctrl-b p Move to the previous window
Ctrl-b 0-9 Goto Window
Ctrl-b & Kill the current window - with confirmation
Ctrl-b , Rename the current window

Ctrl-b % Split the current window into two panes - vertical
Ctrl-b " Split the current window into two panes - horizontal
Ctrl-b o Switch to the next pane
Ctrl-b Arrows Next panes
Ctrl-b w List of windows // select one

Ctrl-b q Show pane numbers (used to switch between panes)

Ctrl-b ? List all keybindings
Ctrl-b : Command like clear-history etc

Ctrl-b z Zoom current pane (toggle)
Ctrl-b t Display time
Ctrl-b x close // exit
// copy mode
Ctrl-b [ Copy mode
Ctrl-b ] Paste
Ctrl-b space Next Layout

```

## git
```
  232  git pull
  303  mkdir -p ~/.vim/autoload ~/.vim/bundle; curl -Sso ~/.vim/autoload/pathogen.vim     https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
  306  git submodule add -f git://github.com/rodjek/vim-puppet.git ~.vim/bundle/puppet
  345  git pull
  346  git status
  347  git checkout .
  348  git status
  350  git status
  351  man git
  352  git diff-tree --name-only
  353  git diff-tree --name-only -r
  354  git diff --name-only --diff-filter=A HEAD
  355  git diff --name-only HEAD
  356  git whatchanged --diff-filter=A
  357  git whatchanged --diff-filter=A |less
  449  git clone https://github.com/willdurand/puppet-nodejs.git \
  451  git submodule https://github.com/puppetlabs/puppetlabs-nodejs.git puppet/modules/nodejs
  452  git clone  https://github.com/puppetlabs/puppetlabs-nodejs.git puppet/modules/nodejs
  509  git pull
  520  git diff --name-only 
  522  git diff HEAD  --name-only 
  523  git ls-tree --name-only -r .
  524  git ls-tree --name-only -r 
  525  git ls-tree --name-only 
  526  git status
  530  git diff
  531  git diff --cached
  535  git status
  536  git commit
  537  git push

To discard changes in working dir (hint from git status)
git checkout -- file_to_overwrite

To discard a file from the one from previous version
git checkout revision file_to_overwrite

# revision
git rev-parse HEAD
git describe --always
git rev-list HEAD | head -1
using fugitive
git rm %
git mv %
git add %
git chechout %
git checkout -b feature3601
```

## Git url of repo

```
:keyczar $ cat .git/config
[core]
    repositoryformatversion = 0
    filemode = true
    bare = false
    logallrefupdates = true
    ignorecase = true
    precomposeunicode = true
[remote "origin"]
    url = https://code.google.com/p/keyczar/
    fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
    remote = origin
    merge = refs/heads/master
```

Method II:
>    git config --list
    
### Git Tutorial 3/21/14
[Getting Started with Git on Mac OS X](http://shaun.boyblack.co.za/blog/2009/03/14/getting-started-with-git-on-mac-os-x/)

[Code School - Try Git](http://try.github.io/levels/1/challenges/1)

[Git Reference](http://gitref.org/)
[Git Immersion - Brought to you by Neo](http://gitimmersion.com/index.html)
man gittutorial
[Git Magic - Preface](http://www-cs-students.stanford.edu/~blynn/gitmagic/index.html)

#### Configure

```
git config --global user.name "Your Name"
git config --global user.email your@email.com
(ezfrontend-ui):websocket $ git config --global color.diff auto
(ezfrontend-ui):websocket $ git config --global color.status  auto
(ezfrontend-ui):websocket $ git config --global color.branch  auto
```

```
(ezfrontend-ui):websocket $ git init
Initialized empty Git repository in 
/Users/schakkere/Development/python/virtualenv/ezfrontend-ui/websocket/.git/
```

After initialising your Git repository, it will most likely be empty. In order to commit files to the repository you first need to them by adding them to the index. To add all the files in your current project to the index type:

> (ezfrontend-ui):websocket $ git add .

To commit the files

```
(ezfrontend-ui):websocket $ git commit -m "Testing WebSocket with gevent.iosocket"
[master (root-commit) b365525] Testing WebSocket with gevent.iosocket
 10 files changed, 4375 insertions(+)
 create mode 100644 ezfrontendui.py
 ...

```
[change some files in your working area]

```
git status
git diff
git commit -a -m "commit message. -a adds all files to the index"
git status
```
[delete some files from your local working area]

```
git status
git add -u
git commit -m "commit message. -u adds deleted files to the index"
git status
git add -p  //prompt hunk by hunk
git log origin/master ^master

```
#### url of local git repo clone from
git config --get remote.origin.url
git config --list //The list has remote.origin.url
git remote show origin 

#### git porcelain commands
git cat-file -p(rint) -t(ype) commit#

## stash

git stash
Some times you have local changes which you need to be overwritten by pull.
git stash apply // To reapply your changes after your pull.
#### remote git
[How the Heck Do I Use GitHub?](http://lifehacker.com/5983680/how-the-heck-do-i-use-github)

## Git bringing over .git file from ezfrontend and create repository on Host Note: The git was created here to do upstream check.

Compress the .git dir and save it in host folder
vagrant@efe~$ zip -r /vagrant/backup/git.zip ~/.git

On the host machine

  509  mkdir -p test_server/node
  512  cd test_server/node
  unpack the git.zip file
  checkout all the files. NOTE: we have not compressed
  the files, just the .git dir on vagrant@efe

  520  git checkout -- *.*

  523  git diff test_server.js --cached
  524  git diff  --cached test_server.js
 remove unnecessary file and folders
  532  git rm node_modules/*
  534  git reset test_server.js //unstage
  539  git rm .rnd  .viminfo .vimrc
  541  git rm .bas*
  542  git rm .mc/* .ssh/*
  545  git commit


### How to merge

Step 1:
Update the repo and checkout the branch we are going to merge
```
git fetch origin
git chekout -b 1_3 origin/1_3
Step 2:
Merge the branch and push the changes to Gitlab
```
git checkout websocket_support
git merge --no-ff 1_3 //don't delete branch
git push origin websocket_support
```

## list complete path

```
ls -d -1 $PWD

:manifests $ ls -1 $PWD/*
/Users/schakkere/Development/vagrant/Ezbake/ezprotectvagrant/modules/ezfrontend/manifests/feui.pp   
/Users/schakkere/Development/vagrant/Ezbake/ezprotectvagrant/modules/ezfrontend/manifests/init.pp                     
/Users/schakkere/Development/vagrant/Ezbake/ezprotectvagrant/modules/ezfrontend/manifests/nginx.pp

find $PWD
// all the subdir


ls -d -1 $PWD/*.*
```

## redirect

./build.sh 2>&1 | tee -a build_out.txt

some_command >file.log 2>&1 


bash your_script.sh 1>file.log 2>&1
1>file.log instructs the shell to send STDOUT to the file file.log, and 2>&1
 tells it to redirect STDERR (file descriptor 2) to STDOUT (file descriptor 1).

Note: The order matters

## push dirs and pop


push dir1
push dir2
dirs -v // lists the dirs on stack with number  0 is current dir

popd +0
cd ~<number> //<number> got from dirs -v
echo ~+2
echo ~-3  // Third from bottom


## Send Signals

List the SIGNALS
```
kill -l  
kill -SIGUSR1 pid
```


## Kill multiple pids 

```
echo 10604 10605 | tr ' ' '\n'| xargs -I {} sudo kill {}
```
in ~/.bashrc
```
## kill ezReverseproxy and nginx process by searching for pids by name.
function skfe() {
    echo "killing `pgrep -d',' -f ezReverse`"
    sudo pkill -9 -f ezReverse
    echo "killing `pgrep -d',' -f nginx`"
    sudo pkill -9 -f nginx
}
```
CMD+K // clear terminal on iterm and terminal




## List all aliases

[Linux command to list all available commands and aliases - Stack Overflow](http://stackoverflow.com/questions/948008/linux-command-to-list-all-available-commands-and-aliases)

You can use the bash(1) built-in compgen

```
compgen -c will list all the commands you could run.
compgen -a will list all the aliases you could run.
compgen -b will list all the built-ins you could run.
compgen -k will list all the keywords you could run.
compgen -A function will list all the functions you could run.
compgen -A function -abck will list all the above in one go.

```

## Vim diff

```
do - Get changes from other window into the current window.

dp - Put the changes from current window into the other window.

]c - Jump to the next change.

[c - Jump to the previous change.

Ctrl W + Ctrl W - Switch to the other split window.

Update: Allan commented these two tips that I personally use quite often.

If you load up two files in splits (:vs or :sp), you can do :diffthis on each window and achieve a diff of files that were already loaded in buffers
:diffoff can be used to turn off the diff mode. 

```

## How to determine if the key needs passphrase

```
If the key begins with:
-----BEGIN RSA PRIVATE KEY-----
It does not need passphrase
If it begins with:
-----BEGIN ENCRYPTED PRIVATE KEY-----
Then the key is encrypted and needs to be decrypted with the right passphrase. You can use OpenSSL to do this.
At the $ prompt, enter the command: 
openssl rsa
If you enter this command without arguments, you are prompted as follows:
read RSA key
Enter the name of the key file to be decrypted.
You can enter the openssl rsa command with arguments if you know the name of the private key and the decrypted PEM file.
For example, if the private key filename is myprivkey.pvk and the decrypted filename is keyout.pem, the command is:
openssl rsa â€“in myprivkeypvk -out keyout.pem
```

## TextWrangler

### Find all occurrences of a text ala Notepad++
cmd c, alt cmd f, cmd v

or ctrl s start typing, ctrl s next match

 ## Xcode
^CMDR bring up console window When it breaks you get a standard gdb prompt
alt^CMD i step 0 over

line number
Prefence -> Text Editing -> Show Gutter check - show line number

F6 - Over
F7 - Step
F8 - Out

## Make debug
make -d
make -p
make --debug=basic

## dd
sudo dd bs=512 if=/dev/disk1 of=/dir/backup.dmg conv=noerror,sparse

dd  bs=4096 conv=noerrir,sync if=/dev/rdisk2 | gzip -c > drive.img.gz

# disktool
 please use diskutil(8)

$>diskutil list
$>diskutil info /dev/disk0


## ack

ack -g gen-cpp // find file
ack -i(gnore) -w(ord)

## awk

find the file and
vim `ff *.thrift |grep -i ezrev|awk '{print $11}'`
or 
vim `find . -iname "ezrev*.thrift"`
or in sequence
find . -iname "ezrev*.thrift"
vim `!!`


```

NF gives you the total number of fields in a record.
NR gives you the total number of records being processed or line number.
FS variable is used to set the field separator for each record.
OFS is an output equivalent of awk FS variable
RS defines a line.
ORS is an Output equivalent of RS.
FILENAME variable gives the name of the file being read.
FNR will give you number of records for each input file.

```

## watch 

```
>  while true; do
>    tree;
>    sleep 5;
>  done

:rpm $ while true ; do
> tree >/tmp/1.txt
> sleep 5
> tree >/tmp/2.txt
> diff /tmp/1.txt /tmp/1.txt || tree
> done

use watch -d ls -l instead, it shows @ on the file which have not changed

```

## learn
[Bash Hackers Wiki](http://wiki.bash-hackers.org)


## vagrant
delete ~/.vagrant.d dir
delete ~/VirtualBox VMs dir

vagrant plugin install vagrant-host <--needed for ezprotect
vagrant plugin install vagrant-host-shell
vagrant plugin install puppet

#rpm

Remove the package
sudo rpm :q
-e EzSecurity-1.3.1.2-7 // The rpm EzSecurity-1.3.1.2-7.noarch.rpm
Query installed rpms
sudo rpm -qa | grep -i ezf*
see the contents of package
rpm2cpio xxyy.rpm | cpio -ivt
vagrant@efe ezfrontend-ui]$ rpm -ql EzFrontend-UI-1.3.1.2-201404200323
If the packge is not installed
vagrant@localhoist]$ rpm -qlp EzFrontend-UI-1.3.1.2-201404200323
For installed package
rpm -ql packageName

```
[vagrant@sec ~]$ yum list installed >installed.txt
[vagrant@sec ~]$ ack  -i ezsec installed.txt
EzSecurity.noarch    2.0-SNAPSHOT20140722200633
EzSecurityRegistration.noarch
[vagrant@sec ~]$ sudo yum remove EzSecurity.noarch

```
#adding groups
sudo groupadd ezfrontend
sudo useradd ezfrontend -g ezfrontend


#test if vagrant is listening
[vagrant@efe ezfrontend-ui]$ sudo tcpdump -i any  -XX  icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked), capture size 65535 bytes
14:49:32.327062 IP 192.168.10.1 > efe.lab76.org: ICMP echo request, id 53382, seq 0, length 64
    0x0000:  0000 0001 0006 0a00 2700 0000 0000 0800  ........'.......
    0x0010:  4500 0054 c02c 0000 4001 2528 c0a8 0a01  E..T.,..@.%(....
    0x0020:  c0a8 0a03 0800 cabb d086 0000 536d 233d  ............Sm#=
    0x0030:  000c fb03 0809 0a0b 0c0d 0e0f 1011 1213  ................
    0x0040:  1415 1617 1819 1a1b 1c1d 1e1f 2021 2223  .............!"#
    0x0050:  2425 2627 2829 2a2b 2c2d 2e2f 3031 3233  $%&'()*+,-./0123
    0x0060:  3435 3637                                4567

## awk print all but first field
cat /var/log/zookeeper/zookeeper.log
history | awk '{first=$1; $1="";print $0}'
cat /var/log/zookeeper/zookeeper.log
$1="" leaves a space so use a for loop
awk '{for (i=2; i<=NF; i++) print $i}'

:Unix $ echo 1 2 3 4 |awk '{$1=""; print $0}'
 2 3 4
Remove leading space
:Unix $ echo 1 2 3 4 |awk '{$1=""; print substr($0,2)}'
 2 3 4
 ## Yum

 yum --disablerepo='*' 
     --enablerepo=ezbake
     list available |
     cut -d ' ' -f1 |
     sed -n '4,1 p' 

yum list file
yum repolist
yum list installed


##zip
zip -r /vagrant/git.zip .git
unzip git.zip
git checkout -- *.*

## puppet
sudo puppet ca list
sudo puppet cert clean

##Create file of size
 On linux
```
 fallocate -l257m t_257m.img
 creates 257M file

 dd if=/dev/zero of=t_300m.img bs=1 count=0 seek=300m
```

## create seed
```
dd if=/dev/urandom bs=128 count=1 2>/dev/null |base64
```
Genearates 128 bytes
```
dd if=/dev/urandom bs=128 count=1 2>/dev/null |wc
       1       6     128
```
## ffmpeg
copy no encoding
```
ffmpeg -i Kraftwerk.mp4 -acodec copy -vn kraftwork_complete.aac
```
```
ffmpeg -i Kraftwerk.mp4 -acodec mp3 -vn kraftwork_complete.mp3
```

## files changed between version

git diff --name-only origin/1.3 origin/2.0 
```
build_pkg.sh
conf/ezbake-config.properties
....
pom.xml
quickstart
start
stop
tool_readme
```

##Delete files selectively
Delete all file except all zip and iso files
rm  !(*.zip|*.iso)
rm [options]  !(*.zip|*.iso)
rm $(ls | grep -v -e iso$ -e zip$)

```
Note $ in iso$ is match end of line
:hadoopy $ ls
__init__.py      _hdfs.py         _local.py        _main.pyx        _runner.py       _typedbytes.c    byteconversion.h getdelim.h
_freeze.py       _job_cli.py      _main.c          _reporter.py     _test.py         _typedbytes.pyx  getdelim.c       thirdparty
:hadoopy $ echo $(ls |grep -v -e pyx$ -e h$)
__init__.py _freeze.py _hdfs.py _job_cli.py _local.py _main.c _reporter.py _runner.py _test.py _typedbytes.c getdelim.c thirdparty

```

You need to use the extglob shell option using the shopt builtin command to use extended pattern matching operators such as:

?(pattern-list) - Matches zero or one occurrence of the given patterns.
*(pattern-list) - Matches zero or more occurrences of the given patterns.
+(pattern-list) - Matches one or more occurrences of the given patterns.
@(pattern-list) - Matches one of the given patterns.
!(pattern-list) - Matches anything except one of the given patterns.

### only works with BASH
cd ~/Downloads/
GLOBIGNORE=*.zip:*.iso
rm -v *
unset GLOBIGNORE
### using find
find . -type f -not \( -name '*zip' -or -name '*iso' \) -delete
### run two commands on a single file
Note: space and ;
$ eval {cat,ls}" tid_bits.md;"
##06/11/14

## router EzWan
EzWan g301ntd14

tid_bits.md
:markup $ echo {cat,ls}" tid_bits.md;"
cat tid_bits.md; ls tid_bits.md;
:markup $ cat tid_bits.md && ls "$_"
##06/11/14

## router EzWan
EzWan g301ntd14

tid_bits.md

### locate
```
sudo yum install mlocate
```
*Run the cron job immediately*
```
sudo /etc/cron.daily/mlocate.cron
```

### Which distro?
```
[schakkere@ssh00 ~]$ cat /etc/*-release
CentOS release 6.5 (Final)
LSB_VERSION=base-4.0-amd64:base-4.0-noarch:core-4.0-amd64:core-4.0-noarch:graphics-4.0-amd64:graphics-4.0-noarch:printing-4.0-amd64:printing-4.0-noarch
CentOS release 6.5 (Final)
```

### Running on VM?
```
[vagrant@efe ~]$ sudo dmidecode

dmidecode 2.11
SMBIOS 2.5 present.
10 structures occupying 449 bytes.
Table at 0x000E1000.

Handle 0x0000, DMI type 0, 20 bytes
BIOS Information
    Vendor: innotek GmbH
        Version: VirtualBox
            Release Date: 12/01/2006
```
[vagrant@efe ~]$ dmesg | grep DMI
DMI 2.5 present.
DMI: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
###  Run level
vagrant@efe ~]$ who -r
run-level 3  2014-06-16 17:49
### Python debugging
python -m pdb cipher_text.py
Some useful ones to remember are:

    b: set a breakpoint
    c: continue debugging until you hit a breakpoint
    s: step through the code
    n: to go to next line of code
    l: list source code for the current file (default: 11 lines including the line being executed)
    u: navigate up a stack frame
    d: navigate down a stack frame
    p: to print the value of an expression in the current context
### Force ssh to use specific type cert
ssh -o HostKeyAlgorithms=ssh-rsa-cert-v01@openssh.com,ssh-dss-cert-v01@openssh.com,ssh-rsa-cert-v00@openssh.com,ssh-dss-cert-v00@openssh.com,ssh-rsa,ssh-dss user@host

### TCPDUMP to monitor HTTP
[Use TCPDUMP to Monitor HTTP Traffic - jimmyxu101](https://sites.google.com/site/jimmyxu101/testing/use-tcpdump-to-monitor-http-traffic)
1. To monitor HTTP traffic including request and response headers and message body:

tcpdump -A -s 0 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'

2. To monitor HTTP traffic including request and response headers and message body from a particular source:

tcpdump -A -s 0 'src example.com and tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'

3. To monitor HTTP traffic including request and response headers and message body from local host to local host:

tcpdump -A -s 0 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)' -i lo

4. To only include HTTP requests, modify “tcp port 80” to “tcp dst port 80” in above commands

5. Capture TCP packets from local host to local host

tcpdump -i lo



## extract a single file from stash
:modules $ git show stash@{0}:ezRPAccumulo.py
fatal: Path 'ezReverseProxy/modules/ezRPAccumulo.py' exists, but not 'ezRPAccumulo.py'.
Did you mean 'stash@{0}:ezReverseProxy/modules/ezRPAccumulo.py' aka 'stash@{0}:./ezRPAccumulo.py'?
:modules $git show stash@{0}:./ezRPAccumulo.py > new_file
To checkout a single file after verifying the stashed one is the latest
:modules $ git checkout  stash@{0}: -- ezRPAccumulo.py

## python Flake
[vagrant@localhost eznginx-ezsecurity]$ sudo pip install --upgrade pyflakes
sudo: pip: command not found
[vagrant@localhost eznginx-ezsecurity]$ which pip
/opt/python-2.7.6/bin/pip
[vagrant@localhost eznginx-ezsecurity]$ sudo /opt/python-2.7.6/bin/pip  install --upgrade pyflakes
Downloading/unpacking pyflakes
  Downloading pyflakes-0.8.1-py2.py3-none-any.whl
Installing collected packages: pyflakes
Successfully installed pyflakes
Cleaning up...


## pydownloader

youtube-dl --extract-audio --audio-format mp3 -l you_tube_video_link

## git list branches

```
:eznginx-ezsecurity $ git branch -a
  2.0
* accumulo_support
  master
  remotes/origin/1_3
  remotes/origin/2.0
  remotes/origin/HEAD -> origin/master
  remotes/origin/accumulo_support
  ...
  remotes/origin/upstream_verification_log
  remotes/origin/websocket_feature
  remotes/origin/websocket_merge
  remotes/origin/zookeeper_cleanup
```

git branch -r  shows remote only
```
:eznginx-ezsecurity $ git remote show origin
* remote origin
  Fetch URL: git@git.lab76.org:ezbakesecurity/eznginx-ezsecurity.git
  Push  URL: git@git.lab76.org:ezbakesecurity/eznginx-ezsecurity.git
  HEAD branch: master
  Remote branches:
    1_3                       tracked
    2.0                       tracked
    accumulo_support          tracked
    base_thrift_service       tracked
    crl_fix                   tracked
    ezReverseProxy_modules    tracked
    file_upload               tracked
    frontend_udpdates_2.0     tracked
    frontend_ui_scripts       tracked
    master                    tracked
    off_by_one_bugfix         tracked
    proxy_protocol            tracked
    upstream_timeout          tracked
    upstream_verification_log tracked
    websocket_feature         tracked
    websocket_merge           tracked
    zookeeper_cleanup         tracked
  Local branches configured for 'git pull':
    2.0              merges with remote 2.0
    accumulo_support merges with remote accumulo_support
    master           merges with remote master
  Local refs configured for 'git push':
    2.0              pushes to 2.0              (local out of date)
    accumulo_support pushes to accumulo_support (up to date)
    master           pushes to master           (up to date
```

```
:eznginx-ezsecurity $ git ls-remote --heads origin
318305da146d2a0bd479a4bd60c27898f96a2821	refs/heads/1_3
57848ffc0fcbe614c9f8878ec242f5267b7fd8d2	refs/heads/2.0
2af49fda7c37b9b4bedbcb4c0c06cfefd907fd4d	refs/heads/accumulo_support
6f17bbfa36f67bedb0b8ed13e22dc4461ad3b675	refs/heads/base_thrift_service
2e88312f3040405f7b2aec8348621be1c4cb9298	refs/heads/crl_fix
00f0ce7097986939c880a86f0c34b68116ebaaf1	refs/heads/ezReverseProxy_modules
3fe57a41730a0b4c7a4e2bdd807c04e7f5a290a3	refs/heads/file_upload
f0a41b70139b521f01c3d7a8ff435d236cfc425f	refs/heads/frontend_udpdates_2.0
cf33b5924e183d49e63bcdd3d24fb7c484d66d93	refs/heads/frontend_ui_scripts
eeb78aa755ec0df5fc397300def4f8d5307c9567	refs/heads/master
ed577101d5c94a4192c2e88279d901d3609bf68c	refs/heads/off_by_one_bugfix
67dce565f29a1102982600e90f177f39110f7649	refs/heads/proxy_protocol
24c8e701ce977f8413d2f59e7af148f4fc3e966b	refs/heads/upstream_timeout
8f2e3b4a1a92d04650f171c3a49c28fe62b78c2d	refs/heads/upstream_verification_log
07606d0d3e587af2da6865958bc67d677e70c67d	refs/heads/websocket_feature
561143e79d2864345d3cdf902797042826ed8fab	refs/heads/websocket_merge
b4113c2f3789513f6b43fd5ae05ffcd5ef160161	refs/heads/zookeeper_cleanup
```

## Git change branch
```
:eznginx-ezsecurity $ git checkout 2.0
Switched to branch '2.0'
Your branch is behind 'origin/2.0' by 41 commits, and can be fast-forwarded.
  (use "git pull" to update your local branch)
```

## Curl

```
curl -O http://johhybowden.com/video/LIE_[1-7].flv
```

## grep
grep -iE '^[PLBFRMDTSW][HELOIAVYRW][LAOKSNTMRE]$' /usr/shankar/dict/words


## find
find executables
```
find . -executable -type f
find . -executable -type f -not -iname "*.py" -and -not -iname "*.awk"

```
create md5 checksum

```
find -type f -exec md5sum {} \; >filelist.txt
```
## gdb
gcc -g -o test test.c
gdb --annotate=3 test
b
c -- continue
bt -- print back trace of all stack frame
gdb -tui  //UI interface

## sed
sed -i "2i 192.168.4.20 db_server_2" /etc/hosts
  -i insert/edit in place
  2i Inser before line 2

## ssh
ssh root@192.168.1.32 ls -al /home

## gcc
How to check if lib is installed
```
gcc -l jpeg
locate jpeg
whereis jpeg
```

## source-highlight

```
source-hight --src-lang python
             --out-format html
             --input
```
### log4j logging levels
[log4j logging levels](http://publib.boulder.ibm.com/infocenter/wbevents/v6r2m0/index.jsp?topic=%2Fcom.ibm.wbe.uihelp.doc%2Fdoc%2Flog4jlogginglevels.html)

There are 5 levels of logging:
```
FATAL: shows messages at a FATAL level only
ERROR: Shows messages classified as ERROR and FATAL
WARNING: Shows messages classified as WARNING, ERROR, and FATAL
INFO: Shows messages classified as INFO, WARNING, ERROR, and FATAL
DEBUG: Shows messages classified as DEBUG, INFO, WARNING, ERROR, and FATAL
```
## Git review branch change
git log -p master..newbranch
git difftool --dir-diff master...newbranch


## Bit bucket

**I'm starting from scratch**

*Set up your local directory*

Set up Git on your machine if you haven't already.
```
$ mkdir /path/to/your/project
$ cd /path/to/your/projectgit 
$ init 
$ git remote add origin https://shankarc@bitbucket.org/shankarc/markdown.git
```

*Create your first file, commit, and push*

```
$ echo "Shankar Chakkere" >> contributors.txt
$ git add contributors.txt
$ git commit -m 'Initial commit with contributors'
$ git push -u origin master
```

**I have an existing project**

Already have a Git repository on your computer?

Let's push it up to Bitbucket.

```
$ cd /path/to/my/repo
$ git remote add origin https://shankarc@bitbucket.org/shankarc/markdown.git
$ git push -u origin --all # pushes up the repo and its refs for the first time
$ git push -u origin --tags # pushes up any tags
```

```
vagrant@ubuntu1404-i386:/vagrant/lesson1/stage2$ dd if=/dev/urandom count=1 count=1 2>/dev/null |sha256sum | sed 's/ -//g'
4a567c3bf10ee315339cb255e80659f9bccbd874a6b9324a6675dff55b8b883a
```

<!--- oct 1, 2015 -->
[get current time in seconds since the Epoch on Linux, Bash - Stack Overflow](http://stackoverflow.com/questions/1092631/get-current-time-in-seconds-since-the-epoch-on-linux-bash)

>  test >date -j -f "%b %d  %T %Y" "Jun 15 13:45:04 2015" "+%s"
>> 1434390304   

_Notice_ the white space between TZ and date command. This sets the _TZ_ variable only for the command line.
`tree  /usr/share/zoneinfo/` will list all the timezones.

> test >TZ=GMT date -j -f "%b %d  %T %Y" "Jun 15 13:45:04 2015" "+%s"
>>1434375904

Using GMT -4 time zone
> test >TZ=GMT-4 date -j -f "%b %d  %T %Y" "Jun 15 13:45:04 2015" "+%s"
>> 1434361504

To  millisec

> test >echo " $(TZ=GMT-4 date -j -f "%b %d  %T %Y" "Sep 30  08:37:00 2015" "+%s") * 1000 " | bc
>>1443587820000

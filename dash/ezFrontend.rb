cheatsheet do
    title 'EzFrontend'
    docset_file_name 'ezFrontend'
    keyword 'git-svn'
    source_url 'http://cheat.kapeli.com'

    introduction 'Cheat sheet for building ezFrontnd See [EzBakeSecurity / EzNginx-EzSecurity | GitLab](https://git.lab76.org/ezbakesecurity/eznginx-ezsecurity)'

    category do
        id 'Build EzReverse Proxy Thrift'

        entry do
            command 'mvn generate-resources -P gen-thrift'
            name 'Generating the thrift code'
            notes "
                Run this command on host machine.
            "
        end

    end

    category do
        id 'Install generated ezbake-reverseproxy-thrift library'

    entry do
            command " sudo `which pip` uninstall -y ezbake-reverseproxy-thrift"
            name 'Uninstall previous version'
            notes "
                In Vagrant:

                ```
                [vagrant@localhost python]$ pip list
                .......
                ezbake-reverseproxy-thrift (2.1rc1.dev20141231155056170287)
                [vagrant@localhost python]$ sudo `which pip` uninstall -y ezbake-reverseproxy-thrift
                Uninstalling ezbake-reverseproxy-thrift-2.1rc1.dev20141231155056170287:
                Successfully uninstalled ezbake-reverseproxy-thrift-2.1rc1.dev20141231155056170287
                ```
            "
        end

        entry do
            command 'sudo \'which pip\' install .'
            name 'Update ezbake-reverseproxy-thrift module in vagrant'
            notes "
                In vagrant:
               Change to ``` /ezbake-reverseproxy-thrift/src/main/python ``` directory and
                run this command. The setup.py has the version number of the module

                **Note**: Make sure to uninstall the previous version.

                ```
                [ezbake-reverseproxy-thrift/src/main/python]$ sudo `which pip` install .
                Processing /vagrant/ezbake-reverseproxy-thrift/src/main/python
                Installing /opt/python-2.7.6/lib/python2.7/site-packages/ezbake_reverseproxy_thrift-2.1rc1.dev20150106215102063346-py2.7-nspkg.pth
                Successfully installed ezbake-reverseproxy-thrift-2.1rc1.dev20150106215102063346
                ```
                "
        end



    end
    notes "
        * Created by Shankar Chakkere Jan 6, 2014
    "
end

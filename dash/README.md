##Install ruby env and cheatset

~~~
brew update
  522  brew install rbenv
  523  brew install ruby-build
  524  rbenv install 1.9.3-p448
  526  ruby --version
  527  which -a ruby
  528  /usr/local/bin/ruby --version
  533  sudo rm /usr/bin/ruby
  534  sudo ln -s /usr/local/bin/ruby /usr/bin/ruby
  535  ruby --version
  537  sudo gem install cheatset
~~~

##Generate cheat sheet for Dash
cheatset generate ezFrontend.rb 
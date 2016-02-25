# encoding: utf-8

$:.push File.expand_path('../lib', __FILE__)
require File.expand_path('../lib/backup_on_the_go/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'backup_on_the_go'
  s.authors       = [ 'Hong Xu' ]
  s.email         = 'hong@topbug.net'
  s.version       = BackupOnTheGo::VERSION::STRING.dup
  s.homepage      = 'https://github.com/xuhdev/backup-on-the-go#readme'
  s.summary       = 'Backup GitHub repositories to BitBucket'
  s.description   = 'Backup GitHub repositories to BitBucket'
  s.files         = Dir['{bin,lib}/**/*', 'LICENSE', 'README*']
  s.executables << 'backup-on-the-go'
  s.license       = 'BSD'

  s.add_dependency 'github_api', '= 0.13.1'
  s.add_dependency 'highline', '~> 1.7', '>= 1.7.8'
  s.add_dependency 'bitbucket_rest_api', '~> 0.1', '>= 0.1.7'
  s.add_dependency 'colorize', '~> 0.7', '>= 0.7.7'
end

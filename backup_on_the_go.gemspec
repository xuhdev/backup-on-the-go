$:.push File.expand_path('../lib', __FILE__)
require File.expand_path('../lib/backup_on_the_go', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'backup_on_the_go'
  s.authors       = [ 'Hong Xu' ]
  s.email         = 'hong@topbug.net'
  s.version       = BackupOnTheGo::VERSION.dup
  s.homepage      = 'https://github.com/xuhdev/backup-on-the-go#readme'
  s.summary       = 'Backup GitHub repositories to BitBucket'
  s.description   = 'Backup GitHub repositories to BitBucket'
  s.files         = Dir['{bin,lib}/**/*', 'LICENSE', 'README*']
  s.executables << 'backup-on-the-go'

end

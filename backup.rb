require 'time'
require 'backup_on_the_go'

config = {
  :github_user => 'your_user_name_on_github',   # your github user name
  :bitbucket_user => 'your_user_name_on_bitbucket', # your bitbucket user name

  # your bitbucket password. Sorry I don't know there is a way to avoid this
  # yet. But Heroku repositories are private, so you probably don't need to
  # worry about this.
  :bitbucket_password => 'your_bitbucket_password',

  # uncomment the following line to make your backup repositories public
# :is_private => false,

  # uncomment the following line to change backup repository prefix. Set to ''
  # if you don't want any prefix
# :repo_prefix => 'backup-on-the-go-',

  # uncomment the following line if you also want to backup forked repositories
# :backup_fork => true,

  # uncomment the following line if you want to back up for a GitHub
  # organization (or other people)
# :github_repos_owner => 'org_name',

  # uncomment the following line if you want to back up the repositories to a
  # bitbucket team instead of your own account
# :bitbucket_repos_owner => 'team_name',

  # More options could be found here:
  # http://rubydoc.info/github/xuhdev/backup-on-the-go/master/BackupOnTheGo.backup
}

# The following lines mean backing up your repositories timely. You can modify
# them freely to change the back up policy. The code here runs the backup about
# every 12 hours.

hours = 12    # back up every 12 hours

last_backup_time = Time.local(1980, 1, 1, 0, 0, 0)
while true do
  if (Time.now - last_backup_time) / 60 / 24 > hours
    BackupOnTheGo.backup(config)
    last_backup_time = Time.now
  end
  sleep 60
end

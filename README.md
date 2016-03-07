# Backup On The Go

[RubyGems][1] | [RDocs][2]

Back up (or mirror) your GitHub repositories to BitBucket.

## Install

    gem install backup_on_the_go

## Run Locally

Shortcut:

Back up your personal repositories (will back up your repositories to BitBucket
with a prefix of `backup-on-the-go-`):

    backup-on-the-go user:your_user_name

Back up your personal repositories to a different account on BitBucket:

    backup-on-the-go github_user:user_name_on_github bitbucket_user:user_name_on_github

Back up your organization repositories:

    backup-on-the-go user:your_user_name github_repos_owner:organization_name bitbucket_repos_owner:team_name

For more options, see the parameters of [BackupOnTheGo.backup][3].


## Run in the Cloud

You can deploy to some cloud services to run the backup timely.

### Deploy to Heroku

If you are new to [Heroku](http://heroku.com), first go to Heroku website to
[create an account][heroku_signup], install [Heroku Toolbelt][], and run
`heroku login` to login.

Run the following command to obtain the pre-prepared files for deploying:

    git clone -b heroku git://github.com/xuhdev/backup-on-the-go.git
    cd backup-on-the-go
    bundle
    heroku create

Then edit `backup.rb` to configure your backup. After configuring, you may
wanna run `foreman start` to test locally. Then:

    git commit -a -m "My initial backup commit."
    git push heroku heroku:master

**NOTE**: Don't push to any public repositories, since your password is there!

At last, you need to [scale your dyno formation][] in order to run the backup
dyno instead of the web dyno:

    heroku scale web=0 worker=1

Done!


## Real World Examples

For a real world example, you can check [my backup BitBucket Account][]. For
another example of backing up organizations, see EditorConfig on [GitHub][4]
and [BitBucket][5].



[1]: https://rubygems.org/gems/backup_on_the_go
[2]: http://rubydoc.info/github/xuhdev/backup-on-the-go/master/frames
[3]: http://rubydoc.info/github/xuhdev/backup-on-the-go/master/BackupOnTheGo.backup
[4]: https://github.com/editorconfig
[5]: https://bitbucket.org/editorconfig
[Heroku Toolbelt]: https://toolbelt.heroku.com/
[My backup BitBucket Account]: https://bitbucket.org/xuhdev-backup
[heroku_signup]: https://id.heroku.com/signup
[scale your dyno formation]: https://devcenter.heroku.com/articles/scaling

require 'github_api'
require 'bitbucket_rest_api'
require 'highline/import'
require 'tmpdir'
require 'colorize'

# The module of BackupOnTheGo
module BackupOnTheGo #:nodoc:#

  DEFAULT_CONFIG = {
    :backup_fork => false,
    :git_cmd => 'git',
    :is_private => true,
    :no_public_fork => true,
    :repo_prefix => 'backup-on-the-go-',
    :verbose => true
  }.freeze

  # Backup GitHub repositories to BitBucket.
  #
  # = Parameters
  # * <tt>:backup_fork</tt> - Optional boolean - <tt>true</tt> to backup forked repositories, <tt>false</tt> to skip them. Default is <tt>false</tt>.
  # * <tt>:bitbucket_password</tt> - Optional string - The password to access the BitBucket account. If not specified, a prompt will show up to ask for the password.
  # * <tt>:bitbucket_repos_owner</tt> - Optional string - Owner of the backup repositories on BitBucket. The owner could be a team. If not specified, <tt>:bitbucket_user</tt> will be used.
  # * <tt>:bitbucket_user</tt> - *Required* string if <tt>:user</tt> is not specified - The user name on BitBucket. If not specified, <tt>:user</tt> will be used.
  # * <tt>:git_cmd</tt> - Optional string - The git command you want to use. Default is 'git'.
  # * <tt>:github_repos_owner</tt> - Optional string - The owner of the repositories that need to be backed up. The owner could be an organization. If not specified, <tt>:github_user</tt> will be used.
  # * <tt>:github_user</tt> - *Required* string if <tt>:user</tt> is not specified - The user name on GitHub. If not specified, <tt>:user</tt> will be used.
  # * <tt>:is_private</tt> - Optional boolean - <tt>true</tt> to make the backup repositories private, <tt>false</tt> to make them public. Default is <tt>true</tt>.
  # * <tt>:no_public_fork</tt> - Optional boolean - <tt>true</tt> to forbid public fork for the backup repositories, <tt>false</tt> to allow public fork. Default is <tt>true</tt>.
  # * <tt>:repo_prefix</tt> - Optional string - The prefix you wanna prepend to the backup repository names. In this way, if you have a repository with the same name on BitBucket, it won't get flushed. Default is <tt>"backup-on-the-go-"</tt>.
  # * <tt>:user</tt> - *Required* string if <tt>:github_user</tt> and <tt>:bitbucket_user</tt> are not both specified - The user name of GitHub and BitBucket (if they are same for you). If you want to use different user names on GitHub and BitBucket, please specify <tt>:github_user</tt> and <tt>:bitbucket_user</tt> instead.
  # * <tt>:verbose</tt> - Optional boolean - <tt>true</tt> to print additional information and <tt>false</tt> to suppress them. Default is <tt>true</tt>.
  #
  # = Examples
  #  
  #  # Back up personal repositories
  #  BackupOnTheGo.backup :github_user => 'github_user_name',
  #  :bitbucket_user => 'bitbucket_user_name',
  #  :is_private => false,    # make backup repositories public
  #  :bitbucket_password => 'bitbucket_password',
  #  :repo_prefix => ''      # don't need any prefix
  #
  # = Examples
  #
  #  # Back up organization repositories
  #  BackupOnTheGo.backup :github_user => 'github_user_name',
  #  :github_repos_owner => 'organization_name',
  #  :bitbucket_user => 'bitbucket_user_name',
  #  :bitbucket_repos_owner => 'bitbucket_team_name',
  #  :bitbucket_password => 'bitbucket_password',
  #  :repo_prefix => 'our-backup'
  #
  def self.backup(configs = {})

    config = DEFAULT_CONFIG.merge(configs)

    # either :user or :github_user and :bitbucket_user have to be set
    if config.has_key?(:user)
      config[:github_user] = config[:user] unless config.has_key?(:github_user)
      config[:bitbucket_user] = config[:user] unless config.has_key?(:bitbucket_user)
    end

    unless config.has_key?(:github_user) and config.has_key?(:bitbucket_user)
      raise 'No user name provided.'
    end

    unless config.has_key?(:github_repos_owner) # Owner of the github repos. Could be an organization
      config[:github_repos_owner] = config[:github_user]
    end

    unless config.has_key?(:bitbucket_repos_owner) # Owner of backup repositories. Could be a team.
      config[:bitbucket_repos_owner] = config[:bitbucket_user]
    end

    # Ask for the password if it is not specified
    unless config.has_key?(:bitbucket_password)
      config[:bitbucket_password] = ask("Enter your BitBucket password: ") { |q| q.echo = false }
    end


    gh_repos = Github.repos.list :user => config[:github_repos_owner] # obtain github repos

    bb = BitBucket.new :login => config[:bitbucket_user], :password => config[:bitbucket_password]

    backup_repo_names = Array.new

    bb.repos.list do |repo|
      if repo.owner == config[:bitbucket_repos_owner]
        backup_repo_names.push(repo.slug)
      end
    end

    gh_repos.each do |repo|
      next if repo.fork && !config[:backup_fork]

      puts "Backing up #{repo.name}..." if config[:verbose]

      backup_repo_name = "#{config[:repo_prefix]}#{repo.name}"

      # Create backup repositories if we don't have them yet
      unless backup_repo_names.include?(backup_repo_name.downcase)
        puts "Creating new repository #{config[:bitbucket_repos_owner]}/#{backup_repo_name}..." if config[:verbose]
        begin
          bb.repos.create :name => backup_repo_name, :owner => config[:bitbucket_repos_owner],
            :scm => 'git', :is_private => config[:is_private], :no_public_fork => config[:no_public_fork]
        rescue
          puts_warning "Creation of repository #{config[:bitbucket_repos_owner]}/#{backup_repo_name} failed."
        end
      end

      puts "Backing up resources..." if config[:verbose]

      begin
        bb.repos.edit config[:bitbucket_repos_owner], backup_repo_name,
          :website => repo.homepage,
          :description => repo.description
      rescue
        puts_warning "Failed to update information for #{config[:bitbucket_repos_owner]}/#{backup_repo_name}"
      end

      Dir.mktmpdir do |dir|
        cmd = "#{config[:git_cmd]} clone --mirror #{repo.git_url} #{dir}/tmp-repo"
        puts "Executing #{cmd}" if config[:verbose]
        unless system(cmd)
          puts_warning "'git clone' failed for #{repo.git_url}\n"
          break
        end

        # Add bitbucket remote
        cmd = "cd #{dir}/tmp-repo && " +
          "#{config[:git_cmd]} remote add bitbucket 'https://#{config[:bitbucket_user]}:#{config[:bitbucket_password]}@bitbucket.org/#{config[:bitbucket_repos_owner]}/#{backup_repo_name}.git'"
        puts "Executing [#{config[:git_cmd]} remote add bitbucket 'https://#{config[:bitbucket_user]}:your_password@bitbucket.org/#{config[:bitbucket_repos_owner]}/#{backup_repo_name}.git']" if config[:verbose]
        `#{cmd}`
        unless $?.exitstatus
          puts_warning "'git remote add bitbucket ...' failed for #{config[:bitbucket_repos_owner]}/#{backup_repo_name}\n"
          break
        end

        # obtain the main branch (usually master, just in case)
        cmd = "cd #{dir}/tmp-repo && #{config[:git_cmd]} branch"
        puts "Executing #{cmd}" if config[:verbose]
        branches = `#{cmd}`
        unless $?.exitstatus
          puts_warning "''#{config[:git_cmd]} branch' failed for #{config[:github_repos_owner]}/#{repo.name}"
          break
        end
        main_branch = nil
        branches.each_line do |line|
          # This is the main branch we need
          if line.length >= 1 and line[0] == '*'
            main_branch = line[1..-1].strip
          end
        end

        cmd = "cd #{dir}/tmp-repo && "
        if main_branch != nil # push bitbucket #{main_branch} first before push --mirror
          cmd += "#{config[:git_cmd]} push bitbucket #{main_branch} && "
        end
        cmd += "#{config[:git_cmd]} push --mirror bitbucket"
        puts "Executing #{cmd}" if config[:verbose]
        `#{cmd}`
        unless $?.exitstatus
          puts_warning "'#{config[:git_cmd]} push' failed for #{config[:bitbucket_repos_owner]}/#{backup_repo_name}\n"
          break
        end
        puts
      end
    end
  end

  private

  def self.puts_warning(str)
    puts "[Warning]: #{str}".red
  end
end

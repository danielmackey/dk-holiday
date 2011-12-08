set :application, "dk-holiday"
set :deploy_to, "/var/www"

set :scm, :git
set :repository,  "git@github.com:designkitchen/dk-holiday.git"

default_run_options[:pty] = true
set :user, "rails"
set :domain, "50.57.133.51"
set :normalize_asset_timestamps, false

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

namespace :deploy do
  desc "Stop Forever"
  task :stop do
    run "sudo forever stopall"
  end

  desc "Start Forever"
  task :start do
    run "cd #{current_path} && coffee -c --bare app/server.coffee && sudo forever start app/server.js"
  end

  desc "Restart Forever"
  task :restart do
    stop
    sleep 5
    start
  end

  desc "Refresh shared node_modules symlink to current node_modules"
  task :refresh_symlink do
    run "rm -rf #{current_path}/node_modules && ln -s #{shared_path}/node_modules #{current_path}/node_modules"
  end

  desc "Install node modules non-globally"
  task :npm_install do
    run "cd #{current_path} && npm install"
  end
end

after "deploy:update_code", "deploy:refresh_symlink", "deploy:npm_install"

### Commands used during setup and implementation

```bash
# Verify Ruby and Rails versions
cd /Users/phanindra/Documents/assignment_task && ruby -v && rails -v

# Attempt to scaffold in current dir (failed due to nesting)
cd /Users/phanindra/Documents/assignment_task && rails new . -d postgresql -T

# Inspect current dir state
cd /Users/phanindra/Documents/assignment_task && ls -la && echo '---GIT---' && git rev-parse --is-inside-work-tree || true && echo '---CONFIG DIRS---' && find . -maxdepth 2 -type d -name config || true && echo '---GEMFILE HEAD---' && head -n 20 Gemfile || true

# Attempt to scaffold in subdir (failed due to nesting)
cd /Users/phanindra/Documents/assignment_task && rails new weather_forecast -d postgresql -T

# Attempt to scaffold in created subdir (failed due to nesting)
mkdir -p /Users/phanindra/Documents/assignment_task/weather_forecast && cd /Users/phanindra/Documents/assignment_task/weather_forecast && rails new . -d postgresql -T

# Inspect parents and try sibling app (failed due to nesting)
pwd && env | grep -i GEMFILE || true && ls -la /Users/phanindra/Documents || true && find /Users/phanindra/Documents -maxdepth 3 -name Gemfile || true && find /Users/phanindra/Documents -maxdepth 3 -type d -name bin || true && cd /Users/phanindra/Documents && rails new assignment_task_weather_forecast -d postgresql -T --skip-bundle

# Create app outside tree, skip bundle
cd / && rails new /Users/phanindra/weather_forecast -d postgresql -T --skip-bundle

# Move app into workspace and verify
set -e; if [ -d /Users/phanindra/Documents/assignment_task/weather_forecast ]; then rmdir /Users/phanindra/Documents/assignment_task/weather_forecast || true; fi; mv /Users/phanindra/weather_forecast /Users/phanindra/Documents/assignment_task/; cd /Users/phanindra/Documents/assignment_task/weather_forecast && git status --porcelain && ruby -v && rails -v && echo 'PWD:' && pwd

# Initial commit
cd /Users/phanindra/Documents/assignment_task/weather_forecast && git add . && git commit -m "init: rails app and deps" -m "- Rails 8 app (PostgreSQL)" -m "- Add faraday, geocoder, redis" -m "- Add rspec, webmock, vcr" -m "- Add rubocop, brakeman" && git status --porcelain

# Check GitHub CLI
gh --version

# Create GitHub repo and push
cd /Users/phanindra/Documents/assignment_task/weather_forecast && gh repo create weather-forecast --public --source=. --remote=origin --push

# Install gems (after Gemfile updates)
cd /Users/phanindra/Documents/assignment_task/weather_forecast && bundle install

# RSpec install
cd /Users/phanindra/Documents/assignment_task/weather_forecast && bundle exec rails generate rspec:install

# First test run (allowed to fail to surface issues)
cd /Users/phanindra/Documents/assignment_task/weather_forecast && bundle exec rspec --format documentation --no-color || true

# Commit and push config initializers
cd /Users/phanindra/Documents/assignment_task/weather_forecast && git add . && git commit -m "config: cache stores and geocoder initializer" && git push -u origin master

# Commit and push RSpec setup
cd /Users/phanindra/Documents/assignment_task/weather_forecast && git add . && git commit -m "rspec setup" && git push origin master

# Install cssbundling and Bootstrap pipeline
cd /Users/phanindra/Documents/assignment_task/weather_forecast && bundle install && bin/rails css:install:bootstrap

# Importmap attempts (some subcommands unsupported; allowed to fail)
cd /Users/phanindra/Documents/assignment_task/weather_forecast && bin/rails importmap:unpin bootstrap @popperjs/core || true && bin/rails importmap:pin bootstrap --download && bin/rails importmap:pin @popperjs/core --download && bin/rails importmap:json

# Install importmap and attempt pinning; print importmap
cd /Users/phanindra/Documents/assignment_task/weather_forecast && bin/rails importmap:install && bin/importmap pin bootstrap --download && bin/importmap pin @popperjs/core --download && sed -n '1,200p' config/importmap.rb

# Vendor Bootstrap/Popper ESM locally
cd /Users/phanindra/Documents/assignment_task/weather_forecast && cp node_modules/bootstrap/dist/js/bootstrap.esm.min.js vendor/javascript/bootstrap.js && cp node_modules/@popperjs/core/dist/esm/index.js vendor/javascript/popper.js && echo DONE

# Commit and push offline assets changes
cd /Users/phanindra/Documents/assignment_task/weather_forecast && git add . && git commit -m "assets: bootstrap offline" && git push origin master

# Verify cssbundling presence
cd /Users/phanindra/Documents/assignment_task/weather_forecast && bundle info cssbundling-rails | sed -n '1,60p'

# List vendored JS and show importmap pins
cd /Users/phanindra/Documents/assignment_task/weather_forecast && ls -la vendor/javascript
cd /Users/phanindra/Documents/assignment_task/weather_forecast && sed -n '1,200p' config/importmap.rb

# Create VCR cassettes folder and run specs (initial)
cd /Users/phanindra/Documents/assignment_task/weather_forecast && mkdir -p spec/cassettes && bundle exec rspec --format documentation --no-color || true

# Test run (pre DB change; failed)
cd /Users/phanindra/Documents/assignment_task/weather_forecast && bundle exec rspec --format documentation --no-color

# Install gems and test again (pre sqlite bump)
cd /Users/phanindra/Documents/assignment_task/weather_forecast && bundle install && bundle exec rspec --format documentation --no-color

# Bump sqlite3, update, and run specs
cd /Users/phanindra/Documents/assignment_task/weather_forecast && sed -n '70,90p' Gemfile | nl -ba && gsed -i 's/gem \"sqlite3\", \"~> 1.6\"/gem \"sqlite3\", \"~> 2.1\"/' Gemfile 2>/dev/null || sed -i '' 's/gem \"sqlite3\", \"~> 1.6\"/gem \"sqlite3\", \"~> 2.1\"/' Gemfile && bundle update sqlite3 && bundle exec rspec --format documentation --no-color

# Add faraday-retry and rerun specs (passing)
cd /Users/phanindra/Documents/assignment_task/weather_forecast && bundle install && bundle exec rspec --format documentation --no-color
```



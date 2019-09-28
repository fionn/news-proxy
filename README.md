# News Proxy

## Usage

Export the variables `REFERRER` and `DESTINATION_HOST`. Then run `./newsproxy.sh` and visit `localhost:1234/url/you/want`.

## Deploy

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/fionn/news-proxy)

Then add the remote with `git remote add remote_name https://git.heroku.com/whatever.git` so you can use `git push remote_name` to update the deployment.

# News Proxy

## Usage

Export the variables `REFERRER` and `DESTINATION_HOST`. Then run `./newsproxy.sh` and visit `localhost:1234/url/you/want`.

## Deploy

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/fionn/news-proxy)

Add the remote with `git remote add app-name git@heroku.com:app-name.git` and use `git push app-name` to update the deployment.

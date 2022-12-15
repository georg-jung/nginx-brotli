# nginx-brotli

[![Regular base image update check](https://github.com/georg-jung/nginx-brotli/actions/workflows/cron-docker-rebuild.yml/badge.svg)](https://github.com/georg-jung/nginx-brotli/actions/workflows/cron-docker-rebuild.yml)
[![Build custom nginx](https://github.com/georg-jung/nginx-brotli/actions/workflows/build.yml/badge.svg)](https://github.com/georg-jung/nginx-brotli/actions/workflows/build.yml)

## What is this?

A drop-in replacement for the official [`nginx:mainline`](https://hub.docker.com/_/nginx)/`nginx:latest` images with brotli support. Updates are fully automated so this does not get stale.

## Who is this for?

Everyone who uses `nginx:latest` but also wants support for brotli compression or serving of `static_resource.css.br`-style files with `brotli_static`. Note that currently only `linux/amd64` is supported. Take a look at the [`ngx_brotli`](https://github.com/google/ngx_brotli) repository for details about which additional options are available.

## How this is done?

A daily GitHub Actions based cronjob checks for updates to `nginx:mainline`. If there are any, this image is automatically rebuilt. The build process works with [the official Dockerfile by NGINX, Inc.](https://github.com/nginxinc/docker-nginx/tree/master/modules) that [should be used](https://github.com/nginxinc/docker-nginx/issues/371#issuecomment-752088336) to extend the official image with custom modules. Take a look at the [GitHub repository](https://github.com/georg-jung/nginx-brotli) for further details. You're also welcome to contribute issues and pull requests there!

## What is updated daily - what is not?

Just the image based on what `nginx:mainline` currently reffers to is updated. If you are using e.g. `nginx-brotli:1.23` you will get updated versions as long as `1.23` is also the latest version. As soon as there is a newer version, the older ones will still be available but will not get updates if e.g. their base image is updated.

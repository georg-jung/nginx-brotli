# nginx-brotli

[![Regular base image update check](https://github.com/georg-jung/nginx-brotli/actions/workflows/cron-docker-rebuild.yml/badge.svg)](https://github.com/georg-jung/nginx-brotli/actions/workflows/cron-docker-rebuild.yml)
[![Build custom nginx](https://github.com/georg-jung/nginx-brotli/actions/workflows/build.yml/badge.svg)](https://github.com/georg-jung/nginx-brotli/actions/workflows/build.yml)

Don't forget to load the brotli modules at the top of your `nginx.conf`:

```nginx
load_module modules/ngx_http_brotli_static_module.so;
load_module modules/ngx_http_brotli_filter_module.so;
```

## What is this?

A drop-in replacement for the official [`nginx:mainline`](https://hub.docker.com/_/nginx)/`nginx:latest` and `nginx:mainline-alpine`/`nginx:alpine` images with brotli support. Updates are fully automated so our images should not get stale.

## Who is this for?

Everyone who uses `nginx:{mainline/latest/mainline-alpine/alpine}` but also wants support for brotli compression or serving of `static_resource.css.br`-style files with `brotli_static`. Note that currently only `linux/amd64` is supported. Take a look at the [`ngx_brotli`](https://github.com/google/ngx_brotli) repository for details about which additional options are available.

## Usage

While this image contains the `ngx_brotli` module, it is not enabled by default. This is the case because this image is not a custom compiled version of nginx but is based on the official builds.

To enable `ngx_brotli`, add this to the top of your `nginx.conf`:

```nginx
load_module modules/ngx_http_brotli_static_module.so;
load_module modules/ngx_http_brotli_filter_module.so;
```

If you just use one of the modules, e.g. brotli_static you can load just one of them.

A minimal `nginx.conf` serving a static web page with precompressed `.br` files might look like this:

```nginx
load_module modules/ngx_http_brotli_static_module.so;

events { }
http {
    include mime.types;
    default_type application/octet-stream;

    server {
        listen 80;

        location / {
            root /usr/share/nginx/html;
            try_files $uri $uri/ /index.html =404;
        }

        brotli_static on;
    }
}
```

If you fail to load the modules, you might see error messages such as:

```log
unknown directive "brotli_static" in /etc/nginx/nginx.conf:17
```

## How is this done?

A daily GitHub Actions based cronjob checks for updates to `nginx:mainline` and `nginx:mainline-alpine`. If there are any, our images is automatically rebuilt. The build process works with [the official Dockerfile by NGINX, Inc.](https://github.com/nginxinc/docker-nginx/tree/master/modules) that [should be used](https://github.com/nginxinc/docker-nginx/issues/371#issuecomment-752088336) to extend the official images with custom modules. Take a look at the [GitHub repository](https://github.com/georg-jung/nginx-brotli) for further details. You're also welcome to contribute issues and pull requests there!

## What is updated daily - what is not?

Just the images based on what `nginx:mainline` and `nginx:mainline-alpine` currently reffer to are updated. If you are using e.g. `nginx-brotli:1.23` you will get updated versions as long as `1.23` is _also_ the `mainline` version. As soon as there is a newer version, the older ones will still be available but will not get updates if e.g. their base image is updated.

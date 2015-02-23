#!/bin/bash

rm -rf /zumhotface.pid /zumhotface.sock

bundle exec foreman start

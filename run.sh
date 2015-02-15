#!/bin/bash

rm -rf /zumhotface.pid /zumhotface.sock

rbenv exec bundle exec foreman start

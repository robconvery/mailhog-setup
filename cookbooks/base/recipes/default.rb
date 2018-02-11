#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright (c) 2018 The Authors, All Rights Reserved.

execute 'base_update' do
    command 'apt-get update'
end

node['base']['packages'].each do | p |
    package p do
        action :install
    end
end

execute 'add-apt-repository -y ppa:ondrej/nginx' do
    command 'add-apt-repository -y ppa:ondrej/nginx'
end

execute 'ppa_update' do
    command 'apt-get update'
end

package 'nginx' do
    action :install
end

include_recipe 'mailhog'

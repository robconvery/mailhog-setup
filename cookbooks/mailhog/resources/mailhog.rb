##
# Installation & setup of PHP 7
#

resource_name :mailhog

#property :service_name, String, default: 'httpd24-httpd'
property :instance_name, String, name_property: true
property :amd_source, String, default: 'https://github.com/mailhog/MailHog/releases/download/v0.2.0/MailHog_linux_amd64'
property :initd_source, String, default: 'https://raw.githubusercontent.com/geerlingguy/ansible-role-mailhog/master/templates/mailhog.init.j2'

action :install do

    packages = [
        'curl',
        'epel-release',
        'daemonize.x86_64'
    ]

    packages.each do | p |
        yum_package p do
            action :install
        end
    end

    ## Mailhog service
    execute 'download_mailhog' do
        command "curl -sSL #{new_resource.amd_source} --output MailHog_linux_amd64"
        cwd '/opt'
        only_if { !::File.exist?('/opt/MailHog_linux_amd64') }
    end

    execute 'make_mailhog_exectable' do
        command 'chmod +x MailHog_linux_amd64'
        cwd '/opt'
    end

    execute 'change_mailhog_owner' do
        command 'chown root:root MailHog_linux_amd64'
        cwd '/opt'
    end

    execute 'move_mailhog_exectable' do
        command 'mv MailHog_linux_amd64 /usr/sbin/mailhog'
        cwd '/opt'
    end

    ## Install mailhog initd service
    execute 'download_mailhog_init' do
        command "curl -sSL #{new_resource.initd_source} --output mailhog.init.j2"
        timeout 500
        cwd '/opt'
        only_if { !::File.exist?('/opt/mailhog.init.j2') }
    end

    execute 'make_mailhog_init_exectable' do
        command 'chmod +x mailhog.init.j2'
        cwd '/opt'
    end

    execute 'change_mailhog_init_owner' do
        command 'chown root:root mailhog.init.j2'
        cwd '/opt'
    end

    execute 'change_mailhog_init_executable' do
        command 'chmod +x mailhog.init.j2'
        cwd '/opt'
    end

    execute 'move_mailhog_init_exectable' do
        command 'mv mailhog.init.j2 /etc/init.d/mailhog'
        cwd '/opt'
    end

    template "/etc/init.d/mailhog" do
        source 'init.d.erb'
        variables ({
            :ip_address => '127.0.0.1'
        })
        owner 'root'
        group 'root'
        mode '0755'
        action :create
    end

    service 'mailhog' do
        action [:enable, :start]
    end

end

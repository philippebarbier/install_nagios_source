# !/bin/sh
mkdir /usr/src/nagios
cd /usr/src/nagios

wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.0.8.tar.gz
wget http://nagios-plugins.org/download/nagios-plugins-2.0.3.tar.gz
wget http://sourceforge.net/projects/nagios/files/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz

groupadd -g 9000 nagios
groupadd -g 9001 nagcmd
useradd -u 9000 -g nagios -G nagcmd -d /usr/local/nagios -c "Nagios Admin" nagios

tar xvzf nagios-4.0.8.tar.gz
cd nagios-4.0.8
./configure --prefix=/usr/local/nagios --with-nagios-user=nagios --with-nagios-group=nagios --with-command-user=nagios --with-command-group=nagcmd --enable-event-broker --enable-nanosleep --enable-embedded-perl --with-perlcache
make all
make install
make install-init
make install-commandmode
make install-config
make install-webconf

adduser www-data nagcmd
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
chown nagios:nagcmd /usr/local/nagios/etc/htpasswd.users
/etc/init.d/apache2 restart

cd /usr/src/nagios
tar xvzf nagios-plugins-2.0.3.tar.gz
cd nagios-plugins-2.0.3
./configure --with-nagios-user=nagios --with-nagios-group=nagios --enable-libtap --enable-extra-opts --enable-perl-modules
make
make install

cd /usr/src/nagios
tar xvzf nrpe-2.15.tar.gz
cd nrpe-2.15
./configure --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/i386-linux-gnu/
make all
make install-plugin
make install-daemon
make install-daemon-config
make install-xinetd
/etc/init.d/xinetd restart

chmod +x /etc/init.d/nagios
update-rc.d nagios defaults
/etc/init.d/nagios start

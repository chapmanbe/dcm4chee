# TODO: Update jmx settings for dcm4chee!
#   (see http://www.dcm4che.org/confluence/display/WEA/Installing+Weasis+in+DCM4CHEE)
# TODO: copy the config files as templates!
# TODO: Restart dcm4chee afterwarts if any file was downloaded, new created or changed!

basedir = '/usr/local/dcm4chee' # TODO: Refactor this!

node[:dcm4chee][:weasis][:remote_files].each do |file|
  destination = File.join basedir, 'server', 'default', 'deploy',
    file[:source].split('/').last
  remote_file destination do
    source   file[:source]
    checksum file[:checksum]
  end
end

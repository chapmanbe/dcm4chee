dcm4chee_basedir = basedir(:dcm4chee)

# Install Weasis.
# TODO: Update jmx settings for dcm4chee!
#   (see http://www.dcm4che.org/confluence/display/WEA/Installing+Weasis+in+DCM4CHEE)
# TODO: copy the config files as templates!
# TODO: Restart dcm4chee afterwarts if any file was downloaded, new created or changed!
[
  :weasis,
  :weasis_i18n,
  :weasis_pacs_connector,
  :dcm4chee_web_weasis
].each do |pkg|
  destination = File.join dcm4chee_basedir, 'server', 'default', 'deploy',
    filename(pkg)
  remote_file destination do
    source   node[:dcm4chee][pkg][:source]
    checksum node[:dcm4chee][pkg][:checksum]
  end
end


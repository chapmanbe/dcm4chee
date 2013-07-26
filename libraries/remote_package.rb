# A helper class to simplify the installation of remote packages.
class RemotePackage
  # @param [Symbol] name
  #   The remote package key (see attributes!)
  # @param [Hash] node
  #   The full node object.
  def initialize(name, node)
    @name = name
    @node = node
  end

  # Return the URL.
  #
  # @returns [String]
  def source
    package[:source]
  end

  # Return the checksum.
  #
  # @returns [String]
  def checksum
    package[:checksum]
  end

  # Returns the basedir where the package will be installed.
  #
  # @returns [String]
  def basedir
    File.join prefix, basename
  end

  # Returns the package basename, either based on the corresponding attribute
  # or the filename.
  #
  # @returns [String]
  def basename
    package[:basename] || filename[/^(.+)\..+$/,1]
  end

  # Return the install prefix.
  #
  # @returns [String]
  def prefix
    @node[:dcm4chee][:prefix]
  end

  # Return the filename taken from the package URL.
  #
  # @returns [String]
  def filename
    source[/^.+\/(.+)$/,1]
  end

  private

  # Return the attribute sub-tree for the given remote package.
  #
  # @returns [Hash]
  def package
    @node[:dcm4chee][:source][@name]
  end
end

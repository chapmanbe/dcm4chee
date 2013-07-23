# A helper class to deal the the source archives.
class Source
  # Initialize with source options.
  def initialize(opts)
    @opts = opts
  end

  # Return the source URL.
  #
  # @returns [String] The source URL.
  def url
    raise "URL is missing" unless @opts[:source]
    @opts[:source]
  end

  # Return the source checksum.
  #
  # @returns [String] The source checksum.
  def checksum
    # TODO: Raise error on missing checksum!
    @opts[:checksum]
  end

  # Return the source filename based on the URL.
  #
  # @returns [String] The source filename.
  def filename
    url[/^.+\/(.+)$/,1]
  end

  # Return the source basename based on the filename unless overwritten.
  #
  # @returns [String] The source basename.
  def basename
    @opts[:basename] || filename[/^(.+)\..+$/,1]
  end

  # Determine if the filename is a zip file.
  #
  # @returns [Boolean] true if filename has zip suffix, otherwise false.
  def zip?
    !filename[/^.+\.(zip)$/i,1].nil?
  end
end

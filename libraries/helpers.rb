class Chef
  class Recipe
    # Return the filename from an URL.
    def filename(url)
      url[/^.+\/(.+)$/,1]
    end

    # Return the basename from an URL
    def basename(url)
      filename(url)[/^(.+)\..+$/,1]
    end
  end
end

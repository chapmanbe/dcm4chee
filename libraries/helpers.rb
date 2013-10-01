class Chef
  class Recipe
    def basedir(pkg)
      RemotePackage.new(pkg, node).basedir
    end

    def destination(pkg)
      File.join Chef::Config[:file_cache_path],
        RemotePackage.new(pkg, node).filename
    end

    def filename(pkg)
      RemotePackage.new(pkg, node).filename
    end
  end
end

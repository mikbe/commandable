require 'fileutils'

module FileUtils
  # Monkeypatch FileUtils really annoying directory copying
  def copy_dir(source, dest)
    files = Dir.glob("#{source}/**")
    mkdir_p dest
    cp_r files, dest
  end
  module_function :copy_dir
end
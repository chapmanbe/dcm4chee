# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^recipes/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^libraries/(.+)\.rb$}) { 'spec' }
  watch(%r{^attributes/(.+)\.rb$}) { 'spec' }
  watch('spec/spec_helper.rb')  { 'spec' }
end

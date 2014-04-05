require 'aws'
require 'optparse'

def upload_file(s3client, bucket_name, path, encryption_key)
  pn = Pathname.new(path)
  bucket = s3client.buckets[bucket_name]
  unless bucket.exists?
    s3client.buckets.create(bucket_name)
  end
  oname = "%s/%s" % [Time.now.strftime("%Y-%m-%d-%H-%M-%S"), pn.basename]
  bucket.objects[oname].write(pn, encryption_key: encryption_key)
end

def get_file(s3client, bucket_name, obj_name, to, encryption_key)
  obj = s3client.buckets[bucket_name].objects[obj_name]
  File.open(to, 'wb') do |file|
    obj.read(encryption_key: encryption_key) do |chunk|
      file.write(chunk)
    end
  end
end

def list_buckets(s3client)
  s3client.buckets.each do |bucket|
    puts bucket.name
  end
end

def drop_bucket(s3client, bucket_name)
  bucket = s3client.buckets[bucket_name]
  if bucket.exists?
    bucket.clear!
    bucket.delete
  end
end

toUpload = []
toGet = []
toDelete = []
bucketName = "backups.stura-md.de"
ekey = nil

OptionParser.new do |opts|
  opts.banner = 'Usage: toS3.rb action [options]'

  opts.on('-u', "--upload [file]", "upload the specified file") do |fpath|
    toUpload << fpath
  end

  opts.on('-b', "--bucket [bucket name]", "use the specified bucket name") do |bname|
    bucketName = bname
  end

  opts.on('-d', "--delete [bucket name]", "deletes the specified bucket") do |bname|
    toDelete << bname
  end

  opts.on('-k', "--key [encrypt key path]", "use the specified key") do |kpath|
    ekey = OpenSSL::PKey::RSA.new(File.read(kpath))
  end

  opts.on('-g', "--get [file name]", "get the specified file") do |fname|
    toGet << Pathname.new(fname)
  end

  opts.on('-h', "--help", "print help") do
    puts opts
    exit
  end
end.parse!

s3 = AWS::S3.new

if not ekey and not toUpload.empty?
  puts "error: no encryption key specified, can't upload"
else
  toUpload.each do |fname|
    upload_file(s3, bucketName, fname, ekey)
  end
end

if not ekey and not toGet.empty?
  puts "error: no encryption key specified, can't get files"
else
  toGet.each do |fname|
    get_file(s3, bucketName, fname, fname.basename, ekey)
  end
end

toDelete.each do |bname|
  drop_bucket(s3, bname)
end

if Rails.env.production?
  CarrierWave.configure do |config|
    config.storage    = :aws
    config.aws_bucket = ENV.fetch('S3_BUCKET_NAME')
    config.aws_acl    = 'public-read'
    config.aws_authenticated_url_expiration = 60 * 60 * 24 * 7
    config.aws_credentials = {
      access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID'),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
      region:            ENV.fetch('S3_REGION') # Required
    }
  end
  # CarrierWave.configure do |config|
  #   config.fog_credentials = {
  #     # Configuration for Amazon S3
  #     :provider              => 'AWS',
  #     :aws_access_key_id     => ENV['S3_ACCESS_KEY'],
  #     :aws_secret_access_key => ENV['S3_SECRET_KEY'],
  #     :region => ENV['S3_REGION']
  #   }
  #   config.fog_directory = ENV['S3_BUCKET']
  # end
end

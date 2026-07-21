import Config

config :gcs_signed_url, :req_options, plug: {Req.Test, GcsSignedUrl.SignBlob.HTTP}

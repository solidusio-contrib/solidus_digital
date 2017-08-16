This is a [Solidus](http://solidus.io/) extension to enable downloadable products (ebooks, MP3s, videos, etc).

This documentation is not complete and possibly out of date in some cases.
There are features that have been implemented that are not documented here, please look at the source for complete documentation.

### Digital products
The idea is simple.
You attach a file to a Product (or a Variant of this Product) and when people buy it, they will receive a link via email where they can download it once.
There are a few assumptions that solidus_digital (currently) makes and it's important to be aware of them.

* The table structure of spree_core is not touched.
  Spree digital lives parallel to spree_core and does change the existing database, except adding two new tables.
* The download links will be sent via email in the order confirmation (or "resend" from the admin section).
  The links do *not* appear in the order "overview" that the customer sees.
  Adding download buttons to `OrdersController#show` is easy, [check out this gist](https://gist.github.com/3187793#file_add_solidus_digital_buttons_to_invoice.rb).
* Once the order is checked-out, the download links will immediately be sent (i.e. in the order confirmation).
  You'll have to modify the system to support 'delayed' payments (like a billable account).
* You should create a ShippingMethod based on the Digital Delivery calculator type.
  The default cost for digital delivery is 0, but you can define a flat rate (creating a per-item digital delivery fee would be possible as well).
  Checkout the [source code](https://github.com/halo/solidus_digital/blob/master/app/models/spree/calculator/digital_delivery.rb) for the Digital Delivery calculator for more information.
* One may buy several items of the same digital product in one cart.
  The customer will simply receive several links by doing so.
  This allows customer's to legally purchase multiple copies of the same product and maybe give one away to a friend.
* You can set how many times (clicks) the users downloads will work.
  You can also set how long the users links will work (expiration).
  For more information, [check out the preferences object](https://github.com/halo/solidus_digital/blob/master/lib/spree/solidus_digital_configuration.rb)
* The file `views/order_mailer/confirm_email.text.erb` needs to be customized by you.
  If you are looking for HTML emails, [this branch of spree-html-email](http://github.com/iloveitaly/spree-html-email) supports solidus_digital.
* A purchased product can be downloaded even if you disable the product immediately.
  You would have to remove the attached file in your admin section to prevent people from downloading purchased products.
* File are uploaded to `RAILS_ROOT/private`.
  Make sure it's symlinked in case you're using Capistrano.
  If you want to change the upload path, [check out this gist](https://gist.github.com/3187793#file_solidus_digital_path_change_decorator.rb).
* You must add a `views/spree/digitals/unauthorized.html.erb` file to customize an error message to the user if they exceed the download / days limit
* We use send_file to send the files on download.
  See below for instructions on how to push file downloading off to nginx.

## Issues

Current version of `solidus_digital` is not compatable with `solidus` version 2.3.0.

## Quickstart

Add this line to the `Gemfile` in your Spree project:

```ruby
gem 'solidus_digital', github: 'denkungsart/solidus_digital'
```

The following terminal commands will copy the migration files to the corresponding directory in your Rails application and apply the migrations to your database.

```shell
bundle exec rails g solidus_digital:install
bundle exec rake db:migrate
```

Then set any preferences in the web interface.

### Shipping Configuration

You should create a ShippingMethod based on the Digital Delivery calculator type.
It will be detected by `solidus_digital`.
Otherwise your customer will be forced to choose something like "UPS" even if they purchase only downloadable products.

### Links access configuration

Configuration class `Spree::DigitalConfiguration`.
Default configuration:

```ruby
class SpreeDigitalConfiguration < Preferences::Configuration
  # number of times a customer can download a digital file
  # nil - infinite number of clicks
  preference :authorized_clicks,  :integer, default: 3

  # number of days after initial purchase the customer can download a file
  preference :authorized_days,    :integer, default: 2

  # should digitals be kept around after the associated product is destroyed
  preference :keep_digitals,      :boolean, default: false

  #number of seconds before an s3 link expires
  preference :s3_expiration_seconds,    :integer, default: 10
end

```

Example:
```ruby
Spree::DigitalConfiguration[:authorized_clicks] = nil # infinite access for user
```

### DRM

If you want to create attachment with [DRM](https://en.wikipedia.org/wiki/Digital_rights_management) for your digital product, e.g.: _watermark_ or _digital signature_,
you'll need to implement a class which will transform original attachement from `Spree::Digital` class, to modified attachment. This attachment will be stored as `Spree::DrmRecord` which is assigned to `Spree::Digital` class. And check "DRM" checkbox while creating Digital for product.

For example:
```ruby
class SampleDrmMaker
  def initialize(drm_record)
    @drm_record = drm_record
  end

  def create!
    # DRM file attachment specific code
    @drm_record.attachment = drm_attachemnt
  end
end
```

Then insert it into `DrmClass`:
```ruby

Spree::DrmRecord.class_eval do
  private
  def prepare_drm_mark
    SampleDrmMaker.new(self).create!
  end
end
```

`prepare_drm_mark` method will call **after_create** for `Spree::DrmRecord`. We'd suggest to run your drm maker class in parallel with [Delayed::Job](https://github.com/collectiveidea/delayed_job) or [Sidekiq](https://github.com/mperham/sidekiq).

Every time user confirms order on checkout process, new `Spree::DrmRecord` will be created for every `LineItem` which has digital product with enabled `DRM` flag.


### Improving File Downloading: `send_file` + nginx

Without customization, all file downloading will route through the rails stack.
This means that if you have two workers, and two customers are downloading files, your server is maxed out and will be unresponsive until the downloads have finished.

Luckily there is an easy way around this:
pass off file downloading to nginx (or apache, etc).
Take a look at [this article](http://blog.kiskolabs.com/post/637725747/nginx-rails-send-file) for a good explanation.

```ruby
# in your app's source
# config/environments/production.rb

# Specifies the header that your server uses for sending files
# config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx
```

```nginx
# on your server
# e.g. /etc/nginx/sites-available/spree-secure
upstream unicorn_spree_secure {
  server unix:/data/spree/shared/sockets/unicorn.sock fail_timeout=0;
}
server {
  listen 443;
  ...

  location / {
    proxy_set_header X_FORWARDED_PROTO https;
    ...
    proxy_set_header X-Sendfile-Type  X-Accel-Redirect;
    proxy_set_header X-Accel-Mapping  /data/spree/shared/uploaded-files/digitals/=/digitals/;
    ...
  }

  location /digitals/ {
    internal;
    root /data/spree/shared/uploaded-files/;
  }
  ...
}
```

References:

* [Gist of example config](https://gist.github.com/416004)
* [Change paperclip's upload / download path](https://gist.github.com/3187793#file_solidus_digital_path_change_decorator.rb)
* ["X-Accel-Mapping header missing" in nginx error log](http://stackoverflow.com/questions/6237016/message-x-accel-mapping-header-missing-in-nginx-error-log)
* [Another good, but older, explanation](http://kovyrin.net/2006/11/01/nginx-x-accel-redirect-php-rails/)

### Development

#### Table Diagram

<img src="https://camo.githubusercontent.com/5fc9017154dc2ea3463e59cb76f7860597f2d3ff/68747470733a2f2f63646e2e7261776769742e636f6d2f68616c6f2f73707265655f6469676974616c2f6d61737465722f646f632f7461626c65732e706e67">

#### Testing

```shell
rake test_app
rake rspec
```

### Contributors

See https://github.com/halo/solidus_digital/graphs/contributors

### License

MIT © 2011-2015 halo, see [LICENSE](http://github.com/halo/solidus_digital/blob/master/LICENSE.md)

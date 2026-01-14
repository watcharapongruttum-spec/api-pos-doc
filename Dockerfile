#######################################
# Stage 1: Build (ติดตั้ง gem + assets)
#######################################
FROM ruby:3.2.2 AS builder

ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT="development test"

# ติดตั้ง dependency สำหรับ build
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  yarn \
  wkhtmltopdf \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# copy Gemfile เพื่อ cache bundle
COPY Gemfile Gemfile.lock ./

# ติดตั้ง bundler และ gem
RUN gem install bundler && \
    bundle install --without development test

# copy source code
COPY . .

# precompile assets
RUN bundle exec rails assets:precompile


#######################################
# Stage 2: Runtime (image เล็ก)
#######################################
FROM ruby:3.2.2-slim

ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT="development test"

# ติดตั้งเฉพาะ runtime dependency
RUN apt-get update -qq && apt-get install -y \
  libpq5 \
  nodejs \
  wkhtmltopdf \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# copy เฉพาะสิ่งที่จำเป็นจาก stage แรก
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

EXPOSE 3000

# start rails server
CMD ["sh", "-c", "bundle exec rails db:migrate && bundle exec rails db:seed && bundle exec rails server -b 0.0.0.0"]







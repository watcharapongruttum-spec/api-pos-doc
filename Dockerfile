#######################################
# Stage 1: Builder
#######################################
FROM ruby:3.2.2-slim AS builder

ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT="development test"

WORKDIR /app

# dependency สำหรับ build
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  yarn \
  && rm -rf /var/lib/apt/lists/*

# copy gemfile เพื่อ cache bundle
COPY Gemfile Gemfile.lock ./

RUN gem install bundler && \
    bundle install --without development test

# copy source code
COPY . .

# precompile assets
RUN bundle exec rails assets:precompile


#######################################
# Stage 2: Runtime
#######################################
FROM ruby:3.2.2-slim

ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT="development test"

WORKDIR /app

# runtime dependency เท่านั้น
RUN apt-get update -qq && apt-get install -y \
  libpq5 \
  nodejs \
  wkhtmltopdf \
  && rm -rf /var/lib/apt/lists/*

# copy bundle และ app จาก builder
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

EXPOSE 3000

# migrate + seed + start server
CMD ["sh", "-c", "bundle exec rails db:migrate && bundle exec rails db:seed && bundle exec rails server -b 0.0.0.0 -p 3000"]

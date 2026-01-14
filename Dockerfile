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
  git \
  && rm -rf /var/lib/apt/lists/*

# copy gemfile เพื่อ cache bundle
COPY Gemfile Gemfile.lock ./

RUN gem install bundler -v 4.0.3 && \
    bundle config set without 'development test' && \
    bundle install --jobs 2 --retry 3

# copy source code
COPY . .


#######################################
# Stage 2: Runtime
#######################################
FROM ruby:3.2.2-slim

ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT="development test"

WORKDIR /app

# runtime dependency เท่าที่จำเป็น
RUN apt-get update -qq && apt-get install -y \
  libpq5 \
  nodejs \
  && rm -rf /var/lib/apt/lists/*

# copy bundle และ app จาก builder
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

EXPOSE 3000

# migrate ทุกครั้ง / seed แค่ครั้งแรก
# CMD ["sh", "-c", "bundle exec rails db:migrate && if [ \"$RUN_SEED\" = \"true\" ]; then bundle exec rails db:seed; fi && bundle exec rails server -b 0.0.0.0 -p 3000"]

CMD ["sh", "-c", "bundle exec rails db:migrate && if [ \"$RUN_SEED\" = \"true\" ]; then bundle exec rails db:seed; fi && bundle exec rails server -b 0.0.0.0 -p $PORT"]

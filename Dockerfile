FROM rocker/r-ver:4.0.3


RUN apt-get update -qq && apt-get install -y \
  libssl-dev \
  libcurl4-gnutls-dev \
  libxml2-dev

COPY ./install_deps.R .

RUN Rscript install_deps.R

COPY . .

EXPOSE 5000

ENTRYPOINT ["Rscript", "plumber.R"]

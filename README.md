# Codice R code

This repository contains the code to build a docker container and expose via an API the R script
to obtain the essential words of a series of texts.

The web application that consumes this API is [here](https://github.com/edgar8acas/codice).

## Usage

1. Install docker
2. Build the container, execute the following command inside the folder containing the Dockerfile

```sh
docker build -t r-codice .
```

3. Run the container

```sh
docker run -d -p 5000:5000 r-codice
```

4. Check if the container is running

```sh
docker container ps
```

5. Hit the endpoint with a POST request to localhost:5000, an example JSON body can be found in R/input_example.json.

```sh
curl -X POST -H "Content-Type: application/json" \
  -d '{"texts_collection": [...]}' \
  localhost:5000
```

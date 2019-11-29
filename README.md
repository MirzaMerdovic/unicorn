# Unicorn :unicorn:

## What is it?

A container based on [offical mongo image](https://hub.docker.com/_/mongo) with a purpose of making a data seeding simple 
and a part of your docker-compose setup.
The emphasis is on the local environments, but I supose that doesn't have to be a limit, but in production it is your  responsability!

## How it works?

Repo contains an example, but the snippet below sums it up:

```yaml
unicorn:
    image: unicorn:latest
    container_name: unicorn.ctn
    environment:
      - MONGO_ADDRESS=mongo:27017
      - RECREATE_COLLECTIONS=true
    depends_on:
      - mongo
    volumes:
      - type: bind
        source: ./data
        target: /unicorn/data
        read_only: true
    healthcheck:
      test: echo 'db.stats().ok' | mongo mongo --quiet
      interval: 15s
      timeout: 3s
      retries: 3
      start_period: 1s
```
Note: :unicorn: container is dependant on mongo container and code for it was ommited for brevity sake. 

### So where I should put my import data?

You should put your json files in a folder on your local machine structured like:  
``` root/database_name/collection_name.json ```

Where:
* root - means a root folder that you are going to bind to :unicorn: container
* database_name - folder that represents a future or existing mongo database
* collection_name.json - JSON file that represents a future or existing mongo collection

### Environment variables
Currently there are only 2 of them:
* MONGO_ADDRESS - address of your mongo instance
* RECREATE_COLLECTIONS - if set to true :unicorn: will re-create the specified collection, otherwise it will just import the data.

## Final thoughts

This is a project I created because I found it useful in my day-2-day dev life, but also a way to play around with shell scripts. Having said that I am no expert when ti comes to writting shell scripts, and I am pretty sure that thise one can be optimized or written more friendly, so I will appreciate all the comments.

## TODO
Things that I would like to add:
* Support for credentials
* Support for upsert

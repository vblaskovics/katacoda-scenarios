# Let's try out our elastic search

## Try out REST API
```
curl -XGET 'localhost:9200'
```{{execute}}

## Create a document

We already have a clean Elasticsearch instance initialized and running. The first thing we are going to do is to add documents and to retrieve them. Documents in Elasticsearch are represented in JSON format. Also, documents are added to indices, and documents have a type. We are adding now to the index named accounts a document of type person having the id 1; since the index does not exist yet, Elasticsearch will automatically create it.

```
curl -XPOST -H "Content-type: application/json" -d '{
    "name" : "John",
    "lastname" : "Doe",
    "job_description" : "Systems administrator and Linux specialit"
}' 'localhost:9200/accounts/person/1'

```{{execute}}

## Get document

```
curl -XGET 'localhost:9200/accounts/person/1'
```{{execute}}

## Update

The keen reader already realized that we made a typo in the job description (specialit); let’s correct it by updating the document (_update):

```
curl -XPOST -H "Content-type: application/json" -d '{
      "doc":{
          "job_description" : "Systems administrator and Linux specialist"
       }
}' 'localhost:9200/accounts/person/1/_update'
```{{execute}}

## Post more

```
curl -XPOST -H "Content-type: application/json" -d '{
    "name" : "John",
    "lastname" : "Smith",
    "job_description" : "Systems administrator"
}' 'localhost:9200/accounts/person/2'
```{{execute}}

## Search

```
curl -XGET 'localhost:9200/_search?q=john'
```{{execute}}

```
curl -XGET 'localhost:9200/_search?q=job_description:john'
```{{execute}}

This search will not return any document. 

```
curl -XGET 'localhost:9200/accounts/person/_search?q=job_description:linux'
```{{execute}}
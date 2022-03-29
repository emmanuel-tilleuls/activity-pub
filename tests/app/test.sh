#!/bin/sh
set -e

DIR=$(dirname $0)

php $DIR/index.php doctrine:schema:drop --quiet --force 
echo 'Database supprimée'

php $DIR/index.php doctrine:schema:create --quiet
echo 'Database et schema créée'

# Création d'un acteur (doit créer : "https://127.0.0.1:8000/people/1")
curl -s -X 'POST' \
  'https://127.0.0.1:8000/people' \
  -H 'accept: application/ld+json' \
  -H 'Content-Type: application/ld+json' \
  -d '{
  "@context": "https://www.w3.org/ns/activitystreams",
  "type": "Person",
  "name": "Sally Smith"
}' > /dev/null
echo 'Acteur créé'

# Création d'un object (doit créer : "https://127.0.0.1:8000/articles/2")
curl -s -X 'POST' \
  'https://127.0.0.1:8000/articles' \
  -H 'accept: application/ld+json' \
  -H 'Content-Type: application/ld+json' \
  -d '{
  "@context": "https://www.w3.org/ns/activitystreams",
  "type": "Article",
  "name": "What a Crazy Day I Had",
  "content": "<div>... you will never believe ...</div>",
  "attributedTo": "http://sally.example.org"
}' > /dev/null
echo 'Oject créé'

# Création de l'activité (doit créer "https://127.0.0.1:8000/creates/1")
curl -s -X 'POST' \
  'https://127.0.0.1:8000/creates' \
  -H 'accept: application/ld+json' \
  -H 'Content-Type: application/ld+json' \
  -d '{
  "@context": "https://www.w3.org/ns/activitystreams",
  "summary": "Sally created a note",
  "type": "Create",
  "actor": "https://127.0.0.1:8000/people/1",
  "object": "https://127.0.0.1:8000/articles/2"
}' > /dev/null
echo 'Activité créée'

# Test de la route outbox
curl -s -X 'GET' 'https://127.0.0.1:8000/people/1/outbox' \
  -H 'accept: application/ld+json' \
  -H 'Content-Type: application/ld+json' > /dev/null
echo 'Test OK 🎉'
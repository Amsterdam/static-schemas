# Static Amsterdam Schemas

Dockerfile & Jenkinsfile to host schemas from https://github.com/Amsterdam/amsterdam-schema and https://github.com/Amsterdam/schemas.

The schemas are available at https://static.data.amsterdam.nl

The jsonschema metaschema is available at: /schema@version

The datasets are available at /datasets/

The script static-files.sh does a checkout of those repo's. For amsterdam-schema, all
versions are produced with @<x,y,z> postfix.

The datasets in the schema's repo are published under `datasets`.

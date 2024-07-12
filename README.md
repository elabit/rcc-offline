# rccremote Demo Setup 

## Preparation

`docker-compose up --build -d`

Open two terminals for both rccremote and rcc. 

## rccremote (="server")

```
docker exec -it rccremote-test_rcc_1 bash
cd data
bash run_rccremote.sh
```

This 

- enabled shared holotree (required for rccremote to work)
- builds a playwright environment and starts then `rccremote`, listening on port 4653.

## rcc ("client")

```
docker exec -it rccremote-test_rccremote_1 bash
cd data
bash run_rcc.sh
```

This 

- sets the environment variable `RCC_REMOTE_ORIGIN` to the address `http://rccremote:4653`
- build the playwright env similar to the other container; but this time, it fetches all sources from the rccremote server.

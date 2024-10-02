# rcc Offline Demo Setup 

Scenario for the problem: The execution of Robot Framework tests with Robotmk requires the test client to be connected to the Internet if the underlying Python/nodejs environment is to be built with RCC. 
This is often not permitted for security reasons and the test clients are completely cut off from the Internet. 

This repository serves to demonstrate two ways to circumvent this problem: 

- rccremote
- hololib.zip
- combination of both 


**Proof of concept**: All strategies presented here are for demonstration purposes only. 

## Preparation



`docker compose up --build -d `

Open two terminals for both rccremote and rcc. 

- Server: `docker exec -it server bash`
- Client: `docker exec -it client bash`
- Clientuser: `docker exec -it clientuser bash`

tmuxp: 

- Open the multipane session: `tmuxp load /data/tmuxp.yaml`
- Pane focus: 
  - `Ctrl-a, Cursor`
  - `Ctrl-a, q + Number`
  - Toggle fullscreen: `Ctrl-a, z`

To cleanup the docker compose setup, run: `docker compose down --volumes`

---

## Mode 1: rccremote 

With `rccremote`, a host (server) can provide the holotrees (environments) available on it to other hosts (clients).  
This example shows how an environment is built on the server and then made available via `rccremote`. 
The same environment can be obtained on the client with a considerable time advantage via rccremote instead of building it from scratch. 


### server

```
cd data
bash rccremote_server.sh
```

This 

- enables the "shared holotree" feature (required for rccremote to work properly)
- builds a RCC environment (and downloads the installation sources fwith Playwright and starts then `rccremote`, listening on port 4653.

([This](https://github.com/robocorp/prebuilt-env-docker/blob/master/importer/nginx.conf) is a demo setup which uses nginx to serve rccremote via HTTPS)

### client

#### Creating the environment

```
cd data
bash rccremote_client.sh
```

This 

- sets the environment variable `RCC_REMOTE_ORIGIN` to the address `http://server:4653`
- build the playwright env similar to the other container; but this time, it fetches all sources from the rccremote server.

#### Using the environment

Both commands on server and client should have printed the list of environments; their "Blueprint" should be the same. 
Now its time to prove that the environment can be used on the client: 

```
bash run_robot.sh
```

This starts the Playwright based RF suite in the newly created RCC environment, obtained from server.  

---

## Mode 2: hololib.zip 

This approach represents an even more secure alternative to rccremote.
Another way to set up RCC environments quickly and efficiently is to import a  file. 
First, the environment is built on a reference machine and then exported into a `hololib.zip` file. 
The ZIP file must be transferred to the clients (copying/syncing) and can be imported there. 
In this way, it is possible to transfer RCC environments to hosts that are located in completely isolated network areas. 

### Preparation

`docker compose up --build -d `

Again, open two terminals for both rccremote and rcc. 

- Server: `docker exec -it server bash`
- Client: `docker exec -it client bash`


### server



```
cd data
bash hololib_export.sh
```

This 
- builds the environment
- exports the environment into a file `env.zip`

### client


#### Importing the catalog

```
cd data
bash hololib_import.sh
```

This imports the RCC catalog from the ZIP file. 
From the catalog, the client can now create holotrees from (next step)

#### Using the environment

```
bash run_robot.sh
```

This starts the Playwright based RF suite. RCC will first create a new hololib from the catalog (just takes some seconds), and then starts the test. 

---

## Mode 3: Combination of rccremote + hololib.zip

The two approaches presented above each have a disadvantage: 

- **rccremote**: Clients in isolated network areas may not be allowed to connect to hosts that can access the Internet. 
- **hololib.zip**: no centralized solution, high manual effort

To solve both disadvantages, the third mode is a combination of both: 

- The rccremote server is located **in the same network** as the clients; it also does not need a internet connection.
- The environments are built on a dedicated (development) machine which has internet access. (That's where the environments can also be checked/scanned against security). Finally, they are exported into ZIP files. 
- The ZIP files are copied/synced and imported on the rccremote server. 
- rccremote can serve the environments for the clients. 

Advantages: 
- Central provision of RCC catalogs
- Clean separation of network areas
- Can be automated



---

# Hololib import scenarios


Three docker containers: 
- clientuser (user)
- client (root)
- server (root, with shared holotree enabled)


## Building the environments

`data/` contains 3 folders `minimal5/6/7` with each RF 5/6/7 as dependency in conda.yaml.

On each container, I created the environment with `rcc task run`:

- clientuser: RF5 => Holotree path: `/home/myuser/.robocorp/holotree`
- client: RF6 => Holotree path: `/root/.robocorp/holotree`
- server: RF7 => Holotree path: `/opt/robocorp/ht`

## Exporting the environments

On each container, I exported the catalog with `rcc ht export -r robot.yaml -z ZIPFILE`:
- clientuser: `user_dot_robocorp.zip`
- client: `root_dot_robocorp.zip`
- server: `opt_robocorp.zip`

## Importing the ZIPs on the server

On the server, all three ZIP files can be imported:

```
rcc ht import root_dot_robocorp.zip 
rcc ht import user_dot_robocorp.zip 
rcc ht import opt_robocorp.zip
```

The Holotree column shows the path: 

```
rcc ht catalogs
Blueprint         Platform     Dirs    Files    Size     identity.yaml (gzipped blob inside hololib)                                Holotree path                    Age (days)  Idle (days)
---------         --------     ------  -------  -------  -------------------------------------------                                -------------                    ----------  -----------
2409ce1066f4880d  linux_amd64     694    12221     356M  de/c8/c8/dec8c8458f0ce9c68fe0dc021dd5e948a77b94e747b2bc718bace7bdb6d4426f  /root/.robocorp/holotree                  0            0
35332e65a214c09f  linux_amd64     694    12221     356M  3c/d9/af/3cd9af373a350220e3516310cd08f1519a9952bd29ee906b02d551fad6b75adc  /home/myuser/.robocorp/holotree           0            0
a466d176c7dc6696  linux_amd64     694    12239     357M  f4/71/36/f47136a7931ef758ae45c1cb29f04fb0e27b3ba160bbaa979d83776b507a074f  /opt/robocorp/ht                          0            0

```

```
rcc ht ls
Identity                  Controller  Space     Blueprint         Full path
--------                  ----------  -----     --------          ---------
720c7a8_5a1fac3_35b943a4  rcc.user    minimal6  2409ce1066f4880d  /root/.robocorp/holotree/720c7a8_5a1fac3_35b943a4
720c7a8_5a1fac3_6b6951cb  rcc.user    minimal5  35332e65a214c09f  /home/myuser/.robocorp/holotree/720c7a8_5a1fac3_6b6951cb
720c7a8_5a1fac3_b65c2b39  rcc.user    minimal7  a466d176c7dc6696  /opt/robocorp/ht/720c7a8_5a1fac3_b65c2b39
```

## Serving the catalogs with rccremote, importing the hololibs from rccremote

- Started rccremote on the server: `rccremote -hostname 0.0.0.0 -debug -trace`
- On client and clientuser: `export RCC_REMOTE_ORIGIN="http://server:4653"`

Executed on each host, client and clientuser (without `--space`, rcc would always overwrite the "user" space): 

- `cd minimal5; rcc task run --space minimal5`
- `cd minimal6; rcc task run --space minimal6`
- `cd minimal7; rcc task run --space minimal7`

## Observations

- **Client**: all 3 environments are created and can be used similarly to the server (rcc is running as root)
- **Clientuser**: only the `minimal5` environment can be created and used. The other two environments would require a hololib creation in folders where the normal user does not have access to.


## Conclusion


**Rule of thumb**: Creating and importing Hololibs must always be done with the user that the test execution environment will be run as: 

- Linux: root (unless the CMK agent is run as a different user)
- Windows:
  - Headless execution: LOCAL SYSTEM (unless the CMK agent is run as a different user)
  - Headed execution: the user which is assigned to execute the test

Ignoring this recommendation

- may result in the Holotree folders being spread across the system/different home directories, depending on where they were originally built. (Linux & Windows headless)
- will cause the environment build to fail on Windows/headed, because rcc will then try to create the Holotree directory outside the user context.

### Risk analysis 

Even if the scheduler (running under root) can use a holotree in a user home - this could pose a similar danger as with shared holotrees: in the home dir, an unprivileged user could place malicious code in the holotree that the scheduler executes with root privileges.

(However, the `.roocorp` directory created by rcc is owned by root and only he has write access.)

```
drwxr-x--- 3 root root 4096 Oct  2 08:44 .robocorp
```

### A possible solution?  

Before execution, the scheduler checks with `rcc holotree catalogs`, whether the Holotree path of the environment to be used is in "his" default ht folder (/opt/robocorp/ or the Appdata directory of the system service under Windows) - and denies execution if the path is e.g. `/home/badass/robocorp/ht`
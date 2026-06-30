# Virtual Classroom

A client-server messaging system that models a virtual classroom, written in C
with the POSIX sockets API. Professors create classes and broadcast messages to
their students, students subscribe to classes and receive those messages in real
time, and administrators manage the user database remotely.

The project was developed for the Communication Networks (Redes de Comunicacao)
course, second year of the Informatics Engineering degree at the University of
Coimbra. It is also validated on a simulated network topology built in GNS3.

## Overview

The system is made of three programs:

| Program        | Role          | Transport        | Description                                                                 |
| -------------- | ------------- | ---------------- | --------------------------------------------------------------------------- |
| `class_server` | Server        | TCP, UDP         | Hosts classes and users. Serves students/professors over TCP and admins over UDP. |
| `class_client` | Student / Professor | TCP + multicast | Logs in, manages classes, and listens for class messages over UDP multicast. |
| `class_admin`  | Administrator | UDP              | Manages the user database (add, remove, list users) and can shut the server down. |

### How it works

- The server listens on two ports: one for classes (TCP) and one for
  configuration (UDP).
- Each TCP client connection is handled by a dedicated child process created
  with `fork()`. Class state is shared between processes through System V shared
  memory and guarded by POSIX named semaphores.
- When a professor sends a message to a class, the server relays it to the
  class's IP multicast group. Subscribed clients join that group and receive the
  message directly.
- User accounts are persisted in a plain-text database file
  (`class_config.config`), one record per line in the form
  `username;password;type`, where `type` is `aluno`, `professor`, or
  `administrador`.

## Repository layout

```
.
├── Makefile                  Top-level build file (outputs to bin/)
├── README.md
├── docs/
│   └── RC_relatorio_final.pdf Final project report
├── simulation/
│   └── Projeto/              GNS3 network topology and captured traffic
└── src/
    ├── server/              Server: networking, processes, shared memory
    │   ├── class_server.c   Entry point, TCP/UDP listeners, request routing
    │   ├── commands_server.c Command implementations (login, classes, users)
    │   ├── commands_server.h
    │   ├── class_struct.c    Class data structure and multicast helpers
    │   ├── class_struct.h
    │   ├── file_manager.c    User database read/write
    │   └── file_manager.h
    ├── client/
    │   └── class_client.c    Student/professor TCP client + multicast listener
    ├── admin/
    │   └── class_admin.c     Administrator UDP client
    └── config/
        └── class_config.config Default user database
```

## Requirements

- A Linux environment (the code uses System V IPC, POSIX semaphores, and Linux
  socket headers).
- `gcc` and `make`.

## Building

From the repository root:

```sh
make           # build server, client, and admin into bin/
make server    # build only the server
make client    # build only the client
make admin     # build only the admin client
make configs   # reset src/config/class_config.config to its defaults
make clean     # remove build artifacts and the bin/ directory
```

All executables are placed in the `bin/` directory.

## Running

Start the server, giving it the classes port, the config port, and the path to
the user database:

```sh
bin/class_server <CLASSES_PORT> <CONFIG_PORT> <CONFIG_FILEPATH>
# example:
bin/class_server 9000 9001 src/config/class_config.config
```

Both ports must be different integers in the range 1024 to 65535.

Connect a student or professor over TCP:

```sh
bin/class_client <SERVER_IP> <CLASSES_PORT>
# example:
bin/class_client 127.0.0.1 9000
```

Connect an administrator over UDP:

```sh
bin/class_admin <SERVER_IP> <CONFIG_PORT>
# example:
bin/class_admin 127.0.0.1 9001
```

### Default accounts

The bundled database ships with one account of each type:

| Username | Password | Type          |
| -------- | -------- | ------------- |
| micas    | castela  | aluno         |
| joel     | 1234     | professor     |
| adam     | eve      | administrador |

## Commands

### Client (TCP)

```
LOGIN <username> <password>
HELP
After login:
  LIST_CLASSES
  LIST_SUBSCRIBED
  SUBSCRIBE_CLASS <class_name>
  LOGOUT
Professor only:
  CREATE_CLASS <class_name> <size>
  SEND <class_name> <message>
```

### Admin (UDP)

```
LOGIN <username> <password>
HELP
After login:
  ADD_USER <username> <password> <type>
  DEL <username>
  LIST
  QUIT_SERVER
  LOGOUT
```

## Network simulation

The `simulation/Projeto` directory contains a GNS3 project that runs the server
and clients across routers, switches, and Docker hosts, along with packet
captures (`.pcap`) of the traffic between them. Open `Projeto.gns3` in GNS3 to
inspect or run the topology.

## Documentation

A full write-up of the design, protocol, and results is available in
`docs/RC_relatorio_final.pdf` (in Portuguese).

## Authors

- Miguel Castela
- Francisco Silva

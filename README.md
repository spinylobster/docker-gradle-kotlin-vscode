All-in-one container for TDD/Pair programming/Mob programming with Kotlin

# Example

Launch X11 server on Docker host and then...

On the host,

```
$ mkdir bowling_game
$ cd bowling_game/
$ mkdir .gradle
$ docker run --rm -it -v `pwd`:/project -w /project \
    -v "$(pwd)/.gradle":/home/gradle/.gradle \
    -e 'DISPLAY=host.docker.internal:0' \
    -u root spinylobster/gradle-kotlin-vscode bash
```

In the container,

```
$ gradle init --dsl groovy --package bowlinggame --project-name BowlingGame --test-framework kotlintest --type kotlin-library
$ gradle test
$ code .
```


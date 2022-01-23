
CC = gcc
FLAGS = -Wall -Wextra $(shell pkg-config --cflags --libs gtk4 mysqlclient libbsd) -pthread

snakeviewer: snakeviewer.c
	$(CC) $^ -o $@ $(FLAGS)

.PHONY : clean
clean:
	-rm snakeviewer

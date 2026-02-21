NAME = inception
USER_NAME = $(shell whoami)
SRCS_DIR = ./srcs
DOCKER_COMPOSE = docker compose -f $(SRCS_DIR)/docker-compose.yaml

all: $(NAME)

$(NAME):
	@mkdir -p /home/$(USER_NAME)/data/wordpress
	@mkdir -p /home/$(USER_NAME)/data/mariadb
	$(DOCKER_COMPOSE) up --build -d

clean:
	$(DOCKER_COMPOSE) down --rmi all -v

fclean: clean
	@sudo rm -rf /home/$(USER_NAME)/data

re:
	$(MAKE) fclean
	$(MAKE) all

.PHONY: all clean fclean re
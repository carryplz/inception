NAME          = inception
USER_NAME     = $(shell whoami)
SRCS_DIR      = ./srcs
DOCKER_COMPOSE = docker compose -f $(SRCS_DIR)/docker-compose.yaml

all: $(NAME)

$(NAME):
	@printf "Creating data directories for $(USER_NAME)...\n"
	@mkdir -p /home/$(USER_NAME)/data/wordpress
	@mkdir -p /home/$(USER_NAME)/data/mariadb
	@$(DOCKER_COMPOSE) up --build -d

clean:
	@printf "Stopping and removing containers/images...\n"
	@$(DOCKER_COMPOSE) down --rmi all -v

fclean: clean
	@printf "Deep cleaning: Removing data volumes via Alpine...\n"
	@docker run --rm -v /home/$(USER_NAME)/data:/data alpine:3.18 rm -rf /data/wordpress /data/mariadb
	@printf "All data removed.\n"

re:
	@$(MAKE) fclean
	@$(MAKE) all

.PHONY: all clean fclean re
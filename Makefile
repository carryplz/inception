all:
	@mkdir -p /home/injo/data/wordpress
	@mkdir -p /home/injo/data/mariadb
	docker-compose -f ./srcs/docker-compose.yaml up --build -d

clean:
	docker-compose -f ./srcs/docker-compose.yaml down --rmi all -v

fclean: clean
	rm -rf /home/injo/data

re:
	$(MAKE) fclean
	$(MAKE) all

.PHONY: all clean fclean re
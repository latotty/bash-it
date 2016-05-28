function set-docker-local-host () {
  DOCKER_IP=`docker-machine ip default 2>/dev/null`

  if [[ -z $DOCKER_IP ]]
  then
  	DOCKER_IP="127.0.0.1"
  fi

  local DOCKER_HOSTS_LINE="$DOCKER_IP docker.local # generated"

  if grep -q docker.local /etc/hosts
  then
  	sudo sed -i.bak "s/.*docker.local.*/$DOCKER_HOSTS_LINE/" /etc/hosts
  else
  	echo "$DOCKER_HOSTS_LINE" | sudo tee -a /etc/hosts > /dev/null
  fi
}

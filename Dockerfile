FROM ubuntu:24.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
	wget \
	m4 \
	unzip \
	librsvg2-bin \
	curl \
	bubblewrap \
	opam \
	libev-dev \
	libgmp-dev \
	libssl-dev \
	pkg-config


RUN opam init -y
RUN opam switch create 5.2.1

RUN git clone https://github.com/grew-nlp/arboratorgrew_server.git
RUN cd arboratorgrew_server

RUN <<EOF
eval $(opam env --switch=5.2.1)
opam remote add grew "https://opam.grew.fr"
opam install dune dream grewlib -y
cd arboratorgrew_server
dune build 
dune install
EOF

RUN opam env >> /root/.bashrc

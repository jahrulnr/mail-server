# Dockerized Postfix

This project provides a Dockerized version of Postfix, making it easy to deploy a mail server for handling email delivery for your domain. It is designed to be simple to set up and configure, with sensible defaults and the ability to customize settings as needed.

## Getting Started

These instructions will help you get your Dockerized Postfix server up and running on your local machine for development and testing purposes. You can also follow these steps to deploy the service in a production environment.

### Prerequisites

You need Docker installed on your machine. Follow the [official Docker installation guide](https://docs.docker.com/get-docker/) for your operating system.

### Installation

Clone this repository to your local machine:

```bash
git clone https://github.com/jahrulnr/mail-server.git
cd mail-server
cp mail.env.example mail.env
cp config/postfix/virtual.example config/postfix/virtual
```

Run the Postfix container:

```bash
make up
```

### Configuration

To customize the configuration, edit the ```mail.env``` and ```config/postfix/virtual``` files before building your Docker image. You can specify settings such as myhostname, mydomain, and others according to the Postfix main configuration options at ```start.sh```.

### Usage

Once the Docker container is running, it will start handling emails for the configured domain. Ensure that your DNS settings are correctly set up to point to your server's IP address.

### License

This project is licensed under the MIT License - see the [MIT License](LICENSE) file for details
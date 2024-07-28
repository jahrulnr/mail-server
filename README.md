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

To customize the configuration, edit the `mail.env` and `config/postfix/virtual` files before building your Docker image. You can specify settings such as `myhostname`, `mydomain`, and others according to the Postfix main configuration options in `start.sh`.

#### Adding SPF and DKIM

**SPF (Sender Policy Framework)** and **DKIM (DomainKeys Identified Mail)** are crucial for ensuring your emails are authenticated and less likely to be marked as spam.

#### DKIM Configuration

1. **Generate DKIM Keys**: Typically, this is done as part of your initial setup. The following example shows the contents of a DKIM key file at docker logs:

   ```plaintext
   [info] cat /etc/opendkim/keys/example.com/default.txt
   default._domainkey      IN      TXT     ( "v=DKIM1; h=sha256; k=rsa; "
             "p=MIIBIsample1ObB"
             "oX1+Jfsample2wIDAQAB" )  ; ----- DKIM key default for example.com
    ```

2. **Add the DKIM Record to Your DNS**: Copy the entire string from the DKIM key file and add it as a TXT record in your DNS settings under default._domainkey.example.com.

#### SPF Configuration

1. **Create an SPF Record**: Add an SPF TXT record to your DNS to specify which mail servers are authorized to send email on behalf of your domain:

    ```plaintext
    v=spf1 a mx ip4:YOUR_SERVER_IP ~all
    ```

    Replace YOUR_SERVER_IP with the IP address of your mail server. The include:_spf.google.com part is optional and only necessary if you are using Google's servers to send emails as well.

2. **Update DNS Settings**: Ensure your DNS records are properly updated to reflect these changes. This will help reduce the likelihood of your emails being rejected or marked as spam.

#### Verifying Configuration

After configuring SPF and DKIM, use online tools like MXToolbox to verify that your SPF and DKIM records are correctly published and recognized. This step is crucial to avoid misconfigurations that could affect email deliverability.

### Usage

Once the Docker container is running, it will start handling emails for the configured domain. Ensure that your DNS settings are correctly set up to point to your server's IP address.

### License

This project is licensed under the MIT License - see the [MIT License](LICENSE) file for details
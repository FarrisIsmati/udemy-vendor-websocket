# Build Connect
FROM amazon/aws-lambda-nodejs:12 AS connect
ARG FUNCTION_DIR="/var/task"

COPY package.json  package-lock.json .
RUN npm install\
        && npm install typescript -g

# Use yum to get unzip (-y handles interactivity) yum is linux apt-get is ubuntu
RUN yum -y update
RUN yum -y install unzip
# Install awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" -s
RUN unzip -q awscliv2.zip
RUN ./aws/install

COPY . .

RUN tsc

# Create function directory
RUN mkdir -p ${FUNCTION_DIR}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "build/connect.handler" ]

# Build Disconnect
FROM amazon/aws-lambda-nodejs:12 AS disconnect
ARG FUNCTION_DIR="/var/task"

COPY package.json  package-lock.json .
RUN npm install\
        && npm install typescript -g

# Use yum to get unzip (-y handles interactivity) yum is linux apt-get is ubuntu
RUN yum -y update
RUN yum -y install unzip
# Install awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" -s
RUN unzip -q awscliv2.zip
RUN ./aws/install

COPY . .

RUN tsc

# Create function directory
RUN mkdir -p ${FUNCTION_DIR}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "build/disconnect.handler" ]


# Build send message
FROM amazon/aws-lambda-nodejs:12 AS sendvendor
ARG FUNCTION_DIR="/var/task"

COPY package.json  package-lock.json .
RUN npm install\
        && npm install typescript -g

# Use yum to get unzip (-y handles interactivity) yum is linux apt-get is ubuntu
RUN yum -y update
RUN yum -y install unzip
# Install awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" -s
RUN unzip -q awscliv2.zip
RUN ./aws/install

COPY . .

RUN tsc

# Create function directory
RUN mkdir -p ${FUNCTION_DIR}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "build/send-vendor.handler" ]


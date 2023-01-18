# Build Connect
# We are using a lambda supported node environment here
# we are calling it as connect (this is how our github actions will know how to split this builds)
# Also there are more modern versions of aws-lambda-nodejs but I built it with 12 so I want to make sure it works with this
FROM amazon/aws-lambda-nodejs:12 AS connect
# Here ARG is defining a variable FUNCITON_DIR which we will set to a folder path which is required with lambda functions
# Otherwise lambda wouldn't know where to find our code in the container
ARG FUNCTION_DIR="/var/task"

# As we've done before we copy our package json 
COPY package.json .
# We install npm and typescript same as before
RUN npm install\
        && npm install typescript -g

# # Use yum to get unzip (-y handles interactivity) yum is linux apt-get is ubuntu
# # This is a package manager than linux uses (the OS that aws-lambda-nodejs:12 is running)
# # with yum similar to npm we can install things we might need and in this case we need unzip
# RUN yum -y update
# RUN yum -y install unzip
# # Why do we need unzip?
# # We need to install this aws cli package, and unzip the installation in our container so we can run the install
# RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" -s
# RUN unzip -q awscliv2.zip
# # By installing awscli we can now do something~~~
# RUN ./aws/install

COPY . .

RUN tsc

# Create function directory
RUN mkdir -p ${FUNCTION_DIR}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "build/connect.handler" ]

# Build Disconnect
FROM amazon/aws-lambda-nodejs:12 AS disconnect
ARG FUNCTION_DIR="/var/task"

COPY package.json .
RUN npm install\
        && npm install typescript -g

# # Use yum to get unzip (-y handles interactivity) yum is linux apt-get is ubuntu
# RUN yum -y update
# RUN yum -y install unzip
# # Install awscli
# RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" -s
# RUN unzip -q awscliv2.zip
# RUN ./aws/install

COPY . .

RUN tsc

# Create function directory
RUN mkdir -p ${FUNCTION_DIR}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "build/disconnect.handler" ]


# Build send message
FROM amazon/aws-lambda-nodejs:12 AS sendvendor
ARG FUNCTION_DIR="/var/task"

COPY package.json .
RUN npm install\
        && npm install typescript -g

# # Use yum to get unzip (-y handles interactivity) yum is linux apt-get is ubuntu
# RUN yum -y update
# RUN yum -y install unzip
# # Install awscli
# RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" -s
# RUN unzip -q awscliv2.zip
# RUN ./aws/install

COPY . .

RUN tsc

# Create function directory
RUN mkdir -p ${FUNCTION_DIR}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "build/send-vendor.handler" ]

# ~~ Build getvendors ~~
FROM amazon/aws-lambda-nodejs:12 AS getvendors
ARG FUNCTION_DIR="/var/task"

COPY package.json .
RUN npm install\
        && npm install typescript -g

# # Use yum to get unzip (-y handles interactivity) yum is linux apt-get is ubuntu
# RUN yum -y update
# RUN yum -y install unzip
# # Install awscli
# RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" -s
# RUN unzip -q awscliv2.zip
# RUN ./aws/install

COPY . .

RUN tsc

# Create function directory
RUN mkdir -p ${FUNCTION_DIR}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "build/get-vendors.handler" ]


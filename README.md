<<<<<<< HEAD
# React Docker AWS CI/CD Workflow

This repository demonstrates a **production-grade CI/CD workflow** utilizing **Docker** for containerization, **Travis CI** for continuous integration, and **AWS Elastic Beanstalk** for deployment.

The React application is kept intentionally simple, consisting only of the default React opening page. This allows us to focus solely on understanding the complete workflow of a production-grade CI/CD pipeline.

## Key Technologies Used:
- **React**: A simple front-end web application.
- **Docker**: Used to containerize the application for consistent development and production environments.
- **Travis CI**: Handles automated testing and deployment in a continuous integration/continuous deployment (CI/CD) pipeline.
- **AWS Elastic Beanstalk**: Deploys the containerized React app for production use.

## Purpose:
By keeping the React application simple, we avoid spending time on UI development. Instead, this project emphasizes the workflow and infrastructure behind building, testing, and deploying a React application using Docker and AWS services.


## To-Do:

- [x] **Install Node.js**: Install Node.js by running the following command:

  ```bash
  sudo apt install nodejs

- [x] **Verify the installation**: Run the following command to see you have specifit version of Node.js

  ```bash
  node -v

- [x] **Change the Directory**: To run couple of command inside the project directory, go in this directory with:

  ```bash
  cd your-project-name

---

- [x] **Create Dockerfile for Development:**
   - **File Name:** `Dockerfile.dev`
   - **Base Image:** `node:16-alpine`
   - **Configuration Steps:**
    - Use a base image with Node.js and Alpine:
      ```Dockerfile
      FROM node:16-alpine
      ```
    - Switch to a non-root user for better security:
      ```Dockerfile
      USER node
      ```
    - Create the application directory and set it as the working directory:
      ```Dockerfile
      RUN mkdir -p /home/node/app
      WORKDIR /home/node/app
      ```
    - Copy `package.json` and install dependencies (set ownership to `node` user):
      ```Dockerfile
      COPY --chown=node:node ./package.json ./
      RUN npm install
      ```
    - Copy the rest of the project files (set ownership to `node` user):
      ```Dockerfile
      COPY --chown=node:node ./ ./
      ```
    - Set the command to start the application:
      ```Dockerfile
      CMD ["npm", "start"]
      ```
---

- [x] **Build Docker Image:**
   - **Command:**
     ```bash
     docker build -f Dockerfile.dev -t your-image-name .
     ```
   - **Note:** Replace `your-image-name` with your desired image name.
     
---

- [x] **Run Docker Container:**
   - **Command:**
     ```bash
     docker run -p 3000:3000 your-image-name
     ```
   - **Note:** Ensure you use `-p` to map ports between the container and your local machine.

---

- [x] **Check Development Server:**
   - **URL:** `http://localhost:3000`
   - **Note:** Ensure that the development server is accessible via this URL.

- [x] **Remove Duplicate Dependencies:**
   - **Action:** Delete `node_modules` folder in the project directory before building the Docker image to avoid duplicate dependencies.
   - Two ss below show the difference before and after removing the duplicate dependencies in terms of storage:
  - Before: ![image](https://github.com/user-attachments/assets/409464c3-4514-46d7-89f8-75a790cfb514)
  - After : ![image](https://github.com/user-attachments/assets/ce072e13-2ad9-420b-8639-b1239b41cc7e)

---

- [x] **Handling Source Code Changes:**
   - **Issue:** Changes to source code inside the container won't automatically reflect in the browser.
   - **Solution:** Use Docker volumes to mount your source code into the container to see real-time changes without rebuilding the image. Instead of copying entire directories, set up a reference to the local file system.

  - **Docker Run Command Syntax:**
    - Add a `-v` flag to map a folder inside the container to a folder outside the container.
    - Example: `docker run -it -p 3000:3000 -v /home/node/app/node_modules -v $(pwd):/home/node/app <image id>`
  
  - **Important Notes:**
    - The `-v` flag sets up a mapping between a local directory and a container directory.
    - If you use `$(pwd)` on a terminal, it prints the path to the current directory. This may not work in all terminal types (e.g., Windows Command Prompt).  

  - **Verify Container Changes:**
   - **Action:** Make changes to the source code and verify that they are reflected in the browser after using Docker volumes.

  ### Outcome
  
  - With the correct run syntax, the project starts up as expected.
  - Changes to the local file system are automatically reflected inside the running Docker container.
  - React's automatic refresh feature updates the page when code changes are made.

---

- [x] **Automate with Docker Compose:** Docker Compose streamlines the development process by simplifying long Docker run commands, allowing us to easily manage port mappings and volume mounts with a single command, making it more efficient for running applications like our React app in development.
   - **Create `docker-compose.yml` File:**
     ```yaml
     version: '3'
     services:
       web:
         build:
           context: .
           dockerfile: Dockerfile.dev
         ports:
           - "3000:3000" # map the 3000 outside of the container to  3000 inside of the container
         volumes:
           - /home/node/app/node_modules # this line provides not mapping up against app node modules inside of the container
           - .:/home/node/app # . (dot) => current directory (pwd in run command) | this line provides map that folder (current folder) outside of the container to the app folder inside of the container
     ```
   - **Command to Run Docker Compose:**
     ```bash
     docker-compose up
     ```

    ## Best Practices
  
    - [x] **Keep `COPY` Command in Dockerfile:**
       - **Reason:** Although volume mapping eliminates the need to copy the source code for development, it's good to leave the `COPY . .` instruction for future use cases, such as production or non-Docker Compose scenarios.
    
    - [x] **Use Docker Compose for Simplified Commands:**
       - **Reason:** Docker Compose helps avoid long, complex `docker run` commands by managing port mappings and volumes for you.
     
---

  ## Dealing with Test Suite Changes

- [x] **Container Snapshot Issue:**
   - **Explanation:** When the container is created, it captures a snapshot of the code. Any changes made to your test files after the container starts won't be reflected unless the container is rebuilt or volumes are used.

- [x] **Solution - Using Docker Volumes:**
   - **Command:**
     ```bash
     docker run -it -v $(pwd):/app your-image-id npm run test
     ```
   - **Explanation:** By attaching a volume, changes made to your local test files are reflected inside the running container. This way, you can rerun the tests with updated code.

---

## Simplifying with Docker Compose

- [x] **Create a Separate Service for Testing:**
   - **Update `docker-compose.yml`:**
     ```yaml
     version: '3'
     services:
       web:
         build:
           context: .
           dockerfile: Dockerfile.dev
         ports:
           - "3000:3000"
         volumes:
           - /app/node_modules
           - .:/app
       test:
         stdin_open: true 
         build:
           context: .
           dockerfile: Dockerfile.dev
         volumes:
           - /home/node/app/node_modules
           - .:/home/node/app
         command: ["npm", "run", "test"]
     ```
   - **Explanation:** This Docker Compose setup creates two services: 
     - `web` for running the development server.
     - `test` for running the test suite with live file changes using volumes.

- [x] **Run Docker Compose:**
   - **Command:**
     ```bash
     docker-compose up --build
     ```
   - **Explanation:** This command builds both services (`web` and `test`), enabling live code changes with automatic test re-runs when files are modified.

---

## Interactivity Issues in Docker Compose

- [x] **Lack of Interactivity in Test Suite:**
   - **Problem:** Docker Compose doesn't provide full terminal interactivity (e.g., you can't press `P`, `T`, `Q` to filter tests).
   - **Solution:** Use `docker exec` to interact with a running container.

- [x] **Interactive Test Execution:**
   - **Command:**
     ```bash
     docker exec -it <container_id> npm run test
     ```
   - **Explanation:** You can use this command to interact with the test suite after the container has been created, allowing full control (e.g., filtering test cases with `P`, `T`, `Q`).

---

## Summary

- [x] **Docker Volumes Enable Live Changes:**
   - **Explanation:** By attaching volumes, you can run tests with live code changes without needing to rebuild the container.

- [x] **Two Approaches for Running Tests:**
   1. Use `docker run -it` for full interactivity.
   2. Use Docker Compose to manage both services (`web` and `test`), with automatic test re-runs via volume mapping.

- [x] **Best Practice:** For interactivity with tests, use `docker exec` to attach to the running container.

---

# Docker Production Setup for React Application

In this part, we will walk through how to configure a production-ready Docker setup for a React application using **multi-stage builds** with **Node.js** and **NGINX**. This allows us to build the app with Node.js and serve the static files using NGINX, which is better suited for production environments.

---

## Multi-Stage Dockerfile

- [x] **Build Phase:**
   - **Use Node Alpine:** Use the official Node.js Alpine image as the base to build the React app.
   - **Install Dependencies:** Use `npm install` to install all necessary dependencies from the `package.json` file.
   - **Build the Production Files:** Run `npm run build` to generate the optimized static files for production.

- [x] **Run Phase:**
   - **Use NGINX:** The second phase uses NGINX to serve the built static files.
   - **Copy Files:** Copy the files from the first phase (build phase) into the NGINX server's root directory.

### Dockerfile:
```dockerfile
# ---- First Phase: Build ----
# Use the official Node.js 16 image with Alpine Linux as the base image.
FROM node:16-alpine as builder

# Set the working directory inside the container.
WORKDIR /home/node/app

# Copy only the package.json file to the working directory.
COPY package.json .

# Install all the dependencies.
RUN npm install

# Copy the rest of the application code to the working directory.
COPY . .

# Build the React application for production.
RUN npm run build

# ---- Second Phase: Run ----
# Use the official Nginx image to serve the built files.
FROM nginx

EXPOSE 80

# Copy the built files from the first phase (builder) to Nginx's default serving directory.
COPY --from=builder /home/node/app/build /usr/share/nginx/html
```


## Running the Multi-Stage Dockerfile

- [x] **Build the Docker Image:**
   - **Command:**
     ```bash
     docker build -t your-image-name .
     ```
   - **Explanation:** This command builds the Docker image for production using the Dockerfile. Replace `your-image-name` with the desired name for your image.

- [x] **Run the Container:**
   - **Command:**
     ```bash
     docker run -p 8080:80 your-image-name
     ```
   - **Explanation:** The `-p` flag maps the container's port `80` to the local machine's port `8080`. NGINX will serve the production-ready React application on `localhost:8080`.

---

## Explanation of the Process

- [x] **Build Phase:**
   - **Install Dependencies:** We first install the necessary dependencies from `package.json` because these dependencies are required to run `npm run build`.
   - **Run Build:** The `npm run build` command generates a `build` folder containing the production-ready static files. This is the folder we ultimately care about.

- [x] **Run Phase:**
   - **NGINX:** In the second phase, we switch to an NGINX image. We copy the contents of the `build` folder from the first phase into NGINX's serving directory, `/usr/share/nginx/html`.
   - **Multi-Stage Build:** The key advantage of the multi-stage build process is that we only copy the production-ready files (the `build` directory) to the final image, discarding everything else from the first phase. This keeps the image size minimal.

---

## Key Concepts

- [x] **Multi-Stage Build:**
   - **Why Multi-Stage?** The idea behind a multi-stage build is to use one Docker image to build the app and then use another lighter image (like NGINX) to serve the static files. This helps reduce the final image size.
   - **Optimized for Production:** By using NGINX, a high-performance web server, we ensure our application is ready for production workloads.

- [x] **NGINX:**
   - **Purpose:** NGINX is used to serve the static files (HTML, CSS, JavaScript) generated by the React build process.
   - **Port Configuration:** We map port `80` inside the container (NGINX's default port) to port `8080` on the host machine.

---

## Testing the Setup

- [x] **Test the Setup:**
   - **URL:** [http://localhost:8080](http://localhost:8080)
   - **Explanation:** After running the container, navigate to this URL in your browser. You should see the default React "Welcome to React" page, indicating that the production setup is working.

---

## Setting Up CI/CD Workflow with Docker, GitHub, Travis CI, and AWS

- [x] **Development Workflow Overview**:
   - We’ve now successfully set up Docker containers to handle:
     - Running `npm run start` for development.
     - Running `npm run test` for development.
     - Running `npm run build` for production environments.
   - Now that our Docker setup is complete, it's time to implement a **Continuous Integration/Continuous Deployment (CI/CD) pipeline** that will:
     1. Use GitHub as the repository hosting service.
     2. Use **Travis CI** for running automated tests and managing deployment.
     3. Use **AWS Elastic Beanstalk** for production deployment.
  - Here is the flow diagram of what we are going to build:
    ![image](https://github.com/user-attachments/assets/4874b92b-ca58-41c4-bb6e-06b3bc752ee6)


- [x] **Services Overview**:
   - **GitHub**: We'll be using GitHub to manage our source code and the development process, including branches for features and master branch for deployment.
     - **Assumption**: You are familiar with GitHub, including creating branches, making commits, and pushing code.
     - **Requirement**: If you don’t have a GitHub account, create one at [GitHub Signup](https://github.com).
   
   - **Travis CI**: We'll be integrating **Travis CI**, a **Continuous Integration** service that automatically runs our tests and deploys the app to AWS once the code is merged into the master branch.
     - **Assumption**: No prior experience with Travis CI is required. We'll walk through everything step by step.
     - **Sign up**: If you don't already have a Travis CI account, head over to [Travis CI](https://travis-ci.org/) and sign up using your GitHub account.

   - **AWS Elastic Beanstalk**: We’ll use **AWS** to deploy and host our application.
     - **Assumption**: AWS may require a credit card to sign up for an account. If you don't have or prefer not to use AWS, that's okay — the steps for deploying to other cloud providers like Google Cloud or Digital Ocean are quite similar.
     - **Note**: You can still follow along to understand the process, as deploying Dockerized apps across different cloud platforms is quite similar.
  
---

- [x] **GitHub Setup**:
   - **Create a GitHub Repository**: Push your existing project to GitHub.
     - **Command**:
       ```bash
       git init
       git remote add origin <your-repo-url>
       git add .
       git commit -m "Initial commit"
       git push -u origin master
       ```
     - **Explanation**: The above commands initialize a git repository, add your remote GitHub URL, stage all files, commit them, and push to the master branch.
  
---

- [x] **Travis CI Configuration**:
   - **Add Travis CI to Your Repository**:
     - Go to [Travis CI](https://travis-ci.com) and log in using your GitHub account.
     - Enable your repository under the Travis CI dashboard.
   
   - **Create `.travis.yml` File**:
     - Add the following configuration to enable continuous integration:
       ```yaml
       language: node_js
       node_js:
         - "12"
       
       services:
         - docker

       # Script for running tests before deploying
       script:
         - docker build -t your-app-name .
         - docker run your-app-name npm test
       
       # Deploy to AWS Elastic Beanstalk
       deploy:
         provider: elasticbeanstalk
         region: "us-west-2"
         app: "your-app-name"
         env: "YourApp-env"
         bucket_name: "elasticbeanstalk-us-west-2-your-bucket"
         bucket_path: "your-app-name"
         on:
           branch: master
       ```
     - **Explanation**: This configuration tells Travis CI to use Node.js and Docker, build your Docker image, run tests, and deploy to AWS when changes are pushed to the master branch.

---

- [x] **AWS Elastic Beanstalk Deployment**:
   - **Create an AWS Elastic Beanstalk Environment**:
     - Go to the [AWS Management Console](https://aws.amazon.com) and search for **Elastic Beanstalk**.
     - Create a new application and environment.
     - Choose **Docker** as the platform and set up your environment.

   - **Configure AWS CLI**:
     - Install the AWS CLI and configure it with your credentials:
       ```bash
       aws configure
       ```
     - **Explanation**: This allows Travis CI to authenticate with your AWS account for deployment.

---

- [x] **Testing Your CI/CD Pipeline**:
   - **Push a Feature Branch**:
     - Create a new feature branch:
       ```bash
       git checkout -b feature-branch
       ```
     - Make changes, commit, and push the branch to GitHub.
   
   - **Merge to Master**:
     - Once the feature is complete, merge your feature branch into master:
       ```bash
       git checkout master
       git merge feature-branch
       git push origin master
       ```
     - **Outcome**: Travis CI will automatically run tests and deploy the app to AWS when the code is pushed to the master branch.

---

- [x] **Best Practices**:
   - **Use Feature Branches**: Always develop new features on a separate branch and only merge into master when ready for deployment.
   - **Automated Testing**: Ensure your tests are running correctly in the Travis CI pipeline before deployment.
   - **Monitor Deployment**: Keep track of your deployments through AWS Elastic Beanstalk to ensure that everything is running smoothly in production.







  
=======
# Getting Started with Create React App

This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).

## Available Scripts

In the project directory, you can run:

### `npm start`

Runs the app in the development mode.\
Open [http://localhost:3000](http://localhost:3000) to view it in your browser.

The page will reload when you make changes.\
You may also see any lint errors in the console.

### `npm test`

Launches the test runner in the interactive watch mode.\
See the section about [running tests](https://facebook.github.io/create-react-app/docs/running-tests) for more information.

### `npm run build`

Builds the app for production to the `build` folder.\
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.\
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

### `npm run eject`

**Note: this is a one-way operation. Once you `eject`, you can't go back!**

If you aren't satisfied with the build tool and configuration choices, you can `eject` at any time. This command will remove the single build dependency from your project.

Instead, it will copy all the configuration files and the transitive dependencies (webpack, Babel, ESLint, etc) right into your project so you have full control over them. All of the commands except `eject` will still work, but they will point to the copied scripts so you can tweak them. At this point you're on your own.

You don't have to ever use `eject`. The curated feature set is suitable for small and middle deployments, and you shouldn't feel obligated to use this feature. However we understand that this tool wouldn't be useful if you couldn't customize it when you are ready for it.

## Learn More

You can learn more in the [Create React App documentation](https://facebook.github.io/create-react-app/docs/getting-started).

To learn React, check out the [React documentation](https://reactjs.org/).

### Code Splitting

This section has moved here: [https://facebook.github.io/create-react-app/docs/code-splitting](https://facebook.github.io/create-react-app/docs/code-splitting)

### Analyzing the Bundle Size

This section has moved here: [https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size](https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size)

### Making a Progressive Web App

This section has moved here: [https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app](https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app)

### Advanced Configuration

This section has moved here: [https://facebook.github.io/create-react-app/docs/advanced-configuration](https://facebook.github.io/create-react-app/docs/advanced-configuration)

### Deployment

This section has moved here: [https://facebook.github.io/create-react-app/docs/deployment](https://facebook.github.io/create-react-app/docs/deployment)

### `npm run build` fails to minify

This section has moved here: [https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify](https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify)
>>>>>>> 0599d49 (Initialize project using Create React App)

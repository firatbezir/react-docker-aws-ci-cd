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

- [x] **Build Docker Image:**
   - **Command:**
     ```bash
     docker build -f Dockerfile.dev -t your-image-name .
     ```
   - **Note:** Replace `your-image-name` with your desired image name.

- [x] **Run Docker Container:**
   - **Command:**
     ```bash
     docker run -p 3000:3000 your-image-name
     ```
   - **Note:** Ensure you use `-p` to map ports between the container and your local machine.

- [x] **Check Development Server:**
   - **URL:** `http://localhost:3000`
   - **Note:** Ensure that the development server is accessible via this URL.

- [x] **Remove Duplicate Dependencies:**
   - **Action:** Delete `node_modules` folder in the project directory before building the Docker image to avoid duplicate dependencies.
   - Two ss below show the difference before and after removing the duplicate dependencies in terms of storage:
  - Before: ![image](https://github.com/user-attachments/assets/409464c3-4514-46d7-89f8-75a790cfb514)
  - After : ![image](https://github.com/user-attachments/assets/ce072e13-2ad9-420b-8639-b1239b41cc7e)

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

















  

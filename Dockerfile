# ---- First Phase: Build ----
# Use the official Node.js 16 image with Alpine Linux as the base image.
FROM node:16-alpine as builder

# Set the working directory inside the container.
WORKDIR /home/node/app

# Copy only the package.json file to the working directory.
# This helps leverage Docker's caching mechanism, so `npm install` only runs if package.json changes.
COPY package.json .

# Install all the dependencies defined in package.json.
RUN npm install

# Copy the rest of the application code to the working directory.
COPY . .

# Build the React application for production.
# This will create optimized files in the `build` directory.
RUN npm run build

# ---- Second Phase: Run ----
# Use the official Nginx image as the base image to serve the built files.
FROM nginx

EXPOSE 80

# Copy the built files from the first phase (builder) to the default directory where Nginx serves static files.
# `--from=builder` references the build phase defined above.
COPY --from=builder /home/node/app/build /usr/share/nginx/html


#The reason for the multi-stage build is to keep the final Docker image small and efficient. The first phase installs dependencies and builds the application, but these layers (including all the Node.js dependencies) are not included in the final image. Instead, the final image only contains the built static files and the Nginx server to serve them. This approach is particularly beneficial for production environments, where you want to minimize the size of the image and the surface area for potential vulnerabilities.



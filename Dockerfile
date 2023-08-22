# Use the official Node.js 14 image as the base image
FROM node:14

# Set the working directory to /app
WORKDIR /app

# Copy the package.json and package-lock.json files to the working directory
COPY package*.json ./

# Install the dependencies
RUN npm install

# Copy the rest of the files to the working directory
COPY . .

# Expose port 3000 for the app
EXPOSE 3000

# Run the app
CMD ["node", "index.js"]

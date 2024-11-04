import os
import sys
import json
import tensorflow as tf
import cv2
import numpy as np

# Define parameters
image_size = (64, 64)
model_path = 'handwriting_recognition_model.h5'
input_folder = './input-folder/'

# Check if filename is provided as an argument
if len(sys.argv) < 2:
    print(json.dumps({"error": "No filename provided"}))
    sys.exit(1)

# Get the filename from arguments
filename = sys.argv[1]
file_path = os.path.join(input_folder, filename)

# Verify the file exists
if not os.path.isfile(file_path):
    print(json.dumps({"error": f"File '{filename}' not found"}))
    sys.exit(1)

# Load the model
model = tf.keras.models.load_model(model_path)

# Read, resize, and normalize the image
new_img = cv2.imread(file_path, cv2.IMREAD_GRAYSCALE)
new_img = cv2.resize(new_img, image_size)
new_img = new_img.reshape(1, image_size[0], image_size[1], 1) / 255.0  # Normalize

# Predict the label
prediction = model.predict(new_img)
predicted_label = int(np.argmax(prediction))

# Delete the processed image
os.remove(file_path)

# Output prediction as JSON
obj = {"text": predicted_label}
json_string = json.dumps(obj)
print(json_string)

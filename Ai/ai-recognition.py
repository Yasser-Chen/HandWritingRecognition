import os
import sys
import json
import tensorflow as tf
from PIL import Image
import numpy as np

# Suppress TensorFlow logging and progress bars
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'  # Hide TensorFlow messages
tf.get_logger().setLevel('ERROR')

# Define parameters
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

# Load and prepare the image
new_img = Image.open(file_path).convert('L')  # Convert to grayscale
new_img = new_img.resize((64, 64))  # Resize to 64x64 to match model's expected input size

# Convert the image to a numpy array, normalize, and reshape
new_img = np.array(new_img).reshape(1, 64, 64, 1)  # Reshape to (1, 64, 64, 1)
new_img = new_img.astype('float32') / 255  # Normalize pixel values if required by the model

# Predict the label
prediction = model.predict(new_img, verbose=0)  # Disable prediction progress output
predicted_label = int(np.argmax(prediction))

# Delete the processed image
os.remove(file_path)

# Output prediction as JSON
obj = {"text": predicted_label}
json_string = json.dumps(obj)
print(json_string)

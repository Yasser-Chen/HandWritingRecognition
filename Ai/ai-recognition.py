import os
import sys
import json
import tensorflow as tf
from PIL import Image
import numpy as np
from tensorflow.keras.preprocessing.image import img_to_array

# Suppress TensorFlow logging
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'  # Hide TensorFlow messages
tf.get_logger().setLevel('ERROR')

# Define parameters
model_path = 'handwriting_recognition_model.h5'
input_folder = './input-folder/'
image_size = (64, 64)  # Match this with the training image size

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

def preprocess_image(img_path, target_size=(64, 64)):
    # Open image with Pillow, ensuring it has an alpha channel
    img = Image.open(img_path).convert("RGBA")
    
    # Create a white background image and paste original image onto it
    white_bg = Image.new("RGB", img.size, (255, 255, 255))
    white_bg.paste(img, mask=img.split()[3])  # Use alpha channel as mask
    
    # Convert to grayscale so text is black and background is white
    gray_img = white_bg.convert("L")
    
    # Apply strict black-and-white thresholding
    binary_img = gray_img.point(lambda x: 0 if x > 254 else 255)
    
    # Resize to the target size
    binary_img = binary_img.resize(target_size)
    
    # Convert image to array and normalize
    img_array = img_to_array(binary_img) / 255.0  # Normalize to match training
    img_array = np.expand_dims(img_array, axis=-1)  # Add channel dimension
    return img_array

# Load the model
model = tf.keras.models.load_model(model_path)

# Preprocess the image and prepare for prediction
preprocessed_img = preprocess_image(file_path)
preprocessed_img = np.expand_dims(preprocessed_img, axis=0)  # Reshape for model input (1, 64, 64, 1)

# Predict the label
prediction = model.predict(preprocessed_img, verbose=0)  # Disable prediction progress output
predicted_label = int(np.argmax(prediction))

# Delete the processed image
# os.remove(file_path)

# Output prediction as JSON
obj = {"text": predicted_label}
json_string = json.dumps(obj)
print(json_string)

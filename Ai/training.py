import os
import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing.image import load_img, img_to_array
from tensorflow.keras.utils import to_categorical
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Dropout
from sklearn.model_selection import train_test_split

# Define parameters
image_size = (64, 64)
batch_size = 32
epochs = 10  # Adjust based on your data size
model_path = 'handwriting_recognition_model.h5'
data_dir = './archive/dataset/'  # Path to your dataset

images = []
labels = []

for a in os.listdir(data_dir):
    s = os.path.join(data_dir, a) 
    for label in os.listdir(s):
        label_path = os.path.join(s, label)  # Path to the label folder
        if os.path.isdir(label_path):  # Ensure it's a directory
            for filename in os.listdir(label_path):
                if filename.endswith('.png'):
                    img_path = os.path.join(label_path, filename)

                    # Load image, resize, and convert to array
                    img = load_img(img_path, color_mode='grayscale', target_size=image_size)
                    img_array = img_to_array(img) / 255.0  # Normalize pixel values
                    images.append(img_array)
                    labels.append(int(label))  # Use the folder name as the label

# Convert lists to arrays
images = np.array(images)
labels = np.array(labels)



# One-hot encode labels
num_classes = len(np.unique(labels))
labels = to_categorical(labels, num_classes)

# Split data into training and validation sets
X_train, X_val, y_train, y_val = train_test_split(images, labels, test_size=0.2, random_state=42)

# 2. Model Definition
model = Sequential([
    Conv2D(32, (3, 3), activation='relu', input_shape=(image_size[0], image_size[1], 1)),
    MaxPooling2D(pool_size=(2, 2)),
    Conv2D(64, (3, 3), activation='relu'),
    MaxPooling2D(pool_size=(2, 2)),
    Conv2D(128, (3, 3), activation='relu'),
    MaxPooling2D(pool_size=(2, 2)),
    Flatten(),
    Dense(128, activation='relu'),
    Dropout(0.5),
    Dense(num_classes, activation='softmax')  # Output layer for number of classes
])

# 3. Compile the Model
model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

# 4. Train the Model
history = model.fit(X_train, y_train, epochs=epochs, batch_size=batch_size, validation_data=(X_val, y_val))

# 5. Save the Model
model.save(model_path)
print(f"Model saved as {model_path}")

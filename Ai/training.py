import os
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing.image import load_img, img_to_array
from tensorflow.keras.utils import to_categorical
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Dropout
from tensorflow.keras.callbacks import EarlyStopping
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.regularizers import l2
from PIL import Image

# Define parameters
image_size = (64, 64)
batch_size = 32
epochs = 50
model_path = 'handwriting_recognition_model.h5'
data_dir = './archive/dataset/'

# Step 1: Load and preprocess images
print("Step 1: Loading and preprocessing images...")
images = []
labels = []


def preprocess_image(img_path, target_size=(64, 64)):
    # Open image with Pillow and ensure it has an alpha channel
    img = Image.open(img_path).convert("RGBA")
    
    # Create white background and paste original image on it
    white_bg = Image.new("RGB", img.size, (255, 255, 255))
    white_bg.paste(img, mask=img.split()[3])  # Alpha channel as mask
    
    # Convert to grayscale (black text on white background)
    gray_img = white_bg.convert("L")
    
    # Invert the image: Now black text on white background
    inverted_gray_img = Image.eval(gray_img, lambda x: 255 - x)
    
    # Resize to target size
    inverted_gray_img = inverted_gray_img.resize(target_size)

    # Convert image to array and normalize
    img_array = img_to_array(inverted_gray_img) / 255.0
    return img_array

for a in os.listdir(data_dir):
    s = os.path.join(data_dir, a)
    for label in os.listdir(s):
        label_path = os.path.join(s, label)
        if os.path.isdir(label_path):
            for filename in os.listdir(label_path):
                if filename.endswith('.png'):
                    img_path = os.path.join(label_path, filename)
                    processed_img = preprocess_image(img_path)
                    images.append(processed_img)
                    labels.append(int(label))

print(f"Loaded {len(images)} images and {len(labels)} labels.")

# Step 2: Convert lists to arrays
images = np.array(images)
labels = np.array(labels)

# Step 3: One-hot encode labels
num_classes = len(np.unique(labels))
labels = to_categorical(labels, num_classes)

# Step 4: Model Definition
model = Sequential([
    Conv2D(32, (3, 3), activation='relu', kernel_regularizer=l2(0.001), input_shape=(image_size[0], image_size[1], 1)),
    MaxPooling2D(pool_size=(2, 2)),
    Conv2D(64, (3, 3), activation='relu', kernel_regularizer=l2(0.001)),
    MaxPooling2D(pool_size=(2, 2)),
    Conv2D(128, (3, 3), activation='relu', kernel_regularizer=l2(0.001)),
    MaxPooling2D(pool_size=(2, 2)),
    Flatten(),
    Dense(128, activation='relu', kernel_regularizer=l2(0.001)),
    Dropout(0.5),
    Dense(num_classes, activation='softmax')
])

# Step 5: Compile the model
model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

# Step 6: Image augmentation
datagen = ImageDataGenerator(validation_split=0.2)

# Step 7: Train the model with EarlyStopping
early_stopping = EarlyStopping(monitor='val_loss', patience=5, restore_best_weights=True)
history = model.fit(
    datagen.flow(images, labels, batch_size=batch_size, subset='training'),
    validation_data=datagen.flow(images, labels, batch_size=batch_size, subset='validation'),
    epochs=epochs,
    callbacks=[early_stopping]
)

# Step 8: Save the model
model.save(model_path)
print(f"Model saved as {model_path}")

# Step 9: Evaluate the model
val_loss, val_acc = model.evaluate(images, labels)
print(f"Validation accuracy: {val_acc * 100:.2f}%")

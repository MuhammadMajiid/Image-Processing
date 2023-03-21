import cv2
import numpy as np

# Read the input image as grayscale
# img_1 = cv2.imread('cameraman.jpg', cv2.IMREAD_GRAYSCALE)
# img = cv2.imwrite('cameraman.png', img_1)

# # Convert the image to a 1-dimensional array of grayscale values
# data = img.flatten()

# # Convert the grayscale values to hex strings
# hex_data = [format(int(x), '02x') for x in data]

# # Join the hex strings into a single string with line breaks after every byte
# hex_data_str = '\n'.join(hex_data)

# # Write the hex data to a text file
# with open('cameraman.txt', 'w') as file:
#     file.write(hex_data_str)

###################################################################################################################################

# Read the hex data from the text file
with open('cammanshrink.txt', 'r') as file:
    hex_data = file.read().replace('\n', '') # remove line breaks

squar_dim_nxn =128

# Convert the data from hex to a numpy array
grayscale_array = np.array([int(hex_data[i:i+2], 16) for i in range(0, len(hex_data), 2)], dtype=np.uint8)

# Reshape the array to the original grayscale image shape
width, height = squar_dim_nxn, squar_dim_nxn # Change to your desired image dimensions

grayscale_image = grayscale_array.reshape((height, width))

# Write the grayscale image to a PNG file
cv2.imwrite('camman_restored.png', grayscale_image)
import cv2
import numpy as np

# # ----------->>> Conversion from the png to the hex file

# # Read the input image
# img = cv2.imread('input.png', cv2.IMREAD_COLOR)

# # Convert the image to a 1-dimensional array of RGB pixels
# data = img.reshape((-1, 3))

# # Convert the RGB values to hex strings
# hex_data = [format(int(x), '02x') for x in data.flatten()]

# # Join the hex strings into a single string with line breaks after every 3 bytes
# hex_data_str = '\n'.join([''.join(hex_data[i:i+3]) for i in range(0, len(hex_data), 3)])

# # Write the hex data to a text file
# with open('output.txt', 'w') as file:
#     file.write(hex_data_str)


###################################################################################################################################

# ----------->>> Conversion from the hex to the png


# Input to define the nuber of bytes per pexil
BPP = 3

# Load the hex data from the text file
with open('eff_out.txt', 'r') as f:
    hex_data = f.read().replace('\n', '')

if (BPP == 3):
    dvsr = 6
else:
    dvsr = 1

num_pixels = len(hex_data) // 6
width = int(num_pixels ** 0.5)
height = num_pixels // width

print(len(hex_data))
print(num_pixels)
print(width)
print(width)

# Convert the hex data to a NumPy array of uint8 values
data = np.frombuffer(bytes.fromhex(hex_data), dtype=np.uint8)

# Reshape the data into an array of RGB pixels
data = data.reshape((height, width, 3))

# Convert the array to an RGB image
img = cv2.cvtColor(data, cv2.COLOR_RGB2RGBA)
cv2.imwrite('drk_output.png', img)
import serial
 
ser = serial.Serial(
    port     = 'COM3', # specify the desired port
    baudrate = 115200,
    parity   = serial.PARITY_NONE,
    stopbits = serial.STOPBITS_ONE,
    bytesize = serial.EIGHTBITS,
    timeout  = None
)
 
output_file = open('ter_out.txt', 'wb')

while 1:
    hexData = ser.read().hex()
    print(hexData)

    # Write the byte to the output file
    output_file.write(hexData)
    
    # Write a new line character
    output_file.write(b'\n')

###################################################################################################################################


# this code writes every 3 lines of the 1-byte per line file from the terminal output into a 3-bytes per line file.
# this step is necessary for compatibility with the converion code.

# with open('input.txt', 'r') as input_file, open('output.txt', 'w') as output_file:
#     line_count = 0
#     bytes_per_line = []

#     # Read input file one byte at a time
#     for line in input_file:
#         byte = line.strip()

#         # Add byte to list
#         bytes_per_line.append(byte)

#         # Check if we have three bytes for this line
#         line_count += 1
#         if line_count == 3:
#             # Write three bytes to output file
#             output_file.write(''.join(bytes_per_line) + '\n')
#             line_count = 0
#             bytes_per_line = []
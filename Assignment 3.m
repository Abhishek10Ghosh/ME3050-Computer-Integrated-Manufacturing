% Read the input image file
img = imread('test2.jpg'); 

% Convert the image to grayscale if it's an RGB image
img = rgb2gray(img);

% Get the size of the image (number of rows and columns)
[rows, cols] = size(img);

% Define parameters for engraving
x_spacing = 1;      % Spacing between points in the X direction (in mm)
y_spacing = 1;      % Spacing between points in the Y direction (in mm)
max_depth = 5;      % Maximum engraving depth (in mm) for the darkest areas
min_depth = 0.2;    % Minimum engraving depth (in mm) for the lightest areas

% Normalize pixel values to map to the engraving depth range
% Convert pixel values to double for calculations, normalize to [0, 1],
% and scale to the engraving depth range. Inversion is done for lithophane effect.
depth = min_depth + (1 - (double(img) / 255)) * (max_depth - min_depth);

% Open a file for writing the G-code instructions
gcode_file = fopen('ME21BTECH11001_A3.txt', 'w');

% Write the G-code header (initial setup commands)
fprintf(gcode_file, 'G21 ; Set units to mm\n');           % Set units to millimeters
fprintf(gcode_file, 'G90 ; Absolute positioning\n');      % Set absolute positioning mode
fprintf(gcode_file, 'G0 Z10 ; Move to safe height\n');    % Move the tool to a safe height

% Start engraving path, iterating over each row of the image
for i = 1:rows
    if mod(i, 2) == 1  % Odd rows: process left to right
        for j = 1:cols
            % Calculate the X and Y coordinates based on pixel indices and spacing
            x = j * x_spacing;
            y = i * y_spacing;
            z = depth(i, j);  % Get the engraving depth for the current pixel

            % Move the tool to the current position at a safe height
            fprintf(gcode_file, 'G0 Z10 ; Move to safe height\n');
            fprintf(gcode_file, 'G0 X%.2f Y%.2f\n', x, y);

            % Perform the engraving at the specified depth with a feed rate of 300 mm/min
            fprintf(gcode_file, 'G1 Z-%.2f F300 ; Engrave\n', z);
        end
    else  % Even rows: process right to left (reverse to minimize tool travel)
        for j = cols:-1:1
            % Calculate the X and Y coordinates
            x = j * x_spacing;
            y = i * y_spacing;
            z = depth(i, j);  % Get the engraving depth for the current pixel

            % Move the tool to the current position at a safe height
            fprintf(gcode_file, 'G0 Z10 ; Move to safe height\n');
            fprintf(gcode_file, 'G0 X%.2f Y%.2f\n', x, y);

            % Perform the engraving at the specified depth
            fprintf(gcode_file, 'G1 Z-%.2f F300 ; Engrave\n', z);
        end
    end
end

% Move the tool to a safe height after finishing engraving
fprintf(gcode_file, 'G0 Z10 ; Move to safe height\n');

% Return the tool to the home position (X=0, Y=0)
fprintf(gcode_file, 'G0 X0 Y0 ; Return to home position\n');

% End the G-code program
fprintf(gcode_file, 'M30 ; End of program\n');

% Close the G-code file
fclose(gcode_file);

% Display a completion message in the MATLAB console
disp('G-code generation complete.');

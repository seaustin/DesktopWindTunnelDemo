%=========================================================================%
%                       AOA_Table_Lookup_Script
%
%   The m-file will read in data from an Arduino and use a lookup table
%   with values for the differential pressure based on a given AOA for a 
%   pitot under testing.
%   
%
%
% Set up serial communication with Arduino
arduino = serialport('COM3', 'BaudRate', 9600); % Replace 'COM3' with your serial port identifier
%fopen(arduino);

% Read dPA and qCM from Arduino
flush(port); % Clear unread messages
    data = [];
    while port.NumBytesAvailable < 4
    end
    
    first_line = 1;
    i = 1;
    while i < 50
    %while height(data) < num_lines
        if first_line
            useless = readline(port);
            first_line = 0;
        end
        string = readline(port);
        line = str2double(strsplit(string, "\t"));    

        i = i+1;
    end

dPA = data(); % pressure diff from alpha ports
qCM = data(); % pressure diff bw ref. static and total

%Ask and collect user input 
speedset = input('Please Input Speed with in Range of 45 to 75 (knots) in increments of 10 (knots):');
userAOA = input('Please Input Set Angle of Attack (AOA):');


%Below is an example of a 1xN array for each respective variable. This
%table models as a lookup table for a specific speed.

if speedset == 45 && userAOA
    
    %Example data
    known_AOA_deg = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45];% Known angle of attack values in degrees
    aoa_ratios_at_45 = [0, 0.15, 0.3, 0.45, 0.6, 0.75, 0.9, 1.5]; % Corresponding aoa_ratio values
   
    %Table form of the above
    [known_AOA_deg, aoa_ratios_at_45] = meshgrid(known_AOA_deg, aoa_ratios_at_45);
    airdata_table_45  = [known_AOA_deg(:) aoa_ratios_at_45(:)];

    AOA = calculate_AOA(dPA, qCM, known_AOA_deg, aoa_ratios_at_45);%called based on input of two arrays

end

if speedset == 55 && userAOA

    known_AOA_deg = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45];% Known angle of attack values in degrees
    aoa_ratios_at_55 = [0, 0.15, 0.3, 0.45, 0.6, 0.75, 0.9, 1.5]; % Corresponding aoa_ratio values
   
    %Table form of the above
    %[known_AOA_deg, aoa_ratios_at_55] = meshgrid(known_AOA_deg, aoa_ratios_at_55);
    %airdata_table_55  = [known_AOA_deg(:) aoa_ratios_at_55(:)];

    AOA = calculate_AOA(dPA, qCM, known_AOA_deg, aoa_ratios_at_55);

end

if speedset == 65 && userAOA 

    known_AOA_deg = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45];% Known angle of attack values in degrees
    aoa_ratios_at_65 = [0, 0.15, 0.3, 0.45, 0.6, 0.75, 0.9, 1.5]; % Corresponding aoa_ratio values
   
    %Table form of the above
    %[known_AOA_deg, aoa_ratios_at_65] = meshgrid(known_AOA_deg, aoa_ratios_at_65);
    %airdata_table_65  = [known_AOA_deg(:) aoa_ratios_at_65(:)];

    AOA = calculate_AOA(dPA, qCM, known_AOA_deg, aoa_ratios_at_65);

end

if speedset == 75 && userAOA

    known_AOA_deg = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45];% Known angle of attack values in degrees
    aoa_ratios_at_75 = [0, 0.15, 0.3, 0.45, 0.6, 0.75, 0.9, 1.5]; % Corresponding aoa_ratio values
   
    %Table form of the above
    %[known_AOA_deg, aoa_ratios_at_75] = meshgrid(known_AOA_deg, aoa_ratios_at_75);
    %airdata_table_75  = [known_AOA_deg(:) aoa_ratios_at_75(:)];

    AOA = calculate_AOA(dPA, qCM, known_AOA_deg, aoa_ratios_at_75);
end



% Close serial communication with Arduino (Terminate?)
%fclose(arduino);



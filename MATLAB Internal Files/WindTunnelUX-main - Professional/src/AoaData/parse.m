function jointArray = parse()
    % DESCRIPTION
    %   Uses regular expressions to parse the .dat files from the wind tunnel
    %   testing.
    % SYNOPSIS
    %   jointArray = parse()
    % INPUTS
    %   None
    % OUTPUTS
    %   jointArray      (40, 6)     String array:
    %       Column 1: Filepath to the corresponding data file for each row
    %       Column 2: Comment from the file
    %       Column 3: Pressure sensor number (0 if N/A)
    %       Column 4: Measured density (kg/m^3)
    %       Column 5: Reference dynamic pressure (Pa)
    %       Column 6: Reference airspeed (m/s)

    % Sort dat files based on their comments
    files = ls('ReferenceDat/*.dat');
    files = strsplit(files);
    files(end) = [];
    commentMatch = 'User comment: (\S*)';
    for i = 1:length(files)
        fname(i) = string(files(i));
        contents = fileread(fname(i));
        comment(i) = string(regexp(contents, commentMatch, 'tokens'));
    end
    [commentSorted, sortIdx] = sort(comment, 'descend');
    jointArray = [fname(sortIdx)', commentSorted'];
    
    for i = 1:length(jointArray)
        datafile = fileread(jointArray(i, 1));
        density(i) = str2double( ...
            string( ...
                    regexp(datafile, 'Density\s*=\s(\d+.\d+)', 'tokens') ...
                ) ...
            );
        pressureDiff(i) = str2double( ...
            string( ...
                    regexp(datafile, 'Fixed Pitot Probe Pressure\s*=\s(\d+.?\d*)', 'tokens') ...
                ) ...
            );
        sensorTemp = str2double(string(regexp(commentSorted(i), 'Sensor(\d)', 'tokens')));
        if isempty(sensorTemp)
            sensor(i) = 0;
        else
            sensor(i) = sensorTemp;
        end
        refSpeed(i) = str2double(string(regexp(datafile, 'Fixed Pitot Probe Speed\s*=\s(\d*.?\d*)', 'tokens')));
    end
    
    jointArray = [jointArray, sensor', density', pressureDiff', refSpeed'];
end
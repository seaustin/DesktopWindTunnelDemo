function [alphaPortPressure, dynamicPressure, AOA_grid] = makeLookupTable()
    % DESCRIPTION:
    %   Makes 3 2-D grids that relate alpha port pressure, dynamic pressure, and
    %   angle of attack at each index
    % SYNOPSIS:
    %   [alphaPortPressure, dynamicPressure, AOA_grid] = makeLookupTable()
    % INPUTS:
    %   None
    % OUTPUTS:
    %   alphaPortPressure       (n, n)      2D array of the pressure difference
    %                                       between the alpha ports at (i, j).
    %   dynamicPressure         (n, n)      2D array of the dynamic pressure at
    %                                       (i, j).
    %   AOA_grid                (n, n)      2D array of the angle of attack at
    %                                       (i, j).

    % Obtain the calculated calibration constants from calibrate()
    [caliMultiple, caliOffset] = calibrate(0);
    SENSOR1_CALIBRATION_MULTIPLE = caliMultiple(1);
    SENSOR1_CALIBRATION_OFFSET = caliOffset(1);
    SENSOR3_CALIBRATION_MULTIPLE = caliMultiple(2);
    SENSOR4_CALIBRATION_MULTIPLE = caliMultiple(3);
    
    % Anonymous functions to apply the calibration
    sensor1Correction = @(p) (p + SENSOR1_CALIBRATION_OFFSET).*SENSOR1_CALIBRATION_MULTIPLE;
    sensor3Correction = @(p) p.*SENSOR3_CALIBRATION_MULTIPLE;
    sensor4Correction = @(p) p.*SENSOR4_CALIBRATION_MULTIPLE;
    
    % Set vectors of angles of attack and airspeed
    AOA = [0, 10, 20, 30, 40];
    setSpeed = [0 20 25 30 35];
    jointArray = parse();   % Array containing data parsed from wind tunnel .dat files
    
    for i = 1:5
        for j = 1:5
            fileName = ['deg', num2str(AOA(i)), '_aspd', num2str(setSpeed(j)), '.mat'];
            in = load(fileName);
            p1_datCorrected = sensor1Correction(in.p1_dat(:, 2));
            p3_datCorrected = sensor3Correction(in.p3_dat(:, 2));
            alphaPortPressure(i, j) = mean(p1_datCorrected);
            dynamicPressure(i, j) = 1/2*1.14*setSpeed(j)^2;
        end
    end
    
    AOA_grid = ndgrid(AOA, setSpeed);
end
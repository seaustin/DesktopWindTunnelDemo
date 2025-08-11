function [alphaPortPressure, dynamicPressure, AOA_grid, setSpeed_grid, Table_AOA] = LookupTable_2(arduino_alphaPortPressure, arduino_dynamicPressure)
    [caliMultiple, caliOffset] = calibrate(0);
    SENSOR1_CALIBRATION_MULTIPLE = caliMultiple(1);
    SENSOR1_CALIBRATION_OFFSET = caliOffset(1);
    SENSOR3_CALIBRATION_MULTIPLE = caliMultiple(2);
    SENSOR4_CALIBRATION_MULTIPLE = caliMultiple(3);
    
    sensor1Correction = @(p) (p + SENSOR1_CALIBRATION_OFFSET).*SENSOR1_CALIBRATION_MULTIPLE;
    sensor3Correction = @(p) p.*SENSOR3_CALIBRATION_MULTIPLE;
    sensor4Correction = @(p) p.*SENSOR4_CALIBRATION_MULTIPLE;
    
    AOA = [0, 10, 20, 30, 40];
    setSpeed = [0 20 25 30 35];
    jointArray = parse();
    
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
    
    [AOA_grid, setSpeed_grid] = ndgrid(AOA, setSpeed);
    
    % Fit a surface to the data
    surfacefit = fit([alphaPortPressure(:), dynamicPressure(:)], AOA_grid(:),'poly22','normalize', 'on');
    Table_AOA = surfacefit(arduino_alphaPortPressure,arduino_dynamicPressure);

    % To visualize the surface, uncomment the following lines
     %figure;
     %plot(sf, [alphaPortPressure(:), dynamicPressure(:)], AOA_grid(:));
     %xlabel('alphaPortPressure');
     %ylabel('dynamicPressure');
     %zlabel('AOA');
     %title('Surface Fit');
end

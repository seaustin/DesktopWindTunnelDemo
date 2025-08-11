function [caliConst, caliOffset] = calibrate(makePlots)
    % DESCRIPTION:
    %   Determines the calibration constants for the pressure sensors assuming a
    %   linear error profile between the sensor output and the reference value
    % SYNOPSIS:
    %   [caliConst, caliOffset] = calibrate(makePlots)
    % INPUTS:
    %   makePlots       bool        If true, the function will produce a plot of
    %                               the error vs. dynamic pressure for each 
    %                               sensor
    % OUTPUTS:
    %   caliConst       (1, 3)      Slope of the calibration curve for each
    %                               sensor
    %   caliOffset      (1, 3)      y-intercept of the calibration curve for
    %                               each sensor

    jointArray = parse();
    caliIdx = 1:15;
    caliArray = str2double([jointArray(caliIdx, 4), jointArray(caliIdx, 5), jointArray(caliIdx, 3), ...
                 jointArray(caliIdx, 6)]);
    setSpeed = [35 30 25 20 0 35 30 25 20 0 35 30 25 20 0];
    for i = caliIdx
        fname = ['Sensor', num2str(caliArray(i, 3)), '_spd', num2str(setSpeed(i)), '.mat'];
        load(fname, 'p_dat')
        sensorPressure(i) = mean(p_dat(:, 2));
    end
    
    caliArray = [caliArray, sensorPressure'];
    
    s4Idx = 1:5;
    s1Idx = 6:10;
    s3Idx = 11:15;
    
    caliConst4 = mean(caliArray(1:4, 2)./caliArray(1:4, 5));
    caliConst1 = mean(caliArray(6:9, 2)./(caliArray(6:9, 5) - caliArray(10, 5)));
    caliConst3 = mean(caliArray(11:14, 2)./caliArray(11:14, 5));

    caliConst = [caliConst1, caliConst3, caliConst4];
    caliOffset = [-caliArray(10, 5), 0, 0];

    % Plotting
    if makePlots
        sens4Fig = figure(1);
        plot(caliArray(s4Idx, 2), caliArray(s4Idx, 2) - caliArray(s4Idx, 5), 'r.-', MarkerSize=12, LineWidth=2);
        hold on
        plot(caliArray(s4Idx, 2), caliArray(s4Idx, 2) - caliArray(s4Idx, 5)*caliConst4, 'b.-', MarkerSize=12, LineWidth=2);
        hold off
        title('Sensor 4')
        legend('Raw', 'Calibrated', Location="northwest")
        ylabel('Error (Pa)')
        xlabel('Differential Pressure (Pa)')
        grid on
        grid minor
        
        sens1Fig = figure(2);
        figure(2)
        plot(caliArray(s1Idx, 2), caliArray(s1Idx, 2) - caliArray(s1Idx, 5), 'r.-', MarkerSize=12, LineWidth=2);
        hold on
        plot(caliArray(s1Idx, 2), caliArray(s1Idx, 2) - (caliArray(s1Idx, 5) - caliArray(10, 5))*caliConst1, 'b.-', MarkerSize=12, LineWidth=2);
        hold off
        title('Sensor 1')
        legend('Raw', 'Calibrated', Location="northwest")
        ylabel('Error (Pa)')
        xlabel('Differential Pressure (Pa)')
        grid on
        grid minor
        
        sens3Fig = figure(3);
        plot(caliArray(s3Idx, 2), caliArray(s3Idx, 5), 'r.-', MarkerSize=12, LineWidth=2);
        hold on
        plot(caliArray(s3Idx, 2), caliArray(s3Idx, 2) - caliArray(s3Idx, 5)*caliConst3, 'b.-', MarkerSize=12, LineWidth=2);
        hold off
        title('Sensor 3')
        legend('Raw', 'Calibrated', Location="northwest")
        ylabel('Error (Pa)')
        xlabel('Differential Pressure (Pa)')
        grid on
        grid minor

        print(sens1Fig, 'Sensor1Calibration', '-dsvg')
        print(sens3Fig, 'Sensor3Calibration', '-dsvg')
        print(sens4Fig, 'Sensor4Calibration', '-dsvg')
    end
end
function [intAoa] = interpAoa(arduino_alphaPortPressure, arduino_dynamicPressure)
    % DESCRIPTION:
    %   Interpolate the angle of attack from alpha port pressure and dynamic
    %   pressure using cubic interpolation and linear extrapolation of the
    %   lookup table created by makeLookupTable()
    % SYNOPSIS:
    %   [intAoa] = interpAoa(arduino_alphaPortPressure, arduino_dynamicPressure)
    % INPUTS:
    %   arduino_alphaPortPressure   (1, 1)      Alpha port differential pressure
    %                                           measured on the arduino
    %   arduino_dynamicPressure     (1, 1)      Dynamic pressure from reference
    %                                           pitot measured on ardiuno
    % OUTPUTS:
    %   intAoa      (1, 1)      Interpolated (or extrapolated) angle of attack

    load("LookupTable.mat", "AOA_grid", "alphaPortPressure", "dynamicPressure");
    
    % Expand
    AOA_grid = [AOA_grid; -AOA_grid];
    alphaPortPressure = [alphaPortPressure; -alphaPortPressure];
    dynamicPressure = [dynamicPressure; dynamicPressure];

    % Fit a surface to the data
    if ~isfile("surfacefit.mat")
        surfacefit = fit([alphaPortPressure(:), dynamicPressure(:)], AOA_grid(:), ...
            'cubicinterp', ...
            ExtrapolationMethod='linear');
        save("surfacefit.mat", "surfacefit");
    else    
        load("surfacefit.mat", "surfacefit");
    end
    intAoa = surfacefit(arduino_alphaPortPressure,arduino_dynamicPressure);

    % To visualize the surface, uncomment the following lines
     % figure;
     % plot(surfacefit, [alphaPortPressure(:), dynamicPressure(:)], AOA_grid(:));
     % xlabel('alphaPortPressure');
     % ylabel('dynamicPressure');
     % zlabel('AOA');
     % title('Surface Fit');
end

function [Table_AOA] = interpAoa2(arduino_alphaPortPressure, arduino_dynamicPressure)
    load("LookupTable.mat", "AOA_grid", "alphaPortPressure", "dynamicPressure");

    % Expand
    AOA_grid = [AOA_grid; -AOA_grid];
    alphaPortPressure = [alphaPortPressure; -alphaPortPressure];
    dynamicPressure = [dynamicPressure; dynamicPressure];

    Table_AOA = griddata(alphaPortPressure(:), dynamicPressure(:), AOA_grid(:), ...
                    arduino_alphaPortPressure, arduino_dynamicPressure);

     figure;
     surf(alphaPortPressure, dynamicPressure, AOA_grid)
     xlabel('alphaPortPressure');
     ylabel('dynamicPressure');
     zlabel('AOA');
     title('Surface Fit');
end

function aoa = aoa_ratio_to_AOA(aoa_ratio, known_AOA_deg, aoa_ratios)
    % Function to convert aoa_ratio to angle of attack using linear interpolation
    % Inputs:
    %   aoa_ratio: Ratio of dPA/qCM
    %   known_AOA_deg: Vector of known angle of attack values in degrees
    %   aoa_ratios: Vector of corresponding aoa_ratio values by data table
    %
    % Outputs:
    %   aoa: Angle of attack (AOA) in degrees
    
    % can also use polyfit as alternative
    aoa = interp1(aoa_ratios, known_AOA_deg, aoa_ratio, 'linear', 'extrap');
end

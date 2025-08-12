function aoa = calculate_AOA(dPA, qCM, known_AOA_deg, aoa_ratios)
    % Function to calculate the Angle of Attack (AOA) given dPA and qCM
    % Inputs:
    %   dPA: Differential pressure between the top and bottom alpha ports
    %   qCM: Measured total pressure minus measured static pressure
    %   known_AOA_deg: Vector of known angle of attack values in degrees
    %   aoa_ratios: Vector of corresponding aoa_ratio values
    %
    % Outputs:
    %   aoa: Angle of Attack (AOA) in degrees
    
    if qCM == 0
        error('qCM must be nonzero to calculate AOA.');
    end
    
    aoa_ratio = dPA / qCM;
    aoa = aoa_ratio_to_AOA(aoa_ratio, known_AOA_deg, aoa_ratios);
end

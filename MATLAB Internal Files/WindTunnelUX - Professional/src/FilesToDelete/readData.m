function readData(app, ~, ~)
    numLinesToRead = 4;
    flush(app.SERIAL_PORT);      % Clear unread messages
    data = zeros(numLinesToRead, 3);
    while app.SERIAL_PORT.NumBytesAvailable < 4    % Wait until a full message is ready
    end

    for i = 1:numLinesToRead
        if i == 1
            useless = readline(app.SERIAL_PORT);   % Dump the first line into an unused variable
        end
        string     = readline(app.SERIAL_PORT);
        data(i, :) = str2double(strsplit(string, "\t"));
        
    end
    % Parse data
    aoa_dat = data(data(:, 1)==1, :);
    ref_dat = data(data(:, 1)==3, :);
    uut_dat = data(data(:, 1)==4, :);
    % Update speed and aoa vectors
    app.uut_speeds      = circshift(app.uut_speeds, -1);
    app.uut_speeds(end) = uut_dat(3);
    app.aoa_pres        = circshift(app.aoa_pres, -1);
    app.aoa_pres(end)   = aoa_dat(2);
    % Update plots
    plot(app.AspdPlot, app.uut_speeds);
    plot(app.AspdPlot, app.aoa_pres);
    % Update Gauges
    app.DynamicPressureGauge.Value  = ref_dat(2);
    app.MeasuredAirspeedGauge.Value = ref_dat(3);
end
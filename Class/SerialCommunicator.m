function s = SerialCommunicator(data_pool)
    s = serialport("COM5", 576000, "Timeout", 5);
    s.UserData = data_pool;
    s.configureCallback("terminator", @handleSerial);
    s.flush();
end

%% Function handle declaration
% Serial
function processRxSerialData(serial_port, event)
    % persistent count save_data
    % if isempty(count)
    %     count = 0;
    % end
    % 
    % if isempty(save_data)
    %     save_data = [];
    % end
    % 
    % if count > 50000
    %     save("SaveData", "save_data");
    %     serial_port.configureCallback("off");
    %     count = 0;
    % end

    string_data = serial_port.readline();

    %*Verify the data's integrity*%
    if ~isValid(string_data)
        return;
    end

    data = sscanf(string_data, "S%f %f %f %f"); % x v theta w

    %*Verify the miss data*%
    if length(data) < 4
        return;
    end

    % count = count + 1;
    % % 
    % save_data = [save_data, data];
    serial_port.UserData.x = data(1);
    serial_port.UserData.v = data(2);
    serial_port.UserData.theta = data(3);
    serial_port.UserData.w = data(4);
end

function y = isValid(data)
    %*Get the first character of data, and check whether is the 'S' character*%
    y = extract(data, 1) == "S";
end

function handleSerial(serial_port, event)
    processRxSerialData(serial_port, event)
end


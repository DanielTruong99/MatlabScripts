function [t1, t2] = Timer(s, data_pool, animate_handles, axeses)
    t1 = timer('Name', 'DrawingTimer');
    t1.Period = 1/10;
    t1.ExecutionMode = 'fixedRate';
    t1.TimerFcn = {@handleTimer, data_pool, animate_handles, axeses, s};
    t1.start();
    
    t2 = timer('Name', 'ControllerTimer');
    t2.Period = 0.5;
    t2.ExecutionMode = 'fixedRate';
    t2.TimerFcn = {@handleTimer, data_pool, animate_handles, axeses, s};
    t2.start();
end



%% Function handle declaration
% Timer
function processDrawing(timer, event, data_pool, animate_handles, axeses)
    persistent start_time
    if isempty(start_time)
        start_time = datetime('now');
    end

    x = data_pool.x; v = data_pool.v; theta = data_pool.theta; w = data_pool.w;
    t =  datetime('now') - start_time;
    time_point = datenum(t);
    time_range = datenum([t-seconds(10) t]);

    addpoints(animate_handles(1), time_point, x);
    addpoints(animate_handles(2), time_point, v);
    addpoints(animate_handles(3), time_point, theta);
    addpoints(animate_handles(4), time_point, w);

    axeses(1).XLim = time_range;
    axeses(2).XLim = time_range;
    axeses(3).XLim = time_range;
    axeses(4).XLim = time_range;
    datetick(axeses(1), 'x','keeplimits');
    datetick(axeses(2), 'x','keeplimits');
    datetick(axeses(3), 'x','keeplimits');
    datetick(axeses(4), 'x','keeplimits');
    
    drawnow limitrate;
end

function processController(timer, event, data_pool, serial_port)
    persistent isCartInRange isPrevCartInRange isSafe stabilizer global_t
    if isempty(isCartInRange)
        isCartInRange = true;
    end

    if isempty(isPrevCartInRange)
        isPrevCartInRange = true;
    end

    if isempty(isSafe)
        isSafe = true;
    end    

    if isempty(stabilizer)
        % stabilizer = CartPoleController(); 
        stabilizer = MassController(); 
    end 

    if isempty(global_t)
        global_t = 0;
    end

    x = data_pool.x; v = data_pool.v; theta = data_pool.theta; w = data_pool.w;
    isCartInRange = x >= -0.42 & x <= 0.42; 
    % isSafe = isCartInRange & abs(sign(theta)*theta - pi) <= (pi/3);
    isSafe = isCartInRange;
    global_t = global_t + 1;

    if global_t > 10000
        global_t = 20;
    end

    if global_t < 20
        return
    end

    if isPrevCartInRange ~= isCartInRange
        if isCartInRange == false
            % The cart reach out the safe range, stop motor immediately!
            serial_port.writeline("S0");
            return;
        end

        isPrevCartInRange = isCartInRange;
    end

    if ~isSafe
        return
    end

    %All safe, then compute control input and send
    state = [theta; x; w; v];
    state_desired = [pi; 0; 0; 0];
    voltage = stabilizer.compute(state, state_desired);
    d = voltage * 0.0861 - 0.0104; 
    d = round(d * 1000);
    serial_port.writeline(sprintf("S%d", d));
end

function handleTimer(timer, event, data_pool, animate_handles, axeses, serial_port)
    if strcmp(timer.Name, 'DrawingTimer')
        processDrawing(timer, event, data_pool, animate_handles, axeses);

    elseif strcmp(timer.Name, 'ControllerTimer')
        processController(timer, event, data_pool, serial_port);
   
    end
end


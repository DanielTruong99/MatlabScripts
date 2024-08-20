classdef MassController < handle
    properties
        alpha; 
        inv_alpha;
        start_time;
        motor_parameters;
        i_term;
        % v_dot = motor_parameters(1) * v + motor_parameters(2) * u + motor_parameters(3) * sign(v)
    end

    methods
        function obj = MassController()
            obj.alpha = ((14 / 0.011) / 2.104);
            obj.inv_alpha = 1/obj.alpha;
            obj.start_time = -1;
            obj.motor_parameters = [-8.8262   -0.3713   -0.2154];
            obj.i_term = 0;
        end

        function y = calculateSin(obj, delta_t)
            y = 0.1 * sin(0.005*delta_t);
        end

        function y = calculateDerivativeSin(obj, delta_t)
            y = 0.1 * 0.005 * cos(0.005*delta_t);
        end

        function y = calculateSecondDerivativeSin(obj, delta_t)
            y = -0.1 * 0.005^2 * sin(0.005*delta_t);
        end

        function voltage = compute(obj, state, state_desired)
            if obj.start_time < 0
                obj.start_time = datenum(datetime('now'));
                delta_t = 0;
            else
                delta_t = datenum(datetime('now')) - obj.start_time;
            end

            x = state(2); v = state(4); 
            xd = obj.calculateSin(delta_t); 
            vd = obj.calculateDerivativeSin(delta_t); 
            ad = obj.calculateSecondDerivativeSin(delta_t);
            e_x = x - xd;
            e_v = v - vd;
            i_term = obj.i_term + 0.5 * e_x;
            tau = obj.inv_alpha * (- 20 * e_x + 0.01 * e_v + ad + 0.0001 * i_term);
            obj.i_term = i_term;
            v_dot = tau * (obj.alpha);      
            voltage = ( v_dot - obj.motor_parameters(1) * v - obj.motor_parameters(3) * sign(v) ) / obj.motor_parameters(2);
            
            if abs(voltage) > 12
                voltage = sign(voltage) * 12;
            end
            
            if abs(voltage) < 2.2
                voltage = sign(voltage) * 2.2;
            end
        end
    end
end
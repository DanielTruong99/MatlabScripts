classdef CartPoleController < handle
    properties
        K = [-0.0013   -0.00180/2   -0.0025   -0.0068];
        gamma = 1.7112e+03;
    end

    methods
        function obj = CartPoleController()

        end

        function voltage = compute(obj, state, state_desired)
            e = state - state_desired;
            tau = -obj.K * e;
            voltage = obj.gamma * tau;
            
            if abs(voltage) > 12
                voltage = sign(voltage) * 12;
            end

            if abs(voltage) < 4
                voltage = sign(voltage) * 4;
            end
        end
    end
end
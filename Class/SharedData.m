classdef SharedData < handle
    properties
        x;
        v;
        theta;
        w;
    end

    methods
        function obj = SharedData()
            obj.x = 0;
            obj.v = 0;
            obj.w = 0;
            obj.theta = 0;
        end
    end
end
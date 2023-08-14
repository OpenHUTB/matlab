classdef dummyCodeRegionSim < handle %#internal
% Keep track of number of region start and stop. Perform basic checks
% if input order is incorrect.

%   Copyright 2021 The MathWorks, Inc.
    properties
        timeElapsed;
    end

    methods
        function obj = dummyCodeRegionSim()
            tic;
        end

        function regionEnd(obj)
            obj.timeElapsed = toc;
        end
    end
end

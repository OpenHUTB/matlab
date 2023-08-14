classdef AddAssetsAndAnalyses %#codegen




    methods
        function obj=AddAssetsAndAnalyses
            coder.allowpcode('plain');
        end
    end

    methods(Static)
        sensors=conicalSensor(simulator,scenario,varargin)
        acs=access(source,varargin)
    end
end


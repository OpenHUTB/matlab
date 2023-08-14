classdef(ConstructOnLoad,Hidden)AxesToolbar<matlab.graphics.controls.AxesToolbar


    methods(Hidden)
        function obj=AxesToolbar(varargin)
            obj=obj@matlab.graphics.controls.AxesToolbar(varargin{:});
        end
    end
end
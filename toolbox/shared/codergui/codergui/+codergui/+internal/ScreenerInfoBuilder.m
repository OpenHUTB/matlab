classdef ScreenerInfoBuilder








    methods(Static)
        function result=build(varargin)
            result=coder.ScreenerInfo(varargin{:});
        end
    end
end

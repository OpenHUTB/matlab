classdef MSLValueException<MSLException





    properties
        paramValue='';
    end

    methods
        function obj=MSLValueException(value,varargin)
            obj@MSLException(varargin{:});
            obj.paramValue=value;
        end

        function out=getValue(obj)
            out=obj.paramValue;
        end
    end
end

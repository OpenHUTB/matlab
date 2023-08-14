classdef ErrorCalculator<handle




    methods(Abstract)
        result=calculate(approximateValue,trueValue,varargin)
    end
end
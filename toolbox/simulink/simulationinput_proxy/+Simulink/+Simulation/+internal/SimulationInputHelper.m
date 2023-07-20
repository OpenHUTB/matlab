classdef(Abstract)SimulationInputHelper
    methods(Abstract,Static)
        validateVariable(var,simInput)
        newValue=modifyVariableValue(varName,varValue,varExpr,exprValue)
        [varValue,varWasResolved]=getVariableValue(modelName,varName,varargin)
    end
end

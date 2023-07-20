


classdef DataSource<handle
    methods(Abstract)
        getDataDefaults(obj,modelingElementType,attributeName)
        setDataDefaults(obj,modelingElementType,varargin)
        getAllowedDataDefaultValues(obj,modelingElementType,attributeName)
        getFunctionDefaults(obj,modelFunction,attributeName)
        setFunctionDefaults(obj,modelFunction,varargin)
        getAllowedFunctionDefaultValues(obj,modelFunction,attributeName)
    end
end
classdef(Abstract)LoggingSpecificationImpl<handle
    properties(Abstract,SetAccess=private,GetAccess=public)
SignalsToLog
    end

    methods
        addSignalsToLog(obj,varargin)
        removeSignalsToLog(obj,sigs)
    end

    methods(Hidden=true)
        getSignalsToLog(obj,modelName)
    end
end
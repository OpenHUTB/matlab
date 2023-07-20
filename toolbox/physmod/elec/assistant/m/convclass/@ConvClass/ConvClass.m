classdef ConvClass<handle


    properties
SourceType
    end

    methods
        objSetPath(obj,varargin)
        objGetDropdown(obj,varargin)
        objGetParam(obj,varargin)
        out=objSetOutput(obj)
    end

    methods(Abstract)
        obj=objParamMappingDirect(obj)
        obj=objParamMappingDerived(obj)
        obj=objDropdownMapping(obj)
    end

    methods(Static)
        out=mapDirect(str,num)
        out=strictMonoArray(array)
    end

end






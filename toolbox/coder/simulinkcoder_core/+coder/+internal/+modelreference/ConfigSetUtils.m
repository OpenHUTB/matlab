


classdef ConfigSetUtils<handle
    properties(Access=private)
ConfigSet
    end



    methods(Access=public)
        function this=ConfigSetUtils(configSet)
            this.ConfigSet=configSet;
        end


        function paramValue=getParam(this,paramName)
            paramValue=get_param(this.ConfigSet,paramName);
        end
    end
end

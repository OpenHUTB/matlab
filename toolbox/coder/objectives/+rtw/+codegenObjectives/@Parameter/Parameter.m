classdef Parameter<handle




    properties(SetAccess=public)
name
value
    end

    methods
        function param=Parameter(name,setting,~,toValidate)


            if nargin<4
                toValidate=true;
            end

            if toValidate&&~param.isValidParam(name)
                throw(MSLException([],message(...
                'Simulink:tools:invalidCSParameterError',name)));
            end

            param.name=name;
            param.value=setting;
        end
    end

    methods(Static=true)
        function out=isValidParam(name)
            name=convertStringsToChars(name);
            out=isValidParam(configset.internal.getConfigSetStaticData,name);
        end
    end
end

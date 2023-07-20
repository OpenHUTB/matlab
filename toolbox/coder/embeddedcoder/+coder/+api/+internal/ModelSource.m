


classdef ModelSource<coder.api.internal.DataSource
    properties
modelH
configSet
    end
    methods
        function obj=ModelSource(modelH,configSet)
            obj.modelH=modelH;
            obj.configSet=configSet;
        end
    end
    methods
        function attribValue=getDataDefaults(obj,modelingElementType,...
            attributeName)
            attribValue=coder.api.internal.getDataDefaults(...
            obj.modelH,modelingElementType,...
            attributeName);
        end
        function setDataDefaults(obj,modelingElementType,argParser)
            coder.api.internal.setDataDefaults(obj.modelH,modelingElementType,...
            argParser);
        end
        function allowedValues=getAllowedDataDefaultValues(obj,modelingElementType,...
            attributeName)
            allowedValues=coder.api.internal.getAllowedDataDefaultValues(...
            obj.modelH,modelingElementType,attributeName);
        end

        function attribValue=getFunctionDefaults(obj,modelFunction,attributeName)
            attribValue=coder.api.internal.getFunctionDefaults(...
            obj.modelH,modelFunction,attributeName);
        end
        function setFunctionDefaults(obj,modelFunction,argParser)
            coder.api.internal.setFunctionDefaults(obj.modelH,modelFunction,...
            argParser);
        end
        function allowedValues=getAllowedFunctionDefaultValues(obj,modelFunction,attributeName)
            allowedValues=coder.api.internal.getAllowedFunctionDefaultValues(...
            obj.modelH,modelFunction,attributeName);
        end
    end
end
classdef TimerService<coder.preview.internal.ServiceInterface




    methods
        function obj=TimerService(sourceDD,type,name)

            obj@coder.preview.internal.ServiceInterface(sourceDD,type,name);
        end

        out=getDeclaration(obj)
        out=getUsage(obj)
    end


    methods
        function out=getFunctionClockTickFunction(obj)

            out=obj.getFunctionPrototypeFromPropertyNames('uint32',...
            "FunctionClockTickFunctionName");
        end

        function out=getFunctionPrototypeFromPropertyNames(obj,returnType,namingRuleFieldName)

            typePreview=coder.preview.internal.Type(returnType);
            name=obj.getFunctionName(obj.getProperty(namingRuleFieldName));
            out=obj.getFunctionPrototype(typePreview.getPreview,name);
        end
    end
end

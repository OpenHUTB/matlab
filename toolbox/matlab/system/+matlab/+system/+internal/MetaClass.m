classdef MetaClass<handle&matlab.mixin.internal.indexing.Paren




    properties(SetAccess=private)
ClassName
    end

    properties(Access=private)
pMetaClass
pExternalSerialNumber
    end

    methods
        function obj=MetaClass(className)
            obj.setup(className);
        end

        function v=iscurrent(obj)
            mc=obj.pMetaClass;
            v=~isempty(mc)&&isvalid(mc)&&...
            isequal(obj.pExternalSerialNumber,getExternalSerialNumber(mc));
        end

        function v=parenReference(obj,className)


            if nargin<2
                className=obj.ClassName;
            end


            if~strcmp(className,obj.ClassName)||~obj.iscurrent
                obj.setup(className);
            end


            v=obj.pMetaClass;
        end
    end

    methods(Access=private)
        function setup(obj,className)
            mc=meta.class.fromName(className);
            validateAssociatedClasses(mc);
            obj.ClassName=className;
            obj.pMetaClass=mc;
            obj.pExternalSerialNumber=getExternalSerialNumber(mc);
        end
    end
end

classdef TaskSchema<swarch.internal.propertyinspector.SoftwareElementPropertySchema

    methods
        function this=TaskSchema(studio,task)
            this=this@swarch.internal.propertyinspector.SoftwareElementPropertySchema(studio,task);
        end


        function typeStr=getObjectType(~)
            typeStr='Task';
        end


        function setPrototypableName(this,value)
            this.getPrototypable().taskName=value;
        end


        function name=getPrototypableName(this)
            name=this.getPrototypable().taskName;
        end
    end
end

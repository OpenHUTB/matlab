classdef CodeDescriptorCache<handle





    properties(Access=private)
        ModelName2CodeDescMap;
    end
    methods
        function this=CodeDescriptorCache()
            this.ModelName2CodeDescMap=containers.Map();
        end

        function codeDescObj=getRefModelCodeDescriptor(this,modelName,parentModelCodeDesc)
            assert(isa(parentModelCodeDesc,'coder.codedescriptor.CodeDescriptor'),...
            'Expect a code descriptor object as the parent model');

            parentModelName=parentModelCodeDesc.ModelName;

            if~isKey(this.ModelName2CodeDescMap,parentModelName)
                this.ModelName2CodeDescMap(parentModelName)=parentModelCodeDesc;
            end


            if isKey(this.ModelName2CodeDescMap,modelName)
                codeDescObj=this.ModelName2CodeDescMap(modelName);
            else
                codeDescObj=parentModelCodeDesc.getReferencedModelCodeDescriptor(modelName);
                this.ModelName2CodeDescMap(modelName)=codeDescObj;
            end
        end
    end
end



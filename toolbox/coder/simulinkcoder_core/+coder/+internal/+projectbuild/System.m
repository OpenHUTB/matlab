classdef(Hidden)System<handle






    properties(SetAccess=immutable)

        Name;
    end

    properties(SetAccess=private)

        Models;


        ComponentRootModels;


        ComponentChildModels;
    end

    properties(Access=private)
        ModelTypeMapping;
    end

    methods
        function value=get.Models(this)
            value=this.ModelTypeMapping(uint32(coder.internal.projectbuild.SystemModelType.SystemLevel));
        end

        function value=get.ComponentRootModels(this)
            value=this.ModelTypeMapping(uint32(coder.internal.projectbuild.SystemModelType.ComponentRoot));
        end

        function value=get.ComponentChildModels(this)
            value=this.ModelTypeMapping(uint32(coder.internal.projectbuild.SystemModelType.ComponentChild));
        end


        function this=System(name)
            this.Name=name;

            this.ModelTypeMapping=containers.Map('KeyType','uint32','ValueType','any');
            this.ModelTypeMapping(uint32(coder.internal.projectbuild.SystemModelType.SystemLevel))={};
            this.ModelTypeMapping(uint32(coder.internal.projectbuild.SystemModelType.ComponentRoot))={};
            this.ModelTypeMapping(uint32(coder.internal.projectbuild.SystemModelType.ComponentChild))={};
        end



        function type=getModelType(this,model)

            if any(strcmp(model,this.Models))
                type=coder.internal.projectbuild.SystemModelType.SystemLevel;
            elseif any(strcmp(model,this.ComponentRootModels))
                type=coder.internal.projectbuild.SystemModelType.ComponentRoot;
            elseif any(strcmp(model,this.ComponentChildModels))
                type=coder.internal.projectbuild.SystemModelType.ComponentChild;
            else
                type=coder.internal.projectbuild.SystemModelType.None;
            end
        end



        function addModel(this,model,modelType)

            if~this.ModelTypeMapping.isKey(uint32(modelType))
                assert(false,'Unrecognized model type for Simulink System add.');
            end

            models=this.ModelTypeMapping(uint32(modelType));
            models{end+1}=model;
            this.ModelTypeMapping(uint32(modelType))=models;
        end


        function removeModel(this,model)
            this.removeModelFrom(model,coder.internal.projectbuild.SystemModelType.SystemLevel);
            this.removeModelFrom(model,coder.internal.projectbuild.SystemModelType.ComponentRoot);
            this.removeModelFrom(model,coder.internal.projectbuild.SystemModelType.ComponentChild);
        end
    end

    methods(Access=private)
        function removeModelFrom(this,model,modelType)
            models=this.ModelTypeMapping(uint32(modelType));
            models(strcmp(model,models))=[];
            this.ModelTypeMapping(uint32(modelType))=models;
        end
    end
end



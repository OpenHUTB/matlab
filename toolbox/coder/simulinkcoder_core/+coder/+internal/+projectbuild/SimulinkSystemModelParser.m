classdef(Hidden)SimulinkSystemModelParser<handle






    properties(Access=private)
        ProjectData coder.internal.projectbuild.ProjectData;
        Model;
        ModelsToAssign={};
        SerializationStep coder.internal.projectbuild.SystemModelType;
        OverwriteExistingData logical;
        SystemData coder.internal.projectbuild.System;
        SystemName;

        CompletedModels={};
    end

    methods
        function parse(this,model,projectData,modelType,systemName,overwrite)
            this.Model=model;
            this.ProjectData=projectData;
            this.OverwriteExistingData=overwrite;
            this.SystemName=systemName;
            this.SystemData=coder.internal.projectbuild.System.empty();
            this.CompletedModels={};





            this.excutesStep(modelType);
        end
    end

    methods(Access=private)
        function excutesStep(this,step)
            import coder.internal.projectbuild.SystemModelType
            import coder.internal.projectbuild.isModelInSystem

            this.SerializationStep=step;

            switch this.SerializationStep
            case SystemModelType.SystemLevel



                this.ModelsToAssign={this.Model};


                nextStep=SystemModelType.ComponentRoot;
            case SystemModelType.ComponentRoot





                if isempty(this.CompletedModels)
                    this.ModelsToAssign={this.Model};
                else


                    this.ModelsToAssign=find_mdlrefs(this.Model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',false);



                    this.ModelsToAssign(end)=[];
                end


                nextStep=SystemModelType.ComponentChild;
            case SystemModelType.ComponentChild






                allMdlRefs=find_mdlrefs(this.Model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',true);
                this.ModelsToAssign=setxor(allMdlRefs,this.CompletedModels);


                nextStep=SystemModelType.None;
            case SystemModelType.None
                return;
            otherwise
                assert(false,'Unrecognized system model type for system meta-data.');
            end




            if~this.OverwriteExistingData

                this.removePreAssignedModels();
                if isempty(this.ModelsToAssign)
                    return;
                end
            end

            this.setSystemData();
            this.setModelData();

            this.excutesStep(nextStep);
        end

        function setModelData(this)
            cellfun(@(m)this.assignModelType(m,this.SerializationStep),...
            this.ModelsToAssign);
        end

        function removePreAssignedModels(this)
            import coder.internal.projectbuild.isModelInSystem
            this.ModelsToAssign(cellfun(@(m)isModelInSystem(this.ProjectData,m),this.ModelsToAssign))=[];
        end

        function assignModelType(this,model,modelType)
            import coder.internal.projectbuild.SystemModelType
            import coder.internal.projectbuild.isModelInSystem

            [~,system,type]=isModelInSystem(this.ProjectData,model);

            this.CompletedModels{end+1}=model;

            if modelType==type&&strcmp(system.Name,this.SystemData.Name)


                return;
            end



            if type~=SystemModelType.None
                system.removeModel(model);
            end


            this.SystemData.addModel(model,modelType);
        end

        function setSystemData(this)

            if~isempty(this.SystemData)
                return;
            end




            this.SystemData=this.ProjectData.getSystemData(this.SystemName);



            if isempty(this.SystemData)
                this.SystemData=coder.internal.projectbuild.System(this.SystemName);
                this.ProjectData.Systems(end+1)=this.SystemData;
            end
        end
    end
end



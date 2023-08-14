classdef ProjectSerializer<handle






    properties(Access=private,Constant)
        SystemCategory='System';
        ModelTypeCategory='System Model Type';
    end

    properties(GetAccess=private,SetAccess=immutable)
        Data coder.internal.projectbuild.ProjectData;
    end

    methods


        function this=ProjectSerializer(projectData)
            this.Data=projectData;
        end




        function serialize(this,projectManager)
            import coder.internal.projectbuild.ProjectSerializer

            this.validateSimulinkProject(projectManager);
            if isempty(projectManager.findCategory(ProjectSerializer.SystemCategory))
                projectManager.createCategory(ProjectSerializer.SystemCategory);
            end

            if isempty(projectManager.findCategory(ProjectSerializer.ModelTypeCategory))
                projectManager.createCategory(ProjectSerializer.ModelTypeCategory);
            end



            systemCategory=projectManager.findCategory(ProjectSerializer.SystemCategory);
            systemLabels=systemCategory.LabelDefinitions;
            modelLabels=projectManager.findCategory(ProjectSerializer.ModelTypeCategory).LabelDefinitions;

            for i=1:length(projectManager.Files)
                file=projectManager.Files(i);
                arrayfun(@(l)file.removeLabel(l),modelLabels);
                arrayfun(@(l)file.removeLabel(l),systemLabels);
            end

            arrayfun(@(l)systemCategory.removeLabel(l.Name),systemCategory.LabelDefinitions);

            for i=1:length(this.Data.Systems)
                systemData=this.Data.Systems(i);
                cellfun(@(m)this.addDataToProject(projectManager,m,systemData.Name,...
                coder.internal.projectbuild.SystemModelType.SystemLevel),...
                systemData.Models);

                cellfun(@(m)this.addDataToProject(projectManager,m,systemData.Name,...
                coder.internal.projectbuild.SystemModelType.ComponentRoot),...
                systemData.ComponentRootModels);

                cellfun(@(m)this.addDataToProject(projectManager,m,systemData.Name,...
                coder.internal.projectbuild.SystemModelType.ComponentChild),...
                systemData.ComponentChildModels);
            end
        end




        function deserialize(this,projectManager)
            import coder.internal.projectbuild.ProjectSerializer

            this.validateSimulinkProject(projectManager);


            this.Data.Systems=coder.internal.projectbuild.System.empty();

            files=projectManager.Files;



            systemCategory=projectManager.findCategory(ProjectSerializer.SystemCategory);


            if isempty(systemCategory)
                return;
            end



            simulinkSystemNames={systemCategory.LabelDefinitions.Name};
            for i=1:length(simulinkSystemNames)

                this.Data.Systems(end+1)=coder.internal.projectbuild.System(simulinkSystemNames{i});
            end


            for i=1:length(files)
                file=files(i);


                [~,isModel]=sls_resolvename(file.Path);
                if~isModel
                    continue;
                end



                fileSimulinkSystemInfo=file.Labels(strcmp(ProjectSerializer.SystemCategory,{file.Labels.CategoryName}));




                if~isempty(fileSimulinkSystemInfo)
                    simulinkSystem=this.Data.Systems(strcmp(fileSimulinkSystemInfo.Name,{this.Data.Systems.Name}));
                    type=file.Labels(strcmp(ProjectSerializer.ModelTypeCategory,{file.Labels.CategoryName}));

                    [~,mdlName]=fileparts(file.Path);

                    if isempty(type)



                        modelType=coder.internal.projectbuild.SystemModelType.ComponentChild;
                    else
                        modelType=coder.internal.projectbuild.SystemModelType(type.Name);
                    end

                    simulinkSystem.addModel(mdlName,modelType);
                end
            end
        end
    end

    methods(Access=private)
        function validateSimulinkProject(~,projectManager)

            validateattributes(projectManager,{'slproject.ProjectManager'},{'size',[1,1]});

            assert(projectManager.isLoaded,['The project ',projectManager.RootFolder,' is not currently loaded']);
        end

        function addDataToProject(~,project,model,systemName,modelType)
            import coder.internal.projectbuild.ProjectSerializer
            import coder.internal.projectbuild.projectContainsModel

            [inProject,file]=projectContainsModel(project,model);

            if~inProject


                return;
            end

            file.addLabel(ProjectSerializer.SystemCategory,systemName);

            if modelType==coder.internal.projectbuild.SystemModelType.SystemLevel||...
                modelType==coder.internal.projectbuild.SystemModelType.ComponentRoot
                file.addLabel(ProjectSerializer.ModelTypeCategory,modelType.char());
            end
        end
    end
end



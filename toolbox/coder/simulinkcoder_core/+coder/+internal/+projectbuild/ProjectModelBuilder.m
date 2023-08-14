classdef(Hidden)ProjectModelBuilder<coder.internal.projectbuild.Builder








    properties(GetAccess=private,SetAccess=immutable)
        Project slproject.ProjectManager;
    end

    methods


        function this=ProjectModelBuilder(project,model)
            this@coder.internal.projectbuild.Builder(model);
            this.Project=project;
        end


        function build(this)

            Simulink.output.info(message('RTW:buildProcess:projectBuildStart',this.Project.Name).getString());


            systemDefinition=coder.internal.projectbuild.ProjectData(this.Project);



            if~coder.internal.projectbuild.projectContainsModel(this.Project,this.Model)
                DAStudio.error('RTW:buildProcess:projectBuildNoContainModel',this.Project.Name,this.Model);
            end


            mdlsToClose=slprivate('load_model',this.Model);
            this.CleanupStack{end+1}=@()slprivate('close_models',mdlsToClose);

            builder=coder.internal.projectbuild.createBuilder(this.Model,systemDefinition);
            builder.build();

            Simulink.output.info(message('RTW:buildProcess:projectBuildEndSuccess',this.Project.Name).getString());
        end
    end
end
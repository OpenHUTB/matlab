classdef(Abstract,Hidden)SystemBuilder<coder.internal.projectbuild.Builder






    properties(Access=protected)
        ProjectData coder.internal.projectbuild.ProjectData;
    end

    methods(Access=protected)


        modelsToBuild=getModelsToBuild(this);

        function this=SystemBuilder(model,projectData)
            this@coder.internal.projectbuild.Builder(model);
            this.ProjectData=projectData;
        end



        function onSystemBuildStart(~)
        end



        function onSystemBuildFinish(~)
        end



        function onModelBuildStart(this,model)%#ok<INUSD>
        end



        function onModelBuildFinish(this,model)%#ok<INUSD>
        end
    end

    methods
        function build(this)


            this.onSystemBuildStart();

            modelsToBuild=this.getModelsToBuild();
            nModels=length(modelsToBuild);

            for i=1:nModels
                model=modelsToBuild{i};

                if this.isProtectedModel(model)

                    continue;
                end


                mdlsToClose=slprivate('load_model',model);
                this.CleanupStack{end+1}=@()slprivate('close_models',mdlsToClose);


                this.onModelBuildStart(model);


                builder=coder.internal.projectbuild.createBuilder(model,this.ProjectData);
                builder.build();


                this.onModelBuildFinish(model);
            end

            this.onSystemBuildFinish();
        end
    end

    methods(Access=private)
        function isProtected=isProtectedModel(~,model)
            [~,~,ext]=fileparts(which(model));
            isProtected=ismember(ext,{'slxp','mdlp'});
        end
    end
end



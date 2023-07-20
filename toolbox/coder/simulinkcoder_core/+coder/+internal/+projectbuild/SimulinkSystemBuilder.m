classdef(Hidden)SimulinkSystemBuilder<coder.internal.projectbuild.SystemBuilder





    properties(GetAccess=private,SetAccess=immutable)
        System coder.internal.projectbuild.System;
    end

    methods


        function this=SimulinkSystemBuilder(model,projectData,system)
            this@coder.internal.projectbuild.SystemBuilder(model,projectData);
            this.System=system;
        end
    end

    methods(Access=protected)

        function modelsToBuild=getModelsToBuild(this)








            modelRefs=find_mdlrefs(this.Model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',0);

            modelRefs(end)=[];



            modelCandidates=unique([this.System.Models,this.System.ComponentRootModels]);



            modelsToBuild=intersect(modelRefs,modelCandidates);
        end

        function onSystemBuildStart(this)
            Simulink.output.info(message('RTW:buildProcess:systemBuildStart',this.Model,this.System.Name).getString());
        end

        function onSystemBuildFinish(this)
            Simulink.output.info(message('RTW:buildProcess:systemBuildEndSuccess',this.Model,this.System.Name).getString());
        end
    end
end

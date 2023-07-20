







classdef SystemCompileCloneDetection<slEnginePir.CloneDetection
    properties(Access='public')
        compiled;
        bd;
    end
    methods(Access='public')
        function this=SystemCompileCloneDetection(mdl,clonepattern,enableClonesAnywhere,includeMdl,includeLib,ignoreSignalName,ignoreBlockProperty)
            if nargin<2
                clonepattern='StructuralParameters';
            end
            if nargin<3
                enableClonesAnywhere=false;
            end
            if nargin<4
                includeMdl=true;
            end
            if nargin<5
                includeLib=true;
            end
            if nargin<6
                ignoreSignalName=true;
            end
            if nargin<7
                ignoreBlockProperty=true;
            end

            this@slEnginePir.CloneDetection(mdl,enableClonesAnywhere,'off',includeMdl,includeLib);
            this.genmodelprefix=[slEnginePir.util.Constants.BackupModelPrefix,'_'];
            this.clonepattern=clonepattern;

            sess=Simulink.CMI.CompiledSession(Simulink.EngineInterfaceVal.byFiat);
            this.bd=Simulink.CMI.CompiledBlockDiagram(sess,this.mdlName);
            wstate=warning('QUERY','BACKTRACE');
            warning('OFF','BACKTRACE');
            ME=MException('','');
            try
                this.bd.init;
            catch ME
                warning(wstate);
                DAStudio.error('sl_pir_cpp:creator:UnsimulatableModel',this.mdlName);
            end

            this.creator=this.computeChecksumAndGroupClones(unique([{this.sysFullName},this.refModels],'stable'),clonepattern,'CompiledDomain',ignoreSignalName,ignoreBlockProperty);
            warning(wstate);
            this.compiled=-1;
        end

        function result=identify_clones(this,exclusionList,threshold)
            if nargin<2
                exclusionList=[];
                threshold=50;
            end

            if nargin<3
                threshold=50;
            end

            if this.compiled<0
                this.bd.term;
                this.compiled=0;
            end
            result=this.identifyClones(exclusionList,threshold);

        end

        function result=replace_clones(this,libname,genmodel_prefix)

            mdls={this.mdlName};
            mdls=[mdls,this.refModels,this.libmdls];
            explicitlyLoadedModels=slEnginePir.modelChanged(mdls);
            this.loadedModels=[this.loadedModels;explicitlyLoadedModels];

            if nargin<=1
                libname='functionalCloneLibFile';
            end

            if strcmp(this.clonepattern,'StructuralParameters')
                this.libraryblockcolor='green';
            else
                this.libraryblockcolor='Magenta';
            end

            if nargin>2
                [result,explicitlyLoadedModels]=...
                slEnginePir.CloneRefactor.replaceClones(this,libname,genmodel_prefix);
            else
                [result,explicitlyLoadedModels]=...
                slEnginePir.CloneRefactor.replaceClones(this,libname);
            end

            this.loadedModels=[this.loadedModels;explicitlyLoadedModels];
        end
    end
end



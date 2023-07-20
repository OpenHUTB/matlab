classdef(Sealed)BuildExampleSLXC<handle





    properties(GetAccess=private,SetAccess=private)
AppName
TopModel
RelCacheDir
FileGenConfig
Model
ModelRefs
ModelGraph
ModelBuildFolder
StartupFolder
ModelSkipper
    end

    methods(Access=public)
        function this=BuildExampleSLXC(appName,topModel,relCacheDir,startupFolder,skipper)
            this.AppName=appName;
            this.TopModel=topModel;
            this.RelCacheDir=relCacheDir;
            this.FileGenConfig=Simulink.fileGenControl('getConfig');
            this.ModelRefs={};
            this.ModelGraph=[];
            this.ModelBuildFolder='';
            this.Model='';
            this.StartupFolder=startupFolder;
            this.ModelSkipper=skipper;
        end

        function build(this)
            try
                this.getListOfModelRefs();



                this.copySLXCFilesToCacheFolder();

                this.buildAllModelRefs();
            catch ME


                disp(ME.message);
                disp('Removing slprj and cache files and trying the build again');


                this.cleanupCacheFolder();
                this.ModelSkipper.disable();

                this.buildAllModelRefs();
            end

            this.archiveCacheFiles();

            proj=simulinkproject;
            proj.close;

        end
    end

    methods(Access=private)


        function getListOfModelRefs(this)
            argList={this.TopModel,'KeepModelsLoaded',true,...
            'ReturnTopModelAsLastElement',false,...
            'MatchFilter',@Simulink.match.allVariants};
            [this.ModelRefs,~,this.ModelGraph]=find_mdlrefs(argList{:});
        end



        function copySLXCFilesToCacheFolder(this)
            copyExampleCacheFiles(this.AppName,this.RelCacheDir,...
            "ModelRefs",this.ModelRefs);
        end


        function cleanupCacheFolder(this)
            cf=this.FileGenConfig.CacheFolder;
            cgf=this.FileGenConfig.CodeGenFolder;


            workDirs=unique({cf,cgf});
            for i=1:length(workDirs)
                workDir=fullfile(workDirs{i},'slprj');
                if isfolder(workDir)
                    rmdir(workDir,'s');
                end
            end


            delete(fullfile(cf,...
            Simulink.packagedmodel.constructPackagedFile('*')));


            clear mex;%#ok<CLMEX>
            delete(fullfile(cf,['*.',mexext]));
        end

        function buildAllModelRefs(this)

            cellfun(@(model)this.buildModel(model),this.ModelRefs);





            set_param(this.TopModel,'ModelRefSimModeOverrideType','AllAccel');
            c=onCleanup(@()set_param(this.TopModel,'ModelRefSimModeOverrideType','None'));

            set_param(this.TopModel,'UpdateModelReferenceTargets','IfOutOfDate');
            set_param(this.TopModel,'EnableParallelModelReferenceBuilds','off');
            set_param(this.TopModel,'Dirty','off');
            set_param(this.TopModel,'SimulationCommand','update');
        end




        function buildModel(this,model)


            this.Model=model;

            if this.ModelSkipper.skip(this.Model)
                return;
            end
            models=this.getModelRefsFromGraph();
            this.ModelSkipper.skipChildren(this.Model,models);

            oc1=onCleanup(@()Simulink.fileGenControl('setConfig',...
            'config',this.FileGenConfig));

            this.setupModelBuildFolder();
            oc2=onCleanup(@()rmdir(this.ModelBuildFolder,'s'));

            this.copySLXCFilesToModelBuildFolder(models);


            set_param(model,'UpdateModelReferenceTargets','IfOutOfDateOrStructuralChange');
            set_param(model,'EnableParallelModelReferenceBuilds','off');
            set_param(model,'Dirty','off');
            slbuild(model,'ModelReferenceSimTarget');

            this.ModelSkipper.addModel(model);


            copyfile(fullfile(this.ModelBuildFolder,...
            Simulink.packagedmodel.constructPackagedFile(this.Model)),...
            this.FileGenConfig.CacheFolder);

            clear mex;%#ok<CLMEX>
            oc1.delete();
            oc2.delete();
        end

        function setupModelBuildFolder(this)

            baseDir=['td_',this.Model];
            this.ModelBuildFolder=fullfile(this.StartupFolder,baseDir);


            if isfolder(this.ModelBuildFolder)
                rmdir(this.ModelBuildFolder,'s');
            end
            mkdir(this.ModelBuildFolder);


            aFGC=this.FileGenConfig.copy;
            aFGC.CacheFolder=this.ModelBuildFolder;
            aFGC.CodeGenFolder=this.ModelBuildFolder;
            Simulink.fileGenControl('setConfig','config',aFGC);
        end



        function copySLXCFilesToModelBuildFolder(this,models)

            for i=1:numel(models)
                slxcFile=fullfile(this.FileGenConfig.CacheFolder,...
                Simulink.packagedmodel.constructPackagedFile(models{i}));
                if~isfile(slxcFile)
                    continue;
                end
                copyfile(slxcFile,this.ModelBuildFolder);
            end
        end



        function models=getModelRefsFromGraph(this)
            diGraph=this.ModelGraph.getGraphObject();


            info=table2struct(diGraph.Nodes(:,{'Data','ID'}));
            data=[info.Data];
            id=[info.ID];
            names={data.Name};


            modelID=id(strcmp(names,this.Model));


            vertices=diGraph.dfsearch(modelID);
            [~,ind]=intersect(id,vertices);
            models=names(ind);
        end

        function archiveCacheFiles(this)
            cacheLeafFolder=Simulink.ModelReference.getSLXCCacheLeafFolder();





            assert(~isempty(cacheLeafFolder));

            slxcTargetDir=fullfile(this.RelCacheDir,cacheLeafFolder);




            oldTargetDir=fullfile(this.RelCacheDir,this.AppName);
            if isfolder(oldTargetDir)
                rmdir(oldTargetDir,'s');
            end


            if~isfolder(slxcTargetDir)
                mkdir(slxcTargetDir);
            end

            for i=1:numel(this.ModelRefs)
                slxcSourceFile=fullfile(this.FileGenConfig.CacheFolder,...
                Simulink.packagedmodel.constructPackagedFile(this.ModelRefs{i}));

                copyfile(slxcSourceFile,slxcTargetDir,'f');
            end

            this.storeModelRefsList(slxcTargetDir);
        end


        function storeModelRefsList(this,slxcTargetDir)
            jsonFile=fullfile(slxcTargetDir,[this.AppName,'.json']);


            if isfile(jsonFile)
                oldModelRefs=jsondecode(fileread(jsonFile));
            else
                oldModelRefs={};
            end
            if~isequal(this.ModelRefs,oldModelRefs)
                jsNewContents=jsonencode(this.ModelRefs);

                jsNewContents=regexprep(jsNewContents,'(,|])',['$1',newline]);
                fid=fopen(jsonFile,'w','native','utf8');
                fprintf(fid,jsNewContents);
                fclose(fid);
            end

        end
    end
end

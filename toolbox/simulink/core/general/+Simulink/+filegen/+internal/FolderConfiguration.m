classdef(Hidden)FolderConfiguration<Simulink.filegen.internal.FolderSpecification&matlab.mixin.Copyable
















    properties(Access=private)
        Tokens;
    end

    properties(SetAccess=private)
        ModelName;
        CodeGenFolderStructure;

        IsModelRefSim=false;
    end

    methods(Hidden,Static)





        function folders=getCachedConfig(model)

            buildFolderCache=Simulink.filegen.internal.BuildFolderCache.getInstance();
            folders=buildFolderCache.getFoldersFor(model);

            if isempty(folders)
                folders=Simulink.filegen.internal.FolderConfiguration(model);
            end
        end





        function updateCache(model)
            import Simulink.filegen.internal.FolderConfiguration


            Simulink.filegen.internal.BuildFolderCache.clear(model);


            FolderConfiguration(model);
        end


        function clearCache()
            Simulink.filegen.internal.BuildFolderCache.clear();
        end







        function copyCacheFrom(fromModel,toModel)

            folders=Simulink.filegen.internal.FolderConfiguration.getCachedConfig(fromModel);

            newFolders=folders.copyAndUpdateModelName(toModel);

            cache=Simulink.filegen.internal.BuildFolderCache.getInstance();
            cache.addFoldersFor(newFolders.ModelName,newFolders);
        end



        function folders=forSpecifiedSTFAndHardware(modelName,stf,hardwareDevice,codeGenFolderStructureString)



            if nargin<4
                codeGenFolderStructure=Simulink.fileGenControl('get','CodeGenFolderStructure');
            else
                codeGenFolderStructure=Simulink.filegen.CodeGenFolderStructure.fromString(codeGenFolderStructureString);
            end
            if nargin<3
                isProtected=Simulink.filegen.internal.Helpers.isProtectedModel(modelName);
                if~isProtected&&~bdIsLoaded(modelName)
                    load_system(modelName);
                    modelCl=onCleanup(@()close_system(modelName));
                end
                tokens=Simulink.filegen.internal.FolderSpecificationTokens(modelName,isProtected,true,stf);
            else
                tokens=Simulink.filegen.internal.FolderSpecificationTokens(modelName,[],true,stf,hardwareDevice);
            end

            folders=Simulink.filegen.internal.FolderConfiguration(modelName,false,false);
            folders.Tokens=tokens;
            folders.setFolderValues(codeGenFolderStructure);
        end
    end

    methods





        function this=FolderConfiguration(model,loadModel,useCache)
            import Simulink.filegen.internal.Helpers
            import Simulink.filegen.internal.FolderConfiguration



            this.ModelName=Helpers.getDirectoryModelName(model);

            if nargin<3
                useCache=true;
            end


            if nargin<2
                loadModel=true;
            end






            if useCache
                cache=Simulink.filegen.internal.BuildFolderCache.getInstance();
                folders=cache.getFoldersFor(this.ModelName);



                if~isempty(folders)&&...
                    ~isequal(folders.CodeGenFolderStructure,char(Simulink.fileGenControl('get','CodeGenFolderStructure')))
                    Simulink.filegen.internal.FolderConfiguration.clearCache();
                    folders=FolderConfiguration.empty;
                end
            else
                folders=FolderConfiguration.empty;
            end

            if~bdIsLoaded(this.ModelName)&&~isempty(folders)


                this.Tokens=Simulink.filegen.internal.FolderSpecificationTokens(this.ModelName,false,false);

                if this.Tokens.isSubsetOf(folders.Tokens)
                    this=folders;
                    return
                end
            end






            isProtected=Helpers.isProtectedModel(this.ModelName);

            if(loadModel&&~bdIsLoaded(this.ModelName))&&~isProtected

                if exist(this.ModelName,'file')~=4
                    DAStudio.error('Simulink:FileGen:ModelNotFound',this.ModelName);
                end

                load_system(this.ModelName);
                modelCl=onCleanup(@()close_system(this.ModelName));
            end

            resolveLoadDependentTokens=Helpers.canAccessConfigSet(this.ModelName,isProtected);




            if resolveLoadDependentTokens



                if~isProtected
                    currConfigSet=getActiveConfigSet(this.ModelName);

                    if isa(currConfigSet,'Simulink.ConfigSetRef')
                        if currConfigSet.SourceResolved=="off"||currConfigSet.UpToDate=="off"
                            currConfigSet.refresh;
                        end
                    end
                end

                stf=Helpers.getCachedOrOriginalSystemTargetFile(this.ModelName,isProtected);

                if strcmp(stf,'modelrefsim.tlc')
                    this.setModelRefSimFolderValues();
                    return;
                end
            else
                stf='';
            end

            this.Tokens=Simulink.filegen.internal.FolderSpecificationTokens(this.ModelName,isProtected,resolveLoadDependentTokens,stf);




            if~isempty(folders)

                if~isempty(folders.Tokens)&&this.Tokens.isSubsetOf(folders.Tokens)
                    this=folders;
                    this.addFoldersForMultiInstanceModelRefCopy(model);
                    return
                end
            end

            this.setFolderValues();

            if useCache
                cache.addFoldersFor(this.ModelName,this);
                this.addFoldersForMultiInstanceModelRefCopy(model);
            end
        end



        function folders=getFolderSetFor(this,mdlReferenceTargetType)

            switch mdlReferenceTargetType
            case{'SIM','SIM-ACCEL'}
                folders=this.Simulation;
            case 'RTW'
                folders=this.CodeGeneration;
            case 'NONE'


                if slprivate('isSimulationBuild',this.ModelName,mdlReferenceTargetType)
                    folders=this.Simulation;
                else
                    folders=this.CodeGeneration;
                end
            otherwise
                DAStudio.error('RTW:buildProcess:unknownModelRefTargetType',mdlReferenceTargetType);
            end
        end




        function newFolders=copyAndUpdateModelName(this,modelName)
            newFolders=copy(this);



            if~isempty(newFolders.Tokens)
                newFolders.Tokens.replaceTokenValue('$(NODEID)','');
            end

            newFolders.ModelName=modelName;

            if newFolders.IsModelRefSim
                newFolders.setModelRefSimFolderValues();
            else
                newFolders.Tokens.replaceTokenValue('$(MODELNAME)',modelName);
                newFolders.setFolderValues();
            end
        end
    end

    methods(Access=private)
        function setModelRefSimFolderValues(this)
            spec=Simulink.filegen.internal.Helpers.getModelRefSimFolderSpecification(this.ModelName);

            this.Simulation=spec.Simulation;
            this.CodeGeneration=spec.CodeGeneration;
            this.HDLGeneration=spec.HDLGeneration;
            this.Accelerator=spec.Accelerator;
            this.RapidAccelerator=spec.RapidAccelerator;

            this.IsModelRefSim=true;
        end

        function addFoldersForMultiInstanceModelRefCopy(this,model)
            if~strcmp(model,this.ModelName)




                cache=Simulink.filegen.internal.BuildFolderCache.getInstance();
                cache.addFoldersFor(model,this);
            end
        end

        function setFolderValues(this,folderStructure)

            if nargin<2
                folderStructure=Simulink.fileGenControl('get','CodeGenFolderStructure');
            end



            specTemplate=Simulink.filegen.internal.Helpers.getFolderSpecificationTemplate(folderStructure);


            this.CodeGenFolderStructure=char(specTemplate.CodeGeneration);

            this.Simulation=this.resolveFolders('SIM',specTemplate.Simulation);

            stf=this.Tokens.getValueForToken('$(STF)');



            if strcmp(stf,'$(STF)')
                return;
            end






            if strcmp(stf,'raccel')
                this.CodeGeneration=this.resolveFolders('RACCEL',specTemplate.RapidAccelerator);
                this.Accelerator=this.resolveFolders('ACCEL',specTemplate.Accelerator);
                this.RapidAccelerator=this.CodeGeneration;
            elseif strcmp(stf,'accel')
                this.CodeGeneration=this.resolveFolders('ACCEL',specTemplate.Accelerator);
                this.Accelerator=this.CodeGeneration;
                this.RapidAccelerator=this.resolveFolders('RACCEL',specTemplate.RapidAccelerator);
            else
                this.CodeGeneration=this.resolveFolders('CODEGEN',specTemplate.CodeGeneration);
                this.Accelerator=this.resolveFolders('ACCEL',specTemplate.Accelerator);
                this.RapidAccelerator=this.resolveFolders('RACCEL',specTemplate.RapidAccelerator);
            end

            this.HDLGeneration=this.resolveFolders('HDL',specTemplate.HDLGeneration);
        end

        function folders=resolveFolders(this,build,folderSpec)
            import Simulink.filegen.FolderSet




            tokens=this.Tokens;%#ok<NASGU>

            expression='\$\(\w+\)';
            dynamicReplacement='${tokens.getValueForToken($0)}';

            root=regexprep(folderSpec.Root,expression,dynamicReplacement);
            marker=regexprep(folderSpec.MarkerFile,expression,dynamicReplacement);







            if any(strcmp(build,{'SIM','HDL'}))
                codeFolder=[];
            else
                codeFolder=regexprep(folderSpec.ModelCode,expression,dynamicReplacement);
            end


            if strcmp(build,'HDL')
                sharedUtils=[];
            else
                sharedUtils=regexprep(folderSpec.SharedUtilityCode,expression,dynamicReplacement);
            end

            targetRoot=regexprep(folderSpec.TargetRoot,expression,dynamicReplacement);
            modelRefCode=fullfile(regexprep(folderSpec.ModelReferenceCode,expression,dynamicReplacement));

            folders=FolderSet(marker,root,codeFolder,targetRoot,modelRefCode,sharedUtils);
        end
    end
end


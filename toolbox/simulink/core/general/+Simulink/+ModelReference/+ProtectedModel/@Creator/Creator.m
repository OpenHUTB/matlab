classdef Creator<handle
















    properties(Hidden)





        ModelName='';
        Input='';
        CreateHarness=false;
        CreateProject=false;
        ProjectName='';
        ZipPath='';
        ObfuscateCode=true;
        CodeInterface;
        Webview=false;
        Report=false;
        Target='';
        IsERTTarget=false;
        HasSILSupport=false;
        HasPILSupport=false;
        HasSILPILSupportOnly=false;
        HasHDLSupport=false;
        HasCSupport=false;
        HasSystemComposerInfo=false;
        IsCodeInterfaceFeatureAvailable=false;
        IsAUTOSARModel=false;
        SubModels={};
        SubModelsWithFile={};
        MapFromModelNameToBuildDir;
        Modes='Accelerator';
        CustomRTWFiles=false;
        ReportGenLicense=false;
        CustomHookCommand=[];


        CallbackMgr;


        TunableVarNames={};


        AccessibleVarNames={'-all'};
        UnprotectedParamIdToProtectedId;


        AccessibleSigNames={'-all'};
        UnprotectedSigIdToProtectedId;


        ProductsUsed={};


        BinariesAndHeadersOnly=false;
        AllFilesForStandaloneBuild=false;


        AllHDLCodeGenArtifacts=false;



        isSimEncrypted=false;
        isRTWEncrypted=false;
        isViewEncrypted=false;
        isModifyEncrypted=false;
        isHDLEncrypted=false;


        IsCrossReleaseWorkflow=false;
        ExistingSharedCode='';


        Sign=false;
        CertFile;


        GlobalVariables={};

        DataDictionaries={};

    end

    properties(Hidden,Transient)



        relationshipClasses={};
        parentModel='';
        concurrentTasking;
        OrigConfigSet;
        OrigCSValues;
        adjustedTopModelConfigSet;
        parts=[];
        relationships=[];
        LatchedDefaultCompInfo;
        ProtectedModelCompInfo;
        oldFileGenCfg;
        initialDir='';
        tmpBuildFolder='';
        addedPath=false;
        wasLoaded=false;
        generateCodeOnly=false;

        createSimulationReport=true;


        deferredPopulationRelationshipIndex=[];


        guiEntry=false;


        currentMode='SIM';
        Encrypt=false;
    end

    properties(Hidden,Transient,Constant)

        ReportV2=false;
    end

    methods


        callCustomPostProcessingHook(obj);


        addPasswordsToRelationshipsAndEncrypt(obj);


        registerRelationships(obj);


        registerCodegenRelationships(obj);


        populateRelationships(obj);



        replaceVarNamesInMdlInfos(obj);


        reduceCodeDescriptor(obj);


        srcFile=copyFile(obj,fileName,category,rootDir);



        function obj=Creator(input,varargin)
            import Simulink.ModelReference.ProtectedModel.*;
            narginchk(0,2);


            warnState=warning('query','backtrace');
            oc=onCleanup(@()warning(warnState));
            warning off backtrace;

            if(ishandle(input))
                object=get_param(input,'Object');
                name=object.getFullName;
                clear('object');
            elseif(ischar(input))
                name=input;
            else
                obj.throwError('Simulink:protectedModel:protectModelFirstArgStringOrHandle');
            end

            obj.Input=input;
            obj.ZipPath=pwd;



            obj.ReportGenLicense=builtin('license','test','Simulink_Report_Gen');


            if(nargin==2)
                obj.guiEntry=varargin{1};
            else
                obj.guiEntry=false;
            end

            obj.getPropertiesFromModel(name);

            if obj.guiEntry


                obj.enableSupportForAccel();
            else
                obj.Modes='Normal';
            end

            obj.OrigCSValues=containers.Map;
            obj.UnprotectedParamIdToProtectedId=containers.Map;
            obj.UnprotectedSigIdToProtectedId=containers.Map;

        end




        function getPropertiesFromModel(obj,name)
            import Simulink.ModelReference.ProtectedModel.*;

            if(~contains(name,'/'))

                obj.wasLoaded=bdIsLoaded(name);


                load_system(name);

                if(~isequal(get_param(name,'BlockDiagramType'),'model'))
                    obj.throwError('Simulink:protectedModel:canOnlyProtectModelsOrModelBlocks',name);
                end

                modelname=name;

            else
                if(~isequal(get_param(name,'BlockType'),'ModelReference'))
                    DAStudio.slerror('Simulink:protectedModel:canOnlyProtectModelsOrModelBlocks',...
                    get_param(name,'Handle'),...
                    name);
                end

                if(isequal(get_param(name,'ProtectedModel'),'on'))
                    DAStudio.slerror('Simulink:protectedModel:cannotProtectProtectedModels',...
                    get_param(name,'Handle'),...
                    name,get_param(name,'ModelNameDialog'));
                end

                obj.parentModel=bdroot(name);
                modelname=get_param(name,'ModelName');
                obj.wasLoaded=bdIsLoaded(modelname);
            end
            obj.ModelName=modelname;

            if~bdIsLoaded(modelname)
                load_system(modelname);
                closeModelOnCleanup=onCleanup(@()close_system(modelname,0));
            end


            if(strcmpi(get_param(modelname,'SimulinkSubdomain'),'Architecture'))
                obj.throwError('Simulink:protectedModel:cannotProtectSystemComposerModel',modelname);
            end

            stf=get_param(modelname,'SystemTargetFile');
            obj.IsERTTarget=get_param(modelname,'IsERTTarget');
            obj.IsAUTOSARModel=strcmp(get_param(modelname,'AutosarCompliant'),'on');
            obj.IsCodeInterfaceFeatureAvailable=isCodeInterfaceFeatureAvailable...
            (modelname);
            obj.HasSystemComposerInfo=strcmp(get_param(modelname,'SimulinkSubdomain'),'Simulink')&&...
            strcmp(get_param(modelname,'HasSystemComposerArchInfo'),'on');

            obj.generateCodeOnly=strcmp(get_param(modelname,...
            'GenCodeOnly'),'on');
            obj.concurrentTasking=strcmp(get_param(modelname,'ConcurrentTasks'),'on');

            if obj.IsAUTOSARModel
                obj.CodeInterface='Top model';
            else
                obj.CodeInterface='Model reference';
            end

            [~,obj.Target]=fileparts(stf);
        end



        function registerCustomRelationships(~)

        end


        function addCustomFiles(obj,customFileRec,protectSrc)


            obj.relationshipClasses{end+1}=...
            Simulink.ModelReference.common.RelationshipCustom(...
            obj,...
            customFileRec,...
            protectSrc);

            obj.CustomRTWFiles=true;
        end


        function addRelationships(obj)
            for cnt=1:length(obj.relationshipClasses)
                objRel=obj.relationshipClasses{cnt};
                objRel.PartsMap=containers.Map;
                objRel.addRelationship(obj);
            end

            obj.addRelationshipClassesToInformation();
        end


        function addRelationshipClassesToInformation(obj)
            eifile='extraInformation.mat';
            load(eifile);%#ok<LOAD> 
            gi.relationships=obj.relationshipClasses;
            save(eifile,'gi');
        end



        function[harnessHandle,neededVars]=protect(obj)
            reportFlag=rtw.report.ReportInfo.featureReportV2(obj.ReportV2);
            try

                warnState=warning('query','backtrace');
                oc=onCleanup(@()warning(warnState));
                warning off backtrace;


                obj.updateProgress(0,'ProtectedModelPhaseInit');
                progressDone=onCleanup(@()obj.updateProgress(100,'ProtectedModelPhaseDone'));


                [harnessHandle]=obj.doProtectSetup();
                neededVars={};



                shouldContinue=obj.queryUserForPasswordIfCommandLine();
                if~shouldContinue
                    return;
                end

                obj.checkEncryptedContents();


                [harnessHandle,neededVars]=obj.doProtect(harnessHandle);

                SLM3I.SimulinkModelContext.postModelProtectedEvent(obj.ModelName);
                rtw.report.ReportInfo.featureReportV2(reportFlag);
            catch me

                rtw.report.ReportInfo.featureReportV2(reportFlag);


                obj.clearPasswords();


                obj.restoreLdStatus();


                obj.restoreCurrentTargetToDefault();

                throwAsCaller(me);
            end
        end

        function[harnessHandle]=doProtectSetup(obj)
            harnessHandle=0;


            obj.updateProgress(5,'ProtectedModelPhaseCheck');






            if~slfeature('ProtectedModelRemoveSimulinkCoderCheck')&&...
                ~obj.getSupportsHDL()
                obj.doLicenseCheckRTW();
            end

            obj.loadModel();

            obj.checkModelConfig();

            slprivate('checkWritableDirectory',obj.ZipPath);

            obj.checkExistingSLXP();

            obj.checkProjectStatus();
        end

        function[harnessHandle,neededVars]=doProtect(obj,harnessHandle)

            neededVars={};%#ok<NASGU>




            obj.updateProgress(15,'ProtectedModelPhaseConfig');


            obj.protectingMode('on');


            protectCleanup=onCleanup(@obj.exitProtection);
            directoryCleanup=onCleanup(@obj.backToInitialDir);





            warnStatus=warning('query','Simulink:protectedModel:protectedModelNoExtensionButLoadedError');
            warnState=warnStatus.state;
            oc=onCleanup(@()warning(warnState,'Simulink:protectedModel:protectedModelNoExtensionButLoadedError'));
            warning('off','Simulink:protectedModel:protectedModelNoExtensionButLoadedError');




            if~isempty(obj.CallbackMgr)
                obj.CallbackMgr.update(obj);
            end



            obj.registerRelationships();
            obj.registerCustomRelationships();




            obj.build();




            [protectedModelFile,neededVars]=obj.doPostProcessAndPackage();


            clear protectCleanup;

            isProtectedModelInPath=obj.isOnMATLABPath(obj.ZipPath);
            if(~isProtectedModelInPath)
                addpath(obj.ZipPath);
                pathclean=onCleanup(@()rmpath(obj.ZipPath));
            end

            if obj.Sign
                try
                    Simulink.ProtectedModel.sign(protectedModelFile,which(obj.CertFile));
                catch exception
                    warning(exception.identifier,'%s',exception.message)
                end
            end
            if(obj.CreateProject)
                try
                    obj.createProject(protectedModelFile);
                catch ME
                    newException=MSLException(message('Simulink:protectedModel:CanNotCreateProject',obj.ModelName));
                    MSL=addCause(newException,ME);
                    MSL.reportAsWarning;

                end
            elseif(obj.CreateHarness)
                harnessHandle=obj.createHarness(protectedModelFile);
            end


            clear directoryCleanup;
            if(~isProtectedModelInPath)
                clear pathclean;
                if(harnessHandle>0)
                    obj.throwWarning('Simulink:protectedModel:ProtectedModelNotOnPath',...
                    obj.ModelName);
                end
            end

            obj.restoreLdStatus();


            clear oc;


            obj.clearPasswords();
        end




        function restoreLdStatus(obj)



            if~obj.wasLoaded
                close_system(obj.ModelName);
            end
        end




        function restoreCurrentTargetToDefault(obj)
            import Simulink.ModelReference.ProtectedModel.*;
            CurrentTarget.clear(obj.ModelName);
        end


        function generateProtectedModelReport(obj,rpt)

            rpt.initProtectedModelReport(obj);
            rpt.emitHTML();
        end


        function generateProtectedModelWebview(obj,modelName)


            Oldpwd=pwd;
            cd('slprj');
            restorePath=onCleanup(@()cd(Oldpwd));

            try
                mkdir('webview');

                fileattrib('webview','+w','','s');
                cd('webview');
                searchScope='CurrentAndBelow';

                lookUnderMasks='All';
                followLinks='on';
                viewFile=false;
                followModelReference='on';
                showProgressBar=false;


                if~exist('slwebview','file')
                    DAStudio.error('Simulink:protectedModel:SimulinkReportGenNotInstalled');
                end



                if~obj.ReportGenLicense
                    DAStudio.error('Simulink:protectedModel:SimulinkReportGenLicenseRequired');
                end


                slwebview(modelName,'SearchScope',searchScope,'LookUnderMasks',lookUnderMasks,'FollowLinks',followLinks,...
                'ViewFile',viewFile,'FollowModelReference',followModelReference,'ShowProgressBar',showProgressBar);

            catch ME
                if strcmp(ME.identifier,'glue2:portal:BadContextCannotUpdateBlockGraphics')
                    obj.throwWarning('RTW:report:GenerateWebviewInSimulation',...
                    modelname,...
                    ['rtw.report.generate(''',modelName,''')']);
                else
                    rethrow(ME);
                end
            end

        end


        function generateProtectedModelThumbnail(~,modelName)
            Oldpwd=pwd;
            cd('slprj');
            restorePath=onCleanup(@()cd(Oldpwd));

            mkdir('thumbnail');
            fileattrib('thumbnail','+w','','s');
            cd('thumbnail');
            thumbnailfilename='thumbnail.png';
            thumbnailfile=fullfile(pwd,thumbnailfilename);


            slCreateThumbnailImage(modelName,thumbnailfile);
        end







        function shouldContinue=queryUserForPasswordIfCommandLine(obj)
            shouldContinue=true;
            if~obj.guiEntry&&(obj.needsContentPassword()||obj.needsModifyPassword())
                shouldContinue=obj.showBlockingPasswordDlg(true);
            end
        end

        function out=needsContentPassword(obj)
            out=obj.Encrypt&&~obj.hasAnyContentPassword();
        end

        function out=needsModifyPassword(obj)
            out=obj.getModifiable()&&~obj.hasModifyPassword();
        end


        function checkEncryptedContents(obj)





            import Simulink.ModelReference.ProtectedModel.*;
            if obj.Encrypt&&~obj.guiEntry
                unencryptedCategories='';
                if(obj.supportsNormal()&&~obj.hasSimulationPassword())
                    unencryptedCategories=sprintf([unencryptedCategories,'\n',getStringForEncryptionCategory('SIM')]);
                end
                if(obj.supportsCodeGen()&&obj.getSupportsC()&&~obj.hasCodeGenerationPassword())
                    unencryptedCategories=sprintf([unencryptedCategories,'\n',getStringForEncryptionCategory('RTW')]);
                end
                if(obj.supportsView()&&~obj.hasViewPassword())
                    unencryptedCategories=sprintf([unencryptedCategories,'\n',getStringForEncryptionCategory('VIEW')]);
                end
                if(obj.supportsHDLCodeGen()&&~obj.hasHDLPassword())
                    unencryptedCategories=sprintf([unencryptedCategories,'\n',getStringForEncryptionCategory('HDL')]);
                end
                if~isempty(unencryptedCategories)
                    obj.throwWarning('Simulink:protectedModel:EncryptOnNoPasswordForCategory',...
                    obj.ModelName,...
                    obj.ModelName,...
                    unencryptedCategories);
                end
            end
        end


        function checkProjectStatus(obj)
            if(obj.CreateProject)
                if obj.isViewOnly()
                    DAStudio.error('Simulink:protectedModel:NoProjectForViewOnlyProtectedModels',obj.ModelName);

                end
                if(isempty(obj.ProjectName))
                    obj.setProjectName([obj.ModelName,'_protected']);
                end

                fileName=[obj.ProjectName,'.mlproj'];
                if(isfile(fullfile(obj.ZipPath,fileName)))
                    DAStudio.error('MATLAB:project:api:ExportToNewArchiveOnly',fileName);
                end
            else
                if(~isempty(obj.ProjectName))
                    DAStudio.error('Simulink:protectedModel:ConflictWithProjectNameAndNoProject');
                end
            end
        end


        function checkExistingSLXP(obj)



            fileName=slInternal('getPackageNameForModel',obj.ModelName);
            filesOnPath=which('-all',fileName);
            currentPath=pwd;



            if length(filesOnPath)==1
                [fpath,~,~]=fileparts(filesOnPath{1});
                if strcmp(fpath,currentPath)&&obj.guiEntry
                    result=questdlg(DAStudio.message(...
                    'Simulink:protectedModel:ProtectedModelSLXPOverwriteDlgDescription',fileName),...
                    DAStudio.message('Simulink:editor:DialogMessage'),...
                    DAStudio.message('Simulink:editor:DialogYes'),...
                    DAStudio.message('Simulink:editor:DialogNo'),...
                    DAStudio.message('Simulink:editor:DialogYes'));

                    if strcmp(result,DAStudio.message('Simulink:editor:DialogYes'))
                        delete(filesOnPath{1});
                        return;
                    else
                        obj.throwError('Simulink:protectedModel:ProtectedModelAlreadyExists',fileName);
                    end
                end
            end

            if~isempty(filesOnPath)


                obj.throwError('Simulink:protectedModel:ProtectedModelAlreadyExists',fileName);
            end
        end


        function loadModel(obj)
            load_system(obj.ModelName);
        end




        function updateProgress(obj,pct,message)%#ok<INUSD>
            if obj.guiEntry
                set_param(obj.parentModel,'ProgressPercentage',pct);


                if slsvTestingHook('ProtectedModelTestProgressStatus')>0
                    obj.postUpdateHook();
                end
            end
        end


        function postUpdateHook(~)

        end




        function exitProtection(obj)

            obj.protectingMode('off');
        end



        function ProtectedModelOnPath=isProtectedModelNotOnPath(~,protectedModelFile)
            ProtectedModelOnPath=isempty(which(protectedModelFile));
        end



        function checkIfProtectedModelOnPath(obj,protectedModelFile)
            if(obj.isProtectedModelNotOnPath(protectedModelFile))
                obj.throwWarning('Simulink:protectedModel:ProtectedModelNotOnPath',...
                obj.ModelName);
            end
        end


        function openDDNames=getAllOpenDDNames(~)
            openTopDDs=Simulink.data.dictionary.getOpenDictionaryPaths();

            openDDNames={};
            for n=1:length(openTopDDs)
                topDDPath=openTopDDs{n};
                [~,name,ext]=fileparts(topDDPath);
                ddObj=Simulink.dd.open([name,ext]);
                ddClosure=ddObj.DependencyClosure;
                for m=1:length(ddClosure)
                    [~,name,ext]=fileparts(ddClosure{m});
                    openDDNames{end+1}=[name,ext];%#ok<AGROW> 
                end
            end

            openDDNames=unique(openDDNames);

        end
        function[alreadyExist,destinationFile]=copyDataDictionary(~,sourceFile,openDictionaries)

            alreadyExist=false;


            [~,ddname,ddext]=fileparts(sourceFile);
            dataDictionaryName=[ddname,ddext];
            destinationFile=fullfile(pwd,dataDictionaryName);

            if strcmp(sourceFile,destinationFile)
                alreadyExist=true;
                return;
            end





            if any(strcmp(openDictionaries,dataDictionaryName))
                ddObj=Simulink.data.dictionary.open(dataDictionaryName);
                if(ddObj.HasUnsavedChanges)
                    DAStudio.error(SLDD:sldd:SlddFileWithSameNameAlreadyOpen,...
                    sourceFile,dataDictionaryName);
                else
                    Simulink.data.dictionary.closeAll(dataDictionaryName);
                end
            end


            copyfile(sourceFile,destinationFile,'f');
            fileattrib(destinationFile,'+w');

        end

        function fullPathDataDicitionaries=ddreduction(obj)


            fullPathDataDicitionaries={};


            openDictionaries=obj.getAllOpenDDNames();


            for i=1:numel(obj.DataDictionaries)
                sourceFile=which(obj.DataDictionaries{i});
                [alreadyExist,destinationFile]=obj.copyDataDictionary(sourceFile,openDictionaries);
                if(~alreadyExist)
                    fullPathDataDicitionaries{end+1}=destinationFile;%#ok<AGROW> 


                    depsGraph=dependencies.internal.analyze(sourceFile);
                    fullPathsOfDepsCell=depsGraph.Nodes.Name(depsGraph.Nodes.Resolved);
                    for j=1:length(fullPathsOfDepsCell)
                        [alreadyExist,referencedDD]=obj.copyDataDictionary(fullPathsOfDepsCell{j},openDictionaries);
                        if(~alreadyExist)
                            fullPathDataDicitionaries{end+1}=referencedDD;%#ok<AGROW> 
                        end
                    end
                end
            end


            fullPathDataDicitionaries=unique(fullPathDataDicitionaries);



            dataConnection=Simulink.data.BaseWorkspace;
            tempName=Simulink.ModelReference.Conversion.NameUtils.getValidModelNameForBase(...
            'dTempDDyForProtection',1000,dataConnection,0);

            for i=1:numel(obj.DataDictionaries)


                renamedDD=[tempName,'.sldd'];
                movefile(obj.DataDictionaries{i},renamedDD);

                ddObj=Simulink.data.dictionary.open(renamedDD);
                ocDDSave=onCleanup(@()Simulink.data.dictionary.closeAll(renamedDD,'-save'));

                ocDDClose1=onCleanup(@()movefile(renamedDD,obj.DataDictionaries{i}));

                gsNew=ddObj.getSection('Design Data');
                allEntries=find(gsNew);


                for j=1:numel(allEntries)
                    if(~any(strcmp(obj.GlobalVariables.VariableName,allEntries(j).Name)))
                        deleteEntry(gsNew,allEntries(j).Name);
                    end
                end



                ocDDSave.delete();
                ocDDClose1.delete();

            end
        end

        function enumFileList=getEnumSourceList(obj)

            enumList=get_param(obj.ModelName,"ProtectedModelGlobalEnums");
            enumFileList={};
            if(isempty(enumList))
                return;
            end
            for i=1:numel(enumList)
                file=which([enumList{i},'.m']);
                if(~isempty(file))
                    enumFileList{end+1}=file;%#ok<AGROW> 
                end
            end
        end



        function createProject(obj,protectedModelFile)


            obj.updateProgress(90,'ProtectedModelPhaseProject');

            mlprojFullPath=fullfile(obj.ZipPath,[obj.ProjectName,'.mlproj']);


            harnessHandle=Simulink.ModelReference.ProtectedModel.createHarness(protectedModelFile,"",obj);
            harnessModel=get_param(harnessHandle,'Name');
            if(bdIsLoaded(harnessModel))
                close_system(harnessModel,0,'closeReferencedModels',false);
            end


            fullPathDataDicitionaries=obj.ddreduction();


            files=fullPathDataDicitionaries;


            harnessFile=fullfile(pwd,[harnessModel,'.slx']);
            files{end+1}=harnessFile;

            graph=dependencies.internal.analyze(harnessFile);
            deps=successors(graph,harnessFile);
            resolved=graph.Nodes(graph.findnode(deps),:).Resolved;
            resolvedFiles=deps(resolved);

            enumFileList=obj.getEnumSourceList();
            for i=1:numel(enumFileList)
                resolvedFiles{end+1}=enumFileList{i};%#ok<AGROW> 
            end

            for i=1:size(resolvedFiles)
                [filepath,name,ext]=fileparts(resolvedFiles{i});
                if(~strcmp(filepath,pwd))
                    copyfile(resolvedFiles{i},pwd);
                end
                files{end+1}=fullfile(pwd,[name,ext]);%#ok<AGROW> 
            end


            matlab.internal.project.archive.createArchive(mlprojFullPath,pwd,files);

        end


        function harnessHandle=createHarness(obj,protectedModelFile)

            obj.updateProgress(90,'ProtectedModelPhaseHarness');



            if slfeature('ProtectedModelDirectSimulation')&&~obj.HasSILPILSupportOnly
                harnessHandle=Simulink.ModelReference.ProtectedModel.createHarness(protectedModelFile,"",obj);
            else
                harnessHandle=obj.createHarnessWithotIO(protectedModelFile);
            end
        end
        function harnessHandle=createHarnessWithotIO(obj,protectedModelFullFile)

            [~,fname,fext]=fileparts(protectedModelFullFile);
            protectedModelFile=[fname,fext];

            obj.checkIfProtectedModelOnPath(protectedModelFile);

            if obj.isProtectedModelNotOnPath(protectedModelFile)
                warnStatus=warning('query','Simulink:protectedModel:unableToFindProtectedModelFile');
                oc=onCleanup(@()warning(warnStatus));
                warning('off','Simulink:protectedModel:unableToFindProtectedModelFile');
            end


            harnessHandle=new_system();
            newname=get_param(harnessHandle,'Name');

            inputIsNotMdlRefBlock=isempty(strfind(obj.Input,'/'));





            csSource=strtok(obj.Input,'/');

            if(inputIsNotMdlRefBlock)
                foundIns=find_system(obj.Input,'searchdepth',1,'blocktype','Inport');
                foundOuts=find_system(obj.Input,'searchdepth',1,'blocktype','Outport');

                ports=max([length(foundIns),length(foundOuts),1]);


                add_block('built-in/ModelReference',[newname,'/','Model'],...
                'ModelName',protectedModelFile,...
                'Position',[15,15,150,(60*ports)]);
            else
                origPos=get_param(obj.Input,'Position');
                origWidth=origPos(3)-origPos(1);
                origHeight=origPos(4)-origPos(2);


                handle=add_block(obj.Input,[newname,'/',get_param(obj.Input,'Name')]);

                set_param(handle,'LinkStatus','none');





                set_param(handle,'ModelName',protectedModelFile);
                oldVal=get_param(handle,'ParameterArgumentValues');



                set_param(handle,'Variant','off');

                set_param(handle,'ModelName',protectedModelFile);
                set_param(handle,'ParameterArgumentValues',oldVal);
                set_param(handle,'Position',[15,15,(15+origWidth),(15+origHeight)])

            end

            activeConfigSet=getActiveConfigSet(csSource);
            if(isa(activeConfigSet,'Simulink.ConfigSetRef'))



                origConfigSet=getActiveConfigSet(newname);


                activeConfigSet=activeConfigSet.copy;


                attachConfigSet(newname,activeConfigSet,true);


                setActiveConfigSet(newname,activeConfigSet.name);


                detachConfigSet(newname,origConfigSet.name);


                activeConfigSet.name=origConfigSet.name;
            else

                configSetUtils=Simulink.ModelReference.Conversion.ConfigSet.create;
                configSetUtils.copy(csSource,newname);
            end

            open_system(harnessHandle);
        end

        function createReportIfNecessary(obj,rpt)

            if obj.Report
                if~isempty(rpt)
                    obj.generateProtectedModelReport(rpt);


                    rpt.saveMat();
                end
            end


            rtw.report.ReportInfo.clearInstance(obj.ModelName);
        end



        function build(obj)
            import Simulink.ModelReference.ProtectedModel.*;

            if(isequal(get_param(obj.ModelName,'Dirty'),'on'))
                obj.throwError('Simulink:protectedModel:protectedModelUnsavedChanges',obj.ModelName);
            end

            obj.currentMode='SIM';
            obj.updateProgress(30,'ProtectedModelPhaseSimBuild');

            function setRebuildConfig(modelName,param)
                set_param(modelName,'UpdateModelReferenceTargets',param);
                set_param(modelName,'Dirty','off');
            end
            if(strcmp(get_param(obj.ModelName,'UpdateModelReferenceTargets'),'AssumeUpToDate'))
                setRebuildConfig(obj.ModelName,'Force');
                rebuildC=onCleanup(@()setRebuildConfig(obj.ModelName,'AssumeUpToDate'));
            end

            if obj.supportsSimTargetMex
                lReportInfo=obj.buildTarget('ModelReferenceProtectedSimTarget');
            end

            if obj.createSimulationReport
                obj.updateProgress(40,'ProtectedModelPhaseReport');
                obj.createReportIfNecessary(lReportInfo);
            end


            infoStruct=obj.loadBInfoStruct('SIM');
            if(~isempty(infoStruct)&&infoStruct.modelInterface.HasNonInlinedSfcn)
                if~slfeature('NonInlineSFcnsInProtection')
                    obj.throwError('Simulink:protectedModel:protectedModelCannotHaveNonInlinedSFunctions',obj.ModelName);
                elseif obj.supportsCodeGen()
                    obj.throwError('Simulink:protectedModel:protectedModelWithCodeGenCannotHaveNonInlinedSFunctions',obj.ModelName);
                end
            end

            if obj.supportsCodeGen()&&obj.getSupportsC()
                obj.updateProgress(45,'ProtectedModelPhaseCodeGen');


                allowLcc=true;
                obj.ProtectedModelCompInfo=coder.internal.ModelCompInfo.createModelCompInfo...
                (obj.ModelName,...
                obj.LatchedDefaultCompInfo.DefaultMexCompInfo,allowLcc);

                if strcmp(obj.CodeInterface,'Model reference')

                    obj.currentMode='RTW';
                    lReportInfo=obj.buildTarget('ModelReferenceCoderTargetOnly');
                else



                    obj.currentMode='NONE';
                    lReportInfo=obj.buildTarget('StandaloneCoderTarget');
                end

            end

            if obj.supportsCodeGen()&&obj.getSupportsHDL()

                makehdl(obj.ModelName,'BuildToProtectModel','on');
            end

            obj.updateProgress(55,'ProtectedModelPhaseObfuscating');
            if obj.ObfuscateCode
                obj.obfuscateSharedUtils();
            end


            obj.postCheckForProblems();



            if isWebviewFeatureEnabled(obj.ReportGenLicense)

                if obj.Webview

                    obj.updateProgress(75,'ProtectedModelPhaseView');

                    obj.generateProtectedModelWebview(obj.ModelName);
                    if obj.isThumbnailEnabled
                        obj.generateProtectedModelThumbnail(obj.ModelName);
                    end
                end
            end


            obj.setSILPILsupport;


            obj.MapFromModelNameToBuildDir=obj.getModelNameAndBuildDirMap();


            obj.populateRelationships();


            if obj.hasCustomHookCommand()
                obj.callCustomPostProcessingHook();
            end




            if obj.Report&&obj.supportsCodeGen()

                obj.createReportIfNecessary(lReportInfo);


                for i=1:length(obj.deferredPopulationRelationshipIndex)
                    obj.relationshipClasses{obj.deferredPopulationRelationshipIndex(i)}.populate(obj);
                end
            end
            obj.currentMode='';

        end


        function[protectedModelFile,vars]=doPostProcessAndPackage(obj)

            import Simulink.ModelReference.ProtectedModel.*;


            obj.updateProgress(80,'ProtectedModelPhasePackage');


            lModelReferenceTargetTypeList=obj.getAllModelReferenceTargetTypes();
            vars=obj.findNeededVariables(obj.ModelName,obj.SubModels,lModelReferenceTargetTypeList);

            if(obj.supportsCodeGen()&&~obj.supportsHDLCodeGen())
                targetType='RTW';
                if obj.isTopModelCode
                    targetType='NONE';
                end
                lModelReferenceTargetTypeList=obj.getModelReferenceTargetTypesForTargetType(targetType);
                varsForCodegen=obj.findNeededVariables(obj.ModelName,obj.SubModels,lModelReferenceTargetTypeList);
                vars=union(vars,varsForCodegen);

                tunableParamsOnlyForCodegen=obj.getTunableParamInCodegenButNoSim();
                if(~isempty(tunableParamsOnlyForCodegen))
                    fprintf(newline);
                    MSLDiagnostic('Simulink:protectedModel:ProtectedParamsInSIMThatAreExposedInCodeGen',...
                    strjoin(tunableParamsOnlyForCodegen,', ')).reportAsInfo;
                end
            end

            if~obj.isViewOnly()&&...
                ~isa(obj,'Simulink.ModelReference.ProtectedModel.TargetAdder')
                dataDictionaryFile=obj.getDataDictionaryNameToKeepVariables();
                obj.generateDataDictionarytoFindChecksumMissmatch(dataDictionaryFile);
            end


            obj.replaceVarNamesInMdlInfos();


            if obj.getSupportsC()
                obj.reduceCodeDescriptor();
            end




            if obj.supportsHDLCodeGen()
                try
                    obj.protectHDLGMModel();
                catch me
                    hdlsetuprequired=0;
                    for ii=1:length(me.cause)
                        cause=me.cause{ii};
                        if isequal(cause.identifier,'Simulink:SampleTime:FixedStepNEFundStep')||...
                            isequal(cause.identifier,'Simulink:SampleTime:BlockTsNotAMultipleOfFixedStep')
                            hdlsetuprequired=1;
                        end
                    end
                    if hdlsetuprequired
                        reportHDLErrorsInProtectGMModel(obj,me);
                    else

                        rethrow(me);
                    end
                end
            end


            obj.addPasswordsToRelationshipsAndEncrypt();


            obj.addRelationships();


            protectedModelFile=obj.writeToSLXP();
        end




        function protectHDLGMModel(obj)
            origDir=pwd;
            targetDir=hdlget_param(obj.ModelName,'TargetDirectory');
            if ispc
                targetDir=strrep(targetDir,'/',filesep);
            else
                targetDir=strrep(targetDir,'\',filesep);
            end
            gmDir=fullfile(targetDir,obj.ModelName);
            cd(gmDir);

            gmPrefix=hdlget_param(obj.ModelName,'generatedmodelnameprefix');
            gmModelName=[gmPrefix,obj.ModelName];
            creatorGM=Simulink.ModelReference.ProtectedModel.Creator(gmModelName,false);


            creatorGM.setSupportsHDL(true);
            creatorGM.enableSupportForNormal();
            creatorGM.protect();

            cd(origDir);
            for i=1:length(obj.relationshipClasses)
                if strcmp(obj.relationshipClasses{i}.RelationshipName,'hdl')
                    obj.relationshipClasses{i}.populateProtectedGMModel(creatorGM);
                end
            end





            close_system(gmModelName,0);
        end



        function reportHDLErrorsInProtectGMModel(obj,~)
            if~isequal(get_param(obj.ModelName,'FixedStep'),'auto')
                obj.throwError('hdlcoder:validate:ProtectedModelFixedStepNotAuto',...
                obj.ModelName);
            end
            if~isequal(get_param(obj.ModelName,'Solver'),'fixedstepdiscrete')
                obj.throwError('hdlcoder:validate:ProtectedModelSolverNotFixedStepDiscrete',...
                obj.ModelName);
            end
            if~isequal(get_param(obj.ModelName,'SolverMode'),'SingleTasking')
                obj.throwError('hdlcoder:validate:ProtectedModelSolverNodeNotSingleTasking',...
                obj.ModelName);
            end
        end



        function lReportInfo=buildTarget(obj,mdlRefTarget)



            slBuildFcn=i_getSlBuildFcn(obj.guiEntry,mdlRefTarget);

            isSimTarget=strcmp(mdlRefTarget,'ModelReferenceProtectedSimTarget');
            if isSimTarget

                slBuildFcn(obj.ModelName,mdlRefTarget,...
                'SlbDefaultCompInfo',obj.LatchedDefaultCompInfo);
                lReportInfo=get_param(obj.ModelName,'CoderReportInfo');
            else




                lTopModelSilOrPilBuild=true;
                lTopModelIsSilMode=false;

                slBuildFcn(obj.ModelName,mdlRefTarget,...
                'SlbDefaultCompInfo',obj.LatchedDefaultCompInfo,...
                'SlbModelCompInfo',obj.ProtectedModelCompInfo,...
                'TopModelSilOrPilBuild',lTopModelSilOrPilBuild,...
                'TopModelIsSilMode',lTopModelIsSilMode,...
                'generateCodeOnly',obj.generateCodeOnly);




                lReportInfo=get_param(obj.ModelName,'CoderReportInfo');





                isPortableWordSizes=...
                strcmp(get_param(obj.ModelName,'PortableWordSizes'),'on');
                if isPortableWordSizes&&~obj.packageSourceCode







                    if strcmp(mdlRefTarget,'StandaloneCoderTarget')
                        lTargetType='NONE';
                    else
                        lTargetType='RTW';
                    end
                    lSystemTargetFile=get_param(obj.ModelName,'SystemTargetFile');
                    oInfoStruct=coder.internal.infoMATPostBuild...
                    ('load','binfo',obj.ModelName,lTargetType,lSystemTargetFile);
                    lStoredChecksum=oInfoStruct.checkSum;
                    lStoredParameterChecksum=oInfoStruct.parameterCheckSum;
                    lStoredtflChecksum=oInfoStruct.tflCheckSum;
                    lTopModelSilOrPilBuild=true;
                    lTopModelIsSilMode=true;
                    slBuildFcn(obj.ModelName,mdlRefTarget,...
                    'SlbDefaultCompInfo',obj.LatchedDefaultCompInfo,...
                    'SlbModelCompInfo',obj.ProtectedModelCompInfo,...
                    'TopModelSilOrPilBuild',lTopModelSilOrPilBuild,...
                    'TopModelIsSilMode',lTopModelIsSilMode,...
                    'StoredChecksum',lStoredChecksum,...
                    'StoredParameterChecksum',lStoredParameterChecksum,...
                    'StoredTFLChecksum',lStoredtflChecksum,...
                    'generateCodeOnly',obj.generateCodeOnly);
                end
            end
        end



        function protectedModelFile=writeToSLXP(obj)
            assert(~isempty(obj.parts)&&~isempty(obj.relationships));
            protectedModelFile=fullfile(obj.ZipPath,slInternal('getPackageNameForModel',obj.ModelName));
            slInternal('createProtectedModelOPC',obj.ModelName,protectedModelFile,obj.parts,obj.relationships,obj);
        end



        function checksum=getInterfaceVariableChecksum(obj)
            if obj.supportsSimTargetMex
                checksum=obj.getInterfaceVariableChecksumForTargetType('SIM');
            else
                checksum=obj.getInterfaceVariableChecksumForTargetType('NONE');
            end
        end

        function checksum=getInterfaceVariableChecksumForCodeGen(obj)
            if obj.isTopModelCode
                checksum=obj.getInterfaceVariableChecksumForTargetType('NONE');
            elseif obj.getSupportsHDL()
                checksum=obj.getInterfaceVariableChecksumForTargetType('HDL');
            else
                checksum=obj.getInterfaceVariableChecksumForTargetType('RTW');
            end

        end


        function checksum=getInterfaceVariableChecksumForTargetType(obj,lModelReferenceTargetTypeTop)


            forHDL=strcmp(lModelReferenceTargetTypeTop,'HDL');
            if(forHDL)
                lModelReferenceTargetTypeTop='SIM';
            end

            lModelReferenceTargetTypeList=obj.getModelReferenceTargetTypesForTargetType(lModelReferenceTargetTypeTop);
            infoStruct=obj.loadBInfoStruct(lModelReferenceTargetTypeTop);
            varString=infoStruct.globalsInfo.ProtectedModelInterfaceVariables;

            ignoreCSCs=strcmp(get_param(obj.ModelName,'IgnoreCustomStorageClasses'),'on');
            inlineParameters=strcmp(get_param(obj.ModelName,'RTWInlineParameters'),'on');



            lSystemTargetFile=get_param(obj.ModelName,'SystemTargetFile');



            collapsedVars={};
            for i=1:length(obj.SubModels)
                refMdl=obj.SubModels{i};

                infoStruct=obj.getInfoFromBinfoFile(refMdl,lModelReferenceTargetTypeList{i},lSystemTargetFile,'load');
                collapsedVars=[collapsedVars;infoStruct.globalsInfo.GlobalParamInfo.CollapsedTunableList];%#ok
            end


            checksum.collapsedVars=unique(collapsedVars);


            if(forHDL)
                tunableParams=obj.getSimulationTunableParams();
                simVariables=split(varString,',')';
                hdlVars=setdiff(simVariables,tunableParams);
                checksum.collapsedVars=setdiff(checksum.collapsedVars,tunableParams);
                if(~isempty(hdlVars))
                    varString=hdlVars{1};
                else
                    varString='';
                end
            end


            vars.VarList=varString;
            vars.CollapsedTunableList=checksum.collapsedVars;
            checksum.variables=vars;
            toPerformCleanup=true;

            if strcmp(lModelReferenceTargetTypeTop,'NONE')
                [~,lGenSettings]=coder.internal.getSTFInfo...
                (obj.ModelName,...
                'noTLCSettings',true,...
                'SystemTargetFile',lSystemTargetFile,...
                'modelreferencetargettype',lModelReferenceTargetTypeTop);
                cleanupGenSettingsCache=coder.internal.infoMATFileMgr...
                ([],[],[],[],...
                'InitializeGenSettings',lGenSettings);%#ok<NASGU>
            end
            [checksum.checksum,checksum.varChecksums]=slprivate('getGlobalParamChecksum',...
            obj.ModelName,...
            lModelReferenceTargetTypeTop,...
            vars,...
            inlineParameters,...
            ignoreCSCs,...
            infoStruct.designDataLocation,...
            toPerformCleanup,...
            true,...
            infoStruct.enableAccessToBaseWorkspace);
            checksum.enableAccessToBaseWorkspace=infoStruct.enableAccessToBaseWorkspace;
            checksum.ignoreCSCs=ignoreCSCs;
            checksum.inlineParameters=inlineParameters;
            checksum.designDataLocation=infoStruct.designDataLocation;
        end


        function addSupportForCodegenDeprecatedCB(obj,dlg)
            cgsupport=dlg.getWidgetValue('protectedMdl_CodeGenEnable');
            if cgsupport
                obj.addSupportForCodegen();
            else
                obj.removeSupportForCodegen();
            end
        end







        function isValid=isValidProperty(~,~)
            isValid=true;
        end




        function dataType=getPropDataType(~,propName)
            switch(propName)
            case{'tmpViewSupport','tmpSimulationSupport',...
                'tmpAddCodeGenSupport','CreateHarness'}
                dataType='bool';
            case 'ZipPath'
                dataType='string';
            otherwise
                dataType='invalid';
            end
        end



        function out=getTgtDir(obj)

            if obj.supportsCodeGen()
                out=Simulink.ModelReference.ProtectedModel.getRTWBuildDir();
            else
                out=Simulink.ModelReference.ProtectedModel.getSimBuildDir();
            end
        end



        function configModel(obj,currentModel)
            pvPairs=Simulink.ModelReference.ProtectedModel.Creator.getConfigSetParamValuePairs(obj.ObfuscateCode);


            tmpCS=getActiveConfigSet(currentModel);
            obj.OrigCSValues(currentModel)=tmpCS.copy;


            for i=1:length(pvPairs)
                set_param(currentModel,pvPairs{i}{1},pvPairs{i}{2});
            end



            if~strcmp(get_param(obj.OrigCSValues(currentModel),'CodeProfilingInstrumentation'),...
                get_param(currentModel,'CodeProfilingInstrumentation'))

                obj.throwWarning('Simulink:protectedModel:protectedModelAndProfilingIncompatible',...
                obj.ModelName,...
                obj.ModelName);
            end

            Simulink.ModelReference.ProtectedModel.Creator.processConfigSetStrings(currentModel);


            if obj.supportsAccel()&&obj.ObfuscateCode
                set_param(currentModel,'ObfuscateCode',1);
            end




            if(~strcmp(currentModel,obj.ModelName))
                set_param(currentModel,'ProtectedModelCreator',obj);
            end



            obj.adjustedTopModelConfigSet=getActiveConfigSet(obj.ModelName).copy;



            if~isempty(obj.adjustedTopModelConfigSet.getComponent('Simscape'))
                obj.adjustedTopModelConfigSet.detachComponent('Simscape');
            end
        end


        function restoreModel(obj,currentModel)
            if(~strcmp(currentModel,obj.ModelName))
                set_param(currentModel,'ProtectedModelCreator',{});
            end


            oldCS=getActiveConfigSet(currentModel);
            oldCSName=oldCS.name;


            tmpCS=obj.OrigCSValues(currentModel);
            attachConfigSet(currentModel,tmpCS,true);
            setActiveConfigSet(currentModel,tmpCS.name);


            detachConfigSet(currentModel,oldCSName);
            tmpCS.name=oldCSName;

        end






        function out=addCodegenCallback(~)
            out=true;
        end


        function out=getBuildDir(~,mdlName)
            out=RTW.getBuildDir(mdlName);
        end
        function ddName=getDataDictionaryNameToKeepVariables(~)

            ddName=getString(message...
            ('Simulink:protectedModel:dataDictionaryToConfirmChecksumMismatch'));
        end

        function map=getMapFileNameToKeepVariables(~)

            map=getString(message...
            ('Simulink:protectedModel:mapToConfirmChecksumMismatch'));
        end



        function varNameInDD=getVariableNameInChecksumDD(~,varName,datasource)

            if(~isempty(datasource))
                varNameInDD=Simulink.dd.private.getQualifiedVarName(varName,datasource);
            else
                varNameInDD=varName;
            end
        end

        function generateDataDictionarytoFindChecksumMissmatch(obj,dataDictionaryFile)

            ddObj=Simulink.data.dictionary.open(dataDictionaryFile);
            ocDD=onCleanup(@()Simulink.data.dictionary.closeAll(dataDictionaryFile,'-save'));
            ddSection=ddObj.getSection('Design Data');
            dataAccessor=Simulink.data.DataAccessor.createForGlobalNameSpaceClosure(obj.ModelName);


            mapVariables=containers.Map('KeyType','char','ValueType','char');


            for i=1:numel(obj.GlobalVariables.VariableName)


                qualifiedName=obj.getVariableNameInChecksumDD...
                (obj.GlobalVariables.VariableName{i},obj.GlobalVariables.Source{i});
                newVar=['v',int2str(i)];
                mapVariables(qualifiedName)=newVar;

                varId=dataAccessor.identifyByName(obj.GlobalVariables.VariableName{i});
                if isequal(numel(varId),1)
                    objOfVariable=dataAccessor.getVariable(varId);


                    if~isa(objOfVariable,'Simulink.ConfigSet')&&...
                        ~isa(objOfVariable,'Simulink.ConfigSetRef')
                        ddSection.addEntry(newVar,objOfVariable);
                    end
                else

                    for j=1:numel(varId)
                        dataSource=obj.GlobalVariables.Source{i};
                        if isempty(dataSource)
                            dataSource='base workspace';
                        end
                        if(strcmp(dataSource,varId(j).getDataSourceFriendlyName))
                            objOfVariable=dataAccessor.getVariable(varId(j));
                            if~isa(objOfVariable,'Simulink.ConfigSet')&&...
                                ~isa(objOfVariable,'Simulink.ConfigSetRef')
                                ddSection.addEntry(newVar,objOfVariable);
                            end
                        end

                    end
                end
            end



            save(obj.getMapFileNameToKeepVariables(),'mapVariables');



            ocDD.delete();

        end

        function nonInlineSFcns=getNonInlineSfcs(obj)
            nonInlineSFcns={};
            if obj.HasSILPILSupportOnly
                return;
            end
            lSystemTargetFile=get_param(obj.getModelName(),'SystemTargetFile');
            MF0File=coder.internal.modelRefUtil...
            (obj.getModelName(),'getModelRefInfoFileName','SIM',lSystemTargetFile);
            parser=mf.zero.io.XmlParser;
            parsedContents=parser.parseFile(MF0File);
            paramInfo=parsedContents.sFcnInfo;
            for i=1:paramInfo.Size
                if paramInfo(i).willBeDynamicallyLoaded
                    mexFileName=[paramInfo(i).name,'.',mexext];
                    nonInlineSFcns{end+1}=mexFileName;%#ok<AGROW> 
                end
            end
        end
        function tunableParams=getSimulationTunableParams(obj)
            tunableParams={};
            if(slfeature('ProtectedModelTunableParameters')<2||~obj.supportsSimTargetMex)
                return;
            end

            simInfoStruct=obj.loadBInfoStruct('SIM');


            if~isfield(simInfoStruct.modelInterface,'TunableParamsList')
                return;
            end

            if(numel(simInfoStruct.modelInterface.TunableParamsList)==1)
                tunableParams={simInfoStruct.modelInterface.TunableParamsList.Identifier};
            else
                tunableParams=cellfun(@(x)x.Identifier,simInfoStruct.modelInterface.TunableParamsList,'UniformOutput',false);
            end
            tunableParams=cellfun(@(x)obj.getOrigVarName(x),tunableParams,'UniformOutput',false);

        end

        function var=getOrigVarName(~,name)


            var=Simulink.dd.getVarAndDictionaryNameFromQualifiedName(name);
        end
        function globalVars=getSimulationGlobalVariables(obj)
            globalVars={};
            if~obj.supportsSimTargetMex
                return;
            end
            globalVars=obj.getGlobalVariablesForTarget('SIM');
        end

        function globalVars=getCodeGenGlobalVariables(obj)
            globalVars={};


            if obj.getSupportsHDL()||~obj.supportsSimTargetMex
                return;
            end

            if obj.isTopModelCode
                globalVars=obj.getGlobalVariablesForTarget('NONE');
            else
                globalVars=obj.getGlobalVariablesForTarget('RTW');
            end
        end
        function globalVars=getGlobalVariablesForTarget(obj,targetType)
            globalVars={};
            if(slfeature('ProtectedModelTunableParameters')<2)
                return;
            end

            infoStruct=obj.loadBInfoStruct(targetType);
            globalVariablesStr=infoStruct.globalsInfo.ProtectedModelInterfaceVariables;
            globalVars=strsplit(globalVariablesStr,',');

        end

        function out=getTunableParamInCodegenButNoSim(obj)
            globalVarsForCodegen=obj.getCodeGenGlobalVariables();
            globalVarsForSim=obj.getSimulationGlobalVariables();
            out=setdiff(globalVarsForCodegen,globalVarsForSim);
        end



        function info=getExtraInformation(obj)
            isTopModelCode=obj.isTopModelCode;

            if obj.supportsSimTargetMex
                simInfoStruct=obj.loadBInfoStruct('SIM');
            elseif isTopModelCode
                simInfoStruct=obj.loadBInfoStruct('NONE');
            else
                simInfoStruct=obj.loadBInfoStruct('RTW');
            end
            info=Simulink.ModelReference.ProtectedModel.Information(obj);
            info.simInterfaceChecksum=simInfoStruct.interfaceChecksum;

            if obj.supportsCodeGen()&&obj.getSupportsC()
                if isTopModelCode
                    tgtType='NONE';
                else
                    tgtType='RTW';
                end
                coderInfoStruct=obj.loadBInfoStruct(tgtType);

                info.setRTWInterfaceChecksum(coderInfoStruct.interfaceChecksum);
            end

            info.modelName=obj.ModelName;
            info.slprjVersion=coder.internal.folders.MarkerFile.getCurrentVersion();
        end









        function out=supportsCodeGen(obj)
            out=strcmp(obj.Modes,'CodeGeneration');
        end


        function out=supportsHDLCodeGen(obj)
            out=strcmp(obj.Modes,'CodeGeneration')&&obj.getSupportsHDL();
        end


        function out=supportsSimTargetMex(obj)
            out=~obj.IsCrossReleaseWorkflow;
        end


        function out=supportsAccel(obj)
            out=(obj.supportsCodeGen()||strcmp(obj.Modes,'Accelerator'))&&~obj.IsCrossReleaseWorkflow;
        end


        function out=supportsNormal(obj)
            out=obj.supportsAccel||strcmp(obj.Modes,'Normal');
        end


        function out=supportsView(obj)
            out=obj.Webview;
        end


        function out=isViewOnly(obj)
            out=strcmp(obj.Modes,'ViewOnly');
        end


        function out=hasCustomHook(obj)
            out=~isempty(obj.CustomHookCommand);
        end


        function out=hasCallbacks(obj)
            out=~isempty(obj.CallbackMgr)&&~isempty(obj.CallbackMgr.Callbacks);
        end


        function out=hasCallbackForFunctionality(obj,appliesTo)
            out=false;
            if obj.hasCallbacks()
                for i=1:length(obj.CallbackMgr.Callbacks)
                    callback=obj.CallbackMgr.Callbacks{i};
                    if strcmp(callback.AppliesTo,appliesTo)
                        out=true;
                        return;
                    end
                end
            end
        end

        function result=getModelName(obj)
            result=obj.ModelName;
        end

        function result=getListOfSubModels(obj)
            result=obj.SubModels;
        end


        function infoStruct=getInfoFromBinfoFile(obj,modelName,targert,lSystemTargetFile,action)
            if(~isempty(intersect({modelName},obj.SubModelsWithFile)))
                infoStruct=coder.internal.infoMATPostBuild...
                (action,'binfo',modelName,targert,lSystemTargetFile);
            else

                buildDir=obj.MapFromModelNameToBuildDir(modelName);
                if(strcmp(targert,'NONE'))
                    matFile=fullfile(buildDir.ModelRefRelativeBuildDir,'tmwinternal','binfo.mat');

                elseif(strcmp(targert,'SIM'))
                    matFile=fullfile(buildDir.ModelRefRelativeSimDir,'tmwinternal','binfo_mdlref.mat');

                else
                    matFile=fullfile(buildDir.ModelRefRelativeBuildDir,'tmwinternal','binfo_mdlref.mat');

                end
                infoStruct=coder.internal.infoMATFileMgr('loadPostBuild','binfo',...
                modelName,...
                targert,...
                matFile,false);
            end

        end


        function info=getListOfOrderedSubModels(obj)
            info=struct('name',obj.SubModels,'buildDir',obj.MapFromModelNameToBuildDir.values(obj.SubModels));
        end




        function setMode(obj,value)
            lowercaseValue=lower(value);
            switch(lowercaseValue)
            case 'normal'
                obj.enableSupportForNormal();
            case 'accelerator'
                obj.enableSupportForAccel();
            case 'codegeneration'
                obj.enableSupportForCodeGen();
            case 'hdlcodegeneration'
                obj.enableSupportForHDLCodeGen();
            case 'viewonly'
                obj.enableSupportForViewOnly();
            otherwise
                DAStudio.error('Simulink:protectedModel:InvalidProtectedModelMode',value);
            end
        end


        function setCallbacks(obj,value)
            obj.CallbackMgr=Simulink.ModelReference.ProtectedModel.CallbackManager(value);
        end


        function enableSupportForCodeGen(obj)
            if(~builtin('license','test','Real-Time_Workshop'))
                DAStudio.error('Simulink:protectedModel:SimulinkCoderLicenseRequired');
            end
            obj.Modes='CodeGeneration';
            obj.setSupportsC(true);
        end


        function enableSupportForHDLCodeGen(obj)
            if~slfeature('ProtectedModelWithGeneratedHDLCode')
                DAStudio.error('Simulink:protectedModel:ProtectedModelUnsupportedWithHDLCode');
            end

            if~dig.isProductInstalled('HDL Coder')
                DAStudio.error('Simulink:protectedModel:HDLCoderLicenseRequired');
            end

            obj.Modes='CodeGeneration';
            obj.setSupportsHDL(true);
        end


        function enableSupportForViewOnly(obj)
            obj.enableSupportForView();
            obj.Modes='ViewOnly';
        end


        function removeSupportForView(obj)
            obj.Webview=false;
        end


        function enableSupportForView(obj)


            if(~builtin('license','test','Simulink_Report_Gen'))
                DAStudio.error('Simulink:protectedModel:SimulinkReportGenLicenseRequired');
            end
            obj.Webview=true;
        end


        function enableSupportForAccel(obj)
            obj.Modes='Accelerator';
        end


        function enableSupportForNormal(obj)
            obj.Modes='Normal';
        end


        function setCreateHarness(obj,val)
            obj.CreateHarness=val;
        end

        function setProjectName(obj,val)
            if isempty(val)
                DAStudio.error('Simulink:protectedModel:ProtectedModelEmptyProjectName');
            end
            obj.ProjectName=val;
        end

        function setCreateProject(obj,val)
            obj.CreateProject=val;
        end


        function setPackagePath(obj,packagePath)
            if isempty(packagePath)
                DAStudio.error('Simulink:protectedModel:ProtectedModelEmptyOutputDirectory');
            end
            obj.ZipPath=packagePath;
        end


        function out=packageSourceCode(obj)
            out=~obj.BinariesAndHeadersOnly;
        end


        function out=packageAllSourceCode(obj)
            out=~obj.BinariesAndHeadersOnly&&obj.AllFilesForStandaloneBuild;
        end


        function out=packageAllHDLCode(obj)
            out=obj.AllHDLCodeGenArtifacts;
        end


        function enablePackagingAllHDLCode(obj)
            obj.AllHDLCodeGenArtifacts=true;
        end


        function enablePackagingAllSourceCode(obj)
            obj.BinariesAndHeadersOnly=false;
            obj.AllFilesForStandaloneBuild=true;
        end


        function enablePackagingBinariesOnly(obj)
            obj.BinariesAndHeadersOnly=true;
            obj.AllFilesForStandaloneBuild=false;
        end


        function enablePackagingMinimalCode(obj)
            obj.BinariesAndHeadersOnly=false;
            obj.AllFilesForStandaloneBuild=false;
        end


        function setObfuscation(obj,val)
            obj.ObfuscateCode=val;
        end


        function setCodeInterface(obj,val)



            if~obj.IsCodeInterfaceFeatureAvailable&&strcmp(val,'Top model')
                DAStudio.error('Simulink:protectedModel:EmbeddedCoderLicenseRequiredCodeInterface');
            end

            assert(any(strcmp(val,{'Model reference','Top model'})),...
            'Invalid code interface type %s.',val);
            obj.CodeInterface=val;
        end


        function enableReport(obj)
            obj.Report=true;
        end


        function disableReport(obj)
            obj.Report=false;
        end


        function enableEncryption(obj)
            obj.Encrypt=true;
        end


        function setSign(obj,val)
            obj.Sign=true;
            obj.CertFile=val;
        end




        function setModifiable(obj,val)
            obj.isModifyEncrypted=val;
        end

        function out=getModifiable(obj)
            out=obj.isModifyEncrypted;
        end

        function addSupportForCodegen(obj)
            obj.enableSupportForCodeGen();
            obj.enablePackagingMinimalCode();
        end


        function addSupportForHDLCodegen(obj)
            obj.enableSupportForHDLCodeGen();
        end


        function removeSupportForCodegen(obj)
            obj.Modes='Accelerator';
            obj.enablePackagingBinariesOnly();
        end


        function setCustomHookCommand(obj,val)
            obj.CustomHookCommand=val;
        end


        function out=getSupportedTargets(obj)
            out={obj.Target};
        end


        function out=getSupportedTargetsStr(obj)
            out=strjoin(obj.getSupportedTargets(),',');
        end

        function result=getMiscFileType(~)
            result=slInternal('getProtectedModelTempFileExtension');
        end




        function out=isCodeGenParameterProtectionActive(obj)
            out=(slfeature('ProtectedModelTunableParameters')==1)&&...
            ~obj.AreAllParameterAccessible();
        end
        function out=areAllParametersTunable(obj)
            if~slfeature('ProtectedModelTunableParameters')
                out=true;
            elseif slfeature('ProtectedModelTunableParameters')>1
                out=length(obj.TunableVarNames)==1&&...
                strcmp(obj.TunableVarNames{1},'-all');
            else
                out=obj.AreAllParameterAccessible();
            end

        end
        function out=isAllParametersProtected(obj)
            out=isempty(obj.TunableVarNames)||...
            (length(obj.TunableVarNames)==1&&...
            strcmp(obj.TunableVarNames{1},'-none'));
        end

        function out=AreAllParameterAccessible(obj)
            out=false;
            if length(obj.AccessibleVarNames)==1&&...
                strcmp(obj.AccessibleVarNames{1},'-all')
                out=true;
            end
        end


        function out=AreAllSignalAccessible(obj)
            out=~slfeature('ProtectedModelTunableParameters')==1||...
            (length(obj.AccessibleSigNames)==1&&...
            strcmp(obj.AccessibleSigNames{1},'-all'));
        end


        function out=getSupportsHDL(obj)
            out=obj.HasHDLSupport;
        end

        function setSupportsHDL(obj,value)
            obj.HasHDLSupport=value;
        end

        function out=getSupportsC(obj)
            out=obj.HasCSupport;
        end

        function setSupportsC(obj,value)
            obj.HasCSupport=value;
        end

        function setTunableParameters(obj,TunableVars)

            obj.TunableVarNames=TunableVars;
        end

        function tunableVar=getTunableParameters(obj)
            if slfeature('ProtectedModelTunableParameters')>1
                tunableVar=obj.TunableVarNames;
            else
                tunableVar=obj.getAccessibleParameters();
            end
        end

        function setAccessibleParameters(obj,accessibleVar)

            obj.AccessibleVarNames=accessibleVar;
        end

        function accessibleVar=getAccessibleParameters(obj)
            accessibleVar=obj.AccessibleVarNames;
        end

        function setAccessibleSignals(obj,accessibleSig)

            obj.AccessibleSigNames=accessibleSig;
        end


        function accessibleSig=getAccessibleSignals(obj)

            accessibleSig=obj.AccessibleSigNames;
        end


        function storeParameterIdentifierMapping(obj,unprotectedId,protectedId)
            assert(slfeature('ProtectedModelTunableParameters')==1)
            obj.UnprotectedParamIdToProtectedId(unprotectedId)=protectedId;
        end

        function protectedId=getParameterIdentifierMapping(obj,unprotectedId)
            protectedId='';
            if obj.UnprotectedParamIdToProtectedId.isKey(unprotectedId)
                protectedId=obj.UnprotectedParamIdToProtectedId(unprotectedId);
            end
        end

        function out=generatingObfuscatedParameterMapping(~)
            out=false;
        end


        function storeSignalIdentifierMapping(obj,unprotectedId,protectedId)
            assert(slfeature('ProtectedModelTunableParameters')==1)
            obj.UnprotectedSigIdToProtectedId(unprotectedId)=protectedId;
        end

        function protectedId=getSignalIdentifierMapping(obj,unprotectedId)
            protectedId='';
            if obj.UnprotectedSigIdToProtectedId.isKey(unprotectedId)
                protectedId=obj.UnprotectedSigIdToProtectedId(unprotectedId);
            end
        end

        function out=generatingObfuscatedSignalMapping(~)
            out=false;
        end




        function neededvars=findNeededVariables(obj,mdl,refMdls,lModelReferenceTargetTypeList)
            function isudd=loc_isudd(object)
                try
                    classh=classhandle(object);
                catch me %#ok<NASGU>
                    classh=[];
                end

                isudd=isa(classh,'schema.class');
            end

            function isneeded=loc_isneeded(varname)
                try


                    varval=Simulink.dd.getVarValuefromQualifiedName(mdl,varname,'Global');
                catch me

                    if strcmp(me.identifier,'SLDD:sldd:InvalidEvalinCommand')
                        varval=Simulink.dd.getVarValuefromQualifiedName(mdl,varname,'Configurations');
                    else


                        varval=sl('slbus_get_object_from_name',varname,true);%#ok<NASGU> 
                        isneeded=false;
                        return;
                    end
                end
                isneeded=isobject(varval)||loc_isudd(varval)||...
                (slfeature('ProtectedModelTunableParameters')>0&&isa(varval,'numeric'));
            end

            function[varname,varDic]=loc_getvarname(qualifiedname)
                [varname,varDic]=Simulink.dd.getVarAndDictionaryNameFromQualifiedName(qualifiedname);
                varDic=varDic{:};
            end

            allvars={};
            allDataDictionaryFiles={};



            lSystemTargetFile=get_param(mdl,'SystemTargetFile');

            for i=1:length(refMdls)

                refMdl=refMdls{i};
                infoStruct=obj.getInfoFromBinfoFile(refMdl,lModelReferenceTargetTypeList{i},lSystemTargetFile,'load');

                mdlvars=infoStruct.globalsInfo.GlobalParamInfo.VarList;


                if(~isempty(mdlvars))
                    splitvars=regexp(mdlvars,' *, *','split');

                    allvars=[allvars,splitvars];%#ok<AGROW>
                end

                DataDicionary=infoStruct.designDataLocation;
                if(~isempty(DataDicionary)&&~strcmp(DataDicionary,'base'))
                    allDataDictionaryFiles=[allDataDictionaryFiles,DataDicionary];%#ok<AGROW> 
                end
            end


            uniquevars=unique(allvars);


            uniquevars=uniquevars(cellfun(@loc_isneeded,uniquevars));


            [neededvars,neededDics]=cellfun(@loc_getvarname,uniquevars,'UniformOutput',false);
            Source=neededDics';
            VariableName=neededvars';
            obj.GlobalVariables=table(Source,VariableName);
            neededvars=unique(neededvars);
            obj.DataDictionaries=unique(allDataDictionaryFiles);
        end

    end

    methods(Access=protected)


        function modelsAndDir=getModelNameAndBuildDirMap(obj)


            modelsAndDir=containers.Map('KeyType','char','ValueType','any');

            for i=1:length(obj.SubModelsWithFile)
                currentModelWithFile=obj.SubModelsWithFile{i};

                if~modelsAndDir.isKey(currentModelWithFile)
                    isProtected=Simulink.filegen.internal.Helpers.isProtectedModel(currentModelWithFile);


                    if(~isProtected)
                        modelsAndDir(currentModelWithFile)=RTW.getBuildDir(currentModelWithFile);
                    elseif(~strcmp(obj.Modes,'ViewOnly'))
                        [~,fullName]=slInternal('getReferencedModelFileInformation',...
                        slInternal('getPackageNameForModel',currentModelWithFile));
                        if(~isempty(fullName))
                            opts=slInternal('getProtectedModelExtraInformation',fullName);
                            currentSubModels=opts.subModels;
                            for j=1:length(currentSubModels)
                                modelsAndDir(currentSubModels{j})=opts.getBuildDirFromModel(currentSubModels{j});
                            end
                        end
                    end
                end
            end
        end





        function shouldContinue=showBlockingPasswordDlg(obj,askForVerification)




            [returnValue,exc]=Simulink.ModelReference.ProtectedModel.showPasswordDialogForCommandLine(obj,askForVerification);
            shouldContinue=true;

            if~strcmp(returnValue,'Done')

                shouldContinue=false;
                if~isempty(exc)&&isa(exc,'MException')
                    throw(exc);
                elseif strcmp(returnValue,'NotDone')

                    obj.throwError('Simulink:protectedModel:ProtectedModelPasswordNotProvidedAbortCreation',obj.ModelName);
                else

                    assert(false,'Protected model creation process in incorrect state!');
                end
            end
        end



        function out=hasCustomHookCommand(obj)
            out=~isempty(obj.CustomHookCommand);
        end



        function out=webviewOnly(obj)
            if obj.supportsView()&&~obj.supportsNormal()
                out=true;
            else
                out=false;
            end
        end




        function out=isThumbnailEnabled(obj)
            viewPassword=Simulink.ModelReference.ProtectedModel.PasswordManager.getPasswordForEncryptionCategory(obj.ModelName,'VIEW');
            if obj.Webview
                if obj.Encrypt&&~isempty(viewPassword)
                    out=false;
                else
                    out=true;
                end
            else
                out=false;
            end
        end



        function out=hasAnyPassword(obj)
            assert(strcmp(obj.Modes,'Accelerator')||strcmp(obj.Modes,'Normal')||strcmp(obj.Modes,'CodeGeneration')||strcmp(obj.Modes,'HDLCodeGeneration')||strcmp(obj.Modes,'ViewOnly'));
            out=obj.hasModifyPassword()||obj.hasAnyContentPassword();
        end



        function out=hasModifyPassword(obj)
            import Simulink.ModelReference.ProtectedModel.*;
            out=~isempty(PasswordManager.getPasswordForModify(obj.ModelName));
        end




        function out=hasAnyContentPassword(obj)
            import Simulink.ModelReference.ProtectedModel.*;
            encryptionCats={'VIEW','SIM','RTW','HDL'};
            out=false;
            for i=1:length(encryptionCats)
                encryptionCat=encryptionCats{i};
                out=out||~isempty(PasswordManager.getPasswordForEncryptionCategory(obj.ModelName,encryptionCat));
            end
        end

        function out=hasSimulationPassword(obj)
            import Simulink.ModelReference.ProtectedModel.*;
            out=~isempty(PasswordManager.getPasswordForEncryptionCategory(obj.ModelName,'SIM'));
        end

        function out=hasCodeGenerationPassword(obj)
            import Simulink.ModelReference.ProtectedModel.*;
            out=~isempty(PasswordManager.getPasswordForEncryptionCategory(obj.ModelName,'RTW'));
        end

        function out=hasViewPassword(obj)
            import Simulink.ModelReference.ProtectedModel.*;
            out=~isempty(PasswordManager.getPasswordForEncryptionCategory(obj.ModelName,'VIEW'));
        end

        function out=hasHDLPassword(obj)
            import Simulink.ModelReference.ProtectedModel.*;
            out=~isempty(PasswordManager.getPasswordForEncryptionCategory(obj.ModelName,'HDL'));
        end



        function clearPasswords(obj)
            if obj.hasAnyPassword()&&(obj.Encrypt||obj.getModifiable())
                Simulink.ModelReference.ProtectedModel.clearPasswordsForModel(obj.ModelName);
            end
        end




        function checkModelConfig(obj)







            if exist('coder.internal.xrel.CodeImportHook','class')==8&&...
                coder.internal.xrel.CodeImportHook.isAutosarCodeImport(obj.ModelName)
                obj.IsCrossReleaseWorkflow=true;
                obj.SubModels={obj.ModelName};
                obj.SubModelsWithFile={obj.ModelName};
                obj.createSimulationReport=false;
            end
            obj.ExistingSharedCode=get_param(obj.ModelName,'ExistingSharedCode');


            if~obj.IsCrossReleaseWorkflow&&~isempty(obj.ExistingSharedCode)
                obj.throwError('Simulink:protectedModel:existingSharedCodeConflict',...
                obj.ModelName,get_param(obj.ModelName,'ExistingSharedCode'));
            end


            if obj.hasModelCallbacks()
                obj.throwWarning('Simulink:protectedModel:ProtectedModelCallbackLostWarning',...
                obj.ModelName,...
                obj.ModelName);
            end


            mdlHandle=get_param(obj.ModelName,'handle');
            if Simulink.harness.isHarnessBD(mdlHandle)
                obj.throwError('Simulink:Harness:ProtectedModelNotSupported');
            end


            cs=getActiveConfigSet(obj.ModelName);
            hasASAP2Interface=cs.hasProp('GenerateASAP2')&&strcmp(get_param(cs,'GenerateASAP2'),'on');
            hasExternal=cs.hasProp('ExtMode')&&strcmp(get_param(cs,'ExtMode'),'on');
            hasCAPI=cs.hasProp('RTWCAPISignals')&&strcmp(get_param(cs,'RTWCAPISignals'),'on')||...
            cs.hasProp('RTWCAPIParams')&&strcmp(get_param(cs,'RTWCAPIParams'),'on')||...
            cs.hasProp('RTWCAPIStates')&&strcmp(get_param(cs,'RTWCAPIStates'),'on')||...
            cs.hasProp('RTWCAPIRootIO')&&strcmp(get_param(cs,'RTWCAPIRootIO'),'on');
            hasInterface=hasASAP2Interface||hasExternal||hasCAPI;
            if obj.supportsCodeGen()&&hasInterface
                obj.throwWarning('Simulink:protectedModel:InterfaceMayLeakIP',...
                obj.ModelName,...
                obj.ModelName);
            end



            if obj.generateCodeOnly&&~obj.packageSourceCode()&&obj.supportsCodeGen()
                obj.throwError('Simulink:protectedModel:GenerateCodeOnlyIncompatibleWithBinariesOnly');
            end
        end


        function out=hasModelCallbacks(obj)
            model_callbacks={...
            'CloseFcn',...
            'PostCodeGenCommand',...
            'DefineNamingFcn',...
            'DeleteChildFcn',...
            'InitFcn',...
            'PostLoadFcn',...
            'PostSaveFcn',...
            'PreLoadFcn',...
            'PreSaveFcn',...
            'StartFcn',...
            'PauseFcn',...
            'ContinueFcn',...
'StopFcn'
            };
            for i=1:length(model_callbacks)
                if~isempty(get_param(obj.ModelName,model_callbacks{i}))
                    out=true;
                    return;
                end
            end
            out=false;
        end

        function dirs=getBuildDirectories(obj,forSharedUtils)
            dirs={};


            buildDirs=obj.getBuildDir(obj.ModelName);

            if(forSharedUtils)
                rtwDir=fullfile(buildDirs.CodeGenFolder,buildDirs.SharedUtilsTgtDir);
                simDir=fullfile(buildDirs.CacheFolder,buildDirs.SharedUtilsSimDir);
            else
                if strcmp(obj.CodeInterface,'Top model')
                    rtwDir=fullfile(buildDirs.CodeGenFolder,buildDirs.RelativeBuildDir);
                    simDir=[];
                else
                    assert(strcmp(obj.CodeInterface,'Model reference'));
                    rtwDir=fullfile(buildDirs.CodeGenFolder,buildDirs.ModelRefRelativeBuildDir);
                    simDir=fullfile(buildDirs.CacheFolder,buildDirs.ModelRefRelativeSimDir);
                end
            end

            if~isempty(rtwDir)&&obj.supportsCodeGen()&&(exist(rtwDir,'dir')==7)
                dirs{end+1}=rtwDir;
            end

            if exist(simDir,'dir')==7
                dirs{end+1}=simDir;
            end

        end




        function obfuscateSharedUtils(obj)

            dirs=obj.getBuildDirectories(true);

            origDir=pwd;
            returnCleanup=onCleanup(@()cd(origDir));

            for dirIdx=1:length(dirs)
                cd(dirs{dirIdx});
                if obj.dirHasSource()
                    rtwprivate('doObfuscation',obj.ModelName,1,true);
                end

            end
        end


        function postCheckForProblems(obj)

            if obj.IsCrossReleaseWorkflow
                return;
            end

            if slfeature('ProtectedModelTunableParameters')>1&&...
                ~obj.areAllParametersTunable()

                tunableParameters=obj.getSimulationTunableParams();
                extraParam=setdiff(obj.TunableVarNames,tunableParameters);
                if~isempty(extraParam)
                    obj.throwWarning('Simulink:protectedModel:ParameterIsNotInTheListOfModelTunableParams',...
                    obj.ModelName,strjoin(extraParam,', '));
                end
            end


        end

        function cacheCreatorInBlockDiagram(obj)

            set_param(obj.ModelName,'ProtectedModelCreator',obj);
        end

        function clearCreatorFromBlockDiagram(obj)

            set_param(obj.ModelName,'ProtectedModelCreator',{});
        end






        function protectingMode(obj,protecting)
            import Simulink.ModelReference.ProtectedModel.*;

            if strcmp(protecting,'on')

                if obj.guiEntry
                    statusMessage=DAStudio.message('Simulink:protectedModel:creatingProtectedModel',obj.ModelName);


                    set_param(obj.parentModel,'StatusString',statusMessage);
                end




                if obj.webviewOnly()
                    obj.Target='viewonly';
                elseif~obj.supportsCodeGen()
                    obj.Target='sim';
                end
                setCurrentTarget(obj.ModelName,obj.Target);

                obj.cacheCreatorInBlockDiagram();
                obj.initialDir=pwd;
                obj.tmpBuildFolder=tempname;
                mkdir(obj.tmpBuildFolder);
                if~Creator.isOnMATLABPath(obj.initialDir)
                    addpath(obj.initialDir);
                    obj.addedPath=true;
                end






                obj.LatchedDefaultCompInfo=coder.internal.DefaultCompInfo.createDefaultCompInfo;




                cd(obj.tmpBuildFolder);




                obj.oldFileGenCfg=Simulink.fileGenControl('getConfig');
                obj.oldFileGenCfg.CacheFolder=Simulink.fileGenControl('getInternalValue','CacheFolder');
                obj.oldFileGenCfg.CodeGenFolder=Simulink.fileGenControl('getInternalValue','CodeGenFolder');

                Simulink.fileGenControl('set','CacheFolder',obj.tmpBuildFolder,...
                'CodeGenFolder',obj.tmpBuildFolder);

            elseif strcmp(protecting,'off')


                if obj.guiEntry
                    statusMessage=DAStudio.message('Simulink:editor:DefaultFlybyStr');
                    set_param(obj.parentModel,'StatusString',statusMessage);
                end
                obj.clearCreatorFromBlockDiagram();
            else
                obj.throwError('Simulink:protectedModel:invalidProtectingMode');
            end
        end

        function backToInitialDir(obj)


            Simulink.fileGenControl('setConfig','Config',obj.oldFileGenCfg);

            cd(obj.initialDir);
            slprivate('removeDir',obj.tmpBuildFolder);


            if obj.addedPath
                rmpath(obj.initialDir);
                obj.addedPath=false;
            end
        end










        function[lModelReferenceTargetTypeList]=getModelReferenceTargetTypesForTargetType(obj,lModelReferenceTargetTypeTop)
            if strcmp(lModelReferenceTargetTypeTop,'SIM')
                lModelReferenceTargetTypeList=repmat({'SIM'},1,numel(obj.SubModels));
            else
                lModelReferenceTargetTypeList=repmat({'RTW'},1,numel(obj.SubModels));
                if strcmp(lModelReferenceTargetTypeTop,'NONE')
                    lModelReferenceTargetTypeList{strcmp(obj.SubModels,obj.ModelName)}='NONE';
                end
            end
        end
        function[lModelReferenceTargetTypeList,lModelReferenceTargetTypeTop]=getAllModelReferenceTargetTypes(obj)
            if obj.supportsSimTargetMex
                lModelReferenceTargetTypeTop='SIM';
                lModelReferenceTargetTypeList=obj.getModelReferenceTargetTypesForTargetType('SIM');
            elseif obj.isTopModelCode
                lModelReferenceTargetTypeTop='NONE';
                lModelReferenceTargetTypeList=obj.getModelReferenceTargetTypesForTargetType('NONE');
            else
                lModelReferenceTargetTypeTop='RTW';
                lModelReferenceTargetTypeList=obj.getModelReferenceTargetTypesForTargetType('RTW');
            end
        end
    end


    methods(Access=private)

        function setSILPILsupport(obj)
            if obj.supportsCodeGen&&...
                obj.getSupportsC&&...
                isequal(get_param(obj.ModelName,'IsERTTarget'),'on')
                if strcmp(obj.CodeInterface,'Top model')
                    tgt='NONE';
                else
                    assert(strcmp(obj.CodeInterface,'Model reference'));
                    tgt='RTW';
                end


                lSystemTargetFile=get_param(obj.ModelName,'SystemTargetFile');
                infoStruct=coder.internal.infoMATPostBuild...
                ('load','binfo',obj.ModelName,tgt,lSystemTargetFile);

                if infoStruct.IsPortableWordSizesEnabled

                    obj.HasSILSupport=true;
                    obj.HasPILSupport=true;
                elseif coder.internal.isERTAndHostBasedBuild(infoStruct.configSet,...
                    obj.ProtectedModelCompInfo,...
                    tgt)

                    obj.HasSILSupport=true;
                    obj.HasPILSupport=false;
                else

                    obj.HasSILSupport=false;
                    obj.HasPILSupport=true;
                end



                if obj.IsCrossReleaseWorkflow
                    obj.HasSILPILSupportOnly=true;
                end
            end
        end


        function infoStruct=loadBInfoStruct(obj,tgtType)

            lSystemTargetFile=get_param(obj.ModelName,'SystemTargetFile');
            infoStruct=coder.internal.infoMATPostBuild('loadNoConfigSet',...
            'binfo',...
            obj.ModelName,...
            tgtType,...
            lSystemTargetFile);
        end


        function ret=isTopModelCode(obj)
            ret=strcmp(obj.CodeInterface,'Top model');
        end
    end

    methods(Static=true,Hidden=true)





        function origStrings=processConfigSetStrings(currentModel)
            origStrings={};
            ConfigSetStrParams={'SimCustomSourceCode',...
            'SimCustomHeaderCode',...
            'SimCustomInitializer',...
            'SimCustomTerminator',...
            'CustomSourceCode',...
            'CustomHeaderCode',...
            'CustomInitializer',...
            'CustomTerminator'};
            for currentIndex=1:length(ConfigSetStrParams)
                currentParam=ConfigSetStrParams{currentIndex};
                str=get_param(currentModel,currentParam);
                origStrings(currentIndex)={str};%#ok<AGROW>
                ofcString=Simulink.ModelReference.ProtectedModel.Creator.obfuscateString(str);
                if~isempty(ofcString)&&ischar(ofcString)
                    set_param(currentModel,currentParam,ofcString);
                end
            end
        end







        function out=obfuscateString(str)
            if~isempty(str)


                mkdir('ofc');
                cd('ofc');
                cln=onCleanup(@()Simulink.ModelReference.ProtectedModel.Creator.ofcCleanup());


                fileStart='obfuscateStr';
                fileExt='.c';
                fileName=[fileStart,fileExt];
                fid=fopen(fileName,'w');
                if(fid<0)
                    obj.throwError('Simulink:protectedModel:obfuscateString',str);
                end
                fwrite(fid,str);
                fclose(fid);


                obfuscate('.','.','',1);


                fileName=[fileStart,'_ofc',fileExt];
                fid=fopen(fileName,'r');
                if(fid<0)
                    obj.throwError('Simulink:protectedModel:obfuscateString',str);
                end

                out=[];



                line=fgets(fid);%#ok<NASGU>
                line=fgets(fid);

                while ischar(line)
                    out=[out,line];%#ok<AGROW>
                    line=fgets(fid);
                end
                fclose(fid);

            else
                out='';
            end
        end

        function ofcCleanup()
            delete('*');
            cd('..');
            slprivate('removeDir','ofc');
        end

        function out=isOnMATLABPath(aPath)
            out=false;
            if ispc
                delim=';';
            else
                delim=':';
            end
            currentPaths=textscan(path,'%s','delimiter',delim);
            currentPaths=currentPaths{1};
            for i=1:length(currentPaths)
                currentPath=currentPaths{i};
                if isequal(currentPath,aPath)
                    out=true;
                    return;
                end
            end
        end



        function throwError(errID,varargin)
            narginchk(1,inf);
            msg=message(errID,varargin{:});
            MSLE=MSLException([],msg);
            throw(MSLE);
        end

        function throwWarning(errId,modelName,varargin)
            narginchk(2,inf);
            warnMsg=message(errId,varargin{:});
            MSLE=MSLException(get_param(modelName,'Handle'),warnMsg);
            MSLDiagnostic(MSLE).reportAsWarning;

        end



        function doLicenseCheckRTW()
            import Simulink.ModelReference.ProtectedModel.*;
            if(builtin('_license_checkout','Real-Time_Workshop','quiet')~=0)

                Creator.throwError('Simulink:utility:invalidRTWLicense');
            end
        end


        function doLicenseCheckEC()
            import Simulink.ModelReference.ProtectedModel.*;
            if(builtin('_license_checkout','RTW_Embedded_Coder','quiet')~=0)

                Creator.throwError('Simulink:Engine:ECoder_LicenseError');
            end
        end

        function out=dirHasSource()
            out=~isempty(dir('*.c'))||~isempty(dir('*.h'));
        end



        function removeDir(dname)
            sl('removeDir',dname);
        end




        function removeDlg(dlg)
            if ishandle(dlg)
                dlg.delete;
            end
        end




        function out=getConfigSetParamValuePairs(obfuscateCode)
            retVal={};
            retVal{end+1}={'GenerateReport','off'};
            if obfuscateCode
                retVal{end+1}={'GenerateComments','off'};
            end
            retVal{end+1}={'CodeProfilingInstrumentation','off'};
            retVal{end+1}={'SILDebugging','off'};
            out=retVal;
        end
    end
end


function slBuildFcn=i_getSlBuildFcn(guiEntry,mdlRefTarget)

    if guiEntry
        slBuildGatewayFcn=@slInternal;
        isTopModelBuild=strcmp(mdlRefTarget,'StandaloneCoderTarget');
        if isTopModelBuild
            slBuildFcnName='slBuildMdlRefTop';
        else
            slBuildFcnName='slBuildMdlRef';
        end
    else
        slBuildGatewayFcn=@sl;
        slBuildFcnName='slbuild_private';
    end
    slBuildFcn=@(lModelName,lTarget,varargin)(...
    slBuildGatewayFcn(slBuildFcnName,lModelName,lTarget,varargin{:}));
end













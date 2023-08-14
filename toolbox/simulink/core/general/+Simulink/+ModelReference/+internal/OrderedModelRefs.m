classdef OrderedModelRefs<handle






    properties(Access=private)
TopModel
SearchForAllModels
ConfigSetActivator
IsRapidAccelerator
IsRSim
ModelReferenceRTWTargetOnly
ModelReferenceTargetType
OnlyCheckConfigsetMismatch
TopOfBuildModel
UpdateTopModelReferenceTarget
Verbose
XilInfo_IsModelBlockXil
XilInfo_UpdatingRTWTargetsForXil
isUpdatingSimForRTW
GenerateCodeOnly
NumOutputs
TargetName
ParBuild
ParBuildOrder
ParBuildInfo
AllOutputStruct
OutputStruct
ProtectedStruct
TopSimMode
TopIsNormalMode
TopSkipRebuildChecks
ModelRefInfo
TraversedModels
LibsToClose
OpenModelsAtStart
IsCodeVariant
PerformanceCleanup
UniqueModelRefFactory
IsLicensedForEcoder
IsModelRefSILPILOverride
ModelCompInfo
DefaultCompInfo
    end

    properties(Access=private,Dependent)


IsSIMTarget
    end

    properties(Constant,Access=private)
        NormalString='normal';
        AcceleratorString=Simulink.ModelReference.internal.SimulationMode.SimulationModeAccel;
        SILString=Simulink.ModelReference.internal.SimulationMode.SimulationModeSIL;
        PILString=Simulink.ModelReference.internal.SimulationMode.SimulationModePIL;
    end


    methods(Access=public)

        function this=OrderedModelRefs()
            this.resetProperties();
        end


        function delete(this)

            if~isempty(this.PerformanceCleanup)
                this.PerformanceCleanup.delete();
            end
        end



        function[oStruct,parBInfo,protOStruct,allStruct]=getOrderedModelRefs(this,...
            model,allModelRefs,numOutputs,varargin)


            this.resetProperties();
            this.setupForDFS(model,allModelRefs,numOutputs,varargin{:});


            isMdlRefXilTopCodeIntf=false;
            this.DFS(this.TopModel,this.TopIsNormalMode,this.TopSimMode,false,isMdlRefXilTopCodeIntf,this.TopSkipRebuildChecks);


            this.checkForCaseInsensitiveDuplicates();
            this.postProcess();


            oStruct=this.OutputStruct;
            protOStruct=this.ProtectedStruct;
            parBInfo=this.ParBuildInfo;
            allStruct=this.AllOutputStruct;
        end
    end

    methods
        function ret=get.IsSIMTarget(this)
            ret=strcmpi(this.ModelReferenceTargetType,'SIM');
        end
    end


    methods(Access=private)

        function resetProperties(this)
            this.TopModel='';
            this.SearchForAllModels=false;
            this.NumOutputs=1;
            this.TargetName='';
            this.OpenModelsAtStart={};
            this.ParBuild=false;
            this.ParBuildOrder=[];
            this.ParBuildInfo=[];
            this.TopSimMode='';
            this.TopSkipRebuildChecks=false;
            this.TopIsNormalMode=false;
            this.TraversedModels={};
            this.ModelRefInfo=[];
            this.LibsToClose={};
            this.OutputStruct=[];
            this.ProtectedStruct=[];
            this.IsCodeVariant=false;
            this.PerformanceCleanup=[];
            this.GenerateCodeOnly=false;
            this.IsModelRefSILPILOverride=false;
            this.ModelCompInfo=[];
            this.DefaultCompInfo=[];
        end



        function setupForDFS(this,model,allModelRefs,numOutputs,varargin)

            p=inputParser();
            p.addParameter('SimModeIn','',@ischar);
            p.addParameter('ConfigSetActivator',[]);
            p.addParameter('IsRapidAccelerator',false);
            p.addParameter('IsRSim',false);
            p.addParameter('ModelReferenceRTWTargetOnly',false);
            p.addParameter('ModelReferenceTargetType','NONE');
            p.addParameter('OnlyCheckConfigsetMismatch',false);
            p.addParameter('TopOfBuildModel','');
            p.addParameter('UpdateTopModelReferenceTarget',false);
            p.addParameter('Verbose',false);
            p.addParameter('XilInfo_IsModelBlockXil',false);
            p.addParameter('XilInfo_UpdatingRTWTargetsForXil',false);
            p.addParameter('isUpdatingSimForRTW',false);
            p.addParameter('GenerateCodeOnly',false);
            p.addParameter('ModelCompInfo',[]);
            p.addParameter('DefaultCompInfo',[]);

            p.parse(varargin{:});

            this.TopModel=model;
            this.SearchForAllModels=allModelRefs;
            if slfeature('ConfigSetActivator')>0
                this.ConfigSetActivator=p.Results.ConfigSetActivator;
            end
            this.IsRapidAccelerator=p.Results.IsRapidAccelerator;
            this.IsRSim=p.Results.IsRSim;
            this.ModelReferenceRTWTargetOnly=p.Results.ModelReferenceRTWTargetOnly;
            this.ModelReferenceTargetType=p.Results.ModelReferenceTargetType;
            this.OnlyCheckConfigsetMismatch=p.Results.OnlyCheckConfigsetMismatch;
            this.TopOfBuildModel=p.Results.TopOfBuildModel;
            this.UpdateTopModelReferenceTarget=p.Results.UpdateTopModelReferenceTarget;
            this.Verbose=p.Results.Verbose;
            this.XilInfo_IsModelBlockXil=p.Results.XilInfo_IsModelBlockXil;
            this.XilInfo_UpdatingRTWTargetsForXil=p.Results.XilInfo_UpdatingRTWTargetsForXil;
            this.isUpdatingSimForRTW=p.Results.isUpdatingSimForRTW;
            this.GenerateCodeOnly=p.Results.GenerateCodeOnly;
            this.ModelCompInfo=p.Results.ModelCompInfo;
            this.DefaultCompInfo=p.Results.DefaultCompInfo;

            this.NumOutputs=numOutputs;

            this.prepareBuildArgs();
            this.setupTargetName();


            PerfTools.Tracer.logSimulinkData('SLbuild',this.TopModel,...
            this.TargetName,'get_ordered_model_references',true);
            this.PerformanceCleanup=onCleanup(@()PerfTools.Tracer.logSimulinkData(...
            'SLbuild',this.TopModel,this.TargetName,...
            'get_ordered_model_references',false));

            this.OpenModelsAtStart=find_system('type','block_diagram');
            this.ParBuild=(this.NumOutputs>1);
            if this.ParBuild
                this.ParBuildOrder=Simulink.ModelReference.internal.ModelRefParBuildOrder();
            end


            if strcmp(this.TopOfBuildModel,this.TopModel)&&isempty(p.Results.SimModeIn)
                this.TopSimMode=this.getSimulationMode(this.TopModel);
            else
                this.TopSimMode=p.Results.SimModeIn;
            end



            bList=Simulink.ModelReference.RebuildManager.getBuildList(this.TopOfBuildModel);
            if isempty(bList)
                this.TopSkipRebuildChecks=false;
            else
                this.TopSkipRebuildChecks=true;
            end

            this.isTopModelNormalMode();
            this.isCodeVariant();
            this.IsLicensedForEcoder=license('test','rtw_embedded_coder');
            this.UniqueModelRefFactory=Simulink.ModelReference.internal.UniqueModelRefFactory(this.isUpdatingSimForRTW);
            this.IsModelRefSILPILOverride=Simulink.ModelReference.internal.ModelRefSILPILOverrideCache.isOverride();
        end


        function prepareBuildArgs(this)
            if this.XilInfo_UpdatingRTWTargetsForXil
                this.ModelReferenceTargetType='RTW';
                return;
            end

            if(this.ModelReferenceRTWTargetOnly&&this.IsSIMTarget)


                this.UpdateTopModelReferenceTarget=false;
            end
        end


        function setupTargetName(this)
            this.TargetName=sl('perf_logger_target_resolution',...
            this.ModelReferenceTargetType,...
            this.TopModel,false,false);
        end


        function isTopModelNormalMode(this)
            this.TopIsNormalMode=false;
            runningInAccel=this.runningInAccel();
            runningInRapidAccel=this.IsRapidAccelerator;
            if~this.UpdateTopModelReferenceTarget&&...
                strcmpi(this.ModelReferenceTargetType,'SIM')&&...
                ~runningInAccel&&~runningInRapidAccel
                this.TopIsNormalMode=true;
            end
        end







        function result=runningInAccel(this)
            simMode=get_param(this.TopModel,'SimulationMode');
            simStatus=get_param(this.TopModel,'SimulationStatus');
            mdlRefVmSim=strcmpi(get_param(this.TopModel,'MdlRefVMSimulationCompile'),'on');

            result=(strcmpi(simMode,this.AcceleratorString)&&...
            strcmp(simStatus,'initializing')&&...
            ~mdlRefVmSim);
        end


        function simMode=getSimulationMode(this,model)
            simMode=get_param(model,'SimulationMode');
            if(strcmpi(simMode,this.AcceleratorString)&&...
                strcmpi(get_param(model,'MdlRefVMSimulationCompile'),'on'))
                simMode=this.NormalString;
            end
        end



        function isCodeVariant(this)
            this.IsCodeVariant=(this.isUpdatingSimForRTW||...
            (strcmp(this.ModelReferenceTargetType,'SIM')&&...
            this.XilInfo_IsModelBlockXil))&&...
            ~Simulink.ModelReference.ProtectedModel.protectingModel(...
            this.TopOfBuildModel);
        end






        function DFS(this,model,isNormalMode,simMode,isProtected,isMdlRefXilTopCodeIntf,skipRebuildChecks)
            pathToModel=this.getPathToModel();

            modelRefWithModes={};
            if~isProtected
                this.refreshConfigSetRef(model);
                modelRefWithModes=this.get_mdlrefs(model,isNormalMode,simMode,isMdlRefXilTopCodeIntf);
            end

            if this.ParBuild



                this.setupParChildList(model,modelRefWithModes);
            end



            this.addModelToTraversedList(model);
            oc1=onCleanup(@()this.removeModelFromTraversedList());

            [mdlDirtyFlag,wsDirtyFlag,csDirtyFlag]=this.getDirtyFlags(model);
            [skipRebuildChecks,modelOnBuildList]=this.checkRebuildManager(model,skipRebuildChecks);

            childSkip=true;
            childrenList={};
            if~isempty(modelRefWithModes)
                childrenList={modelRefWithModes.modelName};
            end


            if this.SearchForAllModels
                [skipRebuildChecks,childSkip]=this.searchSubModels(model,modelRefWithModes,skipRebuildChecks,childSkip);
            end

            if modelOnBuildList||~childSkip
                skipRebuildChecks=false;
            end

            newMdlInfo.mdlRefs=model;
            newMdlInfo.pathToMdlRefs=pathToModel;
            newMdlInfo.dirtyFlags=mdlDirtyFlag;
            newMdlInfo.wsDirtyFlags=wsDirtyFlag;
            newMdlInfo.simprmDirtyFlags=csDirtyFlag;
            newMdlInfo.isNormalMode=isNormalMode;
            newMdlInfo.mdlRefSimMode=simMode;
            newMdlInfo.mdlRefTargetType=this.getTargetTypeBasedOnContext(model,simMode,isMdlRefXilTopCodeIntf);
            newMdlInfo.protected=isProtected;
            newMdlInfo.skipRebuild=skipRebuildChecks;
            newMdlInfo.childList=childrenList;
            this.ModelRefInfo=[this.ModelRefInfo;newMdlInfo];
        end


        function checkForCaseInsensitiveDuplicates(this)
            modelRefs={this.ModelRefInfo.mdlRefs};

            uniqueNames=unique(modelRefs);
            uniqueNamesLower=unique(lower(uniqueNames));
            if length(uniqueNames)==length(uniqueNamesLower)
                return;
            end

            for i=1:length(uniqueNamesLower)
                modelName=uniqueNamesLower(i);
                matches=strcmpi(modelName,uniqueNames);
                if~any(matches)
                    continue;
                end

                duplicateNames=uniqueNames(matches);
                DAStudio.error('Simulink:modelReference:duplicatedMdlRefsName',...
                duplicateNames{1},duplicateNames{2});
            end
        end

        function postProcess(this)
            this.LibsToClose=sl...
            ('mdlRefComputeLibrariesToClose',...
            this.ModelRefInfo,...
            this.OpenModelsAtStart);

            modelRefs={this.ModelRefInfo.mdlRefs};
            numModelRefs=length(modelRefs);

            for index=1:numModelRefs




                if(index~=numModelRefs)&&this.IsSIMTarget&&this.ModelRefInfo(index).isNormalMode
                    continue;
                end
                this.storeInOutputStruct(index);
            end

            if~isempty(this.OutputStruct)
                this.ProtectedStruct=this.OutputStruct([this.OutputStruct.protected]==1);
                this.OutputStruct=this.OutputStruct([this.OutputStruct.protected]==0);
            end










            this.AllOutputStruct=this.OutputStruct;

            if this.IsSIMTarget&&(this.TopIsNormalMode||this.runningInAccel())





                bIsXIL=this.isSILOrPILMode({this.OutputStruct.mdlRefSimMode});
                this.OutputStruct=this.OutputStruct(~bIsXIL);
            end

            if this.ParBuild&&~isempty(this.OutputStruct)
                this.ParBuildInfo=this.ParBuildOrder.getParallelBuildStruct(this.OutputStruct);
            end
        end

        function storeInOutputStruct(this,index)
            modelName=this.ModelRefInfo(index).mdlRefs;
            if this.ParBuild
                childInfo=this.ParBuildOrder.getChildren(modelName);
                directParentInfo=this.ParBuildOrder.getGrandParents(modelName);
                protectedChildInfo=this.ParBuildOrder.getProtectedChildren(modelName);
            else
                childInfo.children={};
                childInfo.childSimMode={};
                directParentInfo.grandparents={};
                protectedChildInfo.children={};
                protectedChildInfo.childSimMode={};
            end

            closeLibs={};
            if~isequal(modelName,this.TopModel)&&this.LibsToClose.isKey(modelName)
                closeLibs=this.LibsToClose(modelName);
            end

            info.modelName=modelName;
            info.pathToMdlRef=this.ModelRefInfo(index).pathToMdlRefs;
            info.dirty=this.ModelRefInfo(index).dirtyFlags;
            info.wsDirty=this.ModelRefInfo(index).wsDirtyFlags;
            info.simPrmDirty=this.ModelRefInfo(index).simprmDirtyFlags;
            info.children=childInfo.children;
            info.childSimMode=childInfo.childSimMode;
            info.directParents=directParentInfo.grandparents;
            info.protected=this.ModelRefInfo(index).protected;
            info.libsToClose=closeLibs;
            info.mdlRefSimMode=this.ModelRefInfo(index).mdlRefSimMode;
            info.protectedChildren=protectedChildInfo.children;
            info.protectedChildSimMode=protectedChildInfo.childSimMode;
            info.skipRebuild=this.ModelRefInfo(index).skipRebuild;

            if isempty(this.OutputStruct)
                this.OutputStruct=info;
            else
                this.OutputStruct(end+1)=info;
            end
        end


        function addModelToTraversedList(this,model)
            this.TraversedModels=[this.TraversedModels,{model}];
        end


        function removeModelFromTraversedList(this)
            this.TraversedModels=this.TraversedModels(1:end-1);
        end


        function refreshConfigSetRef(~,model)

            if~bdIsLoaded(model)
                return;
            end
            cs=getActiveConfigSet(model);
            if isa(cs,'Simulink.ConfigSetRef')
                cs.refresh;
            end
        end


        function setupParChildList(this,model,modelRefWithModes)
            if(this.SearchForAllModels&&~isempty(modelRefWithModes))
                trimmed=modelRefWithModes;
                nonProtectedModels=trimmed(~[trimmed(:).protected]);
                protectedModels=trimmed([trimmed(:).protected]);
                children={nonProtectedModels.modelName};
                childSimMode={nonProtectedModels.simMode};
                protectedChildren={protectedModels.modelName};
                protectedChildSimMode={protectedModels.simMode};
            else
                children={};
                childSimMode={};
                protectedChildren={};
                protectedChildSimMode={};
            end

            directParent={};
            if this.SearchForAllModels&&~isempty(this.TraversedModels)
                directParent=this.TraversedModels(end);
            end

            this.ParBuildOrder.setElements(model,children,childSimMode,directParent,...
            protectedChildren,protectedChildSimMode);
        end


        function[mdlDirtyFlag,wsDirtyFlag,csDirtyFlag]=getDirtyFlags(~,model)
            mdlDirtyFlag=false;
            wsDirtyFlag=false;
            csDirtyFlag=false;

            if bdIsLoaded(model)
                cs=getActiveConfigSet(model);
                dialog=cs.getDialogHandle();
                if~isempty(dialog)&&isa(dialog,'DAStudio.Dialog')...
                    &&dialog.hasUnappliedChanges
                    csDirtyFlag=true;
                end
                mdlDirtyFlag=strcmp(get_param(model,'Dirty'),'on');
                modelWorkspace=get_param(model,'ModelWorkspace');
                wsDirtyFlag=modelWorkspace.isDirty;
            end
        end


        function result=getPathToModel(this)
            result='';
            if~isempty(this.TraversedModels)
                result=strjoin(this.TraversedModels,':');
            end
        end











        function result=get_mdlrefs(this,model,isNormalMode,simModeParent,isParentMdlRefXilTopCodeIntf)

            if isNormalMode
                result=this.processNormalMode(model,isNormalMode,simModeParent);
            else
                result=this.processNonNormalMode(model,isNormalMode,simModeParent,isParentMdlRefXilTopCodeIntf);
            end

            result=this.overrideSimMode(result,model,simModeParent);
        end



        function result=processNormalMode(this,model,isNormalMode,simModeParent)
            load_system(model);
            Simulink.ModelReference.internal.ModelRefSILPILOverrideCache.attachOverride(model);



            Simulink.filegen.internal.FolderConfiguration(model);

            if slfeature('ConfigSetActivator')>0&&...
                ~isempty(this.ConfigSetActivator)
                this.ConfigSetActivator.activate(model);
            end




            options={'FollowLinks','on','LookUnderMasks','all','LookUnderReadProtectedSubsystems','on'};
            options{end+1}='MatchFilter';
            options{end+1}=@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices;
            blocks=find_system(model,options{:},'BlockType','ModelReference');



            protected=this.getIsProtectedByBlock(blocks,this.IsCodeVariant);
            this.refreshModelBlocks(blocks(protected));

            [nonUniqueModelRefs,...
            nonUniqueModelRefSimModes,...
            nonUniqueModelRefCodeInterface]=...
            coder.internal.getNonUniqueModelRefsByBlock(blocks,this.IsCodeVariant);

            protectedModelRefs=nonUniqueModelRefs(protected);
            protectedModelRefSimModes=nonUniqueModelRefSimModes(protected);
            protectedModelRefCodeInterface=nonUniqueModelRefCodeInterface(protected);

            nonUniqueModelRefs=nonUniqueModelRefs(~protected);
            nonUniqueModelRefSimModes=nonUniqueModelRefSimModes(~protected);
            nonUniqueModelRefCodeInterface=nonUniqueModelRefCodeInterface(~protected);

            result=Simulink.ModelReference.internal.UniqueModelRef.empty(1,0);
            if~isempty(nonUniqueModelRefs)


                isProtected=false;
                result=this.UniqueModelRefFactory.getUniqueModelRefs(...
                result,...
                nonUniqueModelRefs,...
                nonUniqueModelRefSimModes,...
                nonUniqueModelRefCodeInterface,...
                isProtected);
            end


            this.handleProtectedModel(model,protectedModelRefs,isNormalMode,simModeParent);
            isProtected=true;
            result=this.UniqueModelRefFactory.getUniqueModelRefs(...
            result,...
            protectedModelRefs,...
            protectedModelRefSimModes,...
            protectedModelRefCodeInterface,...
            isProtected);
        end



        function result=processNonNormalMode(this,model,isNormalMode,simModeParent,isParentMdlRefXilTopCodeIntf)

            if strcmp(model,this.TopModel)&&~this.UpdateTopModelReferenceTarget
                targetType=sl('mdlRefGetTopModelTargetForInfoMATFileMgr',...
                this.ModelReferenceTargetType,...
                this.UpdateTopModelReferenceTarget,...
                simModeParent);
            else
                targetType=this.getTargetTypeBasedOnContext(...
                model,simModeParent,isParentMdlRefXilTopCodeIntf);
            end

            if slfeature('ConfigSetActivator')>0&&...
                ~isempty(this.ConfigSetActivator)
                if~bdIsLoaded(model)

                    this.ConfigSetActivator.loadModel(model);
                end
                this.ConfigSetActivator.activate(model);



                Simulink.filegen.internal.FolderConfiguration.updateCache(model);
            end

            cache=this.updateMinfo(model,targetType);


            if strcmp(targetType,'RTW')&&~this.IsSIMTarget




                if(slfeature('NoSimTargetForBuild')>0)
                    targetTypeForChild=targetType;
                else
                    targetTypeForChild='SIM';
                end

                parentSTF=coder.internal.infoMATFileMgr('getSTF','minfo',...
                model,targetType);
                loc_check_stf_consistency(model,this.TopOfBuildModel,targetTypeForChild,parentSTF);
            end


            variantType='';
            if Simulink.ModelReference.ProtectedModel.protectingModel(this.TopOfBuildModel)
                variantType='ActiveVar';
            elseif this.IsCodeVariant
                variantType='CodeVar';
            end

            result=Simulink.ModelReference.internal.UniqueModelRef.empty(1,0);
            result=this.UniqueModelRefFactory.getUniqueModelRefsFromCache(result,variantType,cache,'modelRefs',false);
            result=this.UniqueModelRefFactory.getUniqueModelRefsFromCache(result,variantType,cache,'protectedModelRefs',true);

            this.handleProtectedModel(model,...
            this.UniqueModelRefFactory.getFieldForVariant(variantType,cache,'protectedModelRefs'),...
            isNormalMode,simModeParent);
        end



        function cache=updateMinfo(this,model,targetType)




            coder.internal.modelRefUtil(model,'setupFolderCacheForReferencedModel',this.TopModel);

            this.unpackFromSLXC(model);

            if bdIsLoaded(this.TopModel)
                optArgs.TopModel=get_param(this.TopModel,'handle');
            else
                optArgs.TopModel=-1;
            end

            cache=coder.internal.infoMATFileMgr('updateMinfoWithSave',...
            'minfo',model,targetType,optArgs);
        end




        function lUniqueModelRefs=overrideSimMode(this,lUniqueModelRefs,model,simModeParent)
            for index=1:numel(lUniqueModelRefs)
                lUniqueModelRefs(index)=...
                lUniqueModelRefs(index).overrideSimMode(...
                model,...
                simModeParent,...
                this.TopModel,...
                this.IsRSim,...
                this.IsLicensedForEcoder,...
                this.IsModelRefSILPILOverride);
            end
        end


        function result=isSILOrPILMode(this,simMode)


            result=ismember(simMode,{this.SILString,this.PILString});
        end


        function unpackFromSLXC(this,model)
            setCompileType=~strcmp(model,this.TopModel);
            targetName=sl('perf_logger_target_resolution',...
            this.ModelReferenceTargetType,model,false,setCompileType);
            PerfTools.Tracer.logSimulinkData('SLbuild',model,targetName,...
            'Unpack Simulink Cache',true);
            oc2=onCleanup(@()PerfTools.Tracer.logSimulinkData('SLbuild',model,targetName,...
            'Unpack Simulink Cache',false));


            okayToPushNags=this.Verbose;
            targetType=this.ModelReferenceTargetType;
            compiler=Simulink.packagedmodel.getSimCompilerFromCompInfo(this.DefaultCompInfo);
            builtin('_unpackSLCacheSIM',this.TopModel,model,okayToPushNags,...
            targetType,compiler);
            if strcmp(targetType,'RTW')&&~this.XilInfo_UpdatingRTWTargetsForXil
                STFName=strrep(get_param(this.TopModel,'SystemTargetFile'),'.tlc','');
                targetSuffix=Simulink.packagedmodel.getTargetSuffix(model,'ModelReferenceCode',STFName);
                folderConfig=char(Simulink.fileGenControl('get','CodeGenFolderStructure'));
                compiler=Simulink.packagedmodel.getCoderCompilerFromCompInfo(this.ModelCompInfo);
                builtin('_unpackSLCacheCoder',this.TopModel,model,...
                okayToPushNags,targetType,STFName,targetSuffix,...
                this.GenerateCodeOnly,folderConfig,compiler);
            end
        end



        function handleProtectedModel(this,model,protectedModelRefs,isNormalMode,simModeParent)
            for i=1:length(protectedModelRefs)
                modelName=protectedModelRefs{i};






                if~isempty(Simulink.ModelReference.ProtectedModel.getModelsSupportingOnlyNormalMode({modelName}))
                    if(~this.OnlyCheckConfigsetMismatch&&~this.XilInfo_UpdatingRTWTargetsForXil)
                        if strcmp(this.ModelReferenceTargetType,'RTW')
                            DAStudio.error('Simulink:protectedModel:protectedModelNotSupportedInRTW',modelName);
                        end
                        if(~strcmp(this.TopSimMode,this.NormalString)||~isNormalMode)
                            DAStudio.error('Simulink:protectedModel:protectedModelNotInNormalMode',...
                            model,modelName,modelName,model,model,modelName);
                        end
                    end
                else


                    options=Simulink.ModelReference.ProtectedModel.getOptions(modelName);
                    if strcmp(simModeParent,this.AcceleratorString)&&~isNormalMode&&...
                        Simulink.ModelReference.ProtectedModel.supportsAccel(options)
                        fileDeleter=Simulink.ModelReference.ProtectedModel.FileDeleter.Instance;
                        fileDeleter.setCurrentTopModel(this.TopOfBuildModel);

                        if this.isUpdatingSimForRTW
                            Simulink.ModelReference.ProtectedModel.unpackProtectedModelSimTargetArtifactsForCodegenIfNecessary...
                            (modelName,this.TopOfBuildModel);
                        else
                            Simulink.ModelReference.ProtectedModel.unpackProtectedModelSimTargetArtifactsIfNecessary...
                            (modelName,this.TopOfBuildModel);
                        end
                    end
                end

            end
        end


        function refreshModelBlocks(~,blocks)
            for i=1:length(blocks)
                aBlockObject=get_param(blocks{i},'Object');
                aBlockObject.refreshModelBlock;
            end
        end



        function[skipRebuildChecks,modelOnBuildList]=checkRebuildManager(this,model,skipRebuildChecks)


            skipList=Simulink.ModelReference.RebuildManager.getSkipList(this.TopOfBuildModel);
            if any(strcmp(skipList,model))
                skipRebuildChecks=true;
            end



            buildList=Simulink.ModelReference.RebuildManager.getBuildList(this.TopOfBuildModel);
            modelOnBuildList=any(strcmp(buildList,model));
        end


        function[skipRebuildChecks,childSkip]=searchSubModels(this,model,modelRefWithModes,skipRebuildChecks,childSkip)
            numModelRefs=length(modelRefWithModes);

            for index=1:numModelRefs





















                modelRef=modelRefWithModes(index).modelName;
                modelRefMode=modelRefWithModes(index).mode;
                modelRefProtected=modelRefWithModes(index).protected;
                modelRefSimMode=modelRefWithModes(index).simMode;
                modelRefIsTopCodeInterface=modelRefWithModes(index).isTopCodeInterface;


                this.verifyModelNameAndCycles(modelRef,model);

                [foundDuplicate,skipRebuildChecks]=this.findDuplicates(modelRefWithModes(index),skipRebuildChecks,model);
                if foundDuplicate



                    continue;
                end

                this.DFS(modelRef,modelRefMode,modelRefSimMode,modelRefProtected,modelRefIsTopCodeInterface,skipRebuildChecks);




                if~isempty(this.ModelRefInfo)
                    childSkip=childSkip&&this.ModelRefInfo(end).skipRebuild;
                else
                    childSkip=true;
                end
            end
        end



        function verifyModelNameAndCycles(this,modelRef,model)
            if~isvarname(modelRef)


                DAStudio.error('Simulink:slbuild:invalidModelName',model,modelRef);
            end

            if any(strcmp(modelRef,this.TraversedModels))
                modelRefLoop=[this.getPathToModel(),':',model,':',modelRef];
                DAStudio.error('Simulink:slbuild:mdlRefLoopDetected',modelRefLoop);
            end
        end






        function[duplicateFound,skipRebuildChecks]=findDuplicates(this,aStruct,skipRebuildChecks,model)


            duplicateFound=false;



            if isempty(this.ModelRefInfo)
                return;
            end

            matchIndex=find(strcmp(aStruct.modelName,{this.ModelRefInfo.mdlRefs}));
            if~isempty(matchIndex)








                matchedIsSIL=ismember({this.ModelRefInfo(matchIndex).mdlRefSimMode},this.SILString);
                matchedIsPIL=ismember({this.ModelRefInfo(matchIndex).mdlRefSimMode},this.PILString);
                matchedModes=[this.ModelRefInfo(matchIndex).isNormalMode;...
                this.ModelRefInfo(matchIndex).protected;...
                matchedIsSIL;...
                matchedIsPIL];

                searchIsSIL=strcmp(aStruct.simMode,this.SILString);
                searchIsPIL=strcmp(aStruct.simMode,this.PILString);
                searchKey=[aStruct.mode;aStruct.protected;searchIsSIL;searchIsPIL];
                skipRebuildChild=this.ModelRefInfo(matchIndex).skipRebuild;




                if skipRebuildChecks&&~skipRebuildChild
                    skipOrBuild=Simulink.ModelReference.RebuildManager.isSkipOrBuildListPopulated(this.TopOfBuildModel);
                    if strcmp(skipOrBuild,'build')


                        skipRebuildChecks=false;
                    elseif strcmp(skipOrBuild,'skip')




                        this.setChildSkipRebuild(aStruct.modelName);
                    end
                end

                for searchIndex=1:length(matchIndex)
                    if(isequal(matchedModes(:,searchIndex),searchKey))
                        duplicateFound=true;
                        break;
                    end
                end

                if(duplicateFound)
                    if this.ParBuild
                        this.ParBuildOrder.setElements(aStruct.modelName,{},{},model,{},{});
                    end
                end
            end
        end


        function setChildSkipRebuild(this,modelRef)



            index=find(strcmp(modelRef,{this.ModelRefInfo.mdlRefs}));
            if~isempty(index)


                this.ModelRefInfo(index).skipRebuild=true;
                if~isempty(this.ModelRefInfo(index).childList)
                    childList=this.ModelRefInfo(index).childList;
                    childListLength=length(childList);
                    for i=1:childListLength
                        this.setChildSkipRebuild(childList(i));
                    end
                end
            end
        end

        function targetType=getTargetTypeBasedOnContext(this,model,simModeParent,isParentMdlRefXilTopCodeIntf)



            if this.UpdateTopModelReferenceTarget&&...
                strcmp(this.ModelReferenceTargetType,'SIM')&&...
                ~this.isUpdatingSimForRTW


                targetType='SIM';
            elseif strcmp(model,this.TopModel)&&~this.UpdateTopModelReferenceTarget
                targetType=sl('mdlRefGetTopModelTargetForInfoMATFileMgr',...
                this.ModelReferenceTargetType,...
                this.UpdateTopModelReferenceTarget,...
                simModeParent);
            elseif this.IsSIMTarget&&this.isSILOrPILMode(simModeParent)
                if this.isUpdatingSimForRTW



                    targetType='RTW';
                else




                    if isParentMdlRefXilTopCodeIntf
                        targetType='NONE';
                    else
                        targetType='RTW';
                    end
                end
            else
                targetType=this.ModelReferenceTargetType;
            end
        end
    end

    methods(Static,Access=private)
        function protected=getIsProtectedByBlock(blocks,isCodeVariant)

            if isCodeVariant
                nonUniqueProtectedByBlock=get_param(blocks,'CodeVariantProtectedModels');
            else
                nonUniqueProtectedByBlock={get_param(blocks,'ProtectedModel')};
            end
            nonUniqueProtected=[nonUniqueProtectedByBlock{:}]';

            protected=[];
            if~isempty(nonUniqueProtected)
                protected=strcmp('on',nonUniqueProtected);
            end
        end
    end
end


function loc_check_stf_consistency(iMdl,topMdl,targetType,parentSTF)
    [~,parentSTFName]=fileparts(parentSTF);
    if~bdIsLoaded(iMdl)
        simInfoStruct=coder.internal.infoMATFileMgr...
        ('loadNoConfigSet','minfo',iMdl,targetType);
        [~,thisModelSTFName]=fileparts(simInfoStruct.rtwSystemTargetFile);
    else
        [~,thisModelSTFName]=fileparts(get_param(iMdl,'SystemTargetFile'));
    end

    if~strcmp(thisModelSTFName,parentSTFName)
        isRTT=isequal(parentSTFName,'realtime');
        if isRTT

            DAStudio.error('realtime:build:WrongSystemTargetFileMdlRef',iMdl);
        else

            diag=MSLException([],...
            message('RTW:buildProcess:incompatibleSTF',...
            topMdl,parentSTFName,iMdl,thisModelSTFName));
            throw(diag);
        end
    end
end




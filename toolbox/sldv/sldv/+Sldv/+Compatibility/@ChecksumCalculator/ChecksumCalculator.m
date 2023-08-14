


...
...
...
...
...
...
classdef ChecksumCalculator<handle
    properties(Access=private)
mModelH
mModelName
mComponentH
mAllModels
mChecksumMode
    end

    methods(Access=public)
        function obj=ChecksumCalculator(aModelH,aComponentH,aChecksumMode)
            if~isnumeric(aModelH)
                aModelH=get_param(aModelH,'Handle');
            end
            obj.mModelH=aModelH;
            obj.mModelName=get_param(obj.mModelH,'Name');

            if nargin<3
                aChecksumMode=Sldv.ChecksumMode.SLDV_CHECKSUM_MODEL_TRANSLATION;
            end
            obj.mChecksumMode=aChecksumMode;
            if nargin<2
                obj.mComponentH=[];
            else
                if~isnumeric(aComponentH)
                    aComponentH=get_param(aComponentH,'Handle');
                end
                obj.mComponentH=aComponentH;
            end
        end

        function[cs,msg]=compute(obj)


            obj.attachSLDVPlugin();
            oc_plugin=onCleanup(@()obj.detachSLDVPlugin());



            origVal=getSldvChecksumMode(obj.mModelH);
            setSldvChecksumMode(obj.mModelH,obj.mChecksumMode);
            oc=onCleanup(@()setSldvChecksumMode(obj.mModelH,origVal));

            if isempty(obj.mComponentH)
                [cs,msg]=obj.getModelChecksum();
            else
                [cs,msg]=obj.getComponentChecksum();
            end

            if Sldv.ChecksumMode.SLDV_CHECKSUM_REPORT==obj.mChecksumMode
                if~isempty(msg)


                    cs='';
                    return;
                end
                cs=cs(1).Checksum;


                cs=strrep(strtrim(cs),',',' ');
            end

            function setSldvChecksumMode(modelH,val)

                sldvSession=sldvprivate('sldvGetActiveSession',modelH);
                if~isempty(sldvSession)&&isvalid(sldvSession)
                    sldvSession.setSldvChecksumMode(val);
                end
            end

            function check=getSldvChecksumMode(modelH)
                check=false;

                sldvSession=sldvprivate('sldvGetActiveSession',modelH);
                if~isempty(sldvSession)&&isvalid(sldvSession)
                    check=sldvSession.getSldvChecksumMode();
                end
            end
        end
    end

    methods(Access=private)
        function check=isNonVirtualSubsystem(obj)
            check=false;
            blkType=get_param(obj.mComponentH,'BlockType');
            if~strcmp(blkType,'SubSystem')
                return;
            end
            SS=Simulink.SubsystemType(obj.mComponentH);
            SS_type=SS.getType();
            if strcmp(SS_type,'virtual')
                return;
            end
            check=true;
        end

        function check=isModelReference(obj)
            check=false;
            blkType=get_param(obj.mComponentH,'BlockType');
            if~strcmp(blkType,'ModelReference')
                return;
            end
            check=true;
        end

        function check=isValidComponent(obj)
            check=false;
            if isempty(obj.mComponentH)
                return;
            end
            check=check||obj.isNonVirtualSubsystem();
            check=check||obj.isModelReference();
        end

        function[cs,errMsg]=getModelChecksum(obj)
            cs=struct('System',{},'Checksum',[]);
            errMsg='';


            obj.mAllModels=obj.getAllModels(obj.mModelH);

            if Sldv.ChecksumMode.SLDV_CHECKSUM_REPORT==obj.mChecksumMode





                observerModels={};
                if(slfeature('ObserverSLDV')==1)
                    standaloneMode=false;
                    [observerModels,~,errMsg]=Simulink.observer.internal.loadObserverModelsForBD(get_param(obj.mModelH,'Handle'),standaloneMode);
                    if~isempty(errMsg)
                        return;
                    end
                end



                for currObs=1:numel(observerModels)
                    currObsHier=obj.getAllModels(observerModels{currObs});
                    obj.mAllModels=[obj.mAllModels;currObsHier];
                end
            end
            try
                cleanUpObjs=obj.compileModelForChecksum();%#ok<NASGU>
                jdx=1;
                if Sldv.ChecksumMode.SLDV_CHECKSUM_REPORT==obj.mChecksumMode










                    systemHierarchy=obj.getCompiledModelHier();
                    cs(jdx).System=Simulink.ID.getSID(obj.mModelH);
                    cs(jdx).Checksum=Sldv.slInternal.getModelChecksumHier(systemHierarchy);
                else
                    for idx=1:numel(obj.mAllModels)
                        modelName=obj.mAllModels{idx};
                        if obj.isCompiled(modelName)
                            cs(jdx).System=Simulink.ID.getSID(modelName);
                            cs(jdx).Checksum=Sldv.slInternal.getModelChecksum(get_param(modelName,'Handle'));
                            jdx=jdx+1;
                        end
                    end
                end
            catch MEx
                errMsg=MEx.message;
            end
            cleanUpObjs=[];%#ok<NASGU> % terminate the compile state of model            
        end

        function[cs,errMsg]=getComponentChecksum(obj)
            cs=struct('System',{},'Checksum',[]);
            errMsg='';

            if~obj.isValidComponent()
                errMsg=getString(message('Sldv:Setup:ChecksumComputationInvalidComponent'));
                return;
            end
            if strcmp('on',get_param(obj.mComponentH,'Commented'))
                errMsg=getString(message('Sldv:Setup:ChecksumComputationCommentedComponent'));
                return;
            end

            obj.mAllModels=obj.getAllModels(obj.mComponentH);
            try
                cleanUpObjs=obj.compileModelForChecksum();%#ok<NASGU> (CleanUpObjs are executed at fcn exit)


                if isequal('off',get_param(obj.mComponentH,'CompiledIsActive'))
                    errMsg=getString(message('Sldv:Setup:ChecksumComputationInactiveComponent'));
                    return;
                end

                if Sldv.ChecksumMode.SLDV_CHECKSUM_REPORT==obj.mChecksumMode










                    allMdlHandles=obj.getCompiledModelHier();





                    systemHierarchy=[obj.mComponentH,allMdlHandles];
                    cs(1).System=Simulink.ID.getSID(obj.mComponentH);
                    cs(1).Checksum=Sldv.slInternal.getComponentChecksumHier(systemHierarchy);
                else
                    cs(1).System=Simulink.ID.getSID(obj.mComponentH);
                    cs(1).Checksum=Sldv.slInternal.getComponentChecksum(obj.mComponentH);
                    jdx=2;
                    for idx=1:numel(obj.mAllModels)
                        modelName=obj.mAllModels{idx};
                        modelSID=Simulink.ID.getSID(modelName);
                        if~isequal(Simulink.ID.getSID(obj.mModelH),modelSID)
                            if obj.isCompiled(modelName)
                                cs(jdx).System=modelSID;
                                cs(jdx).Checksum=Sldv.slInternal.getModelChecksum(get_param(modelName,'Handle'));
                                jdx=jdx+1;
                            end
                        end
                    end
                end
            catch MEx
                errMsg=MEx.message;
            end
        end

        function cleanUpActions=compileModelForChecksum(obj)
            simStatus=get_param(obj.mModelName,'SimulationStatus');
            isCompiled=strcmp(simStatus,'paused')||strcmp(simStatus,'initializing');
            if~isCompiled
                settingsCache=obj.modifySettingsForChecksum();


                [prevMsg,prevMsgID]=lastwarn;
                warnStruct=warning;
                warning('off');
                oc1=onCleanup(@()obj.restoreSettingsAfterChecksum(settingsCache));
                oc2=onCleanup(@()warning(warnStruct));
                oc3=onCleanup(@()lastwarn(prevMsg,prevMsgID));

                try
                    cmd=sprintf('feval(''%s'', ''initForChecksumsOnly'', ''simcmd'')',obj.mModelName);
                    evalc(cmd);
                catch MEx
                    rethrow(MEx);
                end
                termCmd=sprintf('feval(''%s'', ''term'')',obj.mModelName);
                oc4=onCleanup(@()evalc(termCmd));

                cleanUpActions=[oc4,oc3,oc2,oc1];
            else
                cleanUpActions=[];
            end
        end

        function allModels=getAllModels(~,system)


            if Simulink.internal.useFindSystemVariantsMatchFilter()
                allModels=find_mdlrefs(system,...
                'AllLevels',true,...
                'IncludeCommented',false,...
                'IncludeProtectedModels',false,...
                'MatchFilter',@Simulink.match.activeVariants,...
                'KeepModelsLoaded',true);
            else
                allModels=find_mdlrefs(system,...
                'AllLevels',true,...
                'IncludeCommented',false,...
                'IncludeProtectedModels',false,...
                'KeepModelsLoaded',true,...
                'Variants','ActiveVariants');
            end
        end

        function modelHandles=getCompiledModelHier(obj)



            modelHandles=zeros(1,numel(obj.mAllModels));
            compiledIdx=1;
            for i=1:numel(obj.mAllModels)
                modelName=obj.mAllModels{i};
                if obj.isCompiled(modelName)
                    modelHandles(compiledIdx)=get_param(modelName,'Handle');
                    compiledIdx=compiledIdx+1;
                end
            end
            modelHandles(compiledIdx:end)=[];
        end

        function yesno=isCompiled(~,modelH)
            simStatus=get_param(modelH,'SimulationStatus');
            yesno=strcmp(simStatus,'paused')||...
            strcmp(simStatus,'compiled')||...
            strcmp(simStatus,'initializing');
        end

        function attachSLDVPlugin(obj)
            h=Simulink.PluginMgr;
            h.attach(obj.mModelH,'SLDVPlugin');
        end

        function detachSLDVPlugin(~)
            h=Simulink.PluginMgr;
            h.detachForAllModels('SLDVPlugin');
        end

        function settingsCache=modifySettingsForChecksum(obj)













            settingsCache=cell(1,numel(obj.mAllModels));
            if(Sldv.ChecksumMode.SLDV_CHECKSUM_REPORT==obj.mChecksumMode)
                return;
            end
            for idx=1:numel(obj.mAllModels)
                modelName=obj.mAllModels{idx};
                modelH=get_param(modelName,'Handle');
                hasAssertionBlks=~isempty(Simulink.findBlocksOfType(modelH,'Assertion'));
                if hasAssertionBlks
                    settingsCache{idx}=sldvprivate('settings_handler',modelH,'store_checksum',[]);
                    settingsCache{idx}=sldvprivate('settings_handler',modelH,'init_checksum',settingsCache{idx});
                else
                    settingsCache{idx}='';
                end
            end
        end

        function restoreSettingsAfterChecksum(obj,settingsCache)



            if(Sldv.ChecksumMode.SLDV_CHECKSUM_REPORT==obj.mChecksumMode)
                return;
            end
            for idx=1:numel(obj.mAllModels)
                if isempty(settingsCache{idx})


                    continue;
                end
                modelName=obj.mAllModels{idx};
                modelH=get_param(modelName,'Handle');
                sldvprivate('settings_handler',modelH,'restore_checksum',settingsCache{idx});
            end
        end
    end

    methods(Static,Access=public)
        function cs=getSFcnChecksum(blk)
            sfcnName=get_param(blk,'FunctionName');
            cs=sldv.code.sfcn.getSFcnChecksum(sfcnName);
        end

        function checksum=getOutOfRangeDiagnosticChecksumForLookupAndInterpolationBlocks(aBlock)
            blockType=get_param(aBlock,'BlockType');
            assert(strcmp(blockType,'Lookup_n-D')||strcmp(blockType,'Interpolation_n-D'));
            checksum=get_param(aBlock,'DiagnosticForOutOfRangeInput');
        end

        function cc_info=getCustomCodeInfo(modelH)
            modelInfo=sldv.code.slcc.internal.getModelInfo(modelH);
            cc_info.SettingsChecksum=modelInfo.SettingsChecksum;
            cc_info.FullChecksum=modelInfo.FullChecksum;
        end

        function xilChecksum=getXilChecksum(modelH,mode)

            xilChecksum=zeros(0,1,'uint32');


            modelName=get_param(modelH,'Name');






            [isATS,harnessInfo]=sldv.code.xil.CodeAnalyzer.isATSHarnessModel(modelName);
            if isATS
                modelName=harnessInfo.model;
            end

            buildDirStruct=RTW.getBuildDir(modelName);
            if mode=="SIL"
                codeGenDir=buildDirStruct.BuildDirectory;
            elseif mode=="ModelRefSIL"
                codeGenDir=fullfile(buildDirStruct.CodeGenFolder,buildDirStruct.ModelRefRelativeBuildDir);
            else
                return
            end
            codeDescFilePath=fullfile(codeGenDir,'codedescriptor.dmr');
            if~isfile(codeDescFilePath)
                return;
            end
            checksum=coder.internal.utils.Checksum.calculate({codeDescFilePath});
            xilChecksum=checksum{1};
        end
    end
end




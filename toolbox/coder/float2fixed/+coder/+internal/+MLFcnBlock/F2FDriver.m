

classdef F2FDriver<handle
    properties
blockID
fxpCfg
State
    end

    properties(Access=private)


GUIState
    end

    properties(Constant)
        NA_TYPE='n/a';
        InstanceMap=containers.Map();
        AUTO_GENERATED_MARKER='auto-generated';

        DEFAULT_BUILDSTATE=struct('inference',[],'messages',[],'callerCalleeList',[],'errorMessage',[],'chartCheckSum',[],'nameResolInfo',[],'mlfbChecksum',[]);
    end

    methods(Static)
        function errState=addMATLABFunctionResults(blkSID,coderReport,loggedVariablesData,runObj)
            errState=[];

            driver=coder.internal.MLFcnBlock.Float2FixedManager.createOrGetMLFBDriver(blkSID);
            coder.internal.MLFcnBlock.DataRepositoryFacade.instrumentationDataMap(blkSID,coderReport,loggedVariablesData);

            dataRepositoryFacade=driver.getDataRepositoryFacade();
            if isempty(dataRepositoryFacade)
                dataRepositoryFacade=coder.internal.MLFcnBlock.DataRepositoryFacade(blkSID);
                driver.setDataRepositoryFacade(dataRepositoryFacade);
            end
            driver.State.isDerivedOnlyWorkflow=false;

            coder.internal.MLFcnBlock.Float2FixedManager.cacheInvalidate(blkSID,runObj.getRunName());
            coder.internal.mlfb.gui.CodeViewUpdater.markMlfbResultsProcessed(runObj.getRunName(),blkSID);



            runName=runObj.getRunName();
            dataRepositoryFacade.addRun(runName);
            dataRepositoryFacade.addRunTimeStampInfo(runName,coder.internal.MLFcnBlock.DataRepositoryFacade.computeCoderReportCheckSum(blkSID,coderReport));
        end

        function addProposedTypesForOneMLFBInBatchMode(results,blkSID,runObj,hasNAs,naResIndices,sudSID)
            try
                runName=runObj.getRunName();
                driver=coder.internal.MLFcnBlock.Float2FixedManager.createOrGetMLFBDriver(blkSID);

                if~driver.isWithinSUDScope(results,sudSID)

                    return;
                end



                if driver.State.isDerivedOnlyWorkflow


                    compilationReport=driver.getCompilationReport();
                    driver.buildFcnInfoRegistry(compilationReport);


                    fptAlertLevel=coder.internal.MLFcnBlock.FPTHelperUtils.FPT_ALERT_LVL_RED;
                    coder.internal.MLFcnBlock.FPTHelperUtils.SetResultAlertLevel(results,fptAlertLevel);


                    driver.removeDerivedOnlyWorklowMsgsFromGUIState();
                    driver.unsupportedDerivedOnlyWorkflow();
                    return;
                end

                coder.internal.MLFcnBlock.Float2FixedManager.cacheInvalidateOnly(blkSID,runName);





                isBuildStale=driver.isBuildStateStale();
                if isempty(driver.State.fcnInfoRegistry)||isBuildStale
                    if isBuildStale
                        buildState=coder.internal.MLFcnBlock.F2FDriver.DEFAULT_BUILDSTATE;
                        driver.putGUIState('buildState',buildState);
                    end


                    compilationReport=driver.getCompilationReport();

                    if isempty(compilationReport)

                        return;
                    end

                    driver.buildFcnInfoRegistry(compilationReport);
                end

                isProposingFixpt=false;
                [~,fixptMLFB]=coder.internal.mlfb.getMlfbVariants(blkSID);
                if~isempty(fixptMLFB)

                    fixptSID=Simulink.ID.getSID(fixptMLFB);
                    isProposingFixpt=strcmp(fixptSID,blkSID);

                    if isProposingFixpt

                        fptAlertLevel=coder.internal.MLFcnBlock.FPTHelperUtils.FPT_ALERT_LVL_YELLOW;
                        coder.internal.MLFcnBlock.FPTHelperUtils.SetResultAlertLevel(results,fptAlertLevel);


                        driver.addCannotApplyForFixptVariantMsg(runName);
                    end
                end

                driver.removeNAMsgsFromGUIState();

                if hasNAs
                    allNA=driver.areAllResultsNA(results);
                    if allNA





                    else

                        driver.addCannotApplyForNATypesMsg(results,naResIndices);
                    end
                end



                driver.checkWhetherSUDIsTestHarnessCUT(results);



                [isChartWithinStateFlow,charFullName]=driver.isWithinStateflowChart(sudSID);
                if isChartWithinStateFlow
                    mlfbInChartMsg=driver.addCannotApplyForMLFBInSFCharts(blkSID,charFullName);
                end

                buildState=driver.getGUIState('buildState');



                if~isProposingFixpt&&~isempty(buildState)&&isfield(buildState,'messages')&&~isempty(buildState.messages)
                    errState=driver.getErrorState(buildState.messages);
                    fptAlertLevel=[];
                    if strcmp(errState,coder.internal.lib.Message.ERR)
                        fptAlertLevel=coder.internal.MLFcnBlock.FPTHelperUtils.FPT_ALERT_LVL_RED;
                    elseif strcmp(errState,coder.internal.lib.Message.WARN)
                        fptAlertLevel=coder.internal.MLFcnBlock.FPTHelperUtils.FPT_ALERT_LVL_YELLOW;
                    end
                    if~isempty(fptAlertLevel)
                        if isChartWithinStateFlow

                            origWarnState=coder.internal.Helper.changeBacktraceWarning('off');
                            cleanUp=onCleanup(@()coder.internal.Helper.changeBacktraceWarning('reset',origWarnState));


                            warning(mlfbInChartMsg);

                            coder.internal.MLFcnBlock.FPTHelperUtils.SetResultAlertLevel(results,fptAlertLevel);
                        else
                            coder.internal.MLFcnBlock.FPTHelperUtils.SetResultAlertLevel(results,fptAlertLevel);
                        end
                    end
                end
            catch ex
                coder.internal.gui.asyncDebugPrint(ex);
            end
        end

        function converted=convertOneMLFBInBatchMode(results,blkSID,modelName,runObj,sudSID)
            converted=false;

            runName=runObj.getRunName();
            driver=coder.internal.MLFcnBlock.Float2FixedManager.getMLFBDriver(blkSID);
            dataRepositoryFacade=driver.getDataRepositoryFacade();

            if isempty(dataRepositoryFacade)

                return;
            end

            if~driver.isWithinSUDScope(results,sudSID)

                return;
            end

            if isempty(results)
                return;
            end


            buildState=driver.getGUIState('buildState');
            if~isempty(buildState)&&isfield(buildState,'messages')&&~isempty(buildState.messages)
                errState=driver.getErrorState(buildState.messages);
                if strcmp(errState,coder.internal.lib.Message.ERR)

                    origWarnState=coder.internal.Helper.changeBacktraceWarning('off');
                    cleanUp=onCleanup(@()coder.internal.Helper.changeBacktraceWarning('reset',origWarnState));

                    errorMsgs=coder.internal.lib.Message.getMessagesOfType(buildState.messages,coder.internal.lib.Message.ERR);
                    blkPath=Simulink.ID.getFullName(blkSID);
                    messageId='Coder:FXPCONV:MLFB_CONVERSION_SKIPPED';
                    skippedText=message(messageId,blkPath,errorMsgs(1).text);
                    warning(skippedText);
                    fxptui.showdialog(messageId,MException(messageId,skippedText.getString));
                    return;
                end
            end

            [~,instrumentationReport,loggedVariablesData]=dataRepositoryFacade.getReports();

            if isempty(driver.State.fcnInfoRegistry)||driver.isBuildStateStale()


                compilationReport=driver.getCompilationReport();

                if isempty(compilationReport)

                    return;
                end

                driver.buildFcnInfoRegistry(compilationReport);
            else



                driver.resetRangeAndTypeProposalData();
            end


            if~driver.State.isF2FCompatible

                return;
            end

            driver.State.coderReport=instrumentationReport;
            try
                inferenceReportMisMatch=driver.addInstrumentationData(driver.State.coderReport,loggedVariablesData,runName);
                if inferenceReportMisMatch



                    driver.warnStaleRun(blkSID,runName);
                    return;
                end
            catch ex
                messageId='Coder:FXPCONV:MLFB_GenerateFixedPointCodeError';
                errorText=message(messageId,blkSID,ex.message);
                warning(errorText);
                fxptui.showdialog(messageId,MException(messageId,errorText.getString));
                return;
            end
            [~,~,~]=driver.proposeTypes(driver.State.fcnInfoRegistry);
            dataRepositoryFacade.addResults(runName,results);
            mappedResults=dataRepositoryFacade.getMappedResults(runName);


            try
                driver.apply(blkSID,mappedResults,runObj,sudSID);
            catch ex
                messageId='Coder:FXPCONV:MLFB_GenerateFixedPointCodeError';
                errorText=message(messageId,blkSID,ex.message);
                warning(errorText);
                fxptui.showdialog(messageId,MException(messageId,errorText.getString));
                return;
            end

            applyState=driver.getGUIState('applyState');
            if~isempty(applyState)&&isfield(applyState,'messages')&&~isempty(applyState.messages)
                messageId='';
                warningText='';
                for ii=1:length(applyState.messages)
                    msg=applyState.messages(ii);
                    messageId='Coder:FXPCONV:MLFB_GenerateFixedPointCodeWARN';
                    warningText=message(messageId,blkSID,msg.text);
                    warning(warningText);
                end

                fxptui.showdialog(messageId,MException(messageId,warningText.getString));
            end


            converted=true;
        end

        function cfg=BuildMLFBF2FConfig()
            cfg=coder.config('fixpt');
            cfg.ProposeTypesMode=coder.FixPtConfig.MODE_MLFB;
        end

        function val=getDefaultSimState()





            val=struct('errorMessage','','coverageInfo',[],'fcnVarsInfo',[],'expressions',[],'messages',[],'backendMessages',[]);
            val.expressions={};
        end
    end

    methods
        function this=F2FDriver(blkSID)
            this.blockID=coder.internal.mlfb.idForBlock(blkSID);
            this.fxpCfg=coder.internal.MLFcnBlock.F2FDriver.BuildMLFBF2FConfig();
            this.fxpCfg.DefaultWordLength=16;
            this.State=struct('fcnInfoRegistry',[],'f2fCompatibilityMessages',[],'isF2FCompatible',true,'dataRepositoryFacade',[],'isDerivedOnlyWorkflow',true,'exprInfoMap',[]);
            this.GUIState=struct('buildState',coder.internal.MLFcnBlock.F2FDriver.DEFAULT_BUILDSTATE,'simState',containers.Map());
        end

        function removeDerivedOnlyWorklowMsgsFromGUIState(this)
            buildState=this.getGUIState('buildState');
            if isempty(buildState)
                return;
            end
            msgList=buildState.messages;
            if isempty(msgList)
                return;
            end

            msgID='Coder:FXPCONV:MLFB_DerivedOnlyWorkflowUnsupported';
            msgList(strcmp({msgList.id},msgID))=[];
            buildState.messages=msgList;
            this.putGUIState('buildState',buildState);
        end

        function removeNAMsgsFromGUIState(this)
            buildState=this.getGUIState('buildState');
            if isempty(buildState)
                return;
            end
            msgList=buildState.messages;
            if isempty(msgList)
                return;
            end



            msgID='Coder:FXPCONV:MLFB_CannotApplyForNATypeResult';
            msgList(strcmp({msgList.id},msgID))=[];
            buildState.messages=msgList;
            this.putGUIState('buildState',buildState);
        end




        function within=isWithinSUDScope(~,results,sudID)
            within=true;
            try
                within=results(1).isWithinProvidedScope(sudID)||...
                doesResultBelongToMLFBSUD(results(1),sudID);
            catch
            end














            function r=doesResultBelongToMLFBSUD(result,sudID)
                sudName=sudID.getObject.getFullName;


                fcnID=result.getUniqueIdentifier.MATLABFunctionIdentifier;


                blockIdentifier=fcnID.BlockIdentifier;
                blockName=blockIdentifier.getObject.getFullName;
                r=strcmp(sudName,blockName);
            end
        end











        function allNA=areAllResultsNA(this,results)
            if~isempty(results)
                for ii=1:numel(results)
                    switch results(ii).getProposedDT()
                    case this.NA_TYPE
                    otherwise

                        allNA=false;
                        return;
                    end
                end
                allNA=true;
            else
                allNA=false;
            end
        end



        function msgObj=addCannotApplyForMLFBInSFCharts(this,blkSID,chartFullName)
            buildState=this.getGUIState('buildState');
            if isempty(buildState)
                buildState=coder.internal.MLFcnBlock.F2FDriver.DEFAULT_BUILDSTATE;
            end


            fcnInfos=this.State.fcnInfoRegistry.getAllFunctionTypeInfos;
            fcnInfos=[fcnInfos{:}];
            fcnIndices=arrayfun(@(f)f.tree.indices,fcnInfos);
            minIdx=min(fcnIndices);
            rootFcnInfo=fcnInfos(fcnIndices==minIdx);

            msgID='Coder:FXPCONV:MLFB_IN_SF_CHART';
            msgType=coder.internal.lib.Message.ERR;

            MLFBFxpVariantCannotApplyMsg=coder.internal.lib.Message.buildMessage(rootFcnInfo,rootFcnInfo.tree,msgType,msgID,{blkSID,chartFullName});
            buildState.messages=[MLFBFxpVariantCannotApplyMsg.toGUIStruct(),buildState.messages];
            this.putGUIState('buildState',buildState);


            msgObj=message(msgID,blkSID,chartFullName);
        end

        function removePreviousMessages(this,msgID)
            buildState=this.getGUIState('buildState');
            if~isempty(buildState)
                msgList=buildState.messages;
                if~isempty(msgList)
                    msgList(strcmp({msgList.id},msgID))=[];
                    buildState.messages=msgList;
                    this.putGUIState('buildState',buildState);
                end
            end
        end


        function pass=checkWhetherSUDIsTestHarnessCUT(this,results)
            pass=true;
            try
                msgID='Coder:FXPCONV:MLFB_CANNOT_APPLY_CUT';
                this.removePreviousMessages(msgID);

                for ii=1:numel(results)
                    result=results(ii);
                    varID=result.getUniqueIdentifier();
                    fcnID=varID.MATLABFunctionIdentifier;
                    blockID=fcnID.BlockIdentifier;%#ok<PROPLC>
                    subSysObject=blockID.getObject;%#ok<PROPLC>
                    subSys=subSysObject.getFullName();



                    isCUT=strcmp(get_param(bdroot(subSys),'IsHarness'),'on')&&...
                    strcmp(get_param(subSys,'SID'),'1');
                    if isCUT
                        pass=false;
                    end

                    break;
                end

                if~pass
                    buildState=this.getGUIState('buildState');
                    if isempty(buildState)
                        buildState=coder.internal.MLFcnBlock.F2FDriver.DEFAULT_BUILDSTATE;
                    end

                    fcnTypeInfos=this.State.fcnInfoRegistry.getAllFunctionTypeInfos();
                    dutInfo=[];
                    for ii=1:numel(fcnTypeInfos)
                        dutInfo=fcnTypeInfos{ii};
                        if dutInfo.isDesign
                            break;
                        end
                    end

                    if~isempty(dutInfo)
                        msgType=coder.internal.lib.Message.ERR;

                        msg=coder.internal.lib.Message.buildMessage(dutInfo,dutInfo.tree,msgType,msgID,{subSys});

                        buildState.messages=[msg.toGUIStruct(),buildState.messages];
                    end


                    this.putGUIState('buildState',buildState);
                end
            catch
            end
        end

        function staleMsg=warnStaleRun(this,blkSID,runName)
            origWarnState=coder.internal.Helper.changeBacktraceWarning('off');
            cleanUp=onCleanup(@()coder.internal.Helper.changeBacktraceWarning('reset',origWarnState));

            staleMsg=this.publishStaleRunMsg(blkSID,runName);
            warning(staleMsg);
        end

        function warningText=publishStaleRunMsg(~,blkSID,runName)
            msgID='Coder:FXPCONV:MLFB_StaleRun';
            staleRunMsg=message(msgID,runName);

            messageId='Coder:FXPCONV:MLFB_GenerateFixedPointCodeWARN';
            warningText=message(messageId,blkSID,staleRunMsg.getString);


            fxptui.showdialog(messageId,MException(messageId,warningText.getString));


















        end


        function addCannotApplyForNATypesMsg(this,results,naResIndices)
            msgs=coder.internal.lib.Message.empty();

            buildState=this.getGUIState('buildState');
            if isempty(buildState)
                buildState=coder.internal.MLFcnBlock.F2FDriver.DEFAULT_BUILDSTATE;
            end

            import coder.internal.MLFcnBlock.Float2FixedManager;

            msgID='Coder:FXPCONV:MLFB_CannotApplyForNATypeResult';
            fcnMap=coder.internal.lib.Map();

            for ii=1:length(naResIndices)
                idx=naResIndices(ii);
                result=results(idx);

                varID=result.getUniqueIdentifier();
                fcnID=varID.MATLABFunctionIdentifier;
                resultFcnInstance=fcnID.InstanceCount;
                fcnInstKey=[fcnID.FunctionName,'>',num2str(resultFcnInstance)];
                if isKey(fcnMap,fcnInstKey)
                    fcnInfo=fcnMap(fcnInstKey);
                else
                    if 1==resultFcnInstance
                        fcnInfoSplID=-1;
                    else
                        fcnInfoSplID=resultFcnInstance;
                    end
                    fcnInfo=internal.mtree.FunctionTypeInfo.empty();
                    fcnInfos=this.State.fcnInfoRegistry.getFunctionTypeInfosByName(fcnID.FunctionName);
                    for jj=1:length(fcnInfos)
                        fcnInfo=fcnInfos{jj};
                        fcnInfoSP=Float2FixedManager.remapScriptPath(fcnInfo.scriptPath,this.blockID.SID);
                        if strcmp(fcnInfoSP,fcnID.ScriptPath)&&fcnInfo.specializationId==fcnInfoSplID
                            break;
                        end
                    end
                end

                varInfos=fcnInfo.getVarInfosByName(varID.VariableName);
                for kk=1:numel(varInfos)
                    baseVarInfo=varInfos{kk};

                    if baseVarInfo.isStruct()
                        varInfo=baseVarInfo.getStructPropVarInfo(result.VarName);
                    else
                        varInfo=baseVarInfo;
                    end

                    if varInfo.isSpecialized()
                        varInstanceCount=varInfo.SpecializationId;
                    else
                        varInstanceCount=1;
                    end
                    if(varID.InstanceCount~=varInstanceCount)
                        continue;
                    end


                    msgs=varInfo.getMessage(message(msgID,varInfo.SymbolName),coder.internal.lib.Message.ERR);
                end
            end

            if~isempty(msgs)
                for ii=1:length(msgs)
                    msg=msgs(ii);
                    buildState.messages=[msg.toGUIStruct(),buildState.messages];
                end
                this.putGUIState('buildState',buildState);
            end
        end

        function unsupportedDerivedOnlyWorkflow(this)
            buildState=this.getGUIState('buildState');
            if isempty(buildState)
                buildState=coder.internal.MLFcnBlock.F2FDriver.DEFAULT_BUILDSTATE;
            end


            fcnInfos=this.State.fcnInfoRegistry.getAllFunctionTypeInfos;
            fcnInfos=[fcnInfos{:}];
            fcnIndices=arrayfun(@(f)f.tree.indices,fcnInfos);
            minIdx=min(fcnIndices);
            rootFcnInfo=fcnInfos(fcnIndices==minIdx);

            msgID='Coder:FXPCONV:MLFB_DerivedOnlyWorkflowUnsupported';
            msgType=coder.internal.lib.Message.ERR;

            MLFBFxpVariantCannotApplyMsg=coder.internal.lib.Message.buildMessage(rootFcnInfo,rootFcnInfo.tree,msgType,msgID,{});
            buildState.messages=[MLFBFxpVariantCannotApplyMsg.toGUIStruct(),buildState.messages];
            this.putGUIState('buildState',buildState);
        end



        function addCannotApplyForFixptVariantMsg(this,runName)
            [simRunState,backendMessages]=this.getGUISimState(runName);
            if isempty(simRunState)
                simRunState=coder.internal.MLFcnBlock.F2FDriver.getDefaultSimState();
            end


            fcnInfos=this.State.fcnInfoRegistry.getAllFunctionTypeInfos;
            fcnInfos=[fcnInfos{:}];
            fcnIndices=arrayfun(@(f)f.tree.indices,fcnInfos);
            minIdx=min(fcnIndices);
            rootFcnInfo=fcnInfos(fcnIndices==minIdx);

            msgID='Coder:FXPCONV:MLFB_CannotApplyFixptVariant';
            msgType=coder.internal.lib.Message.WARN;

            MLFBFxpVariantCannotApplyMsg=coder.internal.lib.Message.buildMessage(rootFcnInfo,rootFcnInfo.tree,msgType,msgID,{});
            backendMessages=[MLFBFxpVariantCannotApplyMsg.toGUIStruct(),backendMessages];
            this.putGUISimState(runName,simRunState,backendMessages);
        end

        function compilationReport=getCompilationReport(this)
            dataRepositoryFacade=this.getDataRepositoryFacade();
            if isempty(dataRepositoryFacade)
                dataRepositoryFacade=coder.internal.MLFcnBlock.DataRepositoryFacade(this.blockID);
                this.setDataRepositoryFacade(dataRepositoryFacade);
            end
            compilationReport=dataRepositoryFacade.getCompilationReport();
        end

        function isStale=isBuildStateStale(this)
            if isempty(this.GUIState)||isempty(this.GUIState.buildState)...
                ||~isfield(this.GUIState.buildState,'chartCheckSum')...
                ||~isfield(this.GUIState.buildState,'nameResolInfo')

                isStale=true;
                return;
            end




            currChksum=coder.internal.MLFcnBlock.Float2FixedManager.computeCheckSum(this.blockID.SID);
            isStale=~strcmp(this.GUIState.buildState.chartCheckSum,currChksum);




            if~isStale
                currNrInfo=this.GUIState.buildState.nameResolInfo;

                chartId=sfprivate('block2chart',this.blockID.SID);
                machineId=sf('get',chartId,'chart.machine');
                if(sf('get',machineId,'machine.isLibrary'))
                    mainMachineId=sf('get',machineId,'machine.mainMachine');
                else
                    mainMachineId=machineId;
                end
                targetId=sfprivate('acquire_target',mainMachineId,'sfun');
                changedEntryIndices=sfprivate('verify_eml_resolved_functions',mainMachineId,targetId,currNrInfo,this.blockID.Handle);
                if~isempty(changedEntryIndices)
                    isStale=true;
                end
            end
        end

        function dataRepFacade=getDataRepositoryFacade(this)
            if~isempty(this.State)&&isfield(this.State,'dataRepositoryFacade')
                dataRepFacade=this.State.dataRepositoryFacade;
            else
                dataRepFacade=coder.internal.MLFcnBlock.DataRepositoryFacade.empty();
            end
        end

        function saveUnSupportedFcnInfo(this,value)
            this.State.unSupportedFcnsInfo=value;
        end

        function value=getUnsupportedFcnInfo(this)
            if~isempty(this.State)&&isfield(this.State,'unSupportedFcnsInfo')
                value=this.State.unSupportedFcnsInfo;
            else
                value=[];
            end
        end

        function setDataRepositoryFacade(this,value)
            this.State.dataRepositoryFacade=value;
        end

        function remapRunFromDataRepository(this,oldRunName,newRunName)
            dataRepositoryFacade=this.getDataRepositoryFacade();
            if~isempty(dataRepositoryFacade)
                if dataRepositoryFacade.hasRunResult(oldRunName)
                    dataRepositoryFacade.removeRun(oldRunName);
                    dataRepositoryFacade.addRun(newRunName);
                end

                if dataRepositoryFacade.hasRunTimeStampInfo(oldRunName)
                    info=dataRepositoryFacade.getRunTimeStampInfo(oldRunName);
                    dataRepositoryFacade.addRunTimeStampInfo(newRunName,info);
                end
            end
        end

        function removeRunFromDataRepository(this,runName)
            if~isempty(this.getDataRepositoryFacade())
                if isempty(runName)
                    this.State.dataRepositoryFacade.removeAllRuns();
                else
                    this.State.dataRepositoryFacade.removeRun(runName);
                end
            end
        end







        function putGUIState(this,guiStepName,value)
            assert(any(ismember({'buildState','simState','applyState','proposeState'},guiStepName)));
            this.GUIState.(guiStepName)=value;
        end


        function value=getGUIState(this,guiStepName)
            if isfield(this.GUIState,guiStepName)
                value=this.GUIState.(guiStepName);
            else
                value=[];
            end
        end


        function value=clearGUIState(this,guiStepName)
            value=this.getGUIState(guiStepName);
            this.GUIState.remove(guiStepName);
        end

        function putGUISimState(this,runName,inputSimState,backendMessages)
            simState=this.GUIState.simState;
            inputSimState.backendMessages=backendMessages;
            simState(runName)=inputSimState;

            this.GUIState.simState=simState;
        end

        function[val,backendMessages]=getGUISimState(this,runName)
            val=[];
            backendMessages=[];
            simState=this.GUIState.simState;
            if simState.isKey(runName)
                val=simState(runName);




                if~isempty(val)
                    backendMessages=val.backendMessages;
                    val=rmfield(val,'backendMessages');
                    areAllFieldsEmpty=all(cellfun(@(x)isempty(val.(x)),fieldnames(val),'UniformOutput',true));
                    if areAllFieldsEmpty
                        val=[];
                    end
                end
            end
        end

        function clearGUISimState(this,runName)
            simState=this.GUIState.simState;
            if isempty(runName)
                simState.remove(simState.keys);
            else
                if simState.isKey(runName)
                    simState.remove(runName);
                end
            end
            this.GUIState.simState=simState;
        end






        function[fcnVarInfo,exprTypeInfo,messages]=proposeTypes(this,fcnInfoRegistry)
            exprTypeInfo={};
            messages=coder.internal.lib.Message.empty();

            generateNegFractionLenWarning=false;
            [fcnVarInfo,messages]=coder.internal.computeBestTypes(fcnInfoRegistry,this.getTypeProposalSettings(),generateNegFractionLenWarning,messages);
            this.setAnnotatedTypes(fcnInfoRegistry);
            if~isempty(this.State.exprInfoMap)
                exprTypeInfo=coder.internal.computeBestTypeForExpressions(this.State.exprInfoMap,this.getTypeProposalSettings());
            end
        end






        function[fcnVarsInfo,exprTypeInfo,proposeTypesMsgs]=addSimulationResults(this,coderReport,loggedVariablesData)
            this.State.coderReport=coderReport;

            this.addInstrumentationData(this.State.coderReport,loggedVariablesData);
            [fcnVarsInfo,exprTypeInfo,proposeTypesMsgs]=this.proposeTypes(this.State.fcnInfoRegistry);
        end

        function inferenceReportMisMatch=addInstrumentationData(this,instrumentationReport,loggedVariablesData,runName)
            if nargin==4
                buildState=this.getGUIState('buildState');
                isRunStale=false;
                if~isempty(buildState)
                    mlfbFacade=this.getDataRepositoryFacade();
                    isRunStale=mlfbFacade.hasRunTimeStampInfo(runName)&&mlfbFacade.isRunStale(runName,buildState.mlfbChecksum);
                end
                if isRunStale
                    masterInferenceManager=coder.internal.MasterInferenceManager.getInstance;
                    report=this.getCompilationReport();
                    masterInferenceManager.setCurrentInferenceReport(report.inference);
                    cleanupMasterInference=onCleanup(@()masterInferenceManager.releaseMasterInferenceReport());
                end
            end

            [this.State.fcnInfoRegistry,exprInfoMap,inferenceReportMisMatch]=this.updateFcnInfoRegistry(instrumentationReport,loggedVariablesData,this.State.fcnInfoRegistry,this.State.userWrittenFunctions);
            this.State.exprInfoMap=exprInfoMap;
        end

        function result=generateCode(this,chart)
            inVals={};
            result=this.generateCodeImpl(inVals,this.State.coderReport,this.State.fcnInfoRegistry,this.State.exprInfoMap,this.State.designExprInfoMap);
        end


        function uniqueKey=getUniqueKey(this,blkSID)
            chartId=sfprivate('block2chart',blkSID);
            emlChart=idToHandle(slroot,chartId);
            blockH=get_param(emlChart.Path,'handle');


            MATLABFunctionBlockSpecializationCheckSum=sf('SFunctionSpecialization',chartId,blockH);
            [~,mainInfoName,~,~]=sfprivate('get_report_path',pwd,MATLABFunctionBlockSpecializationCheckSum,false);

            if~exist(mainInfoName,'file')



                modeldir=fileparts(emlChart.Machine.FullFileName);
                reportDir=fullfile(sfprivate('get_sf_proj',modeldir),...
                'EMLReport');
                mainInfoName=fullfile(reportDir,...
                [MATLABFunctionBlockSpecializationCheckSum,'.mat']);
            end




            fileInfo=dir(mainInfoName);
            uniqueKey=sprintf('%s %s',mainInfoName,fileInfo.date);
        end

        function apply(this,blkSID,results,runObj,sudSID)
            try
                errs=coder.internal.lib.Message.getMessagesOfType(this.State.f2fCompatibilityMessages,...
                coder.internal.lib.Message.ERR);
                if numel(errs)>0
                    throw(MException(errs(1).id,errs(1).text));
                end

                sfId=sfprivate('block2chart',blkSID);
                chart=idToHandle(slroot,sfId);
                needsConversion=this.applyFPTResults(results);
                if~needsConversion
                    return;
                end


                this.applyCodeViewDataToConfig(blkSID);



                if this.isBuildStateStale()
                    buildState=this.getGUIState('buildState');
                    if isempty(buildState)
                        buildState=coder.internal.MLFcnBlock.F2FDriver.DEFAULT_BUILDSTATE;
                    end
                    compilationReport=this.getCompilationReport();

                    if isempty(compilationReport)

                        return;
                    end

                    buildState.inference=@()emlcprivate('flattenInferenceReportForJava',compilationReport.inference);
                    this.putGUIState('buildState',buildState);
                end

                result=this.generateCode(chart);

                if~isempty(result)
                    if strcmp(coder.internal.f2ffeature('MLFBApplyStyle'),'Replace')
                        chart.Script=result.FixPtCode;
                    elseif strcmp(coder.internal.f2ffeature('MLFBApplyStyle'),'Variants')
                        import coder.internal.mlfb.gui.CodeViewUpdater;



                        coder.internal.MLFcnBlock.Float2FixedManager.markForBlockRemapping(blkSID);
                        CodeViewUpdater.markVariantCreationStart(blkSID);

                        fpt=coder.internal.mlfb.FptFacade.getInstance();
                        sudSID=getFixPtToolSUDSID();
                        changeSUDToVariantSubsystem=false;

                        if fpt.isLive()&&strcmp(sudSID,blkSID)

                            fpt.setSystemForConversion(fpt.getSud().getParent(),true);
                            changeSUDToVariantSubsystem=true;
                        end

                        [origMLFB,fixptMLFB,varSubSys,newCreation]=coder.internal.mlfb.makeVariantSubsystemForMLFB(blkSID);
                        coder.internal.MLFcnBlock.addMLFBAnnotation(varSubSys,get_param(origMLFB,'Name'),get_param(fixptMLFB,'Name'));

                        if changeSUDToVariantSubsystem
                            subSys=get_param(blkSID,'Parent');
                            subSysObj=get_param(subSys,'Object');
                            fpt.setSystemForConversion(subSysObj,false);
                        end

                        if newCreation
                            set_param(origMLFB,'TreatAsAtomicUnit','on');
                            set_param(fixptMLFB,'TreatAsAtomicUnit','on');
                            set_param(varSubSys,'TreatAsAtomicUnit','on');
                        end

                        if~strcmp(blkSID,Simulink.ID.getSID(fixptMLFB))
                            if floatOverrideIsOnInHierarchy(fixptMLFB)
                                set_param(varSubSys,'LabelModeActiveChoice',get_param(origMLFB,'VariantControl'));
                            end

                            origSfId=sfprivate('block2chart',origMLFB');
                            origChart=idToHandle(sfroot,origSfId);

                            sfId=sfprivate('block2chart',fixptMLFB);
                            chart=idToHandle(slroot,sfId);

                            set_param(fixptMLFB,'Permissions','ReadWrite');



                            this.copyChartAndInterfaceObjectsProperties(origChart,chart);

                            chart.Script=result.FixPtCode;
                            chart.EmlDefaultFimath='Other:UserSpecified';
                            chart.InputFimath=this.fxpCfg.fimath;

                            Inputs=chart.Inputs;
                            for ii=1:numel(Inputs)
                                inp=Inputs(ii);
                                inp.DataType=sanitizeIOType(inp.DataType);
                            end

                            Outputs=chart.Outputs;
                            for ii=1:numel(Outputs)
                                out=Outputs(ii);
                                out.DataType=sanitizeIOType(out.DataType);
                            end

                            Params=sf('find',sf('DataOf',chart.id),'.scope','PARAMETER');
                            for ii=1:numel(Params)




                                param=Params(ii);
                                sf('set',param,'.dataType','Inherit: Same as Simulink');
                            end

                            ParamNames=get_param(origMLFB,'MaskNames');
                            if~isempty(ParamNames)
                                ParamValues=get_param(origMLFB,'MaskValues');

                                functionTypeInfos=this.State.fcnInfoRegistry.getAllFunctionTypeInfos();
                                mlfbTypeInfo=[];
                                for ii=1:numel(functionTypeInfos)
                                    if functionTypeInfos{ii}.isDesign
                                        mlfbTypeInfo=functionTypeInfos{ii};
                                        break;
                                    end
                                end

                                if~isempty(mlfbTypeInfo)
                                    for ii=1:numel(ParamNames)
                                        paramName=ParamNames{ii};
                                        varTypeInfos=mlfbTypeInfo.getVarInfosByName(paramName);
                                        if~isempty(varTypeInfos)


                                            varTypeInfo=varTypeInfos{1};
                                            NT=varTypeInfo.annotated_Type;
                                            if isa(NT,'embedded.numerictype')
                                                ParamValues{ii}=sprintf('fi(%s, %d, %d, %d)',ParamValues{ii},NT.SignednessBool,NT.WordLength,NT.FractionLength);
                                            end
                                        end
                                    end
                                    set_param(fixptMLFB,'MaskValues',ParamValues);
                                end
                            end


                            set_param(fixptMLFB,'Permissions','ReadOnly');
                        else

                            newCreation=false;
                        end


                        coder.internal.MLFcnBlock.Float2FixedManager.finishBlockRemapping(blkSID);
                        CodeViewUpdater.markVariantCreationEnd(origMLFB,varSubSys,newCreation);
                    end
                end

                this.codeViewStoreApplyState(result);
            catch ex
                if coder.internal.gui.debugmode
                    coder.internal.gui.asyncDebugPrint(ex);
                end
                rethrow(ex);
            end


            function res=floatOverrideIsOnInHierarchy(blk)
                res=false;
                try
                    while~isempty(blk)
                        switch get_param(blk,'DataTypeOverride')
                        case{'Double','Single'}
                            res=res||true;
                        end
                        blk=get_param(blk,'Parent');
                    end
                catch ex
                end
            end

            function type=sanitizeIOType(type)



                switch type
                case{'int8','int16','int32','int64',...
                    'uint8','uint16','uint32','uint64'}
                    type=numerictype(fi(cast(0,type)));
                    type=strrep(tostring(type),'numerictype','fixdt');
                end
            end

            function sudSID=getFixPtToolSUDSID()
                sudSID='';
                try
                    if~isempty(fpt)&&fpt.isLive()
                        sudSID=Simulink.ID.getSID(fpt.getSud());
                    end
                catch
                end
            end
        end

        function copyChartAndInterfaceObjectsProperties(this,origChart,fixPtChart)
            this.copyChartProperties(origChart,fixPtChart);
            [origOutputObjects,origInputObjects]=this.getPrototypeObjects(origChart);
            [fixPtOutputObjects,fixPtInputObjects]=this.getPrototypeObjects(fixPtChart);

            for ii=1:numel(origOutputObjects)
                this.copyObjectProperties(origOutputObjects{ii},fixPtOutputObjects{ii});
            end

            for ii=1:numel(origInputObjects)
                this.copyObjectProperties(origInputObjects{ii},fixPtInputObjects{ii});
            end
        end

        function copyObjectProperties(this,origIO,fixPtIO)
            try

                fixPtIO.Scope=origIO.Scope;
                fixPtIO.Port=origIO.Port;


                fixPtIO.Complexity=origIO.Complexity;
                fixPtIO.Props.Array.Size=origIO.Props.Array.Size;
                fixPtIO.Props.Array.IsDynamic=origIO.Props.Array.IsDynamic;
                fixPtIO.Props.Range.Minimum=origIO.Props.Range.Minimum;
                fixPtIO.Props.Range.Maximum=origIO.Props.Range.Maximum;

                fixPtIO.Props.Unit.Name=origIO.Props.Unit.Name;


                fixPtIO.SaveToWorkspace=origIO.SaveToWorkspace;
                fixPtIO.Description=origIO.Description;
                fixPtIO.Document=origIO.Document;


                fixPtIO.Tunable=origIO.Tunable;
            catch
            end
        end

        function copyChartProperties(this,origChart,fixPtChart)
            fixPtChart.ChartUpdate=origChart.ChartUpdate;
            fixPtChart.SampleTime=origChart.SampleTime;

            fixPtChart.SupportVariableSizing=origChart.SupportVariableSizing;
            fixPtChart.AllowDirectFeedthrough=origChart.AllowDirectFeedthrough;
            fixPtChart.SaturateOnIntegerOverflow=origChart.SaturateOnIntegerOverflow;

            fixPtChart.TreatAsFi=origChart.TreatAsFi;
            fixPtChart.InputFimath=origChart.InputFimath;
            fixPtChart.EmlDefaultFimath=origChart.EmlDefaultFimath;

            fixPtChart.Description=origChart.Description;
            fixPtChart.Document=origChart.Document;
        end

        function[outputObjects,inputObjects]=getPrototypeObjects(this,chart)
            outputObjects={};
            Outputs=chart.Outputs;
            for ii=1:numel(Outputs)
                outputObjects{ii}=Outputs(ii);
            end

            inputObjects={};

            objectMap=containers.Map();
            Inputs=chart.Inputs;
            for ii=1:numel(Inputs)
                inp=Inputs(ii);
                inpName=inp.Name;
                if numel(inpName)>63
                    inpName=inpName(1:63);
                end
                objectMap(inpName)=inp;
            end

            Params=sf('find',sf('DataOf',chart.id),'.scope','PARAMETER');
            for ii=1:numel(Params)
                parId=Params(ii);
                par=idToHandle(slroot,parId);
                parName=par.Name;
                if numel(parName)>63
                    parName=parName(1:63);
                end
                objectMap(parName)=par;
            end

            tr=mtree(chart.Script);
            if~isempty(tr)
                fcn=tr.root;
                if strcmp(fcn.kind,'FUNCTION')
                    ins=fcn.Ins;
                    while~isempty(ins)
                        inpName=string(ins);
                        inputObjects{end+1}=objectMap(inpName);
                        ins=ins.Next;
                    end
                end
            end
        end

        function res=applyFPTResults(this,mappedResults)

            groupedResults=containers.Map();
            for ii=1:numel(mappedResults)
                res=mappedResults(ii);

                key=sprintf('%s::%s::%d',res.FunctionName,normalizeScriptPathForLookup(res.ScriptPath),res.FunctionSpecializationId);
                if~groupedResults.isKey(key)
                    groupedResults(key)=res;
                else
                    items=groupedResults(key);
                    items(end+1)=res;
                    groupedResults(key)=items;
                end
            end

            functionTypeInfos=this.State.fcnInfoRegistry.getAllFunctionTypeInfos();

            functionTable=containers.Map();
            for ii=1:numel(functionTypeInfos)
                fcnInfo=functionTypeInfos{ii};
                key=sprintf('%s::%s::%d',fcnInfo.functionName,normalizeScriptPathForLookup(fcnInfo.scriptPath),fcnInfo.specializationId);
                functionTable(key)=fcnInfo;
            end

            runningFBT=coder.internal.f2ffeature('RunningMLFBFBT');
            count=0;
            keys=groupedResults.keys();
            for ii=1:numel(keys)
                key=keys{ii};

                results=groupedResults(key);
                functionTypeInfo=functionTable(key);
                assert(~isempty(functionTypeInfo));

                for jj=1:numel(results)
                    result=results(jj);

                    varInfos=functionTypeInfo.getVarInfosByName(result.VarName);
                    for kk=1:numel(varInfos)
                        baseVarInfo=varInfos{kk};

                        if baseVarInfo.isStruct()
                            varInfo=baseVarInfo.getStructPropVarInfo(result.VarName);
                        else
                            varInfo=baseVarInfo;
                        end



                        fptMLVarID=result.VarResult.getUniqueIdentifier();
                        if~baseVarInfo.isSpecialized||baseVarInfo.isSpecialized&&any(repmat(varInfo.TextStart,1,length(fptMLVarID.TextStart))==fptMLVarID.TextStart)
                            chosenType=result.ChosenType;


                            if isa(chosenType,'char')&&strcmp(chosenType,coder.internal.MLFcnBlock.F2FDriver.NA_TYPE)&&...
                                all([result.SimMin,result.SimMax]==[0,0])
                                chosenType=numerictype(0,1,0);
                            end
                            if isa(chosenType,'char')&&runningFBT&&strcmp(chosenType,coder.internal.MLFcnBlock.F2FDriver.NA_TYPE)
                                chosenType=numerictype(1,16,8);
                            end

                            if isa(fptMLVarID,'fxptds.MATLABCppSystemObjectVariableIdentifier')


                                varInfo.proposed_Type{end+1}=chosenType;
                            else
                                varInfo.proposed_Type=chosenType;
                            end

                            simMin=result.SimMin;
                            simMax=result.SimMax;
                            if numel(varInfo.loggedFields)>1




                                idx=find(strcmp(varInfo.loggedFields,fptMLVarID.VariableName));

                                if isa(fptMLVarID,'fxptds.MATLABCppSystemObjectVariableIdentifier')


                                    varInfo.proposed_Type{idx}=chosenType;
                                else
                                    varInfo.proposed_Type=chosenType;
                                end

                                if~isempty(simMin)
                                    if isempty(varInfo.SimMin)

                                        varInfo.SimMin=inf(numel(varInfo.loggedFields),1);
                                    end
                                    varInfo.SimMin(idx)=simMin;
                                end
                                if~isempty(simMax)
                                    if isempty(varInfo.SimMax)

                                        varInfo.SimMax=-inf(numel(varInfo.loggedFields),1);
                                    end
                                    varInfo.SimMax(idx)=simMax;
                                end
                            else




                                if isa(fptMLVarID,'fxptds.MATLABCppSystemObjectVariableIdentifier')


                                    varInfo.proposed_Type{end+1}=chosenType;
                                else
                                    varInfo.proposed_Type=chosenType;
                                end

                                if~isempty(simMin)
                                    varInfo.SimMin=simMin;
                                end
                                if~isempty(simMax)
                                    varInfo.SimMax=simMax;
                                end
                            end


                            if count==0&&isa(chosenType,'embedded.numerictype')
                                count=1;
                            end
                        end
                    end
                end
            end


            res=(count>=1);

            function scriptPath=normalizeScriptPathForLookup(scriptPath)



                if~isempty(strfind(scriptPath,'#'))
                    scriptPath=this.blockID.SID;
                end
            end
        end


        function[inferenceMsgs,f2fCompatibilityMessages]=buildFcnInfoRegistry(this,coderReport)
            inferenceReport=coderReport.inference;


            logs=fixed.internal.pullLog(['#',this.blockID.SID]);
            this.State.userWrittenFunctions=this.getUserWrittenFunctions(inferenceReport);
            this.State.fcnInfoRegistry=coder.internal.FunctionTypeInfoRegistry;
            try
                this.State.fcnInfoRegistry.setFimath(eval(this.fxpCfg.fimath));
            catch
                this.State.fcnInfoRegistry.setFimath(fimath);
            end

            rootFcnId=inferenceReport.RootFunctionIDs(1);
            this.fxpCfg.DesignFunctionName=inferenceReport.Functions(rootFcnId).FunctionName;

            globalTypes={};
            userWrittenFunctions=this.State.userWrittenFunctions;
            fcnInfoRegistry=this.State.fcnInfoRegistry;
            [inferenceMsgs,this.State.designExprInfoMap]=coder.internal.FcnInfoRegistryBuilder.populateFcnInfoRegistryFromInferenceInfo(inferenceReport...
            ,this.fxpCfg.DesignFunctionName...
            ,userWrittenFunctions...
            ,fcnInfoRegistry...
            ,globalTypes...
            ,this.fxpCfg.DebugEnabled...
            ,logs);

            [this.State.isF2FCompatible,f2fCompatibilityMessages]=this.runCompatibilityChecks();
            this.State.f2fCompatibilityMessages=f2fCompatibilityMessages;

            buildState=this.getGUIState('buildState');
            if isempty(buildState)
                buildState=coder.internal.MLFcnBlock.F2FDriver.DEFAULT_BUILDSTATE;
            end
            buildState.inference=@processReportForJava;
            buildState.callerCalleeList=@()coder.internal.Float2FixedConverter.BuildCallerCalleeTripes(this.State.fcnInfoRegistry);
            [checksum,nrInfo,~]=coder.internal.MLFcnBlock.Float2FixedManager.computeCheckSum(this.blockID.SID);
            buildState.chartCheckSum=checksum;
            buildState.nameResolInfo=nrInfo;
            buildState.mlfbChecksum=coder.internal.MLFcnBlock.DataRepositoryFacade.computeCoderReportCheckSum(this.blockID.SID,coderReport);
            if~isempty(f2fCompatibilityMessages)
                buildState.messages=[buildState.messages,arrayfun(@(msg)msg.toGUIStruct(),f2fCompatibilityMessages)];
            end

            success=coderReport.summary.passed&&~coder.internal.lib.Message.containErrorMsgs(f2fCompatibilityMessages);
            this.putGUIState('buildState',buildState);

            function inference=processReportForJava()
                inference=emlcprivate('flattenInferenceReportForJava',coderReport.inference);
                if success
                    inference.variableInfo=this.getVariableInfo();
                end
            end
        end

        function info=getVariableInfo(this)
            info=coder.internal.Float2FixedConverter.getVariableInfoUsing(this.State.fcnInfoRegistry,this.getTypeProposalSettings());
        end








        function errState=getErrorState(~,messages)
            errState=[];
            if coder.internal.lib.Message.containErrorMsgs(messages)
                errState=coder.internal.lib.Message.ERR;
            elseif coder.internal.lib.Message.containWarnMsgs(messages)
                errState=coder.internal.lib.Message.WARN;
            elseif coder.internal.lib.Message.containDispMsgs(messages)
                errState=coder.internal.lib.Message.DISP;


            end
        end

        function resetTypeProposalData(this)
            if~isfield(this.State,'fcnInfoRegistry')

                return;
            end
            this.clearAnnotations();
        end

        function resetRangeAndTypeProposalData(this)
            if~isfield(this.State,'fcnInfoRegistry')

                return;
            end

            this.clearSimulationData();
            this.clearStaticAnalysisData();
            this.resetTypeProposalData();
        end
    end

    methods(Access=private)
        function[fcnRegistry,exprInfoMap,inferenceReportMisMatch]=updateFcnInfoRegistry(this,coderReport,loggedVariablesData,fcnInfoRegistry,userWrittenFunctions)
            designName=this.fxpCfg.DesignFunctionName;
            inputArgNames=[];
            coderConstIndicies=[];
            DebugEnabled=true;
            [fcnRegistry,exprInfoMap,~,inferenceReportMisMatch]=coder.internal.FcnInfoRegistryBuilder.updateFunctionInfoRegistry(...
            fcnInfoRegistry,...
            coderReport,...
            {designName},...
            [],...
            {inputArgNames},...
            {coderConstIndicies},...
            [],...
            DebugEnabled);
        end

        function[isF2FCompatible,messages]=runCompatibilityChecks(this)
            messages=[];
            isF2FCompatible=true;

            globalsSupported=false;
            constrainerDriver=coder.internal.Float2FixedConstrainerDriver(this.State.fcnInfoRegistry,this.fxpCfg.DesignFunctionName);
            constrainerDriver.setFillCompiledMxInfo(true);
            constrainerDriver.setCompiledExprInfoMap(this.State.designExprInfoMap);

            mlfb=this.blockID.Block;

            if~coder.internal.mlfb.gui.MlfbUtils.isFixedPointVariant(mlfb)
                checkOtherUnSupportFcns=true;
                [constrainerMessages,unsupportedFcnInfo]=constrainerDriver.constrain(globalsSupported,this.fxpCfg.DoubleToSingle,checkOtherUnSupportFcns,this.blockID.SID);
            else

                constrainerMessages={};
                unsupportedFcnInfo={};
            end
            this.saveUnSupportedFcnInfo(unsupportedFcnInfo);

            runDMMChecks=false;
            [isF2FCompatible,fcnInfoCheckMsgs]=this.checkIfDesignIsF2FCompatible(runDMMChecks);
            messages=[messages,constrainerMessages,fcnInfoCheckMsgs];
        end

        function[compatible,messages]=checkIfDesignIsF2FCompatible(this,runDMMChecks)
            [compatible,messages]=this.checkIfDesignIsF2FCompatibleImpl(runDMMChecks);
        end


        function setAnnotatedTypes(this,fcnInfoRegistry)
            funcs=fcnInfoRegistry.getAllFunctionTypeInfos();
            for i=1:length(funcs)
                func=funcs{i};
                vars=func.getAllVarInfos();
                for j=1:length(vars)
                    var=vars{j};
                    var.clearAnnotations();
                end
            end
        end


        function inVals=createExampleInputVals(this,chart)
            inVals={};
            Inputs=chart.Inputs;

            for ii=1:numel(Inputs)
                in=Inputs(ii);
                inval_eg=sprintf('%s(zeros(%s))',in.CompiledType,in.CompiledSize);

                [~,inVal_type]=evalc(sprintf('%s',inval_eg));
                inVals{end+1}=inVal_type;
            end
        end


        function changeChartInputTypes(this,chart,inVals)
            Inputs=chart.Inputs;
            for ii=1:numel(Inputs)
                coderType=inVals{ii};
                Inputs(ii).DataType=tostring(coderType.NumericTye);
            end
        end

        function result=generateCodeImpl(this,inVals,coderReport,fcnInfoRegistry,exprInfoMap,designExprInfoMap)
            result=[];

            fxpConversionSettings.autoScaleLoopIndexVars=false;
            fxpConversionSettings.globalFimathStr=this.fxpCfg.fimath;
            fxpConversionSettings.fiMathVarName='fm';
            fxpConversionSettings.userFcnTemplatePath=this.fxpCfg.UserFunctionTemplatePath;
            fxpConversionSettings.userFcnMap=this.fxpCfg.getFunctionReplacementMap;
            fxpConversionSettings.suppressErrorMessages=this.fxpCfg.SuppressErrorMessages;
            fxpConversionSettings.fiCastFiVars=this.fxpCfg.FiCastFiVars;
            fxpConversionSettings.fiCastIntegers=this.fxpCfg.FiCastIntegerVars;
            fxpConversionSettings.detectFixptOverflows=this.fxpCfg.DetectFixptOverflows;
            fxpConversionSettings.debugEnabled=this.fxpCfg.DebugEnabled;
            fxpConversionSettings.autoReplaceCfgs=this.fxpCfg.getMathFcnConfigs;
            fxpConversionSettings.FixPtFileNameSuffix=this.fxpCfg.FixPtFileNameSuffix;
            fxpConversionSettings.GenerateParametrizedCode=this.fxpCfg.GenerateParametrizedCode;

            fxpConversionSettings.detectDeadCode=false;
            fxpConversionSettings.fiCastDoubleLiteralVars=true;

            fxpConversionSettings.TransformF2FInIR=false;
            fxpConversionSettings.DoubleToSingle=false;
            fxpConversionSettings.EmitSeperateFimathFunction=true;
            fxpConversionSettings.UseF2FPrimitives=false;

            fxpConversionSettings.MLFBApply=strcmp(this.fxpCfg.ProposeTypesMode,coder.FixPtConfig.MODE_MLFB);

            dName=coderReport.inference.Functions(1).FunctionName;
            designActualFcnName=dName;
            dNameFixPt=[dName,coder.FixPtConfig.DefaultFixPtFileNameSuffix];
            dNameFixptWrapper=[dName,'_wrapper_fixpt'];
            typesTableName='FixedPointTypes';

            designSettings.designNames={dName};
            designSettings.designActualFcnNames={dName};
            designSettings.fixPtDesignNames={dNameFixPt};
            designSettings.outputPath=tempdir;
            designSettings.testbenchName=this.fxpCfg.TestBenchName;
            designSettings.fcnInfoRegistry=fcnInfoRegistry;
            designSettings.compiledExprInfo=designExprInfoMap;

            exprMaps=exprInfoMap.values();


            if~isempty(exprMaps)
                exprInfo=exprMaps{1};
            else
                exprInfo=exprMaps;
            end
            designSettings.simExprInfo=exprInfo;


            designSettings.designIOWrapperName={dNameFixptWrapper};
            designSettings.globalUniqNameMap=containers.Map();

            typePropSettings=this.getTypeProposalSettings();
            fpc=coder.internal.DesignTransformer(designSettings,typePropSettings,fxpConversionSettings);

            dNameFixPtPath=fullfile(designSettings.outputPath,[dNameFixPt,'.m']);

            try



                [result.inVals,result.newTypesInfo,result.allErrorMsgs,~]=fpc.doIt(inVals,containers.Map);
                result.FixPtCode=fileread(dNameFixPtPath);
                result.FixPtCode=['%',this.AUTO_GENERATED_MARKER,char(10),result.FixPtCode];
                delete(dNameFixPtPath);
            catch ex
                if coder.internal.gui.debugmode
                    coder.internal.gui.asyncDebugPrint(ex);
                end
                if exist(dNameFixPtPath,'file')
                    delete(dNameFixPtPath);
                end
                rethrow(ex);
            end
        end


        function typeProposalSettings=getTypeProposalSettings(this)

            typeProposalSettings.proposeTargetContainerTypes=this.fxpCfg.ProposeTargetContainerTypes;
            typeProposalSettings.defaultWL=this.fxpCfg.DefaultWordLength;
            typeProposalSettings.defaultFL=this.fxpCfg.DefaultFractionLength;
            defSigned=this.fxpCfg.DefaultSignedness;
            switch defSigned
            case coder.FixPtConfig.AutoSignedness
                s=[];
            case coder.FixPtConfig.SignedSignedness
                s=true;
            case coder.FixPtConfig.UnsignedSignedness
                s=false;
            otherwise
                assert(false,'Incorrect default signedness value');
            end
            typeProposalSettings.defaultSignedness=s;typeProposalSettings.optimizeWholeNumber=this.fxpCfg.OptimizeWholeNumber;
            typeProposalSettings.proposeWLForDefFL=this.fxpCfg.ProposeWordLengthsForDefaultFractionLength;
            typeProposalSettings.proposeFLForDefWL=this.fxpCfg.ProposeFractionLengthsForDefaultWordLength;
            typeProposalSettings.safetyMargin=this.fxpCfg.SafetyMargin;

            typeProposalSettings.codingForHDL=this.fxpCfg.CodingForHDL;
            typeProposalSettings.useSimulationRanges=this.fxpCfg.UseSimulationRanges;
            typeProposalSettings.useDerivedRanges=this.fxpCfg.UseDerivedRanges;
            typeProposalSettings.DoubleToSingle=false;

            typeProposalSettings.proposeAggregateStructTypes=false;
            typeProposalSettings.Config=this.fxpCfg;
            typeProposalSettings.defaultFimath=eval(this.fxpCfg.fimath);
            typeProposalSettings.disbleProposeTypesForMLFCNBlock=true;
        end



        function[compatible,messages]=checkIfDesignIsF2FCompatibleImpl(this,runDMMChecks)
            compatible=true;
            assert(~isempty(this.State.fcnInfoRegistry));

            fcnTypeInfos=this.State.fcnInfoRegistry.getAllFunctionTypeInfos();

            dvoCfg=[];
            processedClasses=containers.Map();

            isMLFBWorkflow=true;
            messages=coder.internal.lib.Message.empty();
            for ii=1:length(fcnTypeInfos)
                fcnInfo=fcnTypeInfos{ii};
                [fcn_is_compatible,messages]=fcnInfo.isF2FCompatible(messages,runDMMChecks,dvoCfg,processedClasses,this.fxpCfg.DoubleToSingle,this.fxpCfg.EnableArrayOfStructures,isMLFBWorkflow,this.fxpCfg.isNonScalarSupportedForDVO);
                compatible=compatible&&fcn_is_compatible;
            end
            entryPointsCalledByOthers=coder.internal.detectEntryPointsCallingEachother(this.fxpCfg.DesignFunctionName,this.State.fcnInfoRegistry);
            if~isempty(entryPointsCalledByOthers)
                messages=[entryPointsCalledByOthers(:),messages];
                compatible=false;
            end
        end


        function clearSimulationData(this)
            if isempty(this.State.fcnInfoRegistry)
                return;
            end

            funcs=this.State.fcnInfoRegistry.getAllFunctionTypeInfos();
            for i=1:length(funcs)
                func=funcs{i};
                vars=func.getAllVarInfos();
                for j=1:length(vars)
                    var=vars{j};
                    var.clearSimulationData();
                end
            end
        end


        function clearStaticAnalysisData(this)
            if isempty(this.State.fcnInfoRegistry)
                return;
            end

            funcs=this.State.fcnInfoRegistry.getAllFunctionTypeInfos();
            for i=1:length(funcs)
                func=funcs{i};
                vars=func.getAllVarInfos();
                for j=1:length(vars)
                    var=vars{j};
                    var.clearStaticAnalysisData();
                end
            end
        end


        function clearAnnotations(this)
            funcs=this.State.fcnInfoRegistry.getAllFunctionTypeInfos();
            for i=1:length(funcs)
                func=funcs{i};
                vars=func.getAllVarInfos();
                for j=1:length(vars)
                    var=vars{j};
                    var.clearAnnotations();
                end
            end
        end
    end

    methods(Access=private,Static)

        function userWrittenFunctions=getUserWrittenFunctions(inferenceReport)
            inferenceReportFunctions=inferenceReport.Functions;
            inferenceReportScripts=inferenceReport.Scripts;

            userWrittenFunctions=containers.Map;
            for ii=1:length(inferenceReportFunctions)
                fcnInfo=inferenceReportFunctions(ii);
                fcnName=fcnInfo.FunctionName;

                if(fcnInfo.ScriptID<1)||...
                    (fcnInfo.ScriptID>length(inferenceReportScripts))
                    continue;
                end

                if~inferenceReportScripts(fcnInfo.ScriptID).IsUserVisible


                    continue;
                end











                userWrittenFunctions(fcnName)=true;
            end
        end
    end


    methods(Access=private)
        function applyCodeViewDataToConfig(this,mlfb)
            fpt=coder.internal.mlfb.FptFacade.getInstance();

            if~fpt.isLive()

                return;
            end




            sud=fpt.getSud();
            if~isempty(sud)
                sud=Simulink.ID.getSID(sud);

                import coder.internal.MLFcnBlock.Float2FixedManager;
                Float2FixedManager.applyFunctionReplacementsForBlock(this.fxpCfg,sud,mlfb);
                Float2FixedManager.applyFimathForBlock(this.fxpCfg,sud);
            end
        end

        function codeViewStoreApplyState(this,result)
            if isempty(result)||isempty(result.allErrorMsgs)
                this.putGUIState('applyState',struct('messages',{}));
            else
                assert(isstruct(result)&&isfield(result,'allErrorMsgs'));
                flattened=emlcprivate('flattenForJava',result.allErrorMsgs);
                this.putGUIState('applyState',struct('messages',flattened));
            end
        end

        function[res,chartFullName]=isWithinStateflowChart(this,sudID)
            res=false;
            chartFullName='';

            try

                sud=sudID.getObject();
                sudHandle=str2double(sud.getPropValue('Handle'));



                p=this.blockID.getParent();
                while(~isempty(p)&&p.get_param('Handle')~=sudHandle)
                    if p.isStateflowChart()&&~p.isFunctionBlock()
                        res=true;
                        chartFullName=p.FullName;
                        break;
                    end
                    p=p.getParent();
                end
            catch ex
                coder.internal.gui.asyncDebugPrint(ex);
            end
        end
    end


    methods(Hidden)
        function applyMessages=getAndClearApplyMessages(this)
            applyState=this.getGUIState('applyState');
            if~isempty(applyState)
                applyMessages=applyState.messages;
            else
                applyMessages={};
            end
        end
    end
end




classdef Float2FixedManager<handle
    properties(Constant,Access=private)

        DataStore=coder.internal.mlfb.gui.BlockDataStore('Driver',...
        'DefaultReplacements',...
        'BlockReplacements',...
        'Fimath');
    end

    methods(Static,Hidden)
        function[inference,mexFile,messages,success,callerCalleeList,errorMessage]=buildFloatingPointCode(mlfb)
            [inference,mexFile,messages,success,callerCalleeList,errorMessage]=coder.internal.MLFcnBlock.Float2FixedManager.buildFloatingPointCodeImpl(mlfb);
        end

        function[ranges,expressions,coverageInfo,errorMessage,messages]=runSimulation(mlfb)
            driver=getMLFBDriver(mlfb);
            [ranges,expressions,coverageInfo,errorMessage,messages]=coder.internal.MLFcnBlock.Float2FixedManager.runSimulationImpl(driver,mlfb);
        end


        function reset(~)

        end

        function cacheInvalidateForRun(varargin)


            runName=varargin{1}{1};
            drivers=coder.internal.MLFcnBlock.Float2FixedManager.getAllMLFBDrivers();
            cellfun(@(driver)driver.clearGUISimState(runName),drivers);
            cellfun(@(driver)driver.removeRunFromDataRepository(runName),drivers);
        end

        function cacheInvalidate(mlfbSID,runName)



            driver=coder.internal.MLFcnBlock.Float2FixedManager.cacheInvalidateOnly(mlfbSID,runName);
            driver.removeRunFromDataRepository(runName);
        end

        function driver=cacheInvalidateOnly(mlfbSID,runName)

            driver=coder.internal.MLFcnBlock.Float2FixedManager.getMLFBDriver(mlfbSID);
            driver.clearGUISimState(runName);
        end

        function cacheRunRemapped(oldName,newName)
            drivers=coder.internal.MLFcnBlock.Float2FixedManager.getAllMLFBDrivers();
            for ii=1:length(drivers)

                driver=drivers{ii};
                [simRunState,backendMessages]=driver.getGUISimState(oldName);
                driver.clearGUISimState(oldName);
                driver.putGUISimState(newName,simRunState,backendMessages);
                driver.remapRunFromDataRepository(oldName,newName);
            end
        end

        function setSudFimath(block,fimathStr)


            dataStore=coder.internal.MLFcnBlock.Float2FixedManager.DataStore;
            dataStore.setBlockData(block,'Fimath',fimathStr);
        end

        function sudFimath=getSudFimath(sud)


            dataStore=coder.internal.MLFcnBlock.Float2FixedManager.DataStore;
            sudFimath=dataStore.getBlockData(sud,'Fimath');
        end

        function applyFimathForBlock(config,sudBlock)


            dataStore=coder.internal.MLFcnBlock.Float2FixedManager.DataStore;
            if dataStore.isKey(sudBlock)
                fimathStr=dataStore.getBlockData(sudBlock,'Fimath');
                if~isempty(fimathStr)
                    config.fimath=fimathStr;
                end
            end
        end

        function fimath=getFimath(mlfb)
            driver=coder.internal.MLFcnBlock.Float2FixedManager.createOrGetMLFBDriver(mlfb);
            fimath=driver.fxpCfg.fimath;
        end

        function messages=getApplyErrors(mlfb)
            driver=coder.internal.MLFcnBlock.Float2FixedManager.getMLFBDriver(mlfb);
            if~isempty(driver)
                messages=driver.getAndClearApplyMessages();
            else
                messages={};
            end
        end

        function applyFunctionReplacementsForBlock(config,sudBlock,fcnBlock)




            sudXml=coder.internal.MLFcnBlock.Float2FixedManager.DataStore.getBlockData(sudBlock,'DefaultReplacements');
            blockData=coder.internal.MLFcnBlock.Float2FixedManager.DataStore.getBlockData(fcnBlock,'BlockReplacements');

            import com.mathworks.toolbox.coder.mlfb.FunctionBlockUtils;
            try
                xmlReader=FunctionBlockUtils.createReplacementsXmlReader(blockData,sudXml);

                if~isempty(xmlReader)
                    coderprivate.Float2FixedManager.applyFunctionReplacementsToConfig(config,xmlReader);
                end
            catch me
                coder.internal.gui.asyncDebugPrint(me);
            end
        end

        function replacementsXml=getFunctionReplacementsForBlock(id,overrides)
            assert(islogical(overrides));
            if overrides
                fieldName='BlockReplacements';
            else
                fieldName='DefaultReplacements';
            end
            replacementsXml=coder.internal.MLFcnBlock.Float2FixedManager.DataStore.getBlockData(id,fieldName);
        end

        function setSudFunctionReplacements(sud,xml)
            assert(ischar(xml));
            coder.internal.MLFcnBlock.Float2FixedManager.DataStore.setBlockData(sud,'DefaultReplacements',xml);
        end

        function setBlockFunctionReplacements(mlfb,xml)
            assert(ischar(xml)&&coder.internal.mlfb.gui.MlfbUtils.isFunctionBlock(mlfb));
            coder.internal.MLFcnBlock.Float2FixedManager.DataStore.setBlockData(mlfb,'BlockReplacements',xml);
        end

        function success=setProposedType(mlfb,runName,f2fFcnUniqID,varName,varSpecializationID,proposedTypeStr)
            success=false;
            hasSpecialization=~isempty(varSpecializationID);

            if ischar(proposedTypeStr)
                if regexp(proposedTypeStr,'numerictype\(.+\).*')
                    try
                        [~,proposedType]=evalc(proposedTypeStr);
                    catch
                        proposedType=[];
                    end

                    if~isa(proposedType,'embedded.numerictype')
                        return;
                    end
                else
                    [s,wlen,flen,errored]=coder.internal.Float2FixedConverter.getTypeInfoFromStr(proposedTypeStr);
                    if~errored
                        proposedType=numerictype(s,wlen,flen);
                    else
                        return;
                    end
                end
            elseif~isempty(proposedTypeStr)
                proposedType=proposedTypeStr;
            else
                return;
            end

            assert(isa(proposedType,'embedded.numerictype'));

            varTextStart=[];
            driver=coder.internal.MLFcnBlock.Float2FixedManager.getMLFBDriver(mlfb);
            fcnRegistry=driver.State.fcnInfoRegistry;
            fcnInfo=fcnRegistry.getFunctionTypeInfo(f2fFcnUniqID);
            if hasSpecialization

                varInfos=fcnInfo.getVarInfosByName(varName);
                for ii=1:length(varInfos)

                    varInfo=varInfos{ii};
                    if varInfo.SpecializationId==varSpecializationID
                        break;
                    end
                end
                varTextStart=varInfo.TextStart;
            end

            try
                success=coder.internal.MLFcnBlock.Float2FixedManager.setProposedTypeImpl(mlfb,runName,fcnInfo,varName,varTextStart,hasSpecialization,proposedType);
                if success


                    coder.internal.MLFcnBlock.Float2FixedManager.cacheInvalidateOnly(mlfb.SID,runName);
                end
            catch ex
                coder.internal.gui.asyncDebugPrint(ex);
            end
        end

        function[f2fFcnUniqID,varName,varInstanceCount]=getVarMapping(result)
            f2fFcnUniqID=[];
            varName='';
            varInstanceCount=[];

            if~isa(result,'fxptds.MATLABVariableResult')
                return;
            end

            import coder.internal.MLFcnBlock.Float2FixedManager.*;
            mlfbSID=result.getUniqueIdentifier().MATLABFunctionIdentifier.SID;
            driver=coder.internal.MLFcnBlock.Float2FixedManager.getMLFBDriver(mlfbSID);
            fcnRegistry=driver.State.fcnInfoRegistry;

            fcnInfo=[];
            varID=result.getUniqueIdentifier();
            fcnID=varID.MATLABFunctionIdentifier;
            relaventFcnInfos=fcnRegistry.getFunctionTypeInfosByName(fcnID.FunctionName);
            for ii=1:length(relaventFcnInfos)
                fcnInfo=relaventFcnInfos{ii};
                if fcnInfo.isASpecializedFunction
                    fcnInstanceCount=fcnInfo.specializationId;
                else
                    fcnInstanceCount=1;
                end

                realScriptPath=remapScriptPath(fcnInfo.scriptPath,mlfbSID);
                if strcmp(fcnID.FunctionName,fcnInfo.functionName)...
                    &&strcmp(fcnID.ScriptPath,realScriptPath)...
                    &&fcnID.InstanceCount==fcnInstanceCount...
                    &&fcnID.IsClass==fcnInfo.isDefinedInAClass()...
                    &&strcmp(fcnID.ClassName,fcnInfo.getDefiningClass())


                    break;
                end
            end

            if~isempty(fcnInfo)
                f2fFcnUniqID=fcnInfo.uniqueId;
                varName=varID.VariableName;
                varInstanceCount=varID.InstanceCount;
            end
        end

    end

    methods(Static,Hidden)
        function buildData=buildAllFloatingPointModels(mlfbList)
            buildData=cell(numel(mlfbList),1);
            for i=1:numel(mlfbList)
                try
                    [inferenceReport,~,messages]=coder.internal.MLFcnBlock.Float2FixedManager.buildFloatingPointCodeImpl(mlfbList{i});
                    buildData{i}={inferenceReport,messages};
                catch
                    buildData{i}=[];
                end
            end
        end








        function unSupportedFcnInfo=getAllUnSupportedFcnInfos(mlfbList)
            mlfbIds=coder.internal.mlfb.idForBlock(mlfbList);
            unSupportedFcnInfo=coder.internal.mlfb.createBlockMap();

            for i=1:numel(mlfbIds)
                mlfb=mlfbIds{i};
                driver=coder.internal.MLFcnBlock.Float2FixedManager.getMLFBDriver(mlfb);

                try
                    unsupportedForBlock=driver.getUnsupportedFcnInfo();
                catch
                    unsupportedForBlock={};
                end

                unSupportedFcnInfo(mlfb)=unsupportedForBlock;
            end
        end








        function[inference,mexFile,messages,success,callerCalleeList,errorMessage]=buildFloatingPointCodeImpl(mlfb)
            mlfb=coder.internal.mlfb.idForBlock(mlfb);

            inference=[];

            mexFile='';
            messages=[];


            success=true;
            callerCalleeList={};
            errorMessage='';

            blkSID=mlfb.SID;
            driver=coder.internal.MLFcnBlock.Float2FixedManager.createOrGetMLFBDriver(mlfb);

            try
                if~driver.isBuildStateStale()
                    buildState=driver.getGUIState('buildState');
                    try
                        if isa(buildState.inference,'function_handle')
                            inference=buildState.inference();
                        else
                            inference=buildState.inference;
                        end
                        messages=buildState.messages;

                        if isa(buildState.callerCalleeList,'function_handle')
                            callerCalleeList=buildState.callerCalleeList();
                        else
                            callerCalleeList=buildState.callerCalleeList;
                        end
                        errorMessage=buildState.errorMessage;
                        return;
                    catch ex
                        coder.internal.gui.asyncDebugPrint(ex);


                    end
                end


                dataRepositoryFacade=driver.getDataRepositoryFacade();
                if isempty(dataRepositoryFacade)
                    dataRepositoryFacade=coder.internal.MLFcnBlock.DataRepositoryFacade(mlfb);
                end

                compilationReport=dataRepositoryFacade.getCompilationReport();

                if isempty(compilationReport)
                    return;
                end

                driver.State.dataRepositoryFacade=dataRepositoryFacade;
                driver.State.coderReport=[];

                [inferenceMsgs,compatibilityMessages]=driver.buildFcnInfoRegistry(compilationReport);

                inference=emlcprivate('flattenInferenceReportForJava',compilationReport.inference);

                messages=coderprivate.convertMessagesToJavaArray(compilationReport);
                messages=coderprivate.Float2FixedManager.FilterForcePushToCloudMessage(messages,driver.fxpCfg.DesignFunctionName);

                f2fCompatibilityMessages=[compatibilityMessages,inferenceMsgs];
                f2fCompatibilityMessages=arrayfun(@(msg)msg.toGUIStruct(),f2fCompatibilityMessages);
                messages=[messages,f2fCompatibilityMessages];

                success=compilationReport.summary.passed&&~coder.internal.lib.Message.containErrorMsgs(f2fCompatibilityMessages);

                callerCalleeList=coder.internal.Float2FixedConverter.BuildCallerCalleeTripes(driver.State.fcnInfoRegistry);



                if(success)
                    inference.FixedPointVariableInfo=driver.getVariableInfo();
                end


                buildState=coder.internal.MLFcnBlock.F2FDriver.DEFAULT_BUILDSTATE;
                [checkSum,nrInfo,~]=coder.internal.MLFcnBlock.Float2FixedManager.computeCheckSum(blkSID);
                buildState.chartCheckSum=checkSum;
                buildState.nameResolInfo=nrInfo;
                buildState.mlfbChecksum=coder.internal.MLFcnBlock.DataRepositoryFacade.computeCoderReportCheckSum(blkSID,compilationReport);
                buildState.inference=inference;
                buildState.messages=messages;
                buildState.callerCalleeList=callerCalleeList;
                buildState.errorMessage=errorMessage;
                driver.putGUIState('buildState',buildState);
            catch ex
                errorMessage=ex.message;

                buildState.errorMessage=errorMessage;
                driver.putGUIState('buildState',buildState);

                coder.internal.gui.asyncDebugPrint(ex);
            end
        end





        function[fcnVarsInfo,expressions,coverageInfo,errorMessage,messages]=getSimulationResults(mlfb,runName)
            mlfb=coder.internal.mlfb.idForBlock(mlfb);

            defaultSimState=coder.internal.MLFcnBlock.F2FDriver.getDefaultSimState();
            errorMessage=defaultSimState.errorMessage;
            coverageInfo=defaultSimState.coverageInfo;
            fcnVarsInfo=defaultSimState.fcnVarsInfo;
            expressions=defaultSimState.expressions;
            messages=defaultSimState.messages;
            try
                driver=coder.internal.MLFcnBlock.Float2FixedManager.getMLFBDriver(mlfb);
                buildState=driver.getGUIState('buildState');
                dataRepositoryFacade=driver.getDataRepositoryFacade();
                if isempty(dataRepositoryFacade)
                    return;
                end
                if~dataRepositoryFacade.hasRunResult(runName)
                    return;
                end
                isRunStale=dataRepositoryFacade.isRunStale(runName,buildState.mlfbChecksum);

                [simRunState,backendMessages]=driver.getGUISimState(runName);
                if~isRunStale&&~isempty(simRunState)
                    errorMessage=simRunState.errorMessage;
                    coverageInfo=simRunState.coverageInfo;
                    fcnVarsInfo=simRunState.fcnVarsInfo;
                    expressions=simRunState.expressions;
                    messages=[backendMessages,simRunState.messages];
                    return;
                end

                messages=[messages,backendMessages];



                isRunStale=dataRepositoryFacade.hasRunTimeStampInfo(runName)&&dataRepositoryFacade.isRunStale(runName,buildState.mlfbChecksum);
                if isRunStale
                    staleMsg=driver.publishStaleRunMsg(runName);
                    throw(MException(staleMsg.Identifier,staleMsg.getString()));
                end

                [instrumentationReport,loggedVariablesData]=dataRepositoryFacade.getInstrumentationReport();



                driver.resetRangeAndTypeProposalData();
                try

                    driver.addInstrumentationData(instrumentationReport,loggedVariablesData);
                catch ex
                    rethrow(ex);
                end


                driver.resetTypeProposalData();
                mappedResults=dataRepositoryFacade.getMappedResults(runName);
                if~isempty(mappedResults)

                    driver.applyFPTResults(mappedResults);
                end
                [fcnVarsInfo,expressions,proposeTypesMsgs]=driver.proposeTypes(driver.State.fcnInfoRegistry);
                messages=[messages,arrayfun(@(msg)msg.toGUIStruct(),proposeTypesMsgs)];

                simRunState=coder.internal.MLFcnBlock.F2FDriver.getDefaultSimState();
                simRunState.errorMessage=errorMessage;
                simRunState.coverageInfo=coverageInfo;
                simRunState.fcnVarsInfo=fcnVarsInfo;
                simRunState.expressions=expressions;
                simRunState.messages=messages;

                driver.putGUISimState(runName,simRunState,backendMessages);
            catch ex
                errorMessage=ex.message;
                coder.internal.gui.asyncDebugPrint(ex);
            end
        end

        function drivers=getAllMLFBDrivers()
            dm=coder.internal.MLFcnBlock.Float2FixedManager.DataStore;
            drivers=dm.getAllDrivers();
        end

        function driver=getMLFBDriver(blockArg)
            dm=coder.internal.MLFcnBlock.Float2FixedManager.DataStore;
            if dm.isKey(blockArg)
                driver=dm.getBlockData(blockArg,'Driver');
            else
                driver=[];
            end
        end

        function driver=createOrGetMLFBDriver(block)
            mlock;
            dm=coder.internal.MLFcnBlock.Float2FixedManager.DataStore;
            id=coder.internal.mlfb.idForBlock(block);

            if dm.isKey(block)

                driver=coder.internal.MLFcnBlock.Float2FixedManager.getMLFBDriver(id);
            else

                driver=coder.internal.MLFcnBlock.F2FDriver(id.SID);
                dm.setBlockData(id,'Driver',driver);
            end
        end

        function removeMLFBDriver(blkSID)
            coder.internal.MLFcnBlock.Float2FixedManager.DataStore.setBlockData(blkSID,'Driver',[]);
        end




        function[checksum,nrInfo,chartId]=computeCheckSum(blkSID)
            assert(ischar(blkSID));
            chartId=sfprivate('block2chart',blkSID);

            hBlk=sfprivate('chart2block',chartId);
            if sfprivate('model_is_a_library',bdroot(hBlk))
                hBlk=sf('get',chartId,'chart.activeInstance');
            end
            checksum=sf('SFunctionSpecialization',chartId,hBlk,true);
            if isempty(checksum)





                checksum=sf('MD5AsString',getfullname(hBlk));
            end

            nrInfo=coder.internal.MLFcnBlock.Float2FixedManager.computeNameResolutionInfo(chartId,checksum);
        end

        function nrInfo=computeNameResolutionInfo(chartID,checkSum)
            nrInfo=sfprivate('get_eml_name_resolution_info',chartID,checkSum);
        end

        function markForBlockRemapping(mlfb)




            coder.internal.MLFcnBlock.Float2FixedManager.DataStore.beginRemapping(mlfb);
        end

        function finishBlockRemapping(mlfb)
            import coder.internal.MLFcnBlock.Float2FixedManager;
            mlfbId=coder.internal.mlfb.idForBlock(mlfb);



            Float2FixedManager.DataStore.finishRemapping(mlfbId);
            driver=coder.internal.MLFcnBlock.Float2FixedManager.getMLFBDriver(mlfb);





            if~isempty(driver)
                buildState=driver.getGUIState('buildState');
                if~isempty(buildState)


                    [checksum,nrInfo,~]=Float2FixedManager.computeCheckSum(mlfbId.SID);
                    buildState.chartCheckSum=checksum;
                    buildState.nameResolInfo=nrInfo;
                    driver.putGUIState('buildState',buildState);
                end
            end
        end

        function success=setProposedTypeImpl(mlfb,runName,fcnInfo,varName,varTextStart,hasSpecialization,proposedType)
            varResult=coder.internal.MLFcnBlock.Float2FixedManager.getVariableResult(...
            mlfb,runName,fcnInfo,varName,varTextStart,hasSpecialization);
            success=~isempty(varResult);

            if success


                dtHandler=fxptui.Web.ProposedDTChangeHandler(varResult);%#ok<NASGU>
                varResult.batchSetProposedDT(proposedType);
            end
        end

        function varResult=getVariableResult(mlfb,runName,fcnInfo,varName,varTextStart,hasSpecialization)
            varResult=[];

            import coder.internal.MLFcnBlock.Float2FixedManager;
            driver=Float2FixedManager.getMLFBDriver(mlfb);
            dataRepositoryFacade=driver.getDataRepositoryFacade();
            allResults=dataRepositoryFacade.getResults(runName);

            if fcnInfo.isASpecializedFunction
                fcnInstanceCount=fcnInfo.specializationId;
            else
                fcnInstanceCount=1;
            end

            realScriptPath=Float2FixedManager.remapScriptPath(fcnInfo.scriptPath,mlfb.SID);

            for ii=1:length(allResults)
                result=allResults(ii);
                if~isa(result,'fxptds.MATLABVariableResult')
                    continue;
                end




                matchesSpecialization=@(varUniqID)~hasSpecialization||(hasSpecialization&&any(repmat(varTextStart,1,length(varUniqID.TextStart))==varUniqID.TextStart));
                varID=result.getUniqueIdentifier();
                if(strcmp(varID.VariableName,varName)&&...
                    matchesSpecialization(varID)&&...
                    strcmp(varID.MATLABFunctionIdentifier.FunctionName,fcnInfo.functionName)&&...
                    strcmp(varID.MATLABFunctionIdentifier.ScriptPath,realScriptPath)&&...
                    varID.MATLABFunctionIdentifier.InstanceCount==fcnInstanceCount)












                    varResult=result;
                    break;
                end
            end
        end

        function realScriptPath=remapScriptPath(scriptPath,mlfbSID)
            if~isempty(scriptPath)&&strcmp(scriptPath(1),'#')

                realScriptPath=['#',mlfbSID];
            else
                realScriptPath=scriptPath;
            end
        end
    end
end



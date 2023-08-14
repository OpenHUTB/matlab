


classdef ClientServerValidator<autosar.validation.PhasedValidator


    properties(Constant,Access=private)
        slFcnBlkTypeName='Simulink function block';
        fcnCallerBlkTypeName='function caller block';
        ValidNvMServiceNames={'ReadBlock','WriteBlock','RestoreBlockDefaults'};
    end

    methods(Access=protected)

        function verifyInitial(this,hModel)
            this.verifyNoFunctionPorts(hModel);
        end

        function verifyPostProp(this,hModel)
            this.verifyClientArg(hModel);


            msg=this.verifyLocalCallers(hModel);


            tmpMsg=this.verifySimulinkFunctionBlockMapping(hModel);
            for i=1:length(tmpMsg.cause)
                msg=msg.addCause(tmpMsg.cause{i});
            end


            tmpMsg=this.verifyFunctionCallerBlockMapping(hModel);
            for i=1:length(tmpMsg.cause)
                msg=msg.addCause(tmpMsg.cause{i});
            end



            tmpMsg=this.verifyNoCallerAndFcnInSameModel(hModel);
            for i=1:length(tmpMsg.cause)
                msg=msg.addCause(tmpMsg.cause{i});
            end


            tmpMsg=this.verifyGlobalCallers(hModel);
            for i=1:length(tmpMsg.cause)
                msg=msg.addCause(tmpMsg.cause{i});
            end

            if~isempty(msg.cause)
                throw(msg);
            end
        end

    end

    methods(Static,Access=private)
        function msg=verifyNoCallerAndFcnInSameModel(hModel)
            msg=MException('RTW:fcnClass:finish',...
            DAStudio.message('RTW:fcnClass:finish','Multiple causes'));

            modelName=get_param(hModel,'Name');
            mapping=autosar.api.Utils.modelMapping(modelName);
            fcnNameList=cell(1,length(mapping.ServerFunctions));
            for i=1:length(mapping.ServerFunctions)
                [~,~,fcnName]=...
                autosar.validation.ClientServerValidator.getBlockInOutParams(...
                mapping.ServerFunctions(i).Block);
                fcnNameList{i}=fcnName;
            end
            for i=1:length(mapping.FunctionCallers)
                [~,~,fcnName]=...
                autosar.validation.ClientServerValidator.getBlockInOutParams(...
                mapping.FunctionCallers(i).Block);
                if autosar.blocks.InternalTriggerBlock.isInternalTriggerBlock(...
                    mapping.FunctionCallers(i).Block)



                    continue
                end
                [isDefined,slFcnIdx]=ismember(fcnName,fcnNameList);
                if(isDefined(1))
                    tmpMsg=MException('RTW:autosar:slFcnBlkCallerBlkSameModel',...
                    DAStudio.message('RTW:autosar:slFcnBlkCallerBlkSameModel',...
                    mapping.FunctionCallers(i).Block,...
                    mapping.ServerFunctions(slFcnIdx(1)).Block));
                    msg=msg.addCause(tmpMsg);
                end
            end
        end

        function msg=verifyFunctionCallerBlockMapping(hModel)
            modelName=get_param(hModel,'Name');
            mapping=autosar.api.Utils.modelMapping(modelName);

            msg=MException('RTW:fcnClass:finish',...
            DAStudio.message('RTW:fcnClass:finish','Multiple causes'));
            for i=1:length(mapping.FunctionCallers)
                if~mapping.FunctionCallers(i).IsActive
                    continue;
                end

                callerBlock=mapping.FunctionCallers(i).Block;
                if autosar.blocks.InternalTriggerBlock.isInternalTriggerBlock(callerBlock)
                    [isMappable,~,tmpMsg]=...
                    autosar.validation.ClientServerValidator.checkFcnCallerMappableToInternalTriggerPoint(...
                    callerBlock);
                else
                    m3iOperation=...
                    autosar.validation.ClientServerValidator.findM3iOpFromPortOpName(...
                    modelName,mapping.FunctionCallers(i).MappedTo.ClientPort,...
                    mapping.FunctionCallers(i).MappedTo.Operation);
                    if isempty(mapping.FunctionCallers(i).MappedTo.ClientPort)||...
                        isempty(mapping.FunctionCallers(i).MappedTo.Operation)


                        continue;
                    end



                    [isMappable,~,tmpMsg]=...
                    autosar.validation.ClientServerValidator.checkFcnCallerMappableToOperation(...
                    callerBlock,m3iOperation);
                end
                if~isMappable
                    msg=msg.addCause(tmpMsg);
                end
            end
        end

        function msg=verifySimulinkFunctionBlockMapping(hModel)
            modelName=get_param(hModel,'Name');
            mapping=autosar.api.Utils.modelMapping(modelName);
            msg=MException('RTW:fcnClass:finish',...
            DAStudio.message('RTW:fcnClass:finish','Multiple causes'));
            for i=1:length(mapping.ServerFunctions)
                m3iRunnableObj=autosar.validation.ClientServerValidator.findM3iRunnableFromName(...
                modelName,mapping.ServerFunctions(i).MappedTo.Runnable);
                if isempty(m3iRunnableObj)
                    tmpMsg=MException('RTW:autosar:invalidUniqueRunnableName',...
                    DAStudio.message('RTW:autosar:invalidUniqueRunnableName',...
                    mapping.ServerFunctions(i).MappedTo.Runnable));
                    msg=msg.addCause(tmpMsg);
                    continue;
                end


                [isMappable,~,tmpMsg]=...
                autosar.validation.ClientServerValidator.checkSlFcnMappableToRunnable(...
                mapping.ServerFunctions(i).Block,m3iRunnableObj);
                if~isMappable
                    msg=msg.addCause(tmpMsg);
                end
            end
        end

        function verifyClientArg(hModel)

            modelName=get_param(hModel,'Name');
            mapping=autosar.api.Utils.modelMapping(modelName);
            for i=1:length(mapping.FunctionCallers)

                if~mapping.FunctionCallers(i).IsActive||...
                    autosar.blocks.InternalTriggerBlock.isInternalTriggerBlock(...
                    mapping.FunctionCallers(i).Block)
                    continue;
                end

                if isempty(mapping.FunctionCallers(i).MappedTo.ClientPort)||...
                    isempty(mapping.FunctionCallers(i).MappedTo.Operation)


                    continue;
                end
                m3iOperation=...
                autosar.validation.ClientServerValidator.findM3iOpFromPortOpName(...
                modelName,mapping.FunctionCallers(i).MappedTo.ClientPort,...
                mapping.FunctionCallers(i).MappedTo.Operation);

                autosar.validation.ClientServerValidator.checkClientArgDataType(...
                mapping.FunctionCallers(i).Block,m3iOperation);
            end

        end

        function msg=verifyLocalCallers(hModel)


            mdlName=get_param(hModel,'Name');
            msg=MException('RTW:fcnClass:finish',...
            DAStudio.message('RTW:fcnClass:finish','Multiple causes'));


            sfcnCallerHandles=autosar.utils.SimulinkFunction.getSFunctionHandles(mdlName);
            for ii=1:length(sfcnCallerHandles)
                sfcnCallerH=sfcnCallerHandles(ii);


                fcnHandles=autosar.utils.SimulinkFunction.getSimulinkFunctionsForCaller(sfcnCallerH);
                for fcnIdx=1:length(fcnHandles)
                    fcnH=fcnHandles(fcnIdx);
                    if autosar.utils.SimulinkFunction.isGlobalSimulinkFunction(fcnH)



                        callerPath=autosar.utils.SimulinkFunction.removeTrailingSFunctionStr(getfullname(sfcnCallerH));
                        fcnPath=getfullname(fcnH);
                        tmpMsg=MException('autosarstandard:validation:invalidGlobalSimulinkFunctionCall',...
                        DAStudio.message('autosarstandard:validation:invalidGlobalSimulinkFunctionCall',...
                        callerPath,fcnPath));
                        msg=msg.addCause(tmpMsg);
                    end
                end
            end
        end

        function msg=verifyGlobalCallers(hModel)



            mdlName=get_param(hModel,'Name');
            msg=MException('RTW:fcnClass:finish',...
            DAStudio.message('RTW:fcnClass:finish','Multiple causes'));


            callerHandles=autosar.utils.SimulinkFunction.getGlobalFunctionCallerHandles(mdlName);
            for ii=1:length(callerHandles)
                callerH=callerHandles(ii);


                fcnHandles=autosar.utils.SimulinkFunction.getSimulinkFunctionsForCaller(callerH);
                for fcnIdx=1:length(fcnHandles)
                    fcnH=fcnHandles(fcnIdx);
                    if~autosar.utils.SimulinkFunction.isGlobalSimulinkFunction(fcnH)


                        callerPath=getfullname(callerH);
                        fcnPath=autosar.utils.SimulinkFunction.removeTrailingSFunctionStr(getfullname(fcnH));
                        tmpMsg=MException('autosarstandard:validation:invalidNonGlobalSimulinkFunctionCall',...
                        DAStudio.message('autosarstandard:validation:invalidNonGlobalSimulinkFunctionCall',...
                        callerPath,fcnPath));
                        msg=msg.addCause(tmpMsg);
                    end
                end
            end

        end

        function verifyNoFunctionPorts(hModel)

            hModel=get_param(hModel,'Handle');
            functionPorts=[...
            autosar.simulink.functionPorts.Utils.findClientPorts(hModel),...
            autosar.simulink.functionPorts.Utils.findServerPorts(hModel)];
            if~isempty(functionPorts)
                functionPortPaths=arrayfun(@(x)getfullname(x),...
                functionPorts,'UniformOutput',false);
                autosar.validation.Validator.logError(...
                'autosarstandard:validation:ClassicFunctionPorts',...
                autosar.api.Utils.cell2str(functionPortPaths));
            end
        end

    end

    methods(Static,Access=public)
        function[ret,errMsg,m3iOperation]=isFunctionCallerMappable(block,clientPortName,operationName)
            modelName=bdroot(block);
            m3iOperation=autosar.validation.ClientServerValidator.findM3iOpFromPortOpName(...
            modelName,clientPortName,operationName);
            [ret,~,mException]=autosar.validation.ClientServerValidator.checkFcnCallerMappableToOperation(...
            block,m3iOperation);
            if~isempty(mException)
                errMsg=mException.message;
            else
                errMsg='';
            end
        end

        function[ret,errMsg]=isSimulinkFunctionMappable(block,runnableName)
            errMsg='';
            modelName=bdroot(block);
            m3iRunnableObj=autosar.validation.ClientServerValidator.findM3iRunnableFromName(...
            modelName,runnableName);
            [ret,~,mException]=autosar.validation.ClientServerValidator.checkSlFcnMappableToRunnable(...
            block,m3iRunnableObj);
            if~isempty(mException)
                errMsg=mException.message;
            end
        end
        function checkClientArgDataType(blkPath,m3iOperation)



            [~,retArgIdx]=autosar.validation.ClientServerValidator.checkArguments(m3iOperation,blkPath);
            if retArgIdx~=-1
                portHandles=get_param(blkPath,'PortHandles');
                errPortH=portHandles.Outport(retArgIdx);
                autosar.validation.AutosarUtils.checkDataTypeForErrArgPort(errPortH,m3iOperation.containerM3I);
            end
        end


        function checkValidRunnableConfig(hModel)
            hModel=get_param(hModel,'handle');
            isExportFcnModel=slprivate('getIsExportFcnModel',hModel);
            if~isExportFcnModel





                slServers=find_system(hModel,'FollowLinks','on',...
                'MatchFilter',@Simulink.match.activeVariants,...
                'blocktype','SubSystem','IsSimulinkFunction','on');
                for ii=1:length(slServers)
                    if~autosar.validation.ExportFcnValidator.isScopedSimulinkFunction(slServers(ii))
                        autosar.validation.Validator.logError('autosarstandard:validation:unsupportedRunnableWithServer',...
                        getfullname(slServers(ii)));
                    end
                end
            end
        end

        function[isMappable,errIdx,msg]=checkFcnCallerMappableToInternalTriggerPoint(callerBlock)
            isMappable=true;
            errIdx=0;
            msg=[];

            model=bdroot(callerBlock);


            [inParams,outParams,calledFcn]=autosar.validation.ClientServerValidator.getBlockInOutParams(callerBlock);
            if~isempty(inParams)||~isempty(outParams)
                msg=MException('autosarstandard:validation:InternalTriggerBlockArgsNotAllowed',...
                DAStudio.message('autosarstandard:validation:InternalTriggerBlockArgsNotAllowed',callerBlock));
                isMappable=false;
                return;
            end


            fcnHandles=autosar.utils.SimulinkFunction.getSimulinkFunctionsForCaller(callerBlock);
            fcnExists=false;
            for fcnIdx=1:length(fcnHandles)
                fcnH=fcnHandles(fcnIdx);
                if autosar.utils.SimulinkFunction.isGlobalSimulinkFunction(fcnH)
                    slFcnPath=getfullname(fcnH);
                    slFcnPath=strrep(slFcnPath,newline,' ');
                    mapping=autosar.api.Utils.modelMapping(model);
                    slFcnBlockMapping=mapping.ServerFunctions.findobj('Block',slFcnPath);
                    if~isempty(slFcnBlockMapping)
                        m3iRun=autosar.validation.ClientServerValidator.findM3iRunnableFromName(...
                        model,slFcnBlockMapping.MappedTo.Runnable);
                        if~isempty(m3iRun)&&...
                            autosar.mm.mm2sl.RunnableHelper.isInternallyTriggeredRunnable(m3iRun)
                            fcnExists=true;
                            break;
                        end
                    end
                end
            end

            if~fcnExists
                msg=MException('autosarstandard:validation:InternalTriggerBlockFcnDoesNotExist',...
                DAStudio.message('autosarstandard:validation:InternalTriggerBlockFcnDoesNotExist',callerBlock,calledFcn));
                isMappable=false;
                return;
            end
        end

        function[isMappable,errIdx,msg]=checkFcnCallerMappableToOperation(fcnCallerBlock,m3iOperation)
            isMappable=false;
            errIdx=0;
            msg=[];%#ok<NASGU>
            [~,outParams,~]=autosar.validation.ClientServerValidator.getBlockInOutParams(fcnCallerBlock);
            if isempty(m3iOperation)
                msg=MException('RTW:autosar:fcnCallerOpNameMismatch',...
                DAStudio.message('RTW:autosar:fcnCallerOpNameMismatch',...
                fcnCallerBlock,''));
                return;
            else
                m3iInterface=m3iOperation.containerM3I;

                [canHaveError,msg]=autosar.validation.ClientServerValidator.checkOperationHasErrorArg(m3iOperation);
                if~isempty(msg)
                    return;
                end
                if canHaveError
                    msg=autosar.validation.ClientServerValidator.checkAppErr(m3iInterface);
                    if~isempty(msg)
                        return;
                    end
                end
                [isCompatible,errIdx,msg]=autosar.validation.ClientServerValidator.checkArguments(m3iOperation,...
                fcnCallerBlock);
                if~isCompatible
                    return;
                else
                    if(slfeature('SlFcnFPCv2_autosar')==0)
                        if length(outParams)>1&&errIdx>=1
                            msg=MException('RTW:autosar:errorReturnMustBeOnlyOutput',...
                            DAStudio.message('RTW:autosar:errorReturnMustBeOnlyOutput',...
                            fcnCallerBlock));
                            return;
                        end
                    end
                    isMappable=true;
                end
            end
        end

        function[isMappable,errIdx,msg]=checkSlFcnMappableToRunnable(slFcnBlock,m3iRun)
            if autosar.mm.mm2sl.RunnableHelper.isInternallyTriggeredRunnable(m3iRun)
                [isMappable,errIdx,msg]=...
                autosar.validation.ClientServerValidator.checkSlFcnMappableToInternallyTrigRunnable(...
                slFcnBlock,m3iRun);
            else
                [isMappable,errIdx,msg]=...
                autosar.validation.ClientServerValidator.checkSlFcnMappableToServerRunnable(...
                slFcnBlock,m3iRun);
            end
        end

        function[isMappable,errIdx,msg]=checkSlFcnMappableToInternallyTrigRunnable(slFcnBlock,~)
            isMappable=true;
            errIdx=0;
            msg=[];

            if~autosar.utils.SimulinkFunction.isGlobalSimulinkFunction(slFcnBlock)
                return
            end

            [inParams,outParams]=autosar.validation.ClientServerValidator.getBlockInOutParams(slFcnBlock);
            if~isempty(inParams)||~isempty(outParams)
                msg=MException('autosarstandard:validation:InternallyTriggeredRunArgsNotAllowed',...
                DAStudio.message('autosarstandard:validation:InternallyTriggeredRunArgsNotAllowed',slFcnBlock));
                isMappable=false;
            end

        end

        function[isMappable,errIdx,msg]=checkSlFcnMappableToServerRunnable(slFcnBlock,m3iRunnableObj)
            isMappable=false;
            errIdx=0;
            msg=[];
            if~autosar.validation.ExportFcnValidator.isServerSubSys(slFcnBlock)
                return
            end

            allM3iOp=autosar.validation.ClientServerValidator.getAllRunnableOperations(m3iRunnableObj);
            if isempty(allM3iOp)
                msgId='autosarstandard:validation:operationInvokedEventTriggerUnset';
                msg=MException(msgId,DAStudio.message(msgId,m3iRunnableObj.Name));
                return;
            end

            for i=1:length(allM3iOp)
                m3iOp=allM3iOp{i};
                [isMappable,errIdx,msg]=...
                autosar.validation.ClientServerValidator.checkSlFcnMappableToOperation(...
                m3iOp,slFcnBlock,m3iRunnableObj.symbol);
                if~isempty(msg)
                    break;
                end
            end
        end

        function[isMappable,errIdx,msg]=checkSlFcnMappableToOperation(m3iOp,slFcnBlock,~)
            isMappable=false;
            errIdx=0;
            [canHaveError,msg]=autosar.validation.ClientServerValidator.checkOperationHasErrorArg(m3iOp);
            if~isempty(msg)
                return;
            end
            if canHaveError

                m3iInterface=m3iOp.containerM3I;
                msg=autosar.validation.ClientServerValidator.checkAppErr(m3iInterface);
                if~isempty(msg)
                    return;
                end
            end
            [isCompatible,errIdx,msg]=autosar.validation.ClientServerValidator.checkArguments(m3iOp,...
            slFcnBlock);
            if isCompatible
                [~,outParams]=autosar.validation.ClientServerValidator.getBlockInOutParams(slFcnBlock);
                if(slfeature('SlFcnFPCv2_autosar')==0)
                    if length(outParams)>1&&errIdx>=1
                        msg=MException('RTW:autosar:errorReturnMustBeOnlyOutput',...
                        DAStudio.message('RTW:autosar:errorReturnMustBeOnlyOutput',...
                        slFcnBlock));
                        return;
                    end
                end
                isMappable=true;
            else
                isMappable=false;
            end
        end

        function[canHaveError,errmsg]=checkOperationHasErrorArg(m3iOperation)


            canHaveError=false;
            errmsg='';
            errCount=0;

            for index=1:m3iOperation.Arguments.size()
                if m3iOperation.Arguments.at(index).Direction==...
                    Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Error
                    errCount=errCount+1;
                    if errCount>1
                        errmsg=MException('autosarstandard:validation:opMultipleReturnArgs',...
                        DAStudio.message('autosarstandard:validation:opMultipleReturnArgs',m3iOperation.Name));
                        return;
                    end
                end
            end
            canHaveError=errCount>0;
        end

        function[isCompatible,retArgIdx,errmsg]=checkArguments(m3iOperation,blk)



            isCompatible=false;
            retArgIdx=-1;
            errmsg='';



            if~strcmp(get_param(blk,'BlockType'),'FunctionCaller')&&...
                ~autosar.validation.ExportFcnValidator.isServerSubSys(blk)
                errmsg=MException('RTW:autosar:blkRunnableNotASlFcn',...
                DAStudio.message('RTW:autosar:blkRunnableNotASlFcn',blk,m3iOperation.Name));

                return;
            end

            [inparam,outparam,~]=autosar.validation.ClientServerValidator.getBlockInOutParams(blk);



            numMatchInParams=0;
            numMatchOutParams=0;
            for i=1:m3iOperation.Arguments.size
                m3iArg=m3iOperation.Arguments.at(i);
                displayFormat=m3iArg.DisplayFormat;
                [isValid,msg]=autosar.validation.AutosarUtils.checkDisplayFormat(...
                displayFormat,autosar.api.Utils.getQualifiedName(m3iArg));
                if~isValid
                    autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                end
                if(m3iArg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Error)
                    [~,idx]=ismember(m3iArg.Name,outparam);
                    if(idx>0)
                        numMatchOutParams=numMatchOutParams+1;
                        if(slfeature('SlFcnFPCv2_autosar')<=0)

                            if(idx~=numMatchOutParams)
                                errmsg=MException('RTW:autosar:blkRunnableArgOrder',...
                                DAStudio.message('RTW:autosar:blkRunnableArgOrder',...
                                autosar.validation.ClientServerValidator.fcnCallerBlkTypeName,...
                                blk,m3iOperation.Name));
                                return;
                            end
                        end
                        retArgIdx=idx;
                        outparam{idx}='';
                    else
                        errmsg=MException('RTW:autosar:blkRunnableInvalidOutArgName',...
                        DAStudio.message('RTW:autosar:blkRunnableInvalidOutArgName',...
                        m3iArg.Name,...
                        m3iOperation.Name,...
                        blk));
                        return;
                    end
                elseif(m3iArg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out)
                    [~,idx]=ismember(m3iArg.Name,outparam);
                    if(idx>0)
                        outparam{idx}='';
                        numMatchOutParams=numMatchOutParams+1;
                        if(slfeature('SlFcnFPCv2_autosar')<=0)

                            if(idx~=numMatchOutParams)
                                errmsg=MException('RTW:autosar:blkRunnableArgOrder',...
                                DAStudio.message('RTW:autosar:blkRunnableArgOrder',...
                                autosar.validation.ClientServerValidator.fcnCallerBlkTypeName,...
                                blk,m3iOperation.Name));
                                return;
                            end
                        end
                    else
                        errmsg=MException('RTW:autosar:blkRunnableInvalidOutArgName',...
                        DAStudio.message('RTW:autosar:blkRunnableInvalidOutArgName',...
                        m3iArg.Name,...
                        m3iOperation.Name,...
                        blk));
                        return;
                    end
                elseif(m3iArg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In)
                    [~,idx]=ismember(m3iArg.Name,inparam);
                    if(idx>0)
                        inparam{idx}='';
                        numMatchInParams=numMatchInParams+1;
                        if(slfeature('SlFcnFPCv2_autosar')<=0)

                            if(idx~=numMatchInParams)
                                errmsg=MException('RTW:autosar:blkRunnableArgOrder',...
                                DAStudio.message('RTW:autosar:blkRunnableArgOrder',...
                                autosar.validation.ClientServerValidator.fcnCallerBlkTypeName,...
                                blk,m3iOperation.Name));
                                return;
                            end
                        end
                    else
                        errmsg=MException('RTW:autosar:blkRunnableInvalidInArgName',...
                        DAStudio.message('RTW:autosar:blkRunnableInvalidInArgName',...
                        m3iArg.Name,...
                        m3iOperation.Name,...
                        blk));
                        return;
                    end
                else
                    assert(m3iArg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut);

                    [~,inIdx]=ismember(m3iArg.Name,inparam);
                    [~,outIdx]=ismember(m3iArg.Name,outparam);
                    if(inIdx>0&&outIdx>0)
                        inparam{inIdx}='';
                        numMatchInParams=numMatchInParams+1;
                        outparam{outIdx}='';
                        numMatchOutParams=numMatchOutParams+1;
                        if(slfeature('SlFcnFPCv2_autosar')<=0)

                            if(inIdx~=numMatchInParams||outIdx~=numMatchOutParams)
                                errmsg=MException('RTW:autosar:blkRunnableArgOrder',...
                                DAStudio.message('RTW:autosar:blkRunnableArgOrder',...
                                autosar.validation.ClientServerValidator.fcnCallerBlkTypeName,...
                                blk,m3iOperation.Name));
                                return;
                            end
                        end
                    else
                        if(outIdx==0)
                            errmsg=MException('RTW:autosar:blkRunnableInvalidInOutArgName_Output',...
                            DAStudio.message('RTW:autosar:blkRunnableInvalidInOutArgName_Output',...
                            m3iArg.Name,...
                            m3iOperation.Name,...
                            blk));
                        else
                            errmsg=MException('RTW:autosar:blkRunnableInvalidInOutArgName_Input',...
                            DAStudio.message('RTW:autosar:blkRunnableInvalidInOutArgName_Input',...
                            m3iArg.Name,...
                            m3iOperation.Name,...
                            blk));
                        end

                        return;
                    end
                end
            end



            if(numMatchInParams~=numel(inparam))

                unmappedInputs=['{''',strjoin(inparam(~cellfun(@isempty,inparam)),''','''),'''}'];
                errmsg=MException('RTW:autosar:blkRunnableMissingInputArgs',...
                DAStudio.message('RTW:autosar:blkRunnableMissingInputArgs',unmappedInputs,blk,m3iOperation.Name));
                return;
            end


            tmpRetArgIdx=find(~cellfun(@isempty,outparam));
            if(isempty(tmpRetArgIdx))
                isCompatible=true;
            elseif(numel(tmpRetArgIdx)==1)
                errmsg=MException('RTW:autosar:blkRunnableAppErrEnumUnspecified',...
                DAStudio.message('RTW:autosar:blkRunnableAppErrEnumUnspecified',outparam{tmpRetArgIdx},blk,m3iOperation.Name));

                return;
            else
                unmappedOutputs=['{''',strjoin(outparam(~cellfun(@isempty,outparam)),''','''),'''}'];
                errmsg=MException('RTW:autosar:blkRunnableMultipleReturnArgs',...
                DAStudio.message('RTW:autosar:blkRunnableMultipleReturnArgs',unmappedOutputs,blk,m3iOperation.Name));

                return;
            end
        end

        function m3iOperations=getAllRunnableOperations(m3iRunnableObj)
            m3iOperations={};
            for i=1:m3iRunnableObj.Events.size
                m3iEvent=m3iRunnableObj.Events.at(i);
                if isa(m3iEvent,...
                    'Simulink.metamodel.arplatform.behavior.OperationInvokedEvent')
                    if~isempty(m3iEvent.instanceRef)
                        m3iOp=m3iEvent.instanceRef.Operations;
                        m3iPort=m3iEvent.instanceRef.Port;
                        if isvalid(m3iOp)&&isvalid(m3iPort)
                            m3iOperations{end+1}=m3iOp;%#ok<AGROW>
                        else
                            m3iOperations=[];
                            break;
                        end
                    end
                end
            end
        end

        function[inParams,outParams,fcnName]=getBlockInOutParams(blk)


            inParams={};
            outParams={};
            fcnName='';
            if strcmp(get_param(blk,'BlockType'),'FunctionCaller')||...
                autosar.validation.ExportFcnValidator.isServerSubSys(blk)
                fcnProto=get_param(blk,'FunctionPrototype');
                [inParams,outParams,fcnName]=autosar.validation.ClientServerValidator....
                getFcnInOutParamNames(fcnProto);
            end
        end

        function[inParams,outParams,fcnName]=getFcnInOutParamNames(fcnProto)


            inParams={};
            outParams={};
            if contains(fcnProto,'=')
                outparamStr=regexp(fcnProto,'\[?\s*([^\=\]]+)\]?\s*\=','tokens');
                outparamStr=strtrim(char(outparamStr{1}));
                if(~isempty(outparamStr))
                    outParams=regexp(outparamStr,'\s*,\s*','split');
                end
            end
            inparamStr=regexp(fcnProto,'\w+\(([^\)]*)\)','tokens');
            inparamStr=strtrim(char(inparamStr{1}));
            if(~isempty(inparamStr))
                inParams=regexp(inparamStr,'\s*,\s*','split');
            end
            fcnName=regexp(fcnProto,'(\w+(\.\w+)?)\s*\(','tokens');
            fcnName=char(fcnName{1});
        end

        function m3iRunnable=findM3iRunnableFromName(modelName,runnableName)
            m3iRunnable=[];
            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            if m3iComp.Behavior.isvalid()
                m3iRunnable=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                m3iComp.Behavior,m3iComp.Behavior.Runnables,...
                runnableName,'Simulink.metamodel.arplatform.behavior.Runnable');
            end
        end

        function m3iOperation=findM3iOpFromPortOpName(modelName,clientPortName,operationName)
            m3iModel=autosar.api.Utils.m3iModel(modelName);
            m3iOperation=[];


            dataObj=autosar.api.getAUTOSARProperties(modelName,true);
            componentQualifiedName=dataObj.get('XmlOptions',...
            'ComponentQualifiedName');
            if autosar.api.Utils.isMappedToAdaptiveApplication(modelName)
                portMetaClass=Simulink.metamodel.arplatform.port.ServiceRequiredPort.MetaClass();
                opPropName='Methods';
            else
                portMetaClass=Simulink.metamodel.arplatform.port.ClientPort.MetaClass();
                opPropName='Operations';
            end
            m3iClientPortSeq=autosar.mm.Model.findObjectByNameAndMetaClass(...
            m3iModel,[componentQualifiedName,'/',clientPortName],...
            portMetaClass);
            if m3iClientPortSeq.isEmpty()
                return
            elseif m3iClientPortSeq.size()==1
                for i=1:m3iClientPortSeq.at(1).Interface.(opPropName).size
                    m3iOp=m3iClientPortSeq.at(1).Interface.(opPropName).at(i);
                    if strcmp(m3iOp.Name,operationName)
                        m3iOperation=m3iOp;
                        return;
                    end
                end
            else
                autosar.validation.Validator.logError('RTW:autosar:uniqueClientPortNotFound',...
                m3iClientPortSeq.size());
            end
        end

        function msg=checkAppErr(m3iInterface)
            msg='';



            for ii=1:m3iInterface.PossibleError.size()
                if m3iInterface.PossibleError.at(ii).errorCode<0||...
                    m3iInterface.PossibleError.at(ii).errorCode>63


                    msg=MException('autosarstandard:validation:invalidAppErrValue',...
                    DAStudio.message('autosarstandard:validation:invalidAppErrValue',...
                    autosar.api.Utils.getQualifiedName(m3iInterface.PossibleError.at(ii)),...
                    num2str(m3iInterface.PossibleError.at(ii).errorCode)));
                    return;
                end
            end
        end

        function isNvMService=isNvMService(m3iOperation)


            m3iInterface=m3iOperation.containerM3I;


            isNvMServiceInterface=strncmp(m3iInterface.Name,'NvMService',10)&&...
            m3iInterface.IsService;

            isNvMService=isNvMServiceInterface&&...
            any(strcmp(m3iOperation.Name,...
            autosar.validation.ClientServerValidator.ValidNvMServiceNames));

        end

    end
end




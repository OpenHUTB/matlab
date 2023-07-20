classdef ClassicMetaModelValidator<autosar.validation.PhasedValidator



    properties(Access=private)

    end

    methods(Access=protected)

        function verifyInitial(this,hModel)

            m3iModel=autosar.api.Utils.m3iModel(hModel);

            commonValidator=autosar.validation.MetaModelCommonValidator(hModel);
            commonValidator.verify(m3iModel);
            m3iComp=autosar.api.Utils.m3iMappedComponent(hModel);
            compValidator=autosar.validation.MetaModelMappedComponentValidator(hModel);
            compValidator.verify(m3iComp);

            this.verifyXmlOptions(hModel);
            this.verifySwAddrMethods(hModel);
        end

        function verifyPostProp(this,hModel)
            m3iModel=autosar.api.Utils.m3iModel(hModel);
            arRoot=m3iModel.RootPackage.front();
            m3iComp=autosar.api.Utils.m3iMappedComponent(hModel);
            this.verifyRunnables(hModel,m3iComp);
            this.verifyEvents(hModel,m3iComp);
            this.verifyRunnableCanBeInvokedConcurrently(m3iComp,arRoot);
            this.verifyNoInternalBehaviorContaineeShortNameClash(hModel,m3iComp);
        end

    end

    methods(Static,Access=private)

        function verifyRunnables(hModel,compObj)
            activeMapping=autosar.api.Utils.modelMapping(hModel);



            runnableSeq=autosar.mm.Model.findObjectByMetaClass(compObj.Behavior,...
            Simulink.metamodel.arplatform.behavior.Runnable.MetaClass(),false,false);


            functionCallInports=activeMapping.FcnCallInports;
            for ii=1:runnableSeq.size()
                runnable=runnableSeq.at(ii);
                if~isempty(functionCallInports)
                    for jj=1:numel(functionCallInports)
                        if strcmp(runnable.Name,functionCallInports(jj).MappedTo.Runnable)
                            if runnable.Events.isEmpty()
                                mException=MException('RTW:autosar:validateEventForExportedFunction',...
                                DAStudio.message('RTW:autosar:validateEventForExportedFunction',runnable.Name));
                                throw(mException);
                            end
                            break;
                        end
                    end
                end
            end

            irvSeq=autosar.mm.Model.findObjectByMetaClass(compObj.Behavior,...
            Simulink.metamodel.arplatform.behavior.IrvData.MetaClass(),false,false);

            isExportedFunctionModel=...
            autosar.validation.ExportFcnValidator.isExportFcn(hModel);

            if isExportedFunctionModel&&...
                (~isempty(activeMapping.FcnCallInports)||...
                ~isempty(activeMapping.ServerFunctions))
                if runnableSeq.size()~=numel(activeMapping.FcnCallInports)...
                    +numel(activeMapping.ServerFunctions)+...
                    +numel(activeMapping.ResetFunctions)+...
                    numel(activeMapping.TerminateFunctions)+1

                    autosar.validation.Validator.logError('autosarstandard:validation:multiRunnableTooManyRunnables',getfullname(hModel));
                end


                if irvSeq.size()~=(numel(activeMapping.DataTransfers)+numel(activeMapping.RateTransition))

                    autosar.validation.Validator.logError('autosarstandard:validation:multiRunnableTooManyIRVs',getfullname(hModel));
                end
            else

                expectedRunnalbes=numel(activeMapping.FcnCallInports)+...
                length(activeMapping.StepFunctions)+...
                length(activeMapping.ResetFunctions)+...
                numel(activeMapping.TerminateFunctions)+...
                1;



                if runnableSeq.size()~=expectedRunnalbes

                    autosar.validation.Validator.logError('autosarstandard:validation:multiRunnableTooManyRunnables',getfullname(hModel));
                end

                if irvSeq.size()~=length(activeMapping.RateTransition)

                    autosar.validation.Validator.logError('autosarstandard:validation:multitaskingTooManyIRVs',getfullname(hModel));
                end
            end

        end

        function verifyEvents(hModel,m3iComp)

            activeMapping=autosar.api.Utils.modelMapping(hModel);
            schemaVersion=get_param(hModel,'AutosarSchemaVersion');

            if m3iComp.Behavior.isvalid()
                for runIdx=1:m3iComp.Behavior.Runnables.size()
                    m3iRun=m3iComp.Behavior.Runnables.at(runIdx);
                    [messageID,message]=autosar.validation.ClassicMetaModelValidator.verifyEventsForRunnable(...
                    hModel,m3iRun.Name,m3i.mapcell(@(x)x,m3iRun.Events),activeMapping,schemaVersion);
                    if~isempty(messageID)
                        mException=MException(messageID,message);
                        throw(mException);
                    end
                end
            end
        end




        function verifyRunnableCanBeInvokedConcurrently(m3iComp,arRoot)

            classStr='Simulink.metamodel.arplatform.behavior.OperationInvokedEvent';
            messageID='RTW:autosar:validateRunnableCanBeInvokedConcurrently';
            if m3iComp.Behavior.isvalid()
                diag=autosar.mm.util.XmlOptionsAdapter.get(...
                arRoot,'CanBeInvokedConcurrentlyDiagnostic');
                for runIdx=1:m3iComp.Behavior.Runnables.size()
                    m3iRun=m3iComp.Behavior.Runnables.at(runIdx);
                    m3iRunEvents=m3iRun.Events;

                    if(m3iRunEvents.size()==0)
                        cannotBeConcurrent=true;
                    else
                        cannotBeConcurrent=~isa(m3iRunEvents.at(1),classStr);
                    end

                    if(m3iRun.canBeInvokedConcurrently&&cannotBeConcurrent)
                        message=DAStudio.message(messageID,m3iRun.Name);
                        if strcmp(diag,'Error')
                            mException=MException(messageID,message);
                            throw(mException);
                        else
                            autosar.mm.util.MessageReporter.createWarning(messageID);
                        end
                    end
                end
            end
        end

        function verifyNoInternalBehaviorContaineeShortNameClash(hModel,m3iComp)




            m3iBehavior=m3iComp.Behavior;
            if~m3iBehavior.isvalid()
                return
            end

            runnableNames=m3i.mapcell(@(obj)obj.Name,m3iBehavior.Runnables);
            eventNames=m3i.mapcell(@(obj)obj.Name,m3iBehavior.Events);
            irvNames=m3i.mapcell(@(obj)obj.Name,m3iBehavior.IRV);

            dataObjectValidator=autosar.validation.DataObjectValidator(hModel);

            dsmPIMNames=autosar.validation.DataObjectValidator.getDSMPIMNames(hModel);
            internalCalPrmNames=autosar.validation.DataObjectValidator.getInternalCalPrmNames(hModel);
            constMemPrmNames=autosar.validation.DataObjectValidator.getConstMemoryPrmNames(hModel);
            staticMemVarNames=autosar.validation.DataObjectValidator.getStaticMemoryVarNames(hModel);
            internalDataShortNames=dataObjectValidator.getInternalDataMappedToNames(hModel);
            internalBehaviorShortNames=[runnableNames,eventNames,irvNames,dsmPIMNames,internalCalPrmNames,constMemPrmNames,staticMemVarNames,internalDataShortNames];
            [~,unique_indices]=unique(internalBehaviorShortNames);
            duplicates=unique(internalBehaviorShortNames(setdiff(1:length(internalBehaviorShortNames),...
            unique_indices)));
            if~isempty(duplicates)
                msg=DAStudio.message('RTW:autosar:internalBehavShortNameClash',duplicates{1});
                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
            end


            autosar.validation.AutosarUtils.checkShortNameCaseClash(internalBehaviorShortNames);
        end


        function verifyXmlOptions(hModel)

            m3iModel=autosar.api.Utils.m3iModel(hModel);
            arRoot=m3iModel.RootPackage.front();
            dataObj=autosar.api.getAUTOSARProperties(hModel);
            compQName=dataObj.get('XmlOptions','ComponentQualifiedName');
            impQName=dataObj.get('XmlOptions','ImplementationQualifiedName');
            [componentPackage,~]=autosar.mm.sl2mm.ModelBuilder.getNodePathAndName(compQName);
            [foundDuplicate,errmsg]=autosar.mm.util.checkAmbigousXmlOptions(m3iModel,...
            componentPackage,arRoot.DataTypePackage,arRoot.InterfacePackage,...
            impQName);
            if foundDuplicate
                mException=MException('Simulink:Engine:RTWCGAutosarValidateError',errmsg);
                throw(mException);

            end
        end

        function verifySwAddrMethods(hModel)

            m3iModel=autosar.api.Utils.m3iModel(hModel);


            swAddrMethodSeq=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
            Simulink.metamodel.arplatform.common.SwAddrMethod.MetaClass());
            swAddrMethodNames=m3i.mapcell(@(obj)obj.Name,swAddrMethodSeq);
            [~,unique_indices]=unique(swAddrMethodNames);
            duplicates=unique(swAddrMethodNames(setdiff(1:length(swAddrMethodNames),...
            unique_indices)));
            if~isempty(duplicates)
                errorID='RTW:autosar:errorDuplicateSwAddrMethod';
                autosar.validation.Validator.logError(errorID,duplicates{1})
            end
        end

        function[messageID,message]=verifyEventsForAperiodicRunnable(hModel,runnableName,...
            numTimingEvents,numModeSwitchEvents,numInitEvents,numOpInvokedEvents)





            messageID='';
            message='';
            if~autosar.validation.ExportFcnValidator.isExportFcn(hModel)&&...
                numTimingEvents>0
                messageID='autosarstandard:validation:noTimingEventForNonPeriodicRunnable';
                message=DAStudio.message(messageID,runnableName);
                return;
            end

            if numModeSwitchEvents>1
                messageID='RTW:autosar:validateEventTypeForRunnable';
                message=DAStudio.message(messageID,runnableName,...
                'ModeSwitchEvent');
                return;
            end

            if numInitEvents>1
                messageID='RTW:autosar:validateInitEventForRunnable';
                message=DAStudio.message(messageID,runnableName);
                return;
            end

            if numOpInvokedEvents>0
                messageID='autosarstandard:validation:validateOperationInvokedEventForRunnable';
                message=DAStudio.message(messageID,runnableName);
                return;
            end
        end
    end

    methods(Static,Access=public)

        function msgIDAndHoles=verifyModeSwitchInterface(m3iModeSwitchInterface)





            msgIDAndHoles={};
            if isempty(m3iModeSwitchInterface.ModeGroup)
                msgIDAndHoles={'autosarstandard:validation:msInterfaceMissingModeGroup',m3iModeSwitchInterface.Name};
            end
        end

        function[messageID,message]=verifyPRPort(portName,schemaVersion)
            messageID='';
            message='';


            if str2double(schemaVersion)<4.1
                messageID='RTW:autosar:disallowedPRPort';
                message=DAStudio.message('RTW:autosar:disallowedPRPort',portName);
            end
        end

        function[messageID,message]=verifyEventsForRunnable(hModel,...
            runnableName,eventArray,mapping,schemaVersion)
            messageID='';
            message='';
            numTimingEvents=0;
            numDataReceivedEvents=0;
            numDataReceiveErrorEvents=0;
            numModeSwitchEvents=0;
            numInitEvents=0;
            numOpInvokedEvents=0;
            numExternalTriggerOccurredEvents=0;
            numInternalTriggerOccurredEvents=0;
            functionCallInports=mapping.FcnCallInports;
            for ii=1:numel(eventArray)
                if isa(eventArray{ii},'Simulink.metamodel.arplatform.behavior.TimingEvent')
                    numTimingEvents=numTimingEvents+1;
                elseif isa(eventArray{ii},'Simulink.metamodel.arplatform.behavior.DataReceivedEvent')
                    numDataReceivedEvents=numDataReceivedEvents+1;
                elseif isa(eventArray{ii},'Simulink.metamodel.arplatform.behavior.DataReceiveErrorEvent')
                    numDataReceiveErrorEvents=numDataReceiveErrorEvents+1;
                elseif isa(eventArray{ii},'Simulink.metamodel.arplatform.behavior.ModeSwitchEvent')
                    numModeSwitchEvents=numModeSwitchEvents+1;






                    if eventArray{ii}.DisabledMode.size()>0
                        for jj=1:eventArray{ii}.instanceRef.size()
                            for kk=1:eventArray{ii}.DisabledMode.size()
                                if eventArray{ii}.instanceRef.at(jj).Mode==eventArray{ii}.DisabledMode.at(kk).Mode
                                    messageID='RTW:autosar:sameModeForTriggerAndDisabledMode';
                                    message=DAStudio.message(messageID,eventArray{ii}.Name);
                                    return;
                                end
                            end
                        end
                    end
                elseif isa(eventArray{ii},'Simulink.metamodel.arplatform.behavior.InitEvent')





                    if eventArray{ii}.DisabledMode.size()>0
                        messageID='RTW:autosar:noDisabledModeForInitEvent';
                        message=DAStudio.message(messageID,eventArray{ii}.Name);
                        return;
                    end
                    numInitEvents=numInitEvents+1;
                elseif isa(eventArray{ii},'Simulink.metamodel.arplatform.behavior.OperationInvokedEvent')
                    numOpInvokedEvents=numOpInvokedEvents+1;
                elseif isa(eventArray{ii},'Simulink.metamodel.arplatform.behavior.ExternalTriggerOccurredEvent')
                    numExternalTriggerOccurredEvents=numExternalTriggerOccurredEvents+1;
                elseif isa(eventArray{ii},'Simulink.metamodel.arplatform.behavior.InternalTriggerOccurredEvent')
                    numInternalTriggerOccurredEvents=numInternalTriggerOccurredEvents+1;
                end
            end


            if str2double(schemaVersion)<4.1
                if numInitEvents>0
                    messageID='RTW:autosar:invalidInitEvent';
                    message=DAStudio.message(messageID,runnableName);
                    return;
                end
            end

            mappedRunnable=false;


            if~isempty(mapping.InitializeFunctions)&&...
                ~isempty(mapping.InitializeFunctions(1).MappedTo.Runnable)&&...
                strcmp(runnableName,mapping.InitializeFunctions(1).MappedTo.Runnable)

                if numDataReceivedEvents>0||numDataReceiveErrorEvents>0||...
                    numTimingEvents>0||numOpInvokedEvents>0||...
                    (numModeSwitchEvents+numInitEvents)>1
                    messageID='autosarstandard:validation:validateEventForInitFunction';
                    message=DAStudio.message(messageID,runnableName);
                    return;
                end
                mappedRunnable=true;


            elseif~isempty(mapping.TerminateFunctions)&&...
                ~isempty(mapping.TerminateFunctions(1).MappedTo.Runnable)&&...
                strcmp(runnableName,mapping.TerminateFunctions(1).MappedTo.Runnable)

                if numTimingEvents>0||...
                    numModeSwitchEvents+numDataReceivedEvents+...
                    numDataReceiveErrorEvents+numOpInvokedEvents+...
                    numInitEvents+numExternalTriggerOccurredEvents+...
                    numInternalTriggerOccurredEvents>1
                    messageID='autosarstandard:validation:validateEventForTerminateFunction';
                    message=DAStudio.message(messageID,runnableName);
                    return;
                end
                mappedRunnable=true;


            elseif~isempty(mapping.StepFunctions)

                for idx=1:length(mapping.StepFunctions)
                    if~isempty(mapping.StepFunctions(idx).MappedTo.Runnable)&&...
                        strcmp(runnableName,mapping.StepFunctions(idx).MappedTo.Runnable)

                        if mapping.StepFunctions(idx).isAperiodicPartition
                            [messageID,message]=autosar.validation.ClassicMetaModelValidator.verifyEventsForAperiodicRunnable(...
                            hModel,runnableName,numTimingEvents,numModeSwitchEvents,...
                            numInitEvents,numOpInvokedEvents);
                            if~isempty(messageID)
                                assert(~isempty(message),'message cannot be empty since messageID is not empty');
                                return;
                            end
                        else

                            if numTimingEvents==0
                                messageID='RTW:autosar:validateEventForStepFunction';
                                message=DAStudio.message(messageID,runnableName);
                                return;
                            end

                            if numDataReceivedEvents>0||numDataReceiveErrorEvents>0||...
                                numTimingEvents>1||...
                                numModeSwitchEvents>0||numInitEvents>0||...
                                numOpInvokedEvents>0


                                messageID='RTW:autosar:moreThanOneTimingEventPerStepRunnable';
                                message=DAStudio.message(messageID,runnableName);
                                return;
                            end
                            if length(mapping.StepFunctions)==1
                                if strcmp(get_param(hModel,'SampleTimeConstraint'),'STIndependent')
                                    messageID='RTW:autosar:ensureSTIndependentIsOff';
                                    message=DAStudio.message(messageID);
                                    return;
                                end
                            end
                        end
                        mappedRunnable=true;

                    end
                end
            end

            if~mappedRunnable
                for jj=1:numel(mapping.ResetFunctions)
                    if strcmp(runnableName,mapping.ResetFunctions(jj).MappedTo.Runnable)
                        if numTimingEvents>0
                            messageID='autosarstandard:validation:validateEventForResetFunction';
                            message=DAStudio.message(messageID,runnableName);
                            return;
                        end

                        mappedRunnable=true;
                        break;
                    end
                end
            end

            if~mappedRunnable
                for jj=1:numel(functionCallInports)
                    if strcmp(runnableName,functionCallInports(jj).MappedTo.Runnable)




                        if numTimingEvents>1
                            messageID='RTW:autosar:validateEventTypeForRunnable';
                            message=DAStudio.message(messageID,runnableName,...
                            'TimingEvent');
                            return;
                        end
                        [messageID,message]=autosar.validation.ClassicMetaModelValidator.verifyEventsForAperiodicRunnable(...
                        hModel,runnableName,numTimingEvents,numModeSwitchEvents,...
                        numInitEvents,numOpInvokedEvents);
                        if~isempty(messageID)
                            assert(~isempty(message),'message cannot be empty since messageID is not empty');
                            return;
                        end

                        mappedRunnable=true;
                        break;
                    end
                end
                if~mappedRunnable
                    for jj=1:numel(mapping.ServerFunctions)
                        if strcmp(runnableName,mapping.ServerFunctions(jj).MappedTo.Runnable)

                            if numTimingEvents>0||numModeSwitchEvents>0||...
                                numInitEvents>0||numDataReceivedEvents>0||...
                                numDataReceiveErrorEvents>0
                                messageID='RTW:autosar:validateOpInvokedEventForRunnable';
                                message=DAStudio.message(messageID,runnableName);
                                return;
                            end
                            if numOpInvokedEvents>1


                                operation=eventArray{1}.instanceRef.Operations;
                                arguments=eventArray{1}.instanceRef.Operations.Arguments;
                                for index=2:length(eventArray)

                                    assert(arguments.size==eventArray{index}.instanceRef.Operations.Arguments.size,...
                                    'Expected argument number mismatch to be caught earlier during validation');
                                    for j=1:arguments.size
                                        if~strcmp(eventArray{index}.instanceRef.Operations.Arguments.at(j).Name,...
                                            operation.Arguments.at(j).Name)



                                            messageID='RTW:autosar:validateIncompatibleOpInvokedEventForRunnable';
                                            message=DAStudio.message(messageID,runnableName);
                                            return;
                                        end
                                    end
                                end
                            end
                            break;
                        end
                    end
                end
            end
        end
    end

end




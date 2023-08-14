classdef MetaModelMappedComponentValidator<m3i.Validator




    properties(Access=private,Transient)
ModelName
        NumTimingEvents=0;
        RunnableName2SLPortNamesMap;
        RunName2SLPortNamesForDreEvtMap;
        SymbolMap;
    end


    methods(Access=public)

        function self=MetaModelMappedComponentValidator(modelName)
            self.ModelName=modelName;
            self.NumTimingEvents=0;
            self.RunnableName2SLPortNamesMap=containers.Map();
            self.RunName2SLPortNamesForDreEvtMap=containers.Map();
            self.SymbolMap=containers.Map();






            self.dispatcher.bind('Simulink.metamodel.arplatform.behavior.Runnable',@verifyRunnableNames);
            self.dispatcher.bind('Simulink.metamodel.arplatform.behavior.TimingEvent',@verifyTimingEventPeriod);
            self.dispatcher.bind('Simulink.metamodel.arplatform.behavior.DataReceivedEvent',@verifyDataReceivedEventValidPort);
            self.dispatcher.bind('Simulink.metamodel.arplatform.behavior.DataReceiveErrorEvent',@verifyDataReceivedEventValidPort);
            self.dispatcher.bind('Simulink.metamodel.arplatform.behavior.ModeSwitchEvent',@verifyModeSwitchEventValidPort);
            self.dispatcher.bind('Simulink.metamodel.arplatform.behavior.OperationInvokedEvent',@verifyOperationInvokedEvent);
        end


        function verifyRunnableNames(this,m3iRunnable)


            if~autosar.validation.AutosarUtils.isNotCKeyword(m3iRunnable.Name)
                autosar.validation.Validator.logError('RTW:autosar:notValidRunnableName',m3iRunnable.Name);
            end


            if autosar.validation.ExportFcnValidator.isExportFcn(this.ModelName)
                mappingObj=autosar.api.getSimulinkMapping(this.ModelName);
                initRunnableName=mappingObj.getFunction('Initialize');
                if strcmp(initRunnableName,strcat(m3iRunnable.Name,'_Init'))
                    autosar.validation.Validator.logError('RTW:autosar:initRunnableNameClash',initRunnableName,m3iRunnable.Name);
                end
            end


            symbol=m3iRunnable.symbol;
            if~isempty(symbol)
                if~this.SymbolMap.isKey(symbol)
                    this.SymbolMap(symbol)=true;
                else
                    autosar.validation.Validator.logError('autosarstandard:validation:runnableSymbolClash',...
                    symbol,autosar.api.Utils.getQualifiedName(m3iRunnable));
                end
            end

        end

        function verifyTimingEventPeriod(this,~)
            this.NumTimingEvents=this.NumTimingEvents+1;
        end

        function verifyDataReceivedEventValidPort(this,m3iEvent)
            isFound=false;

            if~isempty(m3iEvent.instanceRef)...
                &&~isempty(m3iEvent.instanceRef.Port)...
                &&isvalid(m3iEvent.instanceRef.Port)...
                &&~isempty(m3iEvent.instanceRef.DataElements)...
                &&isvalid(m3iEvent.instanceRef.DataElements)
                arPortName=m3iEvent.instanceRef.Port.Name;
                arElementName=m3iEvent.instanceRef.DataElements.Name;

                [SLObjectName,dataAccessMode,isFound]=this.getMappingData(arPortName,arElementName);
            end
            if~isFound
                autosar.validation.Validator.logError('RTW:autosar:portNotFound',m3iEvent.Name);
            end


            assert(m3iEvent.StartOnEvent.isvalid(),...
            'DataReceivedEvent %s is not associated with a runnable',m3iEvent.Name);

            runnableName=m3iEvent.StartOnEvent.Name;
            if isa(m3iEvent,'Simulink.metamodel.arplatform.behavior.DataReceivedEvent')
                if~ismember(dataAccessMode,{'ImplicitReceive',...
                    'ExplicitReceive',...
                    'ExplicitReceiveByVal',...
                    'EndToEndRead',...
                    'QueuedExplicitReceive'})
                    autosar.validation.Validator.logError('autosarstandard:validation:validPortForDataReceivedEvent',...
                    runnableName,m3iEvent.Name,SLObjectName);
                end
                if~this.RunnableName2SLPortNamesMap.isKey(runnableName)
                    SLPortNames={};
                else
                    SLPortNames=this.RunnableName2SLPortNamesMap(runnableName);
                end

                if any(strcmp(SLObjectName,SLPortNames))
                    autosar.validation.Validator.logError('autosarstandard:validation:duplicateTriggerPort',...
                    runnableName,'DataReceivedEvents',SLObjectName);
                else
                    SLPortNames=[SLPortNames,{SLObjectName}];
                end
                this.RunnableName2SLPortNamesMap(runnableName)=SLPortNames;
            elseif isa(m3iEvent,'Simulink.metamodel.arplatform.behavior.DataReceiveErrorEvent')
                if~any(strcmp(dataAccessMode,{'ImplicitReceive',...
                    'ExplicitReceive',...
                    'EndToEndRead'}))
                    autosar.validation.Validator.logError('autosarstandard:validation:validPortForDataReceiveErrorEvent',...
                    runnableName,m3iEvent.Name,SLObjectName);
                end
                if~this.RunName2SLPortNamesForDreEvtMap.isKey(runnableName)
                    SLPortNames={};
                else
                    SLPortNames=this.RunName2SLPortNamesForDreEvtMap(runnableName);
                end

                if any(strcmp(SLObjectName,SLPortNames))
                    autosar.validation.Validator.logError('autosarstandard:validation:duplicateTriggerPort',...
                    runnableName,'DataReceiveErrorEvents',SLObjectName);
                else
                    SLPortNames=[SLPortNames,{SLObjectName}];
                end
                this.RunName2SLPortNamesForDreEvtMap(runnableName)=SLPortNames;
            else
                assert(false,'Unknown event.');
            end
        end

        function verifyModeSwitchEventValidPort(this,m3iModeSwitchEvent)
            if~isempty(m3iModeSwitchEvent.instanceRef)...
                &&m3iModeSwitchEvent.instanceRef.size()>0...
                &&~isempty(m3iModeSwitchEvent.instanceRef.at(1).Port)...
                &&isvalid(m3iModeSwitchEvent.instanceRef.at(1).Port)
                arPortName1=m3iModeSwitchEvent.instanceRef.at(1).Port.Name;

                mapping=autosar.api.Utils.modelMapping(this.ModelName);
                if~strcmp(mapping.InitializeFunctions.MappedTo.Runnable,m3iModeSwitchEvent.StartOnEvent.Name)
                    if m3iModeSwitchEvent.instanceRef.size()>1
                        if~isempty(m3iModeSwitchEvent.instanceRef.at(2).Port)...
                            &&isvalid(m3iModeSwitchEvent.instanceRef.at(2).Port)
                            arPortName2=m3iModeSwitchEvent.instanceRef.at(2).Port.Name;
                        end


                        if~strcmp(arPortName1,arPortName2)
                            autosar.validation.Validator.logError('RTW:autosar:sameMDGForTransition',m3iModeSwitchEvent.Name);
                        end
                    end
                end
            else
                autosar.validation.Validator.logError('RTW:autosar:eventElementNotFound',...
                'Mode Receiver Port',m3iModeSwitchEvent.Name,...
                'Mode Receiver Port');
            end
            assert(m3iModeSwitchEvent.StartOnEvent.isvalid(),...
            'ModeSwitchEvent %s is not associated with a runnable',m3iModeSwitchEvent.Name);
        end


        function verifyOperationInvokedEvent(~,m3iOperationInvokedEvent)


            instanceRef=m3iOperationInvokedEvent.instanceRef;
            if instanceRef.isvalid()...
                &&instanceRef.Port.isvalid()...
                &&instanceRef.Operations.isvalid()


                m3iInterface=instanceRef.Operations.containerM3I;
                if m3iInterface~=instanceRef.Port.Interface
                    autosar.validation.Validator.logError('RTW:autosar:portNotFound',...
                    m3iOperationInvokedEvent.Name);
                end
            end
        end


    end
    methods(Access=private)
        function[SLObjectName,dataAccessMode,isFound,isErrorStatus]=getMappingData(...
            this,arPortName,arElementName)
            mapping=autosar.api.Utils.modelMapping(this.ModelName);
            SLObjectName='';
            dataAccessMode='';
            isFound=false;
            isErrorStatus=false;
            for ii=1:length(mapping.Inports)
                inport=mapping.Inports(ii);
                if strcmp(inport.MappedTo.Port,arPortName)&&...
                    strcmp(inport.MappedTo.Element,arElementName)
                    SLObjectName=autosar.ui.utils.convertSLObjectNameToGraphicalName(inport.Block);
                    dataAccessMode=inport.MappedTo.DataAccessMode;
                    if strcmp(dataAccessMode,'ErrorStatus')
                        isErrorStatus=true;
                    else
                        isFound=true;
                        break;
                    end
                end
            end
        end

    end
end




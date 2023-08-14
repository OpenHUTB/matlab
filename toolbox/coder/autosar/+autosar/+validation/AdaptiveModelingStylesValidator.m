classdef AdaptiveModelingStylesValidator<autosar.validation.PhasedValidator






    methods(Access=protected)

        function verifyInitial(self,hModel)
            self.checkRootInportMsgTrigSS(hModel);
            self.checkMsgTrigSSTriggerTime(hModel);
        end

        function verifyPostProp(self,hModel)
            self.verifyWordSizeOnMsgTriggSSSideIO(hModel);
            self.verifySideIOOnAsyncResponseSS(hModel);
        end

    end

    methods(Static,Access=public)
        function verifyWordSizeSideIOForSS(subSysH)

            sideIPorts=find_system(subSysH,'SearchDepth',1,...
            'BlockType','Inport','IsClientServer','off');
            sideOPorts=find_system(subSysH,'SearchDepth',1,...
            'BlockType','Outport','IsClientServer','off');

            sideIOPorts=[sideIPorts;sideOPorts];
            for sideIOIdx=1:length(sideIOPorts)
                curPortH=sideIOPorts(sideIOIdx);
                isInport=strcmp(get_param(curPortH,'BlockType'),'Inport');
                dataTypeStruct=get_param(curPortH,'CompiledPortDataTypes');
                if isInport
                    dataTypeName=dataTypeStruct.Outport{1};
                else
                    dataTypeName=dataTypeStruct.Inport{1};
                end
                autosar.validation.AdaptiveModelingStylesValidator.verifyWordSizeOfDataType(curPortH,dataTypeName)
            end
        end
    end

    methods(Static,Access=private)



        function checkRootInportMsgTrigSS(hModel)
            if~slfeature('SubSysTrigOnMsgAdaptiveCodegen')

                msgTriggeredSSBlks=...
                autosar.simulink.msgTrigSS.Utils.findMessageTriggeredSubsystems(hModel);

                if~isempty(msgTriggeredSSBlks)
                    slFuncBlkPaths=...
                    autosar.validation.AutosarUtils.getFullBlockPathsForError(msgTriggeredSSBlks);
                    autosar.validation.Validator.logError(...
                    'autosarstandard:validation:msgTrigSSCodegenNotAllowed',...
                    slFuncBlkPaths);
                end
            end
        end

        function checkMsgTrigSSTriggerTime(hModel)
            if slfeature('SubSysTrigOnMsgAdaptiveCodegen')
                triggerdSSBlks=...
                autosar.simulink.msgTrigSS.Utils.findMessageTriggeredSubsystems(hModel);
                trigPorts=find_system(triggerdSSBlks,'BlockType','TriggerPort');
                for ii=1:numel(trigPorts)
                    actualTriggerTime=get_param(trigPorts(ii),'TriggerTime');
                    expectedTriggerTime='on message available';
                    expectedTriggerTimeUI=DAStudio.message('Simulink:dialog:onMessageAvailable_CB');
                    if~strcmp(actualTriggerTime,expectedTriggerTime)
                        trigPortPath=getfullname(trigPorts(ii));
                        autosar.validation.Validator.logError(...
                        'autosarstandard:validation:WrongMsgTrigTimeForAdptvEvtTrigExec',...
                        trigPortPath,expectedTriggerTimeUI);
                    end
                end
            end
        end

        function verifyWordSizeOnMsgTriggSSSideIO(hModel)



            triggerdSSBlks=...
            autosar.simulink.msgTrigSS.Utils.findMessageTriggeredSubsystems(hModel);
            for ssIdx=1:length(triggerdSSBlks)
                autosar.validation.AdaptiveModelingStylesValidator.verifyWordSizeSideIOForSS(...
                triggerdSSBlks(ssIdx));
            end
        end

        function verifyWordSizeOfDataType(portH,dataTypeName)
            [objExists,slObj]=autosar.utils.Workspace.objectExistsInModelScope(bdroot(portH),dataTypeName);

            if fixed.internal.type.isNameOfTraditionalFixedPointType(dataTypeName,false)
                numType=numerictype(dataTypeName);
                typeWordLength=numType.WordLength;
            elseif~objExists
                return;
            elseif isa(slObj,'Simulink.AliasType')

                if strcmp(dataTypeName,slObj.BaseType)

                    return;
                else
                    autosar.validation.AdaptiveModelingStylesValidator.verifyWordSizeOfDataType(portH,slObj.BaseType);
                end
                return;
            elseif isa(slObj,'Simulink.StructType')

                for elemIdx=1:length(slObj.Elements)
                    elem=slObj.Elements(elemIdx);

                    autosar.validation.AdaptiveModelingStylesValidator.verifyWordSizeOfDataType(portH,elem.DataType);
                end
                return;
            elseif isa(slObj,'Simulink.NumericType')&&~strcmp(slObj.DataTypeMode,'Double')
                typeWordLength=slObj.WordLength;
            else

                return;
            end
            largestInt=get_param(bdroot(portH),'ProdLargestAtomicInteger');
            if strcmp(largestInt,'Integer')
                wordSizeParam='ProdBitPerInt';
            else
                wordSizeParam=['ProdBitPer',largestInt];
            end
            maxIntWordSize=get_param(bdroot,wordSizeParam);
            if typeWordLength>maxIntWordSize
                autosar.validation.Validator.logError('autosarstandard:validation:adaptiveSideIOWordSize',...
                getfullname(portH),dataTypeName,num2str(typeWordLength),...
                num2str(maxIntWordSize),largestInt,wordSizeParam);
            end
        end

        function verifySideIOOnAsyncResponseSS(hModel)


            mapping=autosar.api.Utils.modelMapping(hModel);
            try
                mapping.validateAsyncMethodResponseSS();
            catch ME
                autosar.validation.Validator.logError(ME.identifier,ME);
            end

        end
    end

end



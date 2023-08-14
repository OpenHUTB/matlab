classdef InternalTriggerBlock<handle





    properties(Hidden,Constant)
        LibBlockPath='autosarspkglib_internal/Internal Trigger';
        MaskDisplayTextPrefix='Call:';
    end

    methods(Static)

        function updateBlock(block)


            model=bdroot(block);
            isLib=strcmp(get_param(model,'BlockDiagramType'),'library');
            if isLib
                return
            end
            autosar.blocks.InternalTriggerBlock.checkFunctionName(block);
            autosar.blocks.InternalTriggerBlock.checkInternalTrigPointName(block);
        end

        function isInternalTrigBlk=isInternalTriggerBlock(block)

            isInternalTrigBlk=strcmp(get_param(block,'MaskType'),'InternalTrigger');
        end

        function isMapped=isInternalTriggerBlockMapped(internalTrigBlock,triggeringRunSymbol,intTrigPointName)


            assert(autosar.blocks.InternalTriggerBlock.isInternalTriggerBlock(internalTrigBlock),...
            '%s is not InternalTrigger block.',getfullname(internalTrigBlock));
            modelMapping=autosar.api.Utils.modelMapping(bdroot(internalTrigBlock));
            blockPath=strrep(getfullname(internalTrigBlock),newline,' ');
            blockMapping=modelMapping.FunctionCallers.findobj('Block',blockPath);
            isMapped=strcmp(blockMapping.MappedTo.ClientPort,'_')&&...
            strcmp(blockMapping.MappedTo.Operation,[triggeringRunSymbol,'_',intTrigPointName]);
        end

        function mapInternalTriggerBlock(internalTrigBlock,triggeringRunSymbol)


            assert(autosar.blocks.InternalTriggerBlock.isInternalTriggerBlock(internalTrigBlock),...
            '%s is not InternalTrigger block.',getfullname(internalTrigBlock));
            modelMapping=autosar.api.Utils.modelMapping(bdroot(internalTrigBlock));
            blockPath=strrep(getfullname(internalTrigBlock),newline,' ');
            blockMapping=modelMapping.FunctionCallers.findobj('Block',blockPath);
            intTrigPointName=get_param(internalTrigBlock,'InternalTriggeringPointName');
            portName='_';
            if~autosar.blocks.InternalTriggerBlock.isInternalTriggerBlockMapped(...
                internalTrigBlock,triggeringRunSymbol,intTrigPointName)
                blockMapping.mapPortOperation(portName,[triggeringRunSymbol,'_',intTrigPointName]);
            end
        end

        function isIntTrigPoint=isServerCallPointMappedToInternalTriggerPoint(serverCallPoint)



            assert(rtw.connectivity.CodeInfoUtils.isa(serverCallPoint,'AutosarClientCall'),'input is not serverCallPoint');
            isIntTrigPoint=strcmp(serverCallPoint.PortName,'_')&&...
            contains(serverCallPoint.Prototype.Name,'_');
        end

        function syncMapping(modelName)







            if Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)
                return;
            end

            modelH=get_param(modelName,'Handle');
            internalTrigBlocks=autosar.blocks.InternalTriggerBlock.findInternalTriggerBlocks(modelH);
            if isempty(internalTrigBlocks)
                return
            end


            fcnCallInports=find_system(modelName,'SearchDepth',1,'BlockType','Inport',...
            'OutputFunctionCall','on');
            fcnCallSubsys2FcnCallInportMap=containers.Map();
            for ii=1:length(fcnCallInports)
                fcnCallInport=fcnCallInports{ii};
                triggerPort=autosar.mm.mm2sl.SLModelBuilder.getAllDestinationPortsThroughVirtualBlocks(fcnCallInport);
                assert(length(triggerPort)==1,'could not find function-call subsystem for %s',fcnCallInport);
                fcnCallSubsysName=getfullname(get_param(triggerPort{1},'Parent'));
                fcnCallSubsys2FcnCallInportMap(fcnCallSubsysName)=fcnCallInport;
            end



            mapping=autosar.api.Utils.modelMapping(modelName);
            mapping.syncFunctionCallers();
            runnableHdls=autosar.blocks.InternalTriggerBlock.findAllRunnables(modelName);
            for ii=1:length(internalTrigBlocks)
                internalTrigBlock=internalTrigBlocks(ii);
                trigBlkOwnerSysH=autosar.validation.ExportFcnValidator.findRunnableOwner(...
                internalTrigBlock,runnableHdls);
                trigBlkOwnerSysName=getfullname(trigBlkOwnerSysH);
                triggeringRunnableName=[];
                if slInternal('isSimulinkFunction',trigBlkOwnerSysH)
                    trigBlkOwnerSysName=strrep(trigBlkOwnerSysName,newline,' ');
                    blockMapping=mapping.ServerFunctions.findobj('Block',trigBlkOwnerSysName);
                    if~isempty(blockMapping)
                        triggeringRunnableName=blockMapping.MappedTo.Runnable;
                    end
                elseif slInternal('isFunctionCallSubsystem',trigBlkOwnerSysH)
                    fcnCallInportBlock=fcnCallSubsys2FcnCallInportMap(trigBlkOwnerSysName);
                    fcnCallInportBlock=strrep(fcnCallInportBlock,newline,' ');
                    blockMapping=mapping.FcnCallInports.findobj('Block',fcnCallInportBlock);
                    if~isempty(blockMapping)
                        triggeringRunnableName=blockMapping.MappedTo.Runnable;
                    end
                elseif slInternal('isInitTermOrResetSubsystem',trigBlkOwnerSysH)
                    if~isempty(autosar.utils.InitResetTermFcnBlock.findInitFunctionBlocks(trigBlkOwnerSysName))
                        if~isempty(mapping.InitializeFunctions)
                            triggeringRunnableName=mapping.InitializeFunctions.MappedTo.Runnable;
                        end
                    elseif~isempty(autosar.utils.InitResetTermFcnBlock.findTermFunctionBlocks(trigBlkOwnerSysName))
                        if~isempty(mapping.TerminateFunctions)
                            triggeringRunnableName=mapping.TerminateFunctions.MappedTo.Runnable;
                        end
                    else


                        eventListener=find_system(trigBlkOwnerSysH,...
                        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                        'BlockType','EventListener');
                        assert(strcmp(get_param(eventListener,'EventType'),'Reset'));
                        eventName=get_param(eventListener,'EventName');
                        entryPointMapping=mapping.ResetFunctions.findobj('Name',eventName);
                        if~isempty(entryPointMapping)
                            triggeringRunnableName=entryPointMapping.MappedTo.Runnable;
                        end
                    end
                end


                if~isempty(triggeringRunnableName)
                    m3iRun=autosar.validation.ClientServerValidator.findM3iRunnableFromName(...
                    modelName,triggeringRunnableName);
                    if~isempty(m3iRun)
                        autosar.blocks.InternalTriggerBlock.mapInternalTriggerBlock(...
                        internalTrigBlock,m3iRun.symbol);
                    end
                end
            end
        end

        function blocks=findInternalTriggerBlocks(sys)
            blocks=find_system(sys,'FollowLinks','on',...
            'MatchFilter',@Simulink.match.activeVariants,...
            'LookUnderMasks','all','BlockType','FunctionCaller',...
            'MaskType','InternalTrigger');
        end
    end

    methods(Static,Access=private)
        function runnableHdls=findAllRunnables(modelName)
            modelH=get_param(modelName,'Handle');
            runnableNames=[...
            getfullname(autosar.validation.ExportFcnValidator.getRunnableHdls(modelH,true))...
            ,autosar.utils.InitResetTermFcnBlock.findInitFunctionBlocks(modelName)...
            ,autosar.utils.InitResetTermFcnBlock.findTermFunctionBlocks(modelName)...
            ,autosar.utils.InitResetTermFcnBlock.findResetFunctionBlocks(modelName)];
            runnableHdls=get_param(runnableNames,'Handle');
            runnableHdls=[runnableHdls{:}];
        end

        function checkFunctionName(internalTrigBlock)

            fcnName=get_param(internalTrigBlock,'FunctionName');
            model=bdroot(internalTrigBlock);
            if strcmp(get_param(model,'AutosarCompliant'),'on')
                autosar.api.Utils.checkQualifiedName(model,fcnName,'shortname');
            else

                if~isvarname(fcnName)
                    DAStudio.error('autosarstandard:common:InvalidFunctionName',...
                    fcnName);
                end
            end
            set_param(internalTrigBlock,'FunctionPrototype',[fcnName,'()']);
        end

        function checkInternalTrigPointName(internalTrigBlock)

            itpName=get_param(internalTrigBlock,'InternalTriggeringPointName');
            model=bdroot(internalTrigBlock);
            if strcmp(get_param(model,'AutosarCompliant'),'on')
                autosar.api.Utils.checkQualifiedName(model,itpName,'shortname');
            else

                if~isvarname(itpName)
                    DAStudio.error('autosarstandard:common:InvalidInternalTriggeringPointName',...
                    itpName);
                end
            end
        end
    end
end





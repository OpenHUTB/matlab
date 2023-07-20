classdef Utils<handle




    methods(Static,Access=public)

        function[portName,methodName]=getPortAndMethodForBlock(blkH)
            blockType=get_param(blkH,'BlockType');
            componentAdapter=...
            autosar.ui.wizard.builder.ComponentAdapter.getComponentAdapter(bdroot(blkH));
            fcnName=autosar.ui.utils.getSlFunctionName(blkH);
            methodName=componentAdapter.getAutosarMethodName(fcnName);
            switch blockType
            case 'FunctionCaller'
                tokens=strsplit(fcnName,'.');
                portName=tokens{1};
            case 'SubSystem'
                triggerPort=find_system(blkH,...
                'SearchDepth',1,'BlockType','TriggerPort');
                assert(length(triggerPort)==1,'Expected to find trigger port');
                assert(strcmp(get_param(triggerPort,'FunctionVisibility'),'port'),...
                'Expected port scoped function');
                portName=get_param(triggerPort,'ScopeName');
            otherwise
                assert(false,'Unexpected block type');
            end
        end

        function clientPorts=findClientPorts(model)
            clientPorts=find_system(model,'SearchDepth',1,...
            'BlockType','Inport','IsComposite','on',...
            'IsClientServer','on');
        end

        function serverPorts=findServerPorts(model)
            serverPorts=find_system(model,'SearchDepth',1,...
            'BlockType','Outport','IsComposite','on',...
            'IsClientServer','on');
        end

        function isCSPort=isClientServerPort(blkH)
            blockType=get_param(blkH,'BlockType');
            isPortBlock=any(strcmp(blockType,{'Inport','Outport'}));
            isCSPort=isPortBlock&&...
            slfeature('CompositeFunctionElements')&&...
            strcmp(get_param(blkH,'IsClientServer'),'on');
        end

        function methodName=escapeBrackets(methodName)
            methodName=erase(methodName,"()");
        end

        function[inArgs,outArgs]=getArgumentsFromFunctionPort(modelH,fcnPortPath)

            isClient=strcmp(get_param(fcnPortPath,'BlockType'),'Inport');
            fcnName=[get_param(fcnPortPath,'PortName'),'.'...
            ,get_param(fcnPortPath,'Element')];
            functionH=autosar.api.internal.MappingFinder.getBlockPathsByFunctionName(modelH,fcnName,isClient);
            if iscell(functionH)


                functionH=functionH{1};
            end
            [inArgs,outArgs]=autosar.validation.ClientServerValidator.getBlockInOutParams(functionH);
        end
    end
end

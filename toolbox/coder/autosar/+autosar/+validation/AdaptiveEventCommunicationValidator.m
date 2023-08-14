classdef AdaptiveEventCommunicationValidator<autosar.validation.PhasedValidator




    methods(Access=protected)

        function verifyPostProp(this,hModel)
            this.verifyNoIRTBlocksWithIO(hModel)
            this.verifyEventCommunication(hModel)
        end

    end

    methods(Static,Access=private)
        function verifyNoIRTBlocksWithIO(hModel)




            modelName=get_param(hModel,'Name');

            irtBlocks=autosar.utils.InitResetTermFcnBlock.findIRTBlocks(modelName);



            portConnectivity=get_param(irtBlocks,'PortConnectivity');
            irtBlocksWithIO=irtBlocks(~cellfun(@isempty,portConnectivity));

            if~isempty(irtBlocksWithIO)
                irtBlockPaths=...
                autosar.validation.AutosarUtils.getFullBlockPathsForError(irtBlocksWithIO);
                autosar.validation.Validator.logError('autosarstandard:validation:AdaptiveIRTBlocks',modelName,irtBlockPaths);
            end
        end

        function verifyEventCommunication(hModel)




            mapping=autosar.api.Utils.modelMapping(hModel);
            portNodes=[mapping.Inports,mapping.Outports];
            nonMsgPortPaths={};
            for portIdx=1:length(portNodes)
                portPath=portNodes(portIdx).Block;

                isInport=strcmp(get_param(portPath,'BlockType'),'Inport');
                if isInport
                    portParam='Outport';
                else
                    portParam='Inport';
                end



                if strcmp(get_param(portPath,'CompiledIsActive'),'off')

                    continue;
                end


                if slfeature('PortBlockService')&&slfeature('CompositeFunctionElementsCodegen')&&...
                    strcmp(get_param(portPath,'IsClientServer'),'on')

                    continue;
                end



                connectedBlkH=...
                autosar.validation.AdaptiveEventCommunicationValidator.getConnectedBlkH(portPath);
                if isempty(connectedBlkH)||all(connectedBlkH==-1)

                    continue;
                elseif length(connectedBlkH)~=1
                    autosar.validation.Validator.logError('autosarstandard:validation:branchedMsgPort',portPath);
                end

                isMessage=get_param(portPath,'CompiledPortIsMessage');
                isMessage=isMessage.(portParam);
                if~isMessage
                    if~autosar.validation.AdaptiveEventCommunicationValidator.isPortConnectedToTermOrGround(portPath)
                        nonMsgPortPaths{end+1}=portPath;%#ok<AGROW>
                    end
                end
            end
            if~isempty(nonMsgPortPaths)
                autosar.validation.Validator.logError(...
                'autosarstandard:validation:AdaptiveNonMsgPort',...
                autosar.api.Utils.cell2str(nonMsgPortPaths));
            end
        end

        function isConnectedToTermOrGround=isPortConnectedToTermOrGround(portPath)

            [connectedBlockH,termOrGroundType]=...
            autosar.validation.AdaptiveEventCommunicationValidator.getConnectedBlkH(portPath);

            isConnectedToTermOrGround=...
            all(strcmp(get_param(connectedBlockH,'BlockType'),termOrGroundType));
        end

        function[connectedBlkH,termOrGroundType]=getConnectedBlkH(portPath)


            portData=get_param(portPath,'PortConnectivity');

            isInport=strcmp(get_param(portPath,'BlockType'),'Inport');

            if isInport
                connectedBlkH=portData.DstBlock;
                termOrGroundType='Terminator';
            else
                connectedBlkH=portData.SrcBlock;
                termOrGroundType='Ground';
            end
        end
    end

end



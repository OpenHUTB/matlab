classdef ClassicModelReferenceValidator<autosar.validation.PhasedValidator




    methods(Access=protected)

        function verifyInitial(this,hModel)

            autosar.validation.ClassicModelReferenceValidator.validate(hModel);
        end
    end

    methods(Static,Access=public)
        function validate(hModel)
            autosar.validation.ClassicModelReferenceValidator.validateGlobalSlFcnBlocks(hModel);
        end
    end

    methods(Static,Access=private)
        function slFcnBlocks=getSlFcnBlocks(hModel)
            slFcnBlocks={};
            blocks=find_system(hModel,'MatchFilter',@Simulink.match.allVariants,'BlockType','SubSystem');
            for idx=1:length(blocks)
                if strcmp(get_param(blocks(idx),'IsSimulinkFunction'),'on')
                    slFcnBlocks{end+1}=blocks(idx);
                end
            end
        end

        function isSlFcnGlobal=isSlFcnGlobal(slFcnBlock)
            isSlFcnGlobal=false;
            triggerPort=find_system(slFcnBlock,'BlockType','TriggerPort');
            if strcmp(get_param(triggerPort,'FunctionVisibility'),'global')
                isSlFcnGlobal=true;
            end
        end



        function doesSlFcnDriveRootIO=doesSlFcnDriveRootIO(slFcnBlock)
            doesSlFcnDriveRootIO=false;
            ports=get_param(slFcnBlock,'PortConnectivity');
            for idx=1:length(ports)
                port=ports(idx);
                if~strcmp(port.Type,'trigger')
                    isFedByRootInport=~isempty(port.SrcBlock)&&strcmp(get_param(port.SrcBlock,'BlockType'),'Inport');
                    feedsRootOutport=~isempty(port.DstBlock)&&strcmp(get_param(port.DstBlock,'BlockType'),'Outport');

                    if isFedByRootInport||feedsRootOutport
                        doesSlFcnDriveRootIO=true;
                        return;
                    end
                end
            end
        end


        function validateGlobalSlFcnBlocks(hModel)
            if~strcmp(get_param(hModel,'ModelReferenceTargetType'),'RTW')
                return;
            end

            slFcnBlocks=autosar.validation.ClassicModelReferenceValidator.getSlFcnBlocks(hModel);
            for idx=1:length(slFcnBlocks)
                sFuncBlk=slFcnBlocks{idx};
                if autosar.validation.ClassicModelReferenceValidator.isSlFcnGlobal(sFuncBlk)...
                    &&autosar.validation.ClassicModelReferenceValidator.doesSlFcnDriveRootIO(sFuncBlk)
                    autosar.validation.Validator.logError('RTW:autosar:invalidGlobalSlFcnMdlRef',string(sFuncBlk));
                end
            end
        end
    end
end



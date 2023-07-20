classdef(Sealed,Hidden)VariantManagerBlockType







    enumeration
        VariantSubsystem,
        VariantSourceSink,
        VariantSimFcn,
        VariantIRTSystem,
        VariantPMConnector,
        SFChart,
        SubSystem,
ModelReference
    end

    methods(Static,Access=public,Hidden=true)
        function isNonVariantBlock=getIsNonVariantBlock(vmBlockType)
            isNonVariantBlock=isequal(vmBlockType,Simulink.variant.manager.VariantManagerBlockType.SubSystem)||...
            isequal(vmBlockType,Simulink.variant.manager.VariantManagerBlockType.ModelReference);
        end

        function vmBlockType=getVariantManagerBlockType(blockPath)
            if strcmp(get_param(blockPath,'Type'),'block_diagram')
                vmBlockType='SubSystem';
            else
                vmBlockType=get_param(blockPath,'BlockType');
                if strcmp(vmBlockType,'SubSystem')
                    isVariant=strcmp(get_param(blockPath,'Variant'),'on');


                    if isVariant&&Simulink.variant.utils.isSubsystemReadable(blockPath)
                        vmBlockType='VariantSubsystem';
                    elseif Simulink.variant.utils.isVariantSimulinkFunction(blockPath)
                        vmBlockType='VariantSimFcn';
                    elseif Simulink.variant.utils.isVariantIRTSubsystem(blockPath)
                        vmBlockType='VariantIRTSystem';
                    elseif Simulink.variant.utils.isSFChart(get_param(blockPath,'Handle'))
                        vmBlockType='SFChart';
                    end
                elseif any(strcmp(vmBlockType,{'VariantSource','VariantSink'}))
                    vmBlockType='VariantSourceSink';
                end
            end
            try
                vmBlockType=Simulink.variant.manager.VariantManagerBlockType.(vmBlockType);
            catch

                Simulink.variant.utils.assert(false,['Internal error: Invalid block type ''%s'' to Variant Manager: ',vmBlockType]);
            end
        end
    end
end



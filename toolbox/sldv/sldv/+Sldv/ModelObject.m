classdef ModelObject






    properties
        blockType;
        blockH;
        designSID;

        blocksNotSupportedForValidation={'MATLABSystem'};
    end
    methods
        function obj=ModelObject(blockData)
            obj.blockType=blockData.typeDesc;
            obj.designSID=blockData.designSid;
            if~isempty(blockData.designSid)
                obj.blockH=Simulink.ID.getHandle(blockData.designSid);
            else


                return;
            end
        end

        function isBlockSupportedForValidation=canValidateBlock(obj)

            blocksNotSupported=obj.blocksNotSupportedForValidation;
            isBlockSupportedForValidation=~any(ismember(blocksNotSupported,obj.blockType));

        end
    end
    methods(Static=true,Access='private')
        function dataTypesArr=getPortDataTypeArr(portArr)
            dataTypesArr=cell(1,length(portArr));
            dataTypesArr(1,:)={char()};
            for idx=1:length(portArr)
                compiledportPrm=Simulink.CompiledPortInfo(portArr(idx));
                dataTypesArr{idx}=compiledportPrm.DataType;
            end
        end

        function dataTypesArr=getDataTypeofSFStatement(stateflowData)
            dataTypesArr=cell(1,length(stateflowData));
            dataTypesArr(1,:)={char()};
            for idx=1:length(stateflowData)
                dataTypesArr{idx}=stateflowData(idx).CompiledType;
            end
        end
    end
end

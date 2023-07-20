


classdef FIRRateConversionAutoscaler<dvautoscaler.SPCUniDTAutoscaler





    methods
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)

        function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)

            grandPa=blkObj.getParent.getParent.getParent;
            [DTConInfo,comments,paramNames]=gatherSpecifiedDT@dvautoscaler.SPCUniDTAutoscaler(h,grandPa,pathItem);

        end

        function comment=checkComments(~,~,~)
            comment='';
        end

        function pv=getSettingStrategies(h,blkObj,pathItem,~)

            pv={};
            grandPa=blkObj.getParent.getParent.getParent;
            udtMaskParamStr=strcat(getSPCUniDTParamPrefixStr(h,grandPa,pathItem),'DataTypeStr');
            blockPath=grandPa.getFullName;
            pv{1,1}={'FullDataTypeStrategy',blockPath,udtMaskParamStr};

        end

    end
end



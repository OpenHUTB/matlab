classdef FIRDecimationAutoscaler<dvautoscaler.SPCUniDTAutoscaler


    methods

        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)

        function pathItems=getPathItems(~,blkObj)
            pathItems={};
            BlkDialogParams=fieldnames(blkObj.DialogParameters);
            if ismember('accumDataTypeStr',BlkDialogParams)
                pathItems=[pathItems,'Accumulator'];
            end
            if ismember('prodOutputDataTypeStr',BlkDialogParams)
                pathItems=[pathItems,'Product output'];
            end
            if ismember('outputDataTypeStr',BlkDialogParams)
                pathItems=[pathItems,'Output'];
            end
            if ismember('firstCoeffDataTypeStr',BlkDialogParams)
                pathItems=[pathItems,'Coefficients'];
            end

        end

        function records=gatherAssociatedParam(~,blkObj)
            records=[];
            if isequal(blkObj.FilterSource,'Dialog parameters')||...
                isequal(blkObj.FilterSource,'Auto')
                [isValid,minVal,maxVal,pObj]=...
                SimulinkFixedPoint.slfxpprivate('evalNumericParameterRange',blkObj,'h');

                if isValid
                    records=SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(...
                    blkObj,'Coefficients',[],minVal,maxVal,pObj);
                end
            end
        end
    end

end


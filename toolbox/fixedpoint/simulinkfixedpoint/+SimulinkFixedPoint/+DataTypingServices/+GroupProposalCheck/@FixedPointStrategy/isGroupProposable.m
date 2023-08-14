function[isProposable,comment]=isGroupProposable(~,effectiveConstraint,groupSpecifiedDataType,groupRange,group)


















    isProposable=true;
    comment=[];



    if groupSpecifiedDataType.isUnknown
        isProposable=false;
        return;
    end







    if groupSpecifiedDataType.isIrreplaceableByFixedPointDT
        isProposable=false;
        return;
    end


    groupMembers=group.getGroupMembers;
    for cIndex=1:numel(groupMembers)
        compiledDataTypeStr=groupMembers{cIndex}.CompiledDT;
        if~isempty(compiledDataTypeStr)
            compiledDataType=...
            SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer(compiledDataTypeStr,[]);
            if compiledDataType.isBoolean
                isProposable=false;
                return;
            end
        end
    end

    if~isempty(effectiveConstraint)
        if~SimulinkFixedPoint.AutoscalerUtils.isFixedPointProposalAllowed({effectiveConstraint})
            isProposable=false;
            return;
        end
    end

    if any(isinf(groupRange))||any(isnan(groupRange))
        isProposable=false;
        comment=message('SimulinkFixedPoint:autoscaling:notValidRange').getString;
        return;
    end
end


function specialHandlingDT=specialHandlingForResults(result,resultsScope)














    specialHandlingDT='';


    if~resultsScope(result.getUniqueIdentifier.UniqueKey)

        specialHandlingDT=DataTypeWorkflow.Single.Utils.NOPROPOSAL;
        return;
    end


    compiledType=result.getPropValue('CompiledDT');
    if isempty(compiledType)||strcmp(compiledType,'double')



        if result.IsLocked

            specialHandlingDT=DataTypeWorkflow.Single.Utils.NOPROPOSAL;
            return;
        end


        isFltTrump=DataTypeWorkflow.Utils.isFloatingPointTrump(result);
        if isFltTrump
            specialHandlingDT=DataTypeWorkflow.Single.Utils.NOPROPOSAL;
            return;
        end


        isDataTypeAppliable=DataTypeWorkflow.Utils.checkIfDataTypeApplyPossible(result);
        if~isDataTypeAppliable
            specialHandlingDT=DataTypeWorkflow.Single.Utils.NOPROPOSAL;
            return;
        end


        specifiedDTContainerInfo=result.getSpecifiedDTContainerInfo;

        if isempty(compiledType)&&(specifiedDTContainerInfo.isInherited&&~result.isInheritanceReplaceable)
            specialHandlingDT=DataTypeWorkflow.Single.Utils.NOPROPOSAL;
            return;
        end

        if~(strcmp(specifiedDTContainerInfo.evaluatedDTString,'double')||specifiedDTContainerInfo.isInherited)

            specialHandlingDT=DataTypeWorkflow.Single.Utils.NOPROPOSAL;
        end
    else

        specialHandlingDT=DataTypeWorkflow.Single.Utils.NOPROPOSAL;
        return;
    end
end



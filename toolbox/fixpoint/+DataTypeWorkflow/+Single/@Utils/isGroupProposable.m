function isProposable=isGroupProposable(group)










    isProposable=true;



    isGroupLocked=false;
    isGroupSetToFixPt=false;
    isGroupCompiledDTFixPt=false;
    isGroupHavingIssueFromVariableTracing=false;
    isGroupSpecifiedDataTypeIrreplaceable=false;



    groupMembers=group.getGroupMembers();
    for idxResult=1:numel(groupMembers)
        result=groupMembers{idxResult};

        if~result.isResultValid
            continue;
        end


        isGroupLocked=isGroupLocked||result.IsLocked;





        isFltTrump=DataTypeWorkflow.Utils.isFloatingPointTrump(result);
        specDTContainerInfo=result.getSpecifiedDTContainerInfo;
        isGroupSetToFixPt=isGroupSetToFixPt||specDTContainerInfo.isFixed&&~isFltTrump;




        isGroupCompiledDTFixPt=isGroupCompiledDTFixPt||~isempty(regexpi(result.getCompiledDT,'fixdt'));


        isDataTypeAppliable=DataTypeWorkflow.Utils.checkIfDataTypeApplyPossible(result);
        isGroupHavingIssueFromVariableTracing=...
isGroupHavingIssueFromVariableTracing...
        ||(~isDataTypeAppliable&&~result.getSpecifiedDTContainerInfo.isUnknown);



        isGroupSpecifiedDataTypeIrreplaceable=isGroupSpecifiedDataTypeIrreplaceable||...
        specDTContainerInfo.isIrreplaceableByFixedPointDT;
    end



    if isGroupLocked...
        ||isGroupSetToFixPt...
        ||isGroupCompiledDTFixPt...
        ||isGroupHavingIssueFromVariableTracing...
        ||isGroupSpecifiedDataTypeIrreplaceable
        isProposable=false;
    end

end

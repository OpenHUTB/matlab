function[pTree,scalarVariableList]=addScalarVariableToList(pTree,scalarVariableList,modelName,varOrFieldOrIdxName,var_sz,var_dt,varSource,varValue,varMetaData,isFirstVisit,varNameNoIdx,isRootNode)




    assert(~isempty(var_dt));


    if isFirstVisit
        pTree=FMU2ExpCSDialog.addToTree(pTree,varNameNoIdx,var_sz,uint32.empty(1,0),false,var_dt,varSource,modelName,isRootNode);
    end


    var.name=varOrFieldOrIdxName;
    var.description=varMetaData.description;
    var.unit=varMetaData.unit;
    var.blkPath=varMetaData.blockPath;
    scalarVariableList=[scalarVariableList,var];
end

function isValid=isValidConstrName(constrRowObj,newConstrName)








    if~isvarname(newConstrName)
        isValid=false;
        return;
    end
    constrNamesList=constrRowObj.VarConstrSSSrc.getConstraintNames();
    constrNamesList(constrRowObj.VarConstrIdx)=[];
    isValid=~ismember(newConstrName,constrNamesList);
end

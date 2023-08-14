function combineVariableGradients(visitor)











    vars=visitor.Variables;
    sz=[visitor.TotalVar,visitor.NumExpr];


    varList=struct2cell(vars);
    nVars=numel(varList);

    if nVars==1&&numel(varList{1})==sz(1)



        var=varList{1};
        [jacStr,jacParens]=getJacobianMemory(var);
        jacIsArgOrVar=true;
        jacIsAllZero=false;
        push(visitor,jacStr,jacParens,jacIsArgOrVar,jacIsAllZero);
        return;
    end


    forestIndexList=cell(1,nVars);
    varIndexList=cell(1,nVars);
    varnames=string(fieldnames(vars));
    idxnames=matlab.lang.makeUniqueStrings(varnames+"idx",varnames,namelengthmax);
    for i=1:nVars
        curVar=varList{i};
        thisNumVar=numel(curVar);
        thisIdx=1:thisNumVar;

        forestIndexList{i}=idxnames{i}+",:";









        varIndexList{i}=thisIdx;
    end

    visitor.ChildrenHead=[];
    visitor.visitIndexingNode(...
    @compileVarGrad,sz,nVars,varList,forestIndexList,varIndexList);

    function headIdx=compileVarGrad(visitor,var,~)
        [varStr,varParens]=getJacobianMemory(var);
        isVar=true;
        isAllZero=false;
        push(visitor,varStr,varParens,isVar,isAllZero);
        head=visitor.Head;
        visitor.ChildrenHead=head;
        headIdx=1;
        visitor.Head=head-1;
    end
end

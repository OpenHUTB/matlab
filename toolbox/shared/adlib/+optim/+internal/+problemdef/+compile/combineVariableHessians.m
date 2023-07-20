function[jacStruct,hessStruct]=combineVariableHessians(vars,jacStruct,hessStruct,jacSz,hessSz)








    varList=struct2cell(vars);
    nVars=numel(varList);

    if nVars==1



        var=varList{1};
        [jacStruct.funh,jacStruct.NumParens,hessStruct.funh,hessStruct.NumParens]=getHessianMemory(var);
        clearHessianMemory(var);
        return;
    end


    forestIndexList=cell(1,nVars);
    varIndexList=cell(1,nVars);
    for i=1:nVars
        curVar=varList{i};
        thisNumVar=numel(curVar);
        thisIdx=(1:thisNumVar);

        forestIndexList{i}="idx_"+curVar.Name+",:";


        varIndexList{i}=thisIdx;
    end


    jacStruct=optim.internal.problemdef.SubsasgnExpressionImpl.compileIndexingFunction(...
    @compileVarGrad,@(var)var.Root,jacStruct,jacSz,nVars,varList,forestIndexList,varIndexList);

    hessStruct=optim.internal.problemdef.SubsasgnExpressionImpl.compileIndexingFunction(...
    @compileVarHess,@(var)var.Root,hessStruct,hessSz,nVars,varList,forestIndexList,varIndexList);

    cellfun(@clearHessianMemory,varList);

    function jacStruct=compileVarGrad(var,jacStruct)
        [jacStruct.funh,jacStruct.NumParens]=getHessianMemory(var);
    end

    function hessStruct=compileVarHess(var,hessStruct)
        [~,~,hessStruct.funh,hessStruct.NumParens]=getHessianMemory(var);
    end
end
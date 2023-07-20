function[nlfunStruct,jacStruct,hessStruct]=compileHessianFunction(obj,...
    nlfunStruct,jacStruct,hessStruct)




















    if obj.SingleTreeSpansAllIndices




        [nlfunStruct,jacStruct]=compileHessianForward(obj.TreeList{1},nlfunStruct,jacStruct);





        Root=obj.TreeList{1}.Root;
        Root.JacRADStr="speye("+prod(obj.Size)+")";
        Root.JacRADNumParens=1;

        Root.HessStr="0";
        Root.HessNumParens=0;



        [jacStruct,hessStruct]=compileHessianReverse(obj.TreeList{1},...
        jacStruct,hessStruct);
    else



        nTrees=obj.NumTrees;
        treeList=obj.TreeList;
        forestIndexList=obj.ForestIndexList;
        treeIndexList=obj.TreeIndexList;
        forestSize=obj.Size;



        [nlfunStruct,jacStruct,hessStruct]=...
        optim.internal.problemdef.SubsasgnExpressionImpl.compileIndexingHessianFunction(@compileHessianFunction,...
        @(treei)treei.Root,nlfunStruct,jacStruct,hessStruct,...
        forestSize,nTrees,treeList,forestIndexList,treeIndexList);

    end


    [jacStruct,hessStruct]=optim.internal.problemdef.compile.combineVariableHessians(obj.Variables,...
    jacStruct,hessStruct,[jacStruct.TotalVar,numel(obj)],[hessStruct.TotalVar,hessStruct.TotalVar]);

    if nlfunStruct.reset

        optim.internal.problemdef.Operator.getNumArgs('reset');

        clearVariableMemory(obj);
    end

end

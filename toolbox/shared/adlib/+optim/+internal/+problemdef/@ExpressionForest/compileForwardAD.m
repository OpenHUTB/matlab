function[nlfunStruct,jacStruct]=compileForwardAD(obj,inputs)




















    visitor=optim.internal.problemdef.visitor.CompileForwardAD(obj.Variables,inputs);


    if visitor.TotalVar==0||numel(obj)==0



        nlfunStruct=compileNonlinearFunction(obj,inputs);


        jacStr="sparse("+visitor.TotalVar+", "+numel(obj)+")";
        jacParens=1;
        isArgOrVar=false;
        isAllZero=false;
        jacIsArgOrVar=false;
        jacIsAllZero=true;
        push(visitor,nlfunStruct.funh,nlfunStruct.NumParens,isArgOrVar,isAllZero,nlfunStruct.singleLine);
        pushJac(visitor,jacStr,jacParens,jacIsArgOrVar,jacIsAllZero);
        addToExprBody(visitor,nlfunStruct.fcnBody);
        [~,jacStruct]=getOutputs(visitor);
        jacStruct.extraParams=nlfunStruct.extraParams;

        return;
    end

    visitForest(visitor,obj);

    [nlfunStruct,jacStruct]=getOutputs(visitor);

end

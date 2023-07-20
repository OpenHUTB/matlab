function[nlfunStruct,jacStruct]=compileHessianForward(obj,nlfunStruct,jacStruct)























    stack=obj.Stack;
    for i=1:numel(stack)

        Node=stack{i};




        [nlfunStruct,jacStruct]=compileHessianForward(Node,nlfunStruct,jacStruct);
    end



    nlfunStruct.funh=obj.Root.FunStr;
    nlfunStruct.NumParens=obj.Root.NumParens;

    jacStruct.funh=obj.Root.JacStr;
    jacStruct.NumParens=obj.Root.JacNumParens;


    if isempty(nlfunStruct.funh)
        [nlfunStruct.funh,nlfunStruct.NumParens]=...
        optim.internal.problemdef.ZeroExpressionImpl.getNonlinearStr(obj.Size);
    end


    if isempty(jacStruct.funh)
        jacStruct.funh="sparse("+nlfunStruct.TotalVar+", "+numel(obj)+")";
        jacStruct.JacNumParens=1;
    end


    deallocateJacobianMemory(obj);

end

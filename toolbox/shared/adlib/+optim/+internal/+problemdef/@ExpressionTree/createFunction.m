function createFunction(obj,func,vars,depth,sz,type,idx)
















    Node=optim.internal.problemdef.NonlinearExpressionImpl(func,sz,idx);


    obj.Depth=depth;


    obj.Stack={Node};

    Node.StackLength=1;



    obj.Variables=vars;


    obj.Type=type;


    if type==optim.internal.problemdef.ImplType.Numeric
        Node.SupportsAD=true;
    end

function createStaticAssignment(obj,Op,ExprLeft,ExprRight,PtiesVisitor)


















    LHS=ExprLeft.Root;

    skip=true;
    Node=optim.internal.problemdef.BinaryExpressionImpl(Op,LHS,ExprRight.Root,skip);


    obj.Depth=max(ExprLeft.Depth,ExprRight.Depth)+1;


    vars=ExprRight.Variables;
    stack=[ExprRight.Stack,{Node}];
    nNodes=numel(stack)-1;
    Node.ChildrenPosition=[nNodes,nNodes];


    Node.StackLength=numel(stack);


    obj.Variables=vars;


    obj.Stack=stack;


    rhsType=ExprRight.Type;



    if rhsType==optim.internal.problemdef.ImplType.Numeric


        EvalVisitor=optim.internal.problemdef.visitor.StaticEvaluate;
        acceptVisitor(ExprRight,EvalVisitor);
        rhsValue=getValue(EvalVisitor);
    else
        rhsValue=[];
    end


    push(PtiesVisitor,rhsType,rhsValue);
    pushProperties(PtiesVisitor,ExprRight.Size,ExprRight.SupportsAD);
    acceptVisitor(Node,PtiesVisitor);



    [lhsType,~,lhsSize,lhsCanAD]=popNode(PtiesVisitor,LHS);
    ExprLeft.Variables=vars;
    ExprLeft.Type=lhsType;
    obj.Type=lhsType;
    Node.Size=lhsSize;
    Node.SupportsAD=lhsCanAD;
function visitOperatorSum(visitor,~,~)





    currentNodeIdx=visitor.CurrentNodeIdx-1;
    visitor.CurrentNodeIdx=currentNodeIdx;
    Node=visitor.Stack{currentNodeIdx};
    acceptVisitor(Node,visitor);

end

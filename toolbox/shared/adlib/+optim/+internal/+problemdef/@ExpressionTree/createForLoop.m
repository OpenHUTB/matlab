function createForLoop(obj,loopVariable,loopRange,loopBody,loopLevel,PtiesVisitor)



















    Node=optim.internal.problemdef.ForLoopWrapper(loopVariable.Root,loopRange,loopBody,loopLevel);


    obj.Stack={Node};
    obj.Depth=getDepth(Node);

    acceptVisitor(Node,PtiesVisitor);


    [obj.Type,obj.Variables]=getOutputs(PtiesVisitor,loopBody);

end

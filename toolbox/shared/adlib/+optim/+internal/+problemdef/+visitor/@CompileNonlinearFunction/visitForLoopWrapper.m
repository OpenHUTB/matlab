function visitForLoopWrapper(visitor,LoopWrapper)





    loopVar=LoopWrapper.LoopVar;
    loopValues=LoopWrapper.LoopRange;
    loopBody=LoopWrapper.LoopBody;




    initializeLHS(visitor,loopVar);
    loopVarName=popNode(visitor,loopVar);


    acceptVisitor(loopValues,visitor);
    loopValuesStr=pop(visitor);
    visitor.Head=visitor.Head-1;


    prevBody=visitor.ExprBody;
    visitor.ExprBody="";
    acceptVisitor(loopBody,visitor);


    forloopBody=visitor.ExprBody;
    forloopBody=strjoin("    "+splitlines(strip(forloopBody,'right')),'\n')+newline;
    forloopBody="for "+loopVarName+" = "+loopValuesStr+newline+...
    forloopBody+...
    "end"+newline;


    visitor.ExprBody=prevBody+forloopBody;

end

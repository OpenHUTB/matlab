





function booleanOp=determineMode(code)
    mtreeObj=mtree(code);
    matchingNodes=mtfind(mtreeObj,'Kind','CALL','Left.Fun','image',...
    'Right.Kind','CALL');
    booleanOp=matchingNodes.count>0;
end
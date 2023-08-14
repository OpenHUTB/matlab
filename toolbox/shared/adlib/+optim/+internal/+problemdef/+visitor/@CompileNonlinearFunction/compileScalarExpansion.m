function compileScalarExpansion(visitor,childIdx,thisNode,otherNode)







    if isscalar(thisNode)&&~isscalar(otherNode)
        sizeStr="["+strjoin(string(size(otherNode)))+"]";
        addParens=2;
        [varName,numParens]=getChildArgumentName(visitor,childIdx,addParens);
        funStr="repmat("+varName+", "+sizeStr+")";
        numParens=numParens+2;
        isArgOrVar=false;
        isAllZero=false;
        singleLine=true;
        push(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine);
    else
        [varName,numParens,isArgOrVar,isAllZero,singleLine]=...
        popChild(visitor,childIdx);
        push(visitor,varName,numParens,isArgOrVar,isAllZero,singleLine);
    end

end
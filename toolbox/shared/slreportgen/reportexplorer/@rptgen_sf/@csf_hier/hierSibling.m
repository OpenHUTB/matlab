function sibNodes=hierSibling(thisNode,parentNode,isLeft)







    sibNodes=find(parentNode,'-isa',class(thisNode));
    currIdx=find(sibNodes==thisNode);
    if isempty(currIdx)
        if isLeft
            sibNodes=[];
        else

        end
    else
        if isLeft
            sibNodes=sibNodes(1:currIdx-1);
        else
            sibNodes=sibNodes(currIdx+1:end);
        end
    end
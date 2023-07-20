function cycles=findSimpleGraphCycles(adjMatrix)
    import Simulink.Structure.Utils.*

    cycles={};
    nNodes=size(adjMatrix,1);
    marked=sparse(1,nNodes);
    markedStack=Stack();
    pointStack=Stack();
    for s=1:nNodes
        backTrack(s);
        while~isempty(markedStack)
            n=markedStack.pop();
            marked(n)=false;
        end
    end

    function f=backTrack(v)
        f=false;
        pointStack.push(v);
        marked(v)=true;
        markedStack.push(v);
        neighbors=find(adjMatrix(v,:));
        nNeighbors=length(neighbors);
        for nIdx=1:nNeighbors
            w=neighbors(nIdx);
            if w<s
                adjMatrix(v,w)=0;
            elseif w==s
                cycles{end+1}=cell2mat(pointStack.getElements());
                f=true;
            elseif~marked(w)
                f=backTrack(w)||f;
            end
        end
        if f
            while markedStack.top()~=v
                u=markedStack.pop();
                marked(u)=false;
            end
            markedStack.pop();
            marked(v)=false;
        end
        pointStack.pop();
    end
end

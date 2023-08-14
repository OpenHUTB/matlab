function labelnode(hObj,nodes,labels)




















    import matlab.internal.datatypes.isCharStrings

    nnodes=numnodes(hObj.BasicGraph_);
    if isCharStrings(nodes)||isstring(nodes)
        if isempty(hObj.NodeNames_)
            error(message('MATLAB:graphfun:plot:NoNodeNames'));
        end
        nodes=cellstr(nodes);
        if~isempty(nodes)&&~isvector(nodes)
            error(message('MATLAB:graphfun:plot:NodesInvalidSize'));
        end
        nodes=convertToIndex(nodes(:),hObj.NodeNames_);
    else
        if isnumeric(nodes)
            if~isempty(nodes)&&~(isvector(nodes)&&all(floor(nodes)==nodes)...
                &&all(nodes>=1&nodes<=nnodes)&&isreal(nodes))
                error(message('MATLAB:graphfun:plot:NodesInvalidSize'));
            end
        elseif islogical(nodes)
            if isvector(nodes)&&length(nodes)==nnodes
                nodes=find(nodes);
            else
                error(message('MATLAB:graphfun:plot:NodesInvalidSize'));
            end
        else
            error(message('MATLAB:graphfun:plot:NodesInvalidSize'));
        end
    end

    if~(isCharStrings(labels)||isstring(labels)||isnumeric(labels))
        error(message('MATLAB:graphfun:plot:InvalidLabels'));
    end

    if~ischar(labels)
        if~isempty(labels)&&~isvector(labels)
            error(message('MATLAB:graphfun:plot:InvalidLabels'));
        elseif~isscalar(labels)&&length(labels)~=length(nodes)
            error(message('MATLAB:graphfun:plot:NodeLabelsInvalidSize'));
        end

        if isnumeric(labels)
            labels=hObj.num2labels(labels);
        end
    end

    if isempty(hObj.NodeLabel)
        hObj.NodeLabel_I=repmat({''},1,nnodes);
    end
    hObj.NodeLabel(nodes)=cellstr(labels);
end

function sInd=convertToIndex(s,Names)
    [isThere,sInd]=ismember(s,Names);
    if~all(isThere)
        badNodes=s(~isThere);
        error(message('MATLAB:graphfun:plot:UnknownNodeName',badNodes{1}));
    end
end
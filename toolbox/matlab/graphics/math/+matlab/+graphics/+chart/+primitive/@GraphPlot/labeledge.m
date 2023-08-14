function labeledge(hObj,s,t,labels)

































    import matlab.internal.datatypes.isCharStrings

    nedges=numedges(hObj.BasicGraph_);
    if nargin>3
        if(~isvector(s)&&~isempty(s))||(~isvector(t)&&~isempty(t))
            error(message('MATLAB:graphfun:plot:InvalidSTSize'));
        end

        if(isCharStrings(s)||isstring(s))&&(isCharStrings(t)||isstring(t))

            if isempty(hObj.NodeNames_)
                error(message('MATLAB:graphfun:plot:NoNodeNames'));
            end
            s=cellstr(s);
            t=cellstr(t);
            s=convertToIndex(s(:),hObj.NodeNames_);
            t=convertToIndex(t(:),hObj.NodeNames_);
        end
        if~(isnumeric(s)&&isnumeric(t))
            error(message('MATLAB:graphfun:plot:InvalidST'));
        end
        [edges,m]=findedge(hObj.BasicGraph_,s,t);
        numEdges=max(max(m),0);
        if~all(edges~=0)
            error(message('MATLAB:graphfun:plot:InvalidEdges'));
        end
    else
        if isnumeric(s)
            if~isempty(s)&&~(isvector(s)&&all(floor(s)==s)...
                &&all(s>=1&s<=nedges)&&isreal(s))
                error(message('MATLAB:graphfun:plot:LabeledgeInvalidEdgeIndices'));
            end
        elseif islogical(s)
            if isvector(s)&&length(s)==nedges
                s=find(s);
            else
                error(message('MATLAB:graphfun:plot:LabeledgeInvalidEdgeIndices'));
            end
        else
            error(message('MATLAB:graphfun:plot:LabeledgeInvalidEdgeIndices'));
        end
        s=s(:);
        labels=t;
        edges=s;
        numEdges=length(s);
    end

    if~(isCharStrings(labels)||isnumeric(labels)||isstring(labels))
        error(message('MATLAB:graphfun:plot:InvalidLabels'));
    end
    if ischar(labels)
        labels=cellstr(labels);
    else
        if~isempty(labels)&&~isvector(labels)
            error(message('MATLAB:graphfun:plot:InvalidLabels'));
        elseif~isscalar(labels)&&length(labels)~=numEdges
            error(message('MATLAB:graphfun:plot:EdgeLabelsInvalidSize'));
        end

        if isnumeric(labels)
            labels=hObj.num2labels(labels);
        end
    end



    if nargin>3&&~isscalar(labels)
        labels=labels(m);
    end

    if isempty(hObj.EdgeLabel)
        hObj.EdgeLabel_I=repmat({''},1,nedges);
    end
    hObj.EdgeLabel(edges)=cellstr(labels);
end

function sInd=convertToIndex(s,Names)
    [isThere,sInd]=ismember(s,Names);
    if~all(isThere)
        badNodes=s(~isThere);
        error(message('MATLAB:graphfun:plot:UnknownNodeName',badNodes{1}));
    end
end

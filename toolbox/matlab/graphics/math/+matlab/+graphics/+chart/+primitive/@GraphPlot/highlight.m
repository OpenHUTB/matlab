function highlight(hObj,varargin)
































































    import matlab.internal.datatypes.isCharStrings

    nnodes=numnodes(hObj.BasicGraph_);
    nedges=numedges(hObj.BasicGraph_);

    NVpairs={'Edges','NodeColor','MarkerSize','Marker',...
    'EdgeColor','LineWidth','LineStyle','ArrowSize','ArrowPosition',...
    'NodeLabelColor','NodeFontSize','NodeFontAngle','NodeFontWeight',...
    'EdgeLabelColor','EdgeFontSize','EdgeFontAngle','EdgeFontWeight'};



    if isempty(varargin)||isNVpair(varargin{1},NVpairs,hObj.NodeNames_)
        nrPos=0;
    elseif length(varargin)==1||isNVpair(varargin{2},NVpairs,hObj.NodeNames_)
        nrPos=1;
    else
        nrPos=2;
    end


    nodes='unset';
    edges='unset';

    if nrPos==0

    elseif nrPos==2
        s=varargin{1};
        t=varargin{2};
        edges=checkEdgesNodePair(s,t,hObj);
    else
        posArg=varargin{1};
        if isa(posArg,'graph')
            if hObj.IsDirected_
                error(message('MATLAB:graphfun:plot:HighlightUndirectedSubgraph'));
            end

            sg=posArg;
            edges=checkSubgraph(sg,hObj);
            nodes=find(degree(sg)>0);
        elseif isa(posArg,'digraph')

            sg=posArg;
            edges=checkSubgraph(sg,hObj);
            nodes=find(indegree(sg)>0|outdegree(sg)>0);
        else
            nodes=checkNodes(posArg,hObj);
        end
    end




    defaultHighlighting=true;

    for i=nrPos+1:2:length(varargin)

        name=validatestring(varargin{i},NVpairs);
        varargin{i}=name;
        if length(varargin)<i+1
            error(message('MATLAB:graphfun:plot:ArgNameValueMismatch'));
        end
        value=varargin{i+1};
        if strcmp(name,'Edges')
            if~strcmp(edges,'unset')
                error(message('MATLAB:graphfun:plot:DuplicateEdgeArgs'));
            end
            if isnumeric(value)&&isreal(value)&&...
                all(floor(value)==value)&&all(value>=1)&&all(value<=nedges)
                edges=value;
            elseif islogical(value)&&isvector(value)&&length(value)==nedges
                edges=find(value);
            else
                error(message('MATLAB:graphfun:plot:HighlightInvalidEdgeIndices'));
            end
        else
            defaultHighlighting=false;
        end
    end


    if strcmp(nodes,'unset')&&strcmp(edges,'unset')
        error(message('MATLAB:graphfun:plot:HighlightNoSelection'));
    end

    if defaultHighlighting

        if~isempty(nodes)&&~strcmp(nodes,'unset')
            markersize=hObj.MarkerSize;
            if isscalar(markersize)
                markersize=repmat(markersize,1,nnodes);
            end
            oldmarkersize=markersize(nodes);
            markersize(nodes)=oldmarkersize*2;
            hObj.MarkerSize=markersize;
        end
        if~isempty(edges)&&~strcmp(edges,'unset')
            linewidth=hObj.LineWidth;
            if isscalar(linewidth)
                linewidth=repmat(linewidth,1,nedges);
            end
            oldlinewidth=linewidth(edges);
            linewidth(edges)=oldlinewidth+2;
            hObj.LineWidth=linewidth;
            if hObj.IsDirected_
                arrowsize=hObj.ArrowSize;
                if isscalar(arrowsize)
                    arrowsize=repmat(arrowsize,1,nedges);
                end
                oldarrowsize=arrowsize(edges);
                arrowsize(edges)=oldarrowsize+7;
                hObj.ArrowSize=arrowsize;
            end
        end
    else
        if strcmp(nodes,'unset')


            ed=hObj.BasicGraph_.Edges(edges,:);
            nodes=unique(ed(:));
        end
        if strcmp(edges,'unset')


            edges=findedge(hObj.BasicGraph_,nodes(1:end-1),nodes(2:end));
            edges(edges==0)=[];
        end

        for i=nrPos+1:2:length(varargin)


            value=varargin{i+1};
            switch varargin{i}
            case 'NodeColor'
                if~isempty(nodes)
                    value=validateColor(value);
                    if isempty(value)
                        error(message('MATLAB:graphfun:plot:HighlightNodeColor'));
                    elseif strcmp(value,'none')
                        error(message('MATLAB:graphfun:plot:HighlightNoneNodeColor'));
                    end
                    if strcmp(hObj.NodeColor,'flat')
                        error(message('MATLAB:graphfun:plot:HighlightNodeColorDisabledFlat'));
                    elseif strcmp(hObj.NodeColor,'none')
                        error(message('MATLAB:graphfun:plot:HighlightNodeColorDisabledNone'));
                    elseif isrow(hObj.NodeColor)
                        hObj.NodeColor=repmat(hObj.NodeColor,nnodes,1);
                    end
                    hObj.NodeColor(nodes,:)=repmat(value,length(nodes),1);
                end
            case 'EdgeColor'
                if~isempty(edges)
                    value=validateColor(value);
                    if isempty(value)
                        error(message('MATLAB:graphfun:plot:HighlightEdgeColor'));
                    elseif strcmp(value,'none')
                        error(message('MATLAB:graphfun:plot:HighlightNoneEdgeColor'));
                    end
                    if strcmp(hObj.EdgeColor,'flat')
                        error(message('MATLAB:graphfun:plot:HighlightEdgeColorDisabledFlat'));
                    elseif strcmp(hObj.EdgeColor,'none')
                        error(message('MATLAB:graphfun:plot:HighlightEdgeColorDisabledNone'));
                    elseif isrow(hObj.EdgeColor)
                        hObj.EdgeColor=repmat(hObj.EdgeColor,nedges,1);
                    end
                    hObj.EdgeColor(edges,:)=repmat(value,length(edges),1);
                end
            case 'MarkerSize'
                if~isempty(nodes)
                    if~isscalar(value)||~isnumeric(value)
                        error(message('MATLAB:graphfun:plot:HighlightScalarNumber','MarkerSize'));
                    end

                    markersize=hObj.MarkerSize;
                    if isscalar(markersize)
                        markersize=repmat(markersize,1,nnodes);
                    end
                    markersize(nodes)=value;
                    hObj.MarkerSize=markersize;
                end
            case 'LineWidth'
                if~isempty(edges)
                    if~isscalar(value)||~isnumeric(value)
                        error(message('MATLAB:graphfun:plot:HighlightScalarNumber','LineWidth'));
                    end
                    linewidth=hObj.LineWidth;
                    if isscalar(linewidth)
                        linewidth=repmat(linewidth,1,nedges);
                    end
                    linewidth(edges)=value;
                    hObj.LineWidth=linewidth;
                end
            case 'Marker'
                if~isempty(nodes)
                    if(~isCharStrings(value)&&~isstring(value))||(iscell(value)&&~isscalar(value))
                        error(message('MATLAB:graphfun:plot:HighlightNonCharMarker'));
                    end
                    marker=hObj.Marker;
                    if ischar(marker)
                        marker=repmat({marker},1,nnodes);
                    end
                    marker(nodes)=repmat(cellstr(value),1,numel(nodes));
                    hObj.Marker=marker;
                end
            case 'LineStyle'
                if~isempty(edges)
                    if(~isCharStrings(value)&&~isstring(value))||...
                        (~ischar(value)&&~isscalar(value))
                        error(message('MATLAB:graphfun:plot:HighlightNonCharLineStyle'));
                    end
                    linestyle=hObj.LineStyle;
                    if ischar(linestyle)
                        linestyle=repmat({linestyle},1,nedges);
                    end
                    linestyle(edges)=repmat(cellstr(value),1,numel(edges));
                    hObj.LineStyle=linestyle;
                end
            case 'NodeLabelColor'
                if~isempty(nodes)
                    value=validateColor(value);
                    if isempty(value)||~isnumeric(value)
                        error(message('MATLAB:graphfun:plot:HighlightNodeLabelColor'));
                    end
                    if isrow(hObj.NodeLabelColor)
                        hObj.NodeLabelColor=repmat(hObj.NodeLabelColor,nnodes,1);
                    end
                    hObj.NodeLabelColor(nodes,:)=repmat(value,length(nodes),1);
                end
            case 'NodeFontSize'
                if~isempty(nodes)
                    if~isscalar(value)||~isnumeric(value)
                        error(message('MATLAB:graphfun:plot:HighlightScalarNumber','NodeFontSize'));
                    end
                    fontsize=hObj.NodeFontSize;
                    if isscalar(fontsize)
                        fontsize=repmat(fontsize,1,nnodes);
                    end
                    fontsize(nodes)=value;
                    hObj.NodeFontSize=fontsize;
                end
            case 'NodeFontAngle'
                if~isempty(nodes)
                    value=validatestring(value,{'normal','italic'},class(hObj),'NodeFontAngle');
                    fontangle=hObj.NodeFontAngle;
                    if ischar(fontangle)
                        fontangle=repmat({fontangle},1,nnodes);
                    end
                    fontangle(nodes)={value};
                    hObj.NodeFontAngle=fontangle;
                end
            case 'NodeFontWeight'
                if~isempty(nodes)
                    value=validatestring(value,{'normal','bold'},class(hObj),'NodeFontWeight');
                    fontweight=hObj.NodeFontWeight;
                    if ischar(fontweight)
                        fontweight=repmat({fontweight},1,nnodes);
                    end
                    fontweight(nodes)={value};
                    hObj.NodeFontWeight=fontweight;
                end
            case 'EdgeLabelColor'
                if~isempty(edges)
                    value=validateColor(value);
                    if isempty(value)||~isnumeric(value)
                        error(message('MATLAB:graphfun:plot:HighlightEdgeLabelColor'));
                    end
                    if isrow(hObj.EdgeLabelColor)
                        hObj.EdgeLabelColor=repmat(hObj.EdgeLabelColor,nedges,1);
                    end
                    hObj.EdgeLabelColor(edges,:)=repmat(value,length(edges),1);
                end
            case 'EdgeFontSize'
                if~isempty(edges)
                    if~isscalar(value)||~isnumeric(value)
                        error(message('MATLAB:graphfun:plot:HighlightScalarNumber','EdgeFontSize'));
                    end
                    fontsize=hObj.EdgeFontSize;
                    if isscalar(fontsize)
                        fontsize=repmat(fontsize,1,nedges);
                    end
                    fontsize(edges)=value;
                    hObj.EdgeFontSize=fontsize;
                end
            case 'EdgeFontAngle'
                if~isempty(edges)
                    value=validatestring(value,{'normal','italic'},class(hObj),'EdgeFontAngle');
                    fontangle=hObj.EdgeFontAngle;
                    if ischar(fontangle)
                        fontangle=repmat({fontangle},1,nedges);
                    end
                    fontangle(edges)={value};
                    hObj.EdgeFontAngle=fontangle;
                end
            case 'EdgeFontWeight'
                if~isempty(edges)
                    value=validatestring(value,{'normal','bold'},class(hObj),'EdgeFontWeight');
                    fontweight=hObj.EdgeFontWeight;
                    if ischar(fontweight)
                        fontweight=repmat({fontweight},1,nedges);
                    end
                    fontweight(edges)={value};
                    hObj.EdgeFontWeight=fontweight;
                end
            case 'ArrowSize'
                if~isempty(edges)
                    if~isscalar(value)||~isnumeric(value)
                        error(message('MATLAB:graphfun:plot:HighlightScalarNumber','ArrowSize'));
                    end
                    arrowsize=hObj.ArrowSize;
                    if isscalar(arrowsize)
                        arrowsize=repmat(arrowsize,1,nedges);
                    end
                    arrowsize(edges)=value;
                    hObj.ArrowSize=arrowsize;
                end
            case 'ArrowPosition'
                if~isempty(edges)
                    if~isscalar(value)||~isnumeric(value)
                        error(message('MATLAB:graphfun:plot:HighlightScalarNumber','ArrowPosition'));
                    end
                    arrowposition=hObj.ArrowPosition;
                    if isscalar(arrowposition)
                        arrowposition=repmat(arrowposition,1,nedges);
                    end
                    arrowposition(edges)=value;
                    hObj.ArrowPosition=arrowposition;
                end
            end
        end
    end
end


function tf=isNVpair(arg,NVpairs,nodeNames)

    if~((ischar(arg)&&isrow(arg))||(isstring(arg)&&isscalar(arg)))

        tf=false;
    elseif ismember(arg,NVpairs)

        tf=true;
    elseif ismember(arg,nodeNames)

        tf=false;
    elseif partialMatch(arg,NVpairs)

        tf=true;
    else


        tf=false;
    end
end

function tf=partialMatch(name,candidates)
    len=max(strlength(name),1);
    tf=any(strncmpi(name,candidates,len));
end

function nodes=checkNodes(nodes,hObj)
    import matlab.internal.datatypes.isCharStrings

    nodeNames=hObj.NodeNames_;
    nnodes=numnodes(hObj.BasicGraph_);

    if~isvector(nodes)&&~isempty(nodes)
        error(message('MATLAB:graphfun:plot:NodesInvalidSize'));
    end
    if isCharStrings(nodes)||isstring(nodes)
        [lia,locb]=ismember(nodes,nodeNames);
        if~all(lia)
            error(message('MATLAB:graphfun:plot:InvalidNodeNames'));
        end
        nodes=locb;
    else
        if islogical(nodes)
            if~isvector(nodes)||length(nodes)~=nnodes
                error(message('MATLAB:graphfun:plot:NodesInvalidSize'));
            end
            nodes=find(nodes);
        elseif~(isnumeric(nodes)&&isreal(nodes)&&...
            all(floor(nodes)==nodes)&&all(nodes>=1)&&all(nodes<=nnodes))
            error(message('MATLAB:graphfun:plot:NodesInvalidSize'));
        end
    end
end

function edges=checkEdgesNodePair(s,t,hObj)
    import matlab.internal.datatypes.isCharStrings

    nnodes=numnodes(hObj.BasicGraph_);
    if(~isvector(s)&&~isempty(s))||(~isvector(t)&&~isempty(t))
        error(message('MATLAB:graphfun:plot:InvalidSTSize'));
    end
    if isnumeric(s)&&isnumeric(t)
        validateattributes(s,{'numeric'},{'integer',...
        'positive','<=',nnodes});
        validateattributes(t,{'numeric'},{'integer',...
        'positive','<=',nnodes});
        if~(length(s)==length(t)||isscalar(s)||isscalar(t))
            error(message('MATLAB:graphfun:plot:InvalidSTSize'));
        end
    elseif(isCharStrings(s)||isstring(s))&&(isCharStrings(t)||isstring(t))
        s=cellstr(s);
        t=cellstr(t);
        [liat,s]=ismember(s(:),hObj.NodeNames_);
        [liah,t]=ismember(t(:),hObj.NodeNames_);

        if~all(liat)||~all(liah)
            error(message('MATLAB:graphfun:plot:InvalidNodeNames'));
        end
        if~(length(s)==length(t)||isscalar(s)||isscalar(t))
            error(message('MATLAB:graphfun:plot:InvalidSTSize'));
        end
    else
        error(message('MATLAB:graphfun:plot:InvalidST'));
    end

    edges=findedge(hObj.BasicGraph_,s,t);
    if~all(edges)
        error(message('MATLAB:graphfun:plot:InvalidEdges'));
    end
end

function edges=checkSubgraph(sg,hObj)
    [s,t]=findedge(sg);
    edges=findedge(hObj.BasicGraph_,s,t);
    if~all(edges)||numnodes(hObj.BasicGraph_)~=numnodes(sg)
        error(message('MATLAB:graphfun:plot:HighlightInvalidSubgraph'));
    end
end

function col=validateColor(col)
    if isnumeric(col)
        if~isequal(size(col),[1,3])||~(all(col<=1)&&all(col>=0))
            col=[];
        end
    elseif(ischar(col)&&isrow(col))||(isstring(col)&&isscalar(col))
        try


            col=hgcastvalue('matlab.graphics.datatype.RGBAColor',col);
        catch
            col=[];
        end
    else
        col=[];
    end
end
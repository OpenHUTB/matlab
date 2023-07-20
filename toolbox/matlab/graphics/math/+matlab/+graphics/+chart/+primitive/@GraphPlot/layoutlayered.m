function layoutlayered(hObj,varargin)








































    nvarargin=length(varargin);
    if rem(nvarargin,2)~=0
        error(message('MATLAB:graphfun:plot:ArgNameValueMismatch'));
    end

    direction='down';
    sources=[];
    sinks=[];
    asgnLay='auto';

    layoutparams=varargin;
    for i=1:2:nvarargin
        name=validatestring(varargin{i},{'Direction','Sources','Sinks','AssignLayers'});
        layoutparams{i}=name;
        value=varargin{i+1};
        switch name
        case 'Direction'
            direction=validatestring(value,{'up','down','left','right'});
            layoutparams{i+1}=direction;
        case 'AssignLayers'
            asgnLay=validatestring(value,{'asap','alap','auto'});
            layoutparams{i+1}=asgnLay;
        case 'Sources'
            sources=validateNodeID(hObj.BasicGraph_,hObj.NodeNames_,value);
            if isempty(sources)||numel(sources)~=numel(unique(sources))
                error(message('MATLAB:graphfun:plot:InvalidSources'));
            end
        case 'Sinks'
            sinks=validateNodeID(hObj.BasicGraph_,hObj.NodeNames_,value);
            if isempty(sinks)||numel(sinks)~=numel(unique(sinks))
                error(message('MATLAB:graphfun:plot:InvalidSinks'));
            end
        end
    end


    [gs,edgeind]=matlab.internal.graph.simplify(hObj.BasicGraph_);
    edgemult=accumarray(edgeind,1);

    [nodeCoords,edgeCoords]=layeredLayout(gs,sources,sinks,asgnLay,edgemult);


    checkOutputs(hObj,nodeCoords,edgeCoords);

    ee=numedges(hObj.BasicGraph_);
    blockSizes=cellfun('size',edgeCoords,1);
    edgeCoords=cell2mat(edgeCoords);
    edgeCoords=reshape(edgeCoords,[],2);
    edgeCoordsIndex=repelem((1:ee)',blockSizes);
    edgeCoordsIndex=edgeCoordsIndex(:);

    switch direction
    case 'up'
        maxY=max([nodeCoords(:,2);edgeCoords(:,2)]);
        nodeCoords(:,2)=maxY-nodeCoords(:,2)+1;
        edgeCoords(:,2)=maxY-edgeCoords(:,2)+1;
    case 'left'
        nodeCoords=nodeCoords(:,[2,1]);
        edgeCoords=edgeCoords(:,[2,1]);
    case 'right'
        nodeCoords=nodeCoords(:,[2,1]);
        edgeCoords=edgeCoords(:,[2,1]);
        maxX=max([nodeCoords(:,1);edgeCoords(:,1)]);
        nodeCoords(:,1)=maxX-nodeCoords(:,1)+1;
        edgeCoords(:,1)=maxX-edgeCoords(:,1)+1;
    end



    hObj.Layout_='layered';
    hObj.LayoutParameters_=layoutparams;

    hObj.XData_I=nodeCoords(:,1).';
    hObj.YData_I=nodeCoords(:,2).';
    hObj.EdgeCoords_=[edgeCoords,zeros(size(edgeCoords,1),1)];
    hObj.EdgeCoordsIndex_=edgeCoordsIndex;
    hObj.MarkDirty('all');
    hObj.sendDataChangedEvent();

    function src=validateNodeID(G,nodeNames,s)


        nrNodes=numnodes(G);

        if matlab.internal.datatypes.isCharStrings(s,false,false)||isstring(s)
            s=cellstr(s);
            if isempty(nodeNames)
                error(message('MATLAB:graphfun:findnode:NoNames'));
            end
            [~,src]=ismember(s(:),nodeNames);
        elseif isnumeric(s)
            s=s(:);
            if~isreal(s)||any(fix(s)~=s)||any(s<1)
                error(message('MATLAB:graphfun:findnode:PosInt'));
            end
            src=s;
            src(src>nrNodes)=0;
        else
            error(message('MATLAB:graphfun:findnode:ArgType'));
        end

        if any(src==0)
            if isnumeric(s)
                error(message('MATLAB:graphfun:graph:InvalidNodeID',nrNodes));
            else
                if iscellstr(s)
                    i=find(src==0,1);
                    s=s{i};
                end
                error(message('MATLAB:graphfun:graph:UnknownNodeName',s));
            end
        end


        function checkOutputs(hObj,nodeCoords,edgeCoords)

            ed=hObj.BasicGraph_.Edges;
            assert(all(cellfun(@(x)~isempty(x),edgeCoords)));
            edgeStartCoords=cell2mat(cellfun(@(x)x(1,:),edgeCoords,'UniformOutput',false));
            edgeEndCoords=cell2mat(cellfun(@(x)x(end,:),edgeCoords,'UniformOutput',false));
            edgeStartCoords=reshape(edgeStartCoords,[],2);
            edgeEndCoords=reshape(edgeEndCoords,[],2);
            sourceNodeCoords=[nodeCoords(ed(:,1),1),nodeCoords(ed(:,1),2)];
            targetNodeCoords=[nodeCoords(ed(:,2),1),nodeCoords(ed(:,2),2)];

            if isa(hObj.BasicGraph_,'matlab.internal.graph.MLGraph')

                ind=find(~all(abs(edgeStartCoords-sourceNodeCoords)<1e-6,2));
                swap=edgeStartCoords(ind,:);
                edgeStartCoords(ind,:)=edgeEndCoords(ind,:);
                edgeEndCoords(ind,:)=swap;
            end
            assert(all(all(abs(edgeStartCoords-sourceNodeCoords)<1e-6,2)))
            assert(all(all(abs(edgeEndCoords-targetNodeCoords)<1e-6,2)))

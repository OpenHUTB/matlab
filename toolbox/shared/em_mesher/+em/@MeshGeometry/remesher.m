function[p,e,t]=remesher(gd,dl,Hmax,Hgrad,Hmin,Htarget,Hfeed,feedsAndVias,feedtype)









































































































































































    p=gd;
    t=dl;
    warnflag=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');
    TR=triangulation(t(:,1:3),p);
    warning(warnflag);
    e=edges(TR);

    ptID=featureEdges(TR,pi/6);
    ptID=unique(ptID(:));
    fbp=TR.Points(ptID,:);


    hard_edges=[];
    feedvia_nodes=[];
    feedvia_metricmap=[];

    if isempty(feedvia_nodes)&&~isempty(feedsAndVias)
        for i=1:size(feedsAndVias,1)
            [D,IND]=em.internal.meshprinting.inter2_point_seg(p,e,feedsAndVias(i,:));
            tempIndex=find(D<sqrt(eps)&IND==-1);%#ok<AGROW>
            if~isempty(tempIndex)&&isscalar(tempIndex)
                index(i)=tempIndex;
            else
                closestEdgeId=find(D==min(D));
                index(i)=closestEdgeId(1);
            end
            if~isempty(index)
                feedvia_nodes=[feedvia_nodes,e(index(i),:)];%#ok<AGROW>
            end
        end
        hard_edges=e(index,:)';
        for i=1:numel(index)
            tempHardEdge=p(e(index(i),:),:);
            tempHardEdgeLength(i)=norm(tempHardEdge(1,:)-tempHardEdge(2,:));%#ok<AGROW>
        end
        numFeedViaNodes=numel(feedvia_nodes);
        if isequal(numel(tempHardEdgeLength),numFeedViaNodes)
            feedvia_metricmap=tempHardEdgeLength;
        elseif numel(tempHardEdgeLength)==numFeedViaNodes/2
            feedvia_metricmap=repmat(tempHardEdgeLength,2,1);
            feedvia_metricmap=feedvia_metricmap(:)';
        else
            feedvia_metricmap=min(tempHardEdgeLength).*ones(1,numFeedViaNodes);
        end
    end
    hard_nodes=dsearchn(p,fbp)';
    pIn=p';
    tIn=t';


    [p,t,~]=em.MeshGeometry.cm2_remesher(pIn,tIn,Hmax,Hgrad,Hmin,...
    hard_nodes,feedvia_nodes,...
    Htarget,feedvia_metricmap,...
    hard_edges);




end

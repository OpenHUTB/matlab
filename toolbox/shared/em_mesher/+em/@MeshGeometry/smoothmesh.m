function[ps,ts]=smoothmesh(pm,numiterations,maxtriq,deltriq,order,varargin)




















    P=pm(:,order(1));
    Q=pm(:,order(2));
    R=pm(:,order(3));

    p=[P,Q];

    Dt1=delaunayTriangulation(p);








    if~isempty(varargin)
        hull1=varargin{1};
    else
        hull1=convhull(P(:),Q(:));
    end


    allNodes=1:max(size(Dt1.Points));
    nonBoundaryNodes=allNodes(~ismember(allNodes,hull1));
    numNonBoundaryNodes=max(size(nonBoundaryNodes));


    seed=42;
    rng(seed);




    iterCount=numiterations;
    qavg_termination=maxtriq;
    qavg_change_termination=deltriq;
    qavghistory=zeros(1,iterCount);
    qavg=0.1;
    change_in_qavg=1;
    count=1;
    while(qavg<qavg_termination)&&(count<iterCount)&&abs((change_in_qavg))>qavg_change_termination
        for i=1:numNonBoundaryNodes
            currentNode=nonBoundaryNodes(i);
            CommonVertex=Dt1.Points(currentNode,:);
            triVertex=vertexAttachments(Dt1,currentNode);
            triVertex=triVertex{:};

            uniqueVertices=Dt1(triVertex,:);
            uniqueVertices=uniqueVertices(:);
            uniqueVertices=uniqueVertices(~ismember(uniqueVertices,currentNode));
            uniqueVertices=unique(uniqueVertices);
            UniqueVertices=Dt1.Points(uniqueVertices,:);

            [xSmooth,ySmooth]=em.MeshGeometry.laplacianSmoothing(UniqueVertices,CommonVertex,2);

            Dt1.Points(currentNode,:)=[xSmooth,ySmooth];
        end
        p=Dt1.Points;
        t=Dt1.ConnectivityList;
        [~,~,qavg]=em.internal.meshQualityCheck(p,t);

        qavghistory(count)=qavg;
        Dt1=delaunayTriangulation(p);
        count=count+1;
        if count>=3
            change_in_qavg=diff([qavghistory(count-2),qavghistory(count-1)]);
        end
    end


    ptemp=zeros(max(size(p)),3);
    ptemp(:,order(1))=p(:,1);
    ptemp(:,order(2))=p(:,2);
    ptemp(:,order(3))=R;
    ps=ptemp;
    ts=t;
end
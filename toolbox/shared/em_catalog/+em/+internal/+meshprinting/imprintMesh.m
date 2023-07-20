function M=imprintMesh(P1,t1,P2,t2)

    PGp=P2;
    tGp=t2;
    PRad=P1;
    tRad=t1;
    P1=P1(:,1:2);
    PatchNodes=size(P1,1);

    P2=P2(:,1:2);
    warnflag1=warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
    warnflag2=warning('off','MATLAB:polyfun:ProblemInBoundary');
    TR1=triangulation(t1(:,1:3),P1);
    TR2=triangulation(t2(:,1:3),P2);
    t1contour=boundaryshape(TR1);
    t2contour=boundaryshape(TR2);
    warning(warnflag2);
    warning(warnflag1);





































    IN=zeros(size(P2,1),1);
    for m=1:size(t1,1)
        xv=P1(t1(m,:),1);
        xv(end+1)=xv(1);
        yv=P1(t1(m,:),2);
        yv(end+1)=yv(1);
        [INtemp,~]=inpolygon(P2(:,1),P2(:,2),xv,yv);
        IN=IN+INtemp;
    end
    P2(IN>0,:)=[];


    out_close=em.internal.meshprinting.findPointsNearContour(t1contour.Vertices,P2,1e-12);
    P2(out_close,:)=[];


    edges=em.internal.meshprinting.meshconnee(t1);



    hole_edges=[];
    if t2contour.NumHoles>0
        h=holes(t2contour);
        for holenum=1:t2contour.NumHoles
            hverts=h(holenum).Vertices;
            id=dsearchn(P2,hverts);
            ff=triangulation(h(holenum));
            ee=ff.edges;
            te=[id(ee(:,1)),id(ee(:,2))];
            hole_edges=[hole_edges;te(isConnected(TR2,te),:)];
        end
        hole_edges=hole_edges+size(P1,1);
    end


    edges=[edges;hole_edges];


    P=[P1;P2];


    dt=delaunayTriangulation(P,edges);
    t=dt.ConnectivityList;

    P(:,3)=0;

    holeID=[];
    trcenters=incenter(dt);

    if t2contour.NumHoles>0
        for holenum=1:t2contour.NumHoles
            holeID=[holeID;find(isinterior(h(holenum),trcenters))];
        end
    end

    outerEdgeID=find(~isinterior(t2contour,trcenters));
    holeID=union(holeID,outerEdgeID);
    Pidhole=t(holeID,:);
    Pidhole=unique(Pidhole(:));
    t(holeID,:)=[];


    A=em.internal.meshprinting.meshareas(P,t);

    Epsilon=1e-12;
    id=A<Epsilon;
    Pid=t(id,:);
    Pid=unique(Pid(:));
    t(id,:)=[];


    [BorderTriangles,BorderEdges,BorderNodes]=em.internal.meshprinting.meshborder(t);%#ok<ASGLU>
    nodes=setdiff([1:size(P,1)],BorderNodes);


    nodes=intersect([size(P1,1)+1:size(P,1)],nodes);


    nodes=setdiff(nodes,unique([Pid;Pidhole]));

    iter=1;
    for m=1:iter
        P=em.internal.meshprinting.meshlaplace(P,t,nodes,3,0.5);
    end


    C=em.internal.meshprinting.meshtricenter(P,t);
    IN=zeros(size(C,1),1);
    for m=1:size(t1,1)
        xv=P1(t1(m,:),1);
        xv(end+1)=xv(1);
        yv=P1(t1(m,:),2);
        yv(end+1)=yv(1);
        IN=IN+inpolygon(C(:,1),C(:,2),xv,yv);
    end
    patchtri=find(IN>0);
    nonpatchtri=setdiff([1:size(t,1)],patchtri);


    t=[t(patchtri,:);t(nonpatchtri,:)];
    PatchTriangles=length(patchtri);


    M.P=P;
    M.t=t;
    M.PatchTriangles=PatchTriangles;
    M.PatchNodes=PatchNodes;
    M.PGp=PGp;
    M.tGP=t2;
    M.PRad=PRad;
    M.tRad=t1;
end

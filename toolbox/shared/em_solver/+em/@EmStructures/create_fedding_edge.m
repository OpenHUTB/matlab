function metalbasis=create_fedding_edge(p,t,metalbasis,...
    TrianglesTotal,NumJoints,ismatlab)



    EdgesTotal=size(metalbasis.Edges,2);

    Number1=TrianglesTotal/2-NumJoints+1:1:TrianglesTotal/2;
    Number2=TrianglesTotal-NumJoints+1:1:TrianglesTotal;


    VerPTop=zeros(1,NumJoints);
    FeedEdge=zeros(2,NumJoints);
    for m=1:NumJoints
        Vertex=1;
        index0=t(Vertex,Number1(m));
        for n=2:3
            index=t(n,Number1(m));
            if p(3,index)>p(3,index0)
                Vertex=n;
            end
        end
        VerPTop(1,m)=Vertex;
        if Vertex==1,FeedEdge(:,m)=t([2,3],Number1(m));end
        if Vertex==2,FeedEdge(:,m)=t([1,3],Number1(m));end
        if Vertex==3,FeedEdge(:,m)=t([1,2],Number1(m));end
    end
    if ismatlab
        offset=0;
    else
        offset=1;
    end

    metalbasis.TrianglePlus=[metalbasis.TrianglePlus(1:EdgesTotal/2)...
    ,Number1-offset,metalbasis.TrianglePlus(EdgesTotal/2+1:EdgesTotal)];
    metalbasis.TriangleMinus=[metalbasis.TriangleMinus(1:EdgesTotal/2)...
    ,Number2-offset,metalbasis.TriangleMinus(EdgesTotal/2+1:EdgesTotal)];
    metalbasis.VerP=[metalbasis.VerP(1:EdgesTotal/2)...
    ,VerPTop-offset,metalbasis.VerP(EdgesTotal/2+1:EdgesTotal)];
    metalbasis.VerM=[metalbasis.VerM(1:EdgesTotal/2)...
    ,VerPTop-offset,metalbasis.VerM(EdgesTotal/2+1:EdgesTotal)];
    metalbasis.Edges=[metalbasis.Edges(:,1:EdgesTotal/2)...
    ,FeedEdge,metalbasis.Edges(:,EdgesTotal/2+1:EdgesTotal)];

end


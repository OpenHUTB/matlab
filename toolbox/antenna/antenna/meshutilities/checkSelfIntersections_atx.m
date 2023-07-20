function checkSelfIntersections_atx(g)





    nbs=pdeigeom_atx(g);
    d=pdeigeom_atx(g,1:nbs);
    NSEGPERCURVE=12;

    Xg=zeros(0,1);
    Yg=zeros(0,1);
    Cg=zeros(0,2);
    for i=1:nbs
        if(g(1,i)==2)
            params=[d(1,i),d(2,i)];
        else

            params=linspace(d(1,i),d(2,i),NSEGPERCURVE+1);
        end
        [x,y]=pdeigeom_atx(g,i,params);
        startn=numel(Xg)+1;
        endn=numel(Xg)+numel(x);
        c=[(startn:(endn-1))',(startn+1:endn)'];
        nump=numel(x);
        Xg(end+(1:nump))=x;
        Yg(end+(1:nump))=y;
        Cg(end+(1:nump-1),:)=c;
    end


    comptol=max(max(abs(Xg)),max(abs(Yg)));
    comptol=max(comptol,1)*eps*100;
    [~,I,IC]=uniquetol([Xg,Yg],comptol,'ByRows',true);
    ca=Cg(:,1);
    cb=Cg(:,2);
    Cg=[I(IC(ca)),I(IC(cb))];
    I=sort(I);
    ne=numel(I);
    mymap=containers.Map(I,1:ne);
    ne=numel(Cg);
    for i=1:ne
        Cg(i)=mymap(Cg(i));
    end
    P=[Xg(I),Yg(I)];


    numCpre=size(Cg,1);
    warnState(1)=warning('off','MATLAB:delaunayTriangulation:ConsSplitPtWarnId');
    warnState(2)=warning('off','MATLAB:delaunayTriangulation:ConsConsSplitWarnId');
    warnState(3)=warning('off','MATLAB:delaunayTriangulation:DupConsWarnId');
    warnState(4)=warning('off','MATLAB:delaunayTriangulation:LoopConsWarnId');
    warnState(5)=warning('off','MATLAB:delaunayTriangulation:DupPtsWarnId');
    warnState(6)=warning('off','MATLAB:delaunayTriangulation:DupPtsConsUpdatedWarnId');
    dt=delaunayTriangulation(P,Cg);
    warning(warnState);
    numCpost=size(dt.Constraints,1);
    if numCpre~=numCpost

        error(message('antenna:antennaerrors:BadGeomIntersectingEdgesFromInitMesh'));
    end
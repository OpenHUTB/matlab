function[Points,Tetrahedra]=cylindermesh(radius,H,NN)









    gd=[4,0,0,radius,radius,0,0,0,0,0,0]';
    hsize=H/NN;


    dl=decsg_atx(gd);
    pp=initmesh_atx(dl,'MesherVersion','R2013a','Hmax',hsize,'Hgrad',...
    1.75);
    p=pp';
    p(:,3)=-H/2;

    for m=1:NN
        Ps=pp';
        Ps(:,3)=-H/2+hsize*m;
        p=[p;Ps];%#ok<AGROW>
    end

    DT=delaunayTriangulation(p);

    Points=DT.Points;
    Tetrahedra=DT.ConnectivityList;

    if nargout==0
        figure;hold on;grid On;
        tetramesh(DT,'FaceColor',[0.1,0.7,0.5],'FaceAlpha',0.1);
        view(3);
    end
end
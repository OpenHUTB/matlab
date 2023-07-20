function fout=alignRefiningPolyWithBoardEdge(obj,f,loc,ftype)





    G=obj.Substrate.Geometry;


    if numel(G.Polygons)>1
        a=(size(G.Vertices,1))/(numel(G.Polygons));
        G.Vertices=G.Vertices(1:a,:);
        TR=triangulation(G.Polygons{1},G.Vertices);
    else
        TR=triangulation(G.Polygons{1},G.Vertices);
    end
    e=edges(TR);
    [D,IND]=em.internal.meshprinting.inter2_point_seg(TR.Points,e,loc);
    index=find(D<sqrt(eps)&IND==-1);
    if~isempty(index)
        edge_nodes=e(index,:);
    else
        if strcmpi(ftype,'feed')
            error('Unable to locate feed on edge of board');
        else
            error('Unable to locate via on edge of board');
        end
    end



    boardEdge=TR.Points(edge_nodes,:);
    d=boardEdge(2,:)-boardEdge(1,:);
    dx=d(1);
    dy=d(2);
    n1=[-dy,dx];
    n2=[dy,-dx];


    theta1=atan2(n1(2),n1(1))*180/pi;
    theta2=atan2(n2(2),n2(1))*180/pi;


    [cx,cy]=centroid(f);

    fout=rotate(f,theta1,[cx,cy,0],[cx,cy,1]);



end
function makeBoxGeometry(obj)



    L=obj.Length;
    W=obj.Width;
    T=obj.Thickness;





    numLayers=numel(T);
    thickness=cumsum(T);
    SubVertices=zeros(4+numLayers*4,3);
    SubPolygons=cell(numLayers,1);

    SubVertices(1:4,:)=[-L/2,-W/2,0;-L/2,W/2,0;L/2,W/2,0;L/2,-W/2,0];
    Poly=[1,2,3,4;5,6,7,8;1,5,6,2;4,8,7,3;1,5,8,4;2,6,7,3];
    for m=1:numLayers
        SubVertices(m*4+1:(m+1)*4,:)=[-L/2,-W/2,thickness(m);...
        -L/2,W/2,thickness(m);L/2,W/2,thickness(m);L/2,-W/2,thickness(m)];
        SubPolygons{m}=Poly+(m-1)*4;
    end

    Geometry.Vertices=SubVertices;
    Geometry.Polygons=SubPolygons;


    obj.Geometry=Geometry;

end

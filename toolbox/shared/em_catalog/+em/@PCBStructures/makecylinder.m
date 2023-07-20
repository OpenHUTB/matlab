function fv=makecylinder(r,h,n,tvec)

    if nargin==2
        n=20;
    elseif isempty(n)
        n=20;
    end
    [x,y,z]=cylinder(r,n);
    z=z.*h;
    fv=surf2patch(x,y,z);
    fv.BoundaryEdges=fv.faces;
    fv.faces=zeros(size(fv.vertices,1)-2,3);
    for m=1:size(fv.vertices)-2
        fv.faces(m,:)=[m,m+1,m+2];
    end


    fv.vertices=em.internal.translateshape(fv.vertices',tvec);
end
function[boundingbox,groups]=clipBoundingBoxIntersections(boundingbox,xlimits,ylimits)








    val=max(abs([xlimits,ylimits])).*10;


    boundingbox=cellfun(@(bb)Aero.internal.math.fillBoundingBoxLimits(bb,inf,[-val,val],[-val,val]),boundingbox,"UniformOutput",false);

    pgonvec=cellfun(@(bb)polyshape(bb,Simplify=false,SolidBoundaryOrientation="ccw"),boundingbox);
    pgonvec=simplify(pgonvec);


    pgon=pgonvec(1);
    for i=2:numel(pgonvec)
        tempgon=intersect(pgon,pgonvec(i));
        if~isempty(tempgon.Vertices)


            pgon=tempgon;
        end
    end


    boundingbox=pgon.Vertices;


    boundingbox=[boundingbox;boundingbox(1,:)];
    groups=ones(size(boundingbox,1),1);


    boundingbox=Aero.internal.math.fillBoundingBoxLimits(boundingbox,val,xlimits,ylimits);

end

function[Vertices,Faces,BoundaryEdges,BoundaryVertices]=...
    makeSubstrateGeometry(obj)





    SubstrateGeometry=show(obj.Substrate);

    Sx=0.9999;
    Sy=0.9999;
    Sz=0.9999;
    if isa(obj,'dipoleHelix')||(isprop(obj,'Element')&&isa(obj.Element,'dipoleHelix'))


        if isa(obj,'dipoleHelix')
            N=obj.Turns;S=obj.Spacing;
        else
            N=obj.Element.Turns;S=obj.Element.Spacing;
        end
        tv=[0,0,-0.5*N*S];


        SubstrateGeometry.Vertices=em.internal.translateshape(SubstrateGeometry.Vertices',tv)';
        SubstrateGeometry.BoundaryVertices=em.internal.translateshape(...
        SubstrateGeometry.BoundaryVertices',tv)';
    end
    if isprop(obj,'Element')&&isa(obj.Element,'dipoleHelix')


        SubstrateGeometry.Vertices=orientGeom(obj.Element,SubstrateGeometry.Vertices')';
        SubstrateGeometry.BoundaryVertices=orientGeom(obj.Element,SubstrateGeometry.BoundaryVertices')';
    end

    Vertices=em.MeshGeometry.scaleAxisVertices(Sx,Sy,Sz,SubstrateGeometry.Vertices')';
    if(isa(obj,'pcbStack')||isa(obj,'pcbComponent'))&&~strcmpi(obj.Substrate.Shape,'polyhedron')
        [xc,yc]=centroid(obj.BoardShape);
        Vertices=em.internal.translateshape(Vertices',[xc,yc,0])';
    end


    if isa(obj,'dipoleHelix')||(isprop(obj,'Element')&&isa(obj.Element,'dipoleHelix'))
        val=find(Vertices(:,3)==min(Vertices(:,3)));
        minval=min(Vertices(unique(SubstrateGeometry.Polygons{end}),3));
        maxval=max(Vertices(unique(SubstrateGeometry.Polygons{1}),3));


        Vertices(val,3)=minval+0.01*maxval;%#ok<FNDSB> 
    else
        val=find(Vertices(:,3)==0);
        maxval=max(Vertices(unique(SubstrateGeometry.Polygons{1}),3));
        Vertices(val,3)=0.01*maxval;%#ok<FNDSB>
    end


    maxval=max(Vertices(unique(SubstrateGeometry.Polygons{end}),3));
    minval=min(Vertices(unique(SubstrateGeometry.Polygons{end}),3));
    valmax=find(Vertices(:,3)==maxval);
    if isa(obj,'dipoleHelix')||(isprop(obj,'Element')&&isa(obj.Element,'dipoleHelix'))
        offset=0.01*(maxval);
    else
        offset=0.01*(maxval-minval);
    end
    Vertices(valmax,3)=maxval-offset;%#ok<FNDSB>



    Vertices=orientGeom(obj,Vertices')';
    Faces=SubstrateGeometry.Polygons;
    if isfield(SubstrateGeometry,'BoundaryEdges')
        BoundaryEdges=SubstrateGeometry.BoundaryEdges;
        BoundaryVertices=SubstrateGeometry.BoundaryVertices;
        if(isa(obj,'pcbStack')||isa(obj,'pcbComponent'))&&~strcmpi(obj.Substrate.Shape,'polyhedron')
            [xc,yc]=centroid(obj.BoardShape);
            BoundaryVertices=em.internal.translateshape(BoundaryVertices',...
            [xc,yc,0])';
        end
        BoundaryVertices=orientGeom(obj,BoundaryVertices')';
    else
        BoundaryEdges=[];
        BoundaryVertices=[];
    end



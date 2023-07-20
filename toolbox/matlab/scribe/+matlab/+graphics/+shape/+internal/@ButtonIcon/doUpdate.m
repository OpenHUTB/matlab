function doUpdate(obj,updateState)









    allFaces=obj.Faces;

    if size(allFaces,2)<3

        verts=zeros(3,0,'single');

    elseif size(allFaces,2)==3

        allFaces=allFaces.';
        verts=obj.Vertices(allFaces(:),:);

    else



        ws=warning('off','MATLAB:delaunayTriangulation:ConsConsSplitWarnId');
        wsRestore=onCleanup(@()warning(ws));
        allVerts=obj.Vertices;
        vertsCell=cell(size(allFaces,1),1);

        for n=1:numel(vertsCell)
            thisFace=allFaces(n,:);
            thisFace=thisFace(isfinite(thisFace));

            if numel(thisFace)<3


            elseif numel(thisFace)==3

                vertsCell{n}=allVerts(thisFace,:);

            else


                cons=[1:numel(thisFace);2:numel(thisFace),1].';
                dt=delaunayTriangulation(allVerts(thisFace,:),cons);

                points=dt.ConnectivityList;
                points=points.';
                points=points(:);
                vertsCell{n}=dt.Points(points,:);
            end
        end

        verts=cat(1,vertsCell{:});
    end

    iter=matlab.graphics.axis.dataspace.IndexPointsIterator('Vertices',verts);
    vis=obj.Visible;
    try
        vd=TransformPoints(updateState.DataSpace,updateState.TransformUnderDataSpace,iter);
    catch E
        vd=single([0;0;0]);


        vis='off';
    end

    obj.Face.VertexData=vd;
    obj.Face.Visible=vis;

    iter=matlab.graphics.axis.colorspace.IndexColorsIterator('Colors',obj.FaceColor);
    colordata=updateState.ColorSpace.TransformTrueColorToTrueColor(iter);
    obj.Face.ColorData=colordata.Data;
    obj.Face.ColorType=colordata.Type;
    obj.Face.ColorBinding='object';
end

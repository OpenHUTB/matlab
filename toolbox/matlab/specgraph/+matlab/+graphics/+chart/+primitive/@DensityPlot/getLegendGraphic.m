function graphic=getLegendGraphic(hObj)




    graphic=matlab.graphics.primitive.world.Group;

    face=matlab.graphics.primitive.world.Quadrilateral;

    face.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
    face.VertexIndices=[];
    face.StripData=[];

    ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes');
    if isempty(hObj.Data)

        hgfilter('RGBAColorToGeometryPrimitive',face,[1,1,1,1]);
    else
        face.ColorBinding_I='interpolated';
        face.ColorType_I='truecoloralpha';

        mind=min(hObj.Data);
        maxd=max(hObj.Data);
        ci=matlab.graphics.axis.colorspace.IndexColorsIterator;
        ci.Colors=[maxd;maxd;mind;mind];
        ci.CDataMapping='scaled';
        alphaMapped=strcmp(hObj.FaceAlpha,'interp');
        if alphaMapped
            ci.AlphaData=[maxd;maxd;mind;mind];
            ci.AlphaDataMapping='scaled';
        end

        cdata=TransformColormappedToTrueColor(ax.ColorSpace_I,ci);
        colorMapped=strcmp(hObj.FaceColor,'interp');
        if~colorMapped
            numElements=size(cdata.Data,2);
            cdata.Data(1:3,:)=hObj.FaceColor'*255*ones(1,numElements);
        end
        if~alphaMapped
            cdata.Data(4,:)=255*hObj.FaceAlpha;
        end
        face.ColorData_I=cdata.Data;
    end
    face.Parent=graphic;

    edge=matlab.graphics.primitive.world.LineLoop(...
    'LineJoin','round');

    edge.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
    edge.VertexIndices=[];
    edge.StripData=uint32([1,5]);
    edge.AlignVertexCenters='on';

    coloralpha=[0,0,0,1];
    hgfilter('RGBAColorToGeometryPrimitive',edge,coloralpha);
    edge.LineWidth=ax.LineWidth_I;
    edge.Parent=graphic;
end

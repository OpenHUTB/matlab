function graphic=getPolygonLegendIcon(polygon)



    graphic=matlab.graphics.primitive.world.Group;

    face=matlab.graphics.primitive.world.Quadrilateral;

    face.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
    face.VertexIndices=[];
    face.StripData=[];

    color=polygon.FaceColor;
    if(strcmp(color,'none'))
        face.Visible='off';
    else
        face.Visible='on';
        alpha=polygon.FaceAlpha;
        color(4)=alpha;
        hgfilter('RGBAColorToGeometryPrimitive',face,color);
        if alpha==1
            face.ColorType_I='truecolor';
        else
            face.ColorType_I='truecoloralpha';
        end
    end
    face.Parent=graphic;

    edge=matlab.graphics.primitive.world.LineLoop(...
    'LineJoin','round');

    edge.VertexData=face.VertexData;
    edge.VertexIndices=[];
    edge.StripData=uint32([1,5]);
    edge.AlignVertexCenters='on';

    color=polygon.EdgeColor;
    if(strcmp(color,'none'))
        edge.Visible='off';
    else
        edge.Visible='on';
        alpha=polygon.EdgeAlpha;
        color(4)=alpha;
        hgfilter('RGBAColorToGeometryPrimitive',edge,color);
        if alpha==1
            edge.ColorType_I='truecolor';
        else
            edge.ColorType_I='truecoloralpha';
        end
    end
    hgfilter('LineStyleToPrimLineStyle',edge,polygon.LineStyle);
    edge.LineWidth=polygon.LineWidth;
    edge.Parent=graphic;


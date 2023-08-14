function setupBoxEdge(hObj)













    hObj.BoxEdge.Description_I='Legend BoxEdge';
    hObj.BoxEdge.Internal=true;


    hObj.BoxEdge.Visible_I=hObj.Box_I;
    hObj.BoxEdge.LineWidth_I=hObj.LineWidth_I;
    hgfilter('RGBAColorToGeometryPrimitive',hObj.BoxEdge,hObj.EdgeColor);


    hObj.BoxEdge.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
    hObj.BoxEdge.StripData=uint32([1,5]);
    hObj.BoxEdge.Layer='front';
    hObj.BoxEdge.AlignVertexCenters='on';
    hObj.BoxEdge.LineJoin='miter';




    hObj.TitleSeparator.Description_I='Legend TitleSeparator';
    hObj.TitleSeparator.Internal=true;


    hObj.TitleSeparator.Visible_I=hObj.Box_I;
    hObj.TitleSeparator.LineWidth_I=hObj.LineWidth_I;
    hgfilter('RGBAColorToGeometryPrimitive',hObj.TitleSeparator,hObj.EdgeColor);


    hObj.TitleSeparator.VertexData=single([]);
    hObj.TitleSeparator.Layer='front';
    hObj.TitleSeparator.AlignVertexCenters='on';

end
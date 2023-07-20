function doUpdate(hObj,updateState)




    set(hObj.Text,'Color',hObj.Color);


    warnState=warning('off','MATLAB:gui:latexsup:UnableToInterpretTeXString');
    warnState(2)=warning('off','MATLAB:gui:latexsup:BadTeXString');

    updatePins(hObj,updateState);

    [hObj.Text.String_I,hObj.Position_I]=hObj.resizeText(updateState,hObj.String);
    warning(warnState);
    updateMarkers(hObj,updateState);

    pointsPos=updateState.convertUnits('camera','points',hObj.Units,hObj.Position);
    [textPos,vertAlign]=hObj.calculateTextPosition(pointsPos);
    hObj.Text.VerticalAlignment=vertAlign;
    pos=updateState.convertUnits('camera','normalized','points',textPos);
    hObj.Text.Units_I='data';
    hObj.Text.Position=[pos,0];


    localUpdatePrimitivePosition(hObj,updateState);




    id='MATLAB:hg:DiceyTransformMatrix';
    old_warn_state=warning('query',id);
    warning('off',id);


    tform=getTransformationMatrix(hObj,updateState);
    hObj.Transform.Matrix=tform;


    warning(old_warn_state.state,id);



    hObj.Text.Rotation=hObj.Rotation;


    function localUpdatePrimitivePosition(hObj,updateState)


        hIter=matlab.graphics.axis.dataspace.XYZPointsIterator;
        pos=hObj.NormalizedPosition;
        x=[pos(1),pos(1)+pos(3)];
        y=[pos(2),pos(2)+pos(4)];
        hIter.XData=[x(1),x(1),x(2),x(2)];
        hIter.YData=[y(1),y(2),y(2),y(1)];
        hIter.ZData=[0,0,0,0];
        vertexData=updateState.DataSpace.TransformPoints(updateState.TransformUnderDataSpace,hIter);
        hEdge=hObj.Edge;
        set(hEdge,'VertexData',vertexData);
        set(hEdge,'StripData',uint32([1,5]));
        set(hEdge,'LineJoin','miter');


        hF=hObj.Face;

        hF.PickableParts_I=hObj.PickableParts_I;
        hF.Visible_I=hObj.Visible_I;

        hF.VertexData=vertexData(:,[1,2,4,3]);
        hF.StripData=uint32([1,5]);

        im=hObj.Image;
        if~isempty(im)
            hF.ColorType_I='texturemapped';
            hF.ColorBinding_I='interpolated';
            hF.ColorData_I=single([1,0,1,0;0,0,1,1]);
            tex=matlab.graphics.primitive.world.Texture;

            hColorIter=matlab.graphics.axis.colorspace.IndexColorsIterator;
            hColorIter.Colors=im;
            s=size(im);
            if numel(s)>2

                colorData=updateState.ColorSpace.TransformTrueColorToTrueColor(hColorIter);
            else

                hColorIter.CDataMapping='direct';
                colorData=updateState.ColorSpace.TransformColormappedToTrueColor(hColorIter);
            end
            if~isempty(colorData)

                textureData=reshape(colorData.Data,4,s(1),s(2));

                textureData(4,:,:)=uint8(hObj.FaceAlpha*255);
                tex.CData=textureData;
            end
            set(hF,'Texture',tex);
        else

            hgfilter('RGBAColorToGeometryPrimitive',hF,hObj.BackgroundColor);
            set(hF,'Texture',[]);

            if isequal(hObj.BackgroundColor,'none')
                hF.ColorBinding_I='none';

                hF.PickableParts_I='all';
            else
                hF.ColorBinding_I='object';
                hF.ColorType_I='truecoloralpha';
                colorData=hF.ColorData_I;
                colorData(4,:)=uint8(hObj.FaceAlpha*255);
                hF.ColorData_I=colorData;
            end
        end


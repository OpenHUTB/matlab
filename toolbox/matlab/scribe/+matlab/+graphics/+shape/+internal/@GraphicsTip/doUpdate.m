function doUpdate(hObj,updateState)













    hObj.ScribeHost.Position=hObj.Position;
    hObj.ScribeHost.Visible=hObj.Visible;


    hText=hObj.Text;
    hText.VerticalAlignment='bottom';
    hText.HorizontalAlignment='left';



    alphaValue=hObj.BackgroundAlpha;

    alphaValue=min(max(alphaValue,0),1);
    faceColor=hObj.FaceColor;
    faceColor(4)=alphaValue;


    hRectangle=hObj.Rectangle;
    hRectangle.FaceColor=faceColor;
    hText.BackgroundColor_I='none';



    edgeColor=hObj.EdgeColor;
    if strcmpi(hObj.CurrentTip,'on')

        edgeColor=edgeColor-[.65,.65,.65];
        edgeColor=max(edgeColor,[0.35,.35,.35]);
    end


    hRectangle.Selected=hObj.Selected;
    hRectangle.SelectionHighlight=hObj.SelectionHighlight;


    hRectangle.EdgeColor=edgeColor;


    if strcmp(hObj.ParentLayer,'middle')
        hText.EdgeColor=edgeColor;
        hRectangle.Visible='off';
        hText.BackgroundColor_I=faceColor;
        hText.LineStyle='-';




        hText.Selected=hObj.Selected;
        hText.SelectionHighlight=hObj.SelectionHighlight;


        if strcmp(hText.Selected,'on')
            if~isprop(hText,'OneShotSelectionListener')
                p=addprop(hText,'OneShotSelectionListener');
                p.Transient=true;
                p.Hidden=true;
            end
            if isempty(hText.OneShotSelectionListener)
                hText.OneShotSelectionListener=event.listener(hText,'MarkedClean',@(~,~)localTextMarkedClean(hText));
            end
        end
    elseif hText.Selected



        hText.Selected=false;
    else
        hRectangle.Visible='on';
    end




    hText.Units='data';
    hFont=matlab.graphics.general.Font(...
    'Name',hText.FontName,...
    'Size',hText.FontSize,...
    'Weight',hText.FontWeight,...
    'Angle',hText.FontAngle);





    [textSize,formattedTextString,interpreter]=hObj.TextFormatHelper.getTextStringFormatting...
    (updateState,hFont,hText.String);
    hObj.String=formattedTextString;
    hObj.Interpreter=interpreter;


    markerSize=hObj.LocatorSize;
    markerOffset=markerSize/2;


    marginOffset=hText.Margin;




    rectOffset=1;
    totalOffset=marginOffset+rectOffset;

    if strcmp(hObj.OrientationMode,'auto')
        iter=matlab.graphics.axis.dataspace.XYZPointsIterator;
        iter.XData=hObj.Position(1);
        iter.YData=hObj.Position(2);
        iter.ZData=hObj.Position(3);

        try
            vd=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,iter);
        catch E
            vd=single([0;0;0]);
        end

        totalWidth=(2*marginOffset+markerOffset);
        hObj.Orientation_I=localFindBestOrientation(updateState,...
        double(vd),(textSize+totalWidth));
    end

    textPosition=localGetTextPosition(hObj.Orientation_I,totalOffset);

    localSetTextPosition(hObj,updateState,textPosition);

    localSetTextOrientation(hText,hObj.Orientation_I);



    hRectangle.Position=localGetRectanglePosition(hObj.Orientation_I,textSize,marginOffset,rectOffset);


    hRectangle.MarkDirty('all');


    function recPos=localGetRectanglePosition(orientation,textSize,margin,rectOffset)


        rectWidth=textSize(1)+(margin*2);
        rectHeight=textSize(2)+(margin*2);

        switch orientation
        case 'topleft'
            recPos=[-rectOffset-rectWidth,rectOffset,rectWidth,rectHeight];
        case 'topright'
            recPos=[rectOffset,rectOffset,rectWidth,rectHeight];
        case 'bottomleft'
            recPos=[-rectOffset-rectWidth,-rectOffset-rectHeight,rectWidth,rectHeight];
        case 'bottomright'
            recPos=[rectOffset,-rectOffset-rectHeight,rectWidth,rectHeight];
        end

        function pos=localGetTextPosition(orientation,offset)


            switch orientation
            case 'topleft'
                pos=[-offset,offset,0];
            case 'topright'
                pos=[offset,offset,0];
            case 'bottomleft'
                pos=[-offset,-offset,0];
            case 'bottomright'
                pos=[offset,-offset,0];
            end

            function localSetTextPosition(hObj,updateState,position)









                t=hObj.Text;
                pdt=hObj.Parent;
                if(~isempty(pdt)&&...
                    isprop(pdt,'ParentLayer')&&strcmp(pdt.ParentLayer,'middle')&&...
                    isprop(pdt.Parent,'DataSpace')&&strcmp(pdt.Parent.DataSpace.isLinear,'off'))&&...
                    strcmp(pdt.PinnedView,'on')
















                    iter=matlab.graphics.axis.dataspace.IndexPointsIterator('Vertices',position);
                    pos=updateState.DataSpace.UntransformPoints(updateState.TransformUnderDataSpace,iter);
                    t.Position=pos;
                else
                    t.Position=position;
                end


                function localSetTextOrientation(t,orientation)







                    switch orientation
                    case 'topleft'
                        t.HorizontalAlignment='right';
                        t.VerticalAlignment='bottom';
                    case 'topright'
                        t.HorizontalAlignment='left';
                        t.VerticalAlignment='bottom';
                    case 'bottomleft'
                        t.HorizontalAlignment='right';
                        t.VerticalAlignment='top';
                    case 'bottomright'
                        t.HorizontalAlignment='left';
                        t.VerticalAlignment='top';
                    end

                    function orientation=localFindBestOrientation(updateState,primPosition,size)



                        pixelPoint=matlab.graphics.chart.internal.convertVertexCoordsToViewerCoords(...
                        updateState.Camera,...
                        updateState.TransformAboveDataSpace,...
                        updateState.DataSpace,...
                        updateState.TransformUnderDataSpace,...
                        primPosition(:));


                        vp=updateState.Camera.Viewport;
                        vp.Units='pixels';
                        vpPosition=vp.Position;
                        pixelPoint=pixelPoint.'-vpPosition(1:2);



                        size=size.*updateState.PixelsPerPoint;


                        minX=pixelPoint(1)-size(1)+1;
                        maxX=pixelPoint(1)+size(1)-1;
                        minY=pixelPoint(2)-size(2)+1;
                        maxY=pixelPoint(2)+size(2)-1;


                        lrorientation='right';
                        udorientation='top';

                        if maxX>vpPosition(3)&&minX>=1

                            lrorientation='left';
                        end

                        if maxY>=vpPosition(4)&&minY>1

                            udorientation='bottom';
                        end


                        isOutsideContainerBoundsMaxX=false;
                        isOutsideContainerBoundsMaxY=false;
                        isOutsideContainerBoundsMinX=false;


                        cropFactor=8*updateState.PixelsPerPoint;

                        hContainer=ancestor(updateState.Camera,'figure');
                        if~isempty(hContainer)
                            parentPos=getpixelposition(hContainer);

                            isOutsideContainerBoundsMaxX=maxX+vpPosition(1)>=parentPos(3)+cropFactor;
                            isOutsideContainerBoundsMinX=minX+vpPosition(1)<=-cropFactor;
                            isOutsideContainerBoundsMaxY=maxY+vpPosition(2)>=parentPos(4);
                        end

                        if strcmpi(lrorientation,'right')&&isOutsideContainerBoundsMaxX&&~isOutsideContainerBoundsMinX


                            lrorientation='left';
                        end

                        if strcmpi(udorientation,'top')&&isOutsideContainerBoundsMaxY


                            if maxY+vpPosition(2)-parentPos(4)>minY+vpPosition(2)
                                udorientation='bottom';
                            end
                        end

                        orientation=[udorientation,lrorientation];

                        function localTextMarkedClean(hText)






                            index=find(hText.NodeChildren==findobjinternal(hText,'-isa','matlab.graphics.primitive.world.CompositeMarker'));
                            if index>1
                                cm=hText.NodeChildren(index);
                                cm.Parent=[];
                                hText.addNode(cm);
                            end
                            delete(hText.OneShotSelectionListener);
                            hText.OneShotSelectionListener=[];
                            delete(findprop(hText,'OneShotSelectionListener'))
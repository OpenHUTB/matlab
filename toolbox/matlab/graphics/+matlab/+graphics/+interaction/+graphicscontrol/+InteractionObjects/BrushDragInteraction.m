classdef BrushDragInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.DragInteractionBase




    properties
        LastRegion;
    end

    methods
        function this=BrushDragInteraction(ax)
            this.Type='brushdrag';
            this.Object=ax;
            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Drag;
        end

        function startdata=dragstart(this,eventdata)

            import matlab.graphics.internal.convertUnits


            startdata.DragStartPosition=[eventdata.figx,eventdata.figy];
            startdata.Text=matlab.graphics.primitive.world.Text.empty;



            if is2D(this.Object)
                parentCanvasContainer=ancestor(this.Object,'matlab.ui.internal.mixin.CanvasHostMixin');
                scribeLayer=matlab.graphics.annotation.internal.findAllScribeLayers(parentCanvasContainer);
                fig=ancestor(this.Object,'figure');




                if~isequal(fig,parentCanvasContainer)

                    canvasContainerPosition=getpixelposition(parentCanvasContainer,true);
                    textPosition=convertUnits(scribeLayer.NodeChildren.Viewport,'normalized','pixels',[[eventdata.figx,eventdata.figy]-canvasContainerPosition(1:2),0,0]);
                    startdata.TextDataSpaceAnchor=matlab.graphics.chart.internal.convertViewerCoordsToDataSpaceCoords(this.Object,[eventdata.figx,eventdata.figy]-canvasContainerPosition(1:2));
                else
                    textPosition=convertUnits(scribeLayer.NodeChildren.Viewport,'normalized','pixels',[eventdata.figx,eventdata.figy,0,0]);
                    startdata.TextDataSpaceAnchor=matlab.graphics.chart.internal.convertViewerCoordsToDataSpaceCoords(this.Object,[eventdata.figx,eventdata.figy]);
                end
                textPosition=single(textPosition(1:2)');
                textPosition(3)=single(0);


                startdata.Text=matlab.graphics.primitive.world.Text('parent',scribeLayer,'VertexData',textPosition);
                fontObj=startdata.Text.Font;
                fontObj.Size=9;
                fontObj.Name=get(groot,'defaultUIcontrolFontName');
                set(startdata.Text,'Font',fontObj,'Margin',1);
            end
        end

        function dragprogress(this,eventdata,startdata)

            if~isempty(startdata.Text)


                parentCanvasContainer=ancestor(this.Object,'matlab.ui.internal.mixin.CanvasHostMixin');
                fig=ancestor(this.Object,'figure');
                if~isequal(fig,parentCanvasContainer)
                    canvasContainerPosition=getpixelposition(parentCanvasContainer,true);
                    draggedDataPosition=matlab.graphics.chart.internal.convertViewerCoordsToDataSpaceCoords(this.Object,[eventdata.figx,eventdata.figy]-canvasContainerPosition(1:2));
                else
                    draggedDataPosition=matlab.graphics.chart.internal.convertViewerCoordsToDataSpaceCoords(this.Object,[eventdata.figx,eventdata.figy]);
                end
                startdata.Text.String=formatRegionData(this.Object,startdata.TextDataSpaceAnchor,draggedDataPosition);



                if eventdata.figy-startdata.DragStartPosition(2)>0
                    startdata.Text.VerticalAlignment='top';
                else
                    startdata.Text.VerticalAlignment='bottom';
                end
            end



            dragEndPosition=[eventdata.figx,eventdata.figy];
            brushObjects=datamanager.getBrushableObjs(this.Object);
            h=abs(startdata.DragStartPosition(2)-dragEndPosition(2));
            w=abs(startdata.DragStartPosition(1)-dragEndPosition(1));
            x=min(startdata.DragStartPosition(1),dragEndPosition(1));
            y=min(startdata.DragStartPosition(2),dragEndPosition(2));
            region=[x+w,x,x,x+w;...
            y+h,y+h,y,y];
            if isempty(this.LastRegion)
                this.LastRegion=[x,x,x,x;...
                y,y,y,y];
            end
            datamanager.brushRectangle(this.Object,brushObjects,...
            [],region,this.LastRegion,1,[1,0,0],'','');
            this.LastRegion=region;
        end

        function dragend(this,~,startdata)
            if~isempty(startdata)&&~isempty(startdata.Text)
                delete(startdata.Text);
            end
            this.LastRegion=[];
        end
    end
end

function output=formatRegionData(ax,startPoint,endPoint)

    [xStart,yStart]=matlab.graphics.internal.makeNonNumeric(ax,startPoint(1),startPoint(2));
    [xEnd,yEnd]=matlab.graphics.internal.makeNonNumeric(ax,endPoint(1),endPoint(2));


    if~isnumeric(xStart)
        startPoint=char(xStart);
        endPoint=char(xEnd);
        outputX=sprintf(['%s: %s ',getString(message('MATLAB:datamanager:draw:To')),' %s'],'X',startPoint,endPoint);
    else
        outputX=sprintf(['%s: %0.3g ',getString(message('MATLAB:datamanager:draw:To')),' %0.3g'],'X',xStart,xEnd);
    end
    if~isnumeric(yStart)
        startPoint=char(yStart);
        endPoint=char(yEnd);
        outputY=sprintf(['%s: %s ',getString(message('MATLAB:datamanager:draw:To')),' %s'],'Y',startPoint,endPoint);
    else
        outputY=sprintf(['%s: %0.3g ',getString(message('MATLAB:datamanager:draw:To')),' %0.3g'],'Y',yStart,yEnd);
    end
    output={outputX;outputY};
end

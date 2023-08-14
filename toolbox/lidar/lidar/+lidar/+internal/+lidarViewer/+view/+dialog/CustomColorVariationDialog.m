classdef CustomColorVariationDialog<lidar.internal.lidarViewer.view.dialog.helper.OkCanceDialog





    properties(Access=private)
        ColormapLength=256;
ColorMappingText
PlotAxes
MappingPlot
ColorBarAxes
ColorBar
hMarkers
YMiddle
Plot

ColorMappingTextPos
ColorMappingDropdownPos
MappingPlotPos
ColorBarAxesPos

hContextMenu


StartDragX
PrevDragX
MarkerBeingDragged
DragLeftNeighborX
DragRightNeighborX
ColormapInDisplay
ColormapInternal

LastYDataAfterColorModify

hPoints
hLine

ColormapName
YLabel
SettingNewPosition
        Color=[0,0.4470,0.7410];
    end

    properties
ColorMappingDropdown
    end

    events
CustomColormapRequest
    end

    properties(Dependent)
Colormap
Position
PlotPosition
    end

    methods



        function this=CustomColorVariationDialog(cmap,ydata,cmapVal,colormapText,colormapValText)

            title=getString(message('lidar:lidarViewer:CustomColorVariation'));
            this=this@lidar.internal.lidarViewer.view.dialog.helper.OkCanceDialog(title,[350,400]);
            this.MainFigure.CloseRequestFcn=@(src,evt)cancelClicked(this);
            this.YLabel=colormapValText;
            this.ColormapName=colormapText;


            this.hContextMenu=uicontextmenu(this.MainFigure,'Tag','ControlPointContextMenu');
            uimenu(this.hContextMenu,'Label',getString(message('lidar:lidarViewer:Delete')),'Callback',@(hobj,evt)this.removeMarker());



            this.calculatePosition();


            this.createUI();


            hold(this.PlotAxes,'on')
            loc=rescale(cmapVal,1,256);
            [N,edges]=histcounts(loc,'Normalization','probability');
            xbar=edges(1:numel(N))+mean(diff(edges))/2;
            bar(this.PlotAxes,xbar,rescale(N,1,256),'FaceAlpha',0.2,'EdgeAlpha',0.2,'Tag','CmapValBarPlot');


            this.ColormapInDisplay=cmap;
            this.Colormap=cmap;
            if~isempty(ydata)
                this.hLine.XData=1:256;
                this.hLine.YData=ydata;
                this.Colormap=cmap(fix(ydata),:);
                this.hPoints(1).Position(2)=this.hLine.YData(1);
                this.hPoints(end).Position(2)=this.hLine.YData(end);
            end

            this.addEdgeMarkers();
            this.reactToColormapChange();
        end
    end


    methods
        function set.Colormap(this,cmap)
            this.ColormapInternal=cmap;
            colormap(this.ColorBarAxes,this.Colormap);
        end


        function cmapNew=get.Colormap(this)
            cmapNew=this.ColormapInternal;
        end


        function set.Position(this,pos)
            this.addEdgeMarkers();
        end


        function colorControlPoints=get.Position(this)

            numMarkers=length(this.hMarkers);
            colorControlPoints=zeros(numMarkers,4);

            for i=1:length(this.hMarkers)
                colorControlPoints(i,1)=this.hMarkers(i).XData;
                colorControlPoints(i,2:4)=getMarkerColor(this.hMarkers(i));
            end
        end


        function set.PlotPosition(this,posInit)

            this.SettingNewPosition=true;
            delete(this.hPoints);
            this.SettingNewPosition=false;
            this.hPoints=images.roi.Point.empty();

            delete(this.hLine);

            this.hLine=line('Parent',this.PlotAxes,'XData',posInit(:,1),...
            'YData',posInit(:,2),'Color',this.Color,'ButtonDownFcn',@(hObj,evt)this.addControlPointToLine(evt),...
            'Tag','ColormapPlotLine');

            for p=1:size(posInit,1)
                this.createNewPoint(posInit(p,:),p);
            end

            this.hPoints(1).DrawingArea=[1,1,0,255];
            this.hPoints(end).DrawingArea=[256,1,0,255];

            this.hPoints(1).ContextMenu=[];
            this.hPoints(end).ContextMenu=[];

        end


        function pos=get.PlotPosition(this)

            numPoints=length(this.hPoints);
            pos=zeros(numPoints,2);
            for p=1:numPoints
                pos(p,:)=this.hPoints(p).Position;
            end

            if any(pos<1,'all')
                pos(pos<1)=1;
            elseif any(pos>256,'all')
                pos(pos>256)=256;
            end

        end
    end


    methods(Access=private)
        function calculatePosition(this)

            parentWidth=this.MainFigure.Position(3);
            parentHeight=this.MainFigure.Position(4);

            this.ColorMappingTextPos=...
            [parentWidth*0.1,parentHeight-40,parentWidth*0.5-40,22];
            this.ColorMappingDropdownPos=...
            [parentWidth*0.5,parentHeight-40,parentWidth*0.3,22];
            this.MappingPlotPos=[parentWidth*0.05,parentHeight-260,parentWidth*0.85,200];
            this.ColorBarAxesPos=[20,parentHeight-130,parentWidth-40,5];
        end



        function createUI(this)

            this.addColorMappingTextAndDropdown();

            this.addPlot();

            this.addColorBar();

        end


        function addColorMappingTextAndDropdown(this)
            this.ColorMappingText=uilabel(this.MainFigure,...
            "Position",this.ColorMappingTextPos,...
            "Text","Color Mapping","FontSize",14);

            dropdownStrings={getString(message('lidar:lidarViewer:Linear')),...
            getString(message('lidar:lidarViewer:Log')),...
            getString(message('lidar:lidarViewer:Exp')),...
            getString(message('lidar:lidarViewer:Sigmoid'))};
            this.ColorMappingDropdown=uidropdown(this.MainFigure,...
            "Position",this.ColorMappingDropdownPos,...
            "Items",dropdownStrings,"ValueChangedFcn",...
            @(src,evt)colorMappingChanged(this,evt),"Tag",'colorMappingDropdown');
        end


        function addPlot(this)
            this.PlotAxes=uiaxes(this.MainFigure,...
            "Position",this.MappingPlotPos,...
            'XTickLabel','',...
            'YTickLabel','',...
            'XLimMode','manual',...
            'YLimMode','manual',...
            'Box','on','XLim',[1,256],'YLim',[1,256]);

            ax=axtoolbar(this.PlotAxes);
            ax.Visible='off';
            disableDefaultInteractivity(this.PlotAxes);
            xlabel(this.PlotAxes,this.YLabel);
            ylabel(this.PlotAxes,this.ColormapName);


            this.SettingNewPosition=false;
            this.hPoints=images.roi.Point.empty();
            this.hLine=matlab.graphics.primitive.Line.empty();
            this.PlotPosition=[1,1;256,256];


            hFig=ancestor(this.PlotAxes,'figure');
            addlistener(hFig,'WindowMousePress',@(src,evt)this.wireDragConstraint(src,evt));
        end


        function addColorBar(this)
            this.ColorBarAxes=axes('Parent',this.MainFigure,...
            'Visible','off',...
            'Clipping','off',...
            'Tag','Colorbar');
            this.ColorBarAxes.XLim=[1,256];
            this.ColorBarAxes.YLim=[1,256];
            this.ColorBarAxes.OuterPosition=[0.1,0.1,0.8,0.2];
            this.ColorBarAxes.Clipping='off';
            this.ColorBarAxes.Toolbar=[];
            this.ColorBarAxes.InnerPosition=[0.1,0.25,0.8,0.06];
            disableDefaultInteractivity(this.ColorBarAxes);


            img=1:256;
            img=repmat(img,[256,1]);

            this.ColorBar=image('CData',img,'Parent',this.ColorBarAxes);
            this.ColorBar.ButtonDownFcn=@(~,evt)this.addColorMarker(evt);
        end


        function addEdgeMarkers(this)


            colorControlPoints=[1,this.Colormap(1,:);256,this.Colormap(end,:)];
            numMarkers=size(colorControlPoints,1);
            this.YMiddle=1+diff(this.ColorBar.YData)/2;
            delete(this.hMarkers);
            this.hMarkers=matlab.graphics.primitive.Line.empty();
            this.hMarkers(1)=this.createMarker(1,this.YMiddle);
            this.hMarkers(numMarkers)=this.createMarker(this.ColorBar.XData(2),this.YMiddle);
            setMarkerColor(this.hMarkers(1),colorControlPoints(1,2:end));
            setMarkerColor(this.hMarkers(numMarkers),colorControlPoints(numMarkers,2:end));
            this.hMarkers(1).Tag='endCircle';
            this.hMarkers(numMarkers).Tag='endCircle';
        end


        function colorMappingChanged(this,evt)


            [this.Colormap,map]=this.getColormap(this.ColormapInDisplay,evt.Value);

            this.PlotPosition=[1,1;256,256];
            this.hLine.XData=1:256;
            this.hLine.YData=map;
            this.LastYDataAfterColorModify=map;
            this.Position=[1,this.Colormap(1,:);256,this.Colormap(256,:)];
            this.reactToColormapChange();
            this.customColorMap(false);
        end





        function addColorMarker(this,evt)
            this.addMarker(evt.IntersectionPoint(1)/256);

            hitPos=evt.IntersectionPoint(1:2);
            hitPos(hitPos<1)=1;
            hitPos(hitPos>256)=256;


            leftIdx=find(this.PlotPosition(:,1)<hitPos(1),1,'last');
            rightIdx=leftIdx+1;


            this.hPoints((rightIdx+1):(end+1))=this.hPoints(rightIdx:end);

            xdata=this.hLine.XData;
            ydata=this.hLine.YData;
            try




                vq=interp1(xdata,ydata,hitPos(1));

                hitPos(2)=vq;
                this.createNewPoint(hitPos,leftIdx+1);

                this.customColorMap(true);
            catch
            end
        end


        function addMarker(this,pos)
            currentColormap=this.Colormap;

            xPos=round(1+pos*diff(this.ColorBar.XData));
            xPos=max(1,xPos);
            xPos=min(xPos,this.ColormapLength);

            insertIdx=1;
            for i=1:length(this.hMarkers)
                if xPos<this.hMarkers(i).XData
                    insertIdx=i;
                    break;
                end
            end

            hMarkerNew=this.hMarkers;
            hMarkerNew(end+1)=hMarkerNew(end);
            hMarkerNew(1:(insertIdx-1))=this.hMarkers(1:(insertIdx-1));
            hAddedMarker=this.createMarker(xPos,this.YMiddle);
            hMarkerNew(insertIdx)=hAddedMarker;
            hMarkerNew((insertIdx+1):end)=this.hMarkers(insertIdx:end);
            this.hMarkers=hMarkerNew;

            setMarkerColor(hAddedMarker,currentColormap(xPos,:));
            hAddedMarker.UIContextMenu=this.hContextMenu;
            iptSetPointerBehavior(hAddedMarker,@(varargin)setptr(this.MainFigure,'lrdrag'));
        end


        function hMarker=createMarker(this,xPos,yPos)
            hMarker=line(xPos,yPos,'Marker','o','Parent',this.ColorBarAxes);
            hMarker.MarkerSize=15;
            hMarker.MarkerFaceColor='white';
            hMarker.MarkerEdgeColor='black';
            hMarker.ButtonDownFcn=@(src,evt)this.manageMarkerButtonDown(src,evt);
            hMarker.PickableParts='all';
            hMarker.Tag='ColorbarCircle';
        end


        function manageMarkerButtonDown(this,hObj,~)
            if~strcmp(hObj.Tag,'endCircle')
                idx=find(hObj==this.hMarkers);
                this.DragLeftNeighborX=this.hMarkers(idx-1).XData;
                this.DragRightNeighborX=this.hMarkers(idx+1).XData;
                this.MainFigure.WindowButtonMotionFcn=@(hObj,evt)this.dragControlPoint(evt);
                this.MainFigure.WindowButtonUpFcn=@(hObj,evt)this.endControlPointDrag();
                this.PrevDragX=this.ColorBarAxes.CurrentPoint(1);
                this.StartDragX=this.ColorBarAxes.CurrentPoint(1);
                this.MarkerBeingDragged=hObj;
            end
        end


        function reactToColormapChange(this)
            xdata=this.hLine.XData;
            ydata=this.hLine.YData;
            try




                vq=interp1(xdata,ydata,1:256);
                evt=lidar.internal.lidarViewer.events.CustomColormapRequestEventData(this.Colormap,vq);
                notify(this,'CustomColormapRequest',evt);
            catch
            end
        end


        function removeMarker(this)

            hMarker=this.MainFigure.CurrentObject;
            idx=find(this.hMarkers==hMarker);
            this.hMarkers(idx)=[];

            delete(hMarker);


            vertex=this.hPoints(idx);
            leftNeighbor=this.hPoints(idx-1);
            rightNeighbor=this.hPoints(idx+1);
            this.hPoints(idx)=[];
            delete(vertex);

            leftNeighborIsFirstPoint=find(leftNeighbor==this.hPoints(1));
            if~leftNeighborIsFirstPoint
                leftNeighbor.DrawingArea=this.getDrawingAreaForPoint(leftNeighbor);
            end

            rightNeighborIsLastPoint=find(rightNeighbor==this.hPoints(end));
            if~rightNeighborIsLastPoint
                rightNeighbor.DrawingArea=this.getDrawingAreaForPoint(rightNeighbor);
            end
        end


        function dragControlPoint(this,evt)

            deltaX=this.ColorBarAxes.CurrentPoint(1)-this.StartDragX;
            newPosX=this.StartDragX+deltaX;



            newPosX=max(newPosX,this.DragLeftNeighborX+1);
            newPosX=min(newPosX,this.DragRightNeighborX-1);
            this.PrevDragX=max(this.PrevDragX,this.DragLeftNeighborX+1);
            this.PrevDragX=min(this.PrevDragX,this.DragRightNeighborX-1);


            this.MarkerBeingDragged.XData=newPosX;
            cmap=this.Colormap;


            leftX=floor(this.DragLeftNeighborX);
            rightX=floor(this.DragRightNeighborX);
            oldX=floor(this.PrevDragX);
            newX=floor(newPosX);



            try
                xLhs=leftX:oldX;
                vLhs=cmap(xLhs,:);
                newLhsSize=newX-leftX+1;
                if isscalar(xLhs)
                    vqLhs=repmat(vLhs,[newLhsSize,1]);
                else
                    xqLhs=linspace(leftX,oldX,newLhsSize);
                    vqLhs=interp1(xLhs,vLhs,xqLhs);
                end
                map=interp1(this.hLine.XData,this.hLine.YData,1:256);
                vPlotLhs=map(xLhs);
                xqLhs=linspace(leftX,oldX,newLhsSize);

                vqPlotLhs=interp1(xLhs,vPlotLhs,xqLhs);

                xRhs=oldX+1:rightX;
                vRhs=cmap(xRhs,:);
                newRhsSize=rightX-(newX+1)+1;
                if isscalar(xRhs)
                    vqRhs=repmat(vRhs,[newRhsSize,1]);
                else
                    xqRhs=linspace(oldX+1,rightX,newRhsSize);
                    vqRhs=interp1(xRhs,vRhs,xqRhs);
                end

                map=interp1(this.hLine.XData,this.hLine.YData,1:256);
                vPlotRhs=map(xRhs);
                xqRhs=linspace(oldX+1,rightX,newRhsSize);
                vqPlotRhs=interp1(xRhs,vPlotRhs,xqRhs);

                cmap(leftX:rightX,:)=[vqLhs;vqRhs];
                map(leftX:rightX)=[vqPlotLhs,vqPlotRhs];
            catch
                return;
            end

            this.hLine.XData=1:256;
            this.hLine.YData=map;
            this.LastYDataAfterColorModify=map;

            marker=this.MarkerBeingDragged;

            idx=find(this.hMarkers==marker);
            internalMarker=(idx==1)||(idx==length(this.hMarkers));
            if~internalMarker

                this.hPoints(idx).Position(1)=marker.XData;
            end

            this.updatePointsPos();

            this.PrevDragX=floor(newPosX);
            this.Colormap=cmap;

            this.reactToColormapChange();
        end


        function updatePointsPos(this)
            xq=this.PlotPosition(2:end-1,1);
            xdata=this.hLine.XData;
            ydata=this.hLine.YData;
            vq=interp1(xdata,ydata,xq);

            for i=1:length(xq)
                this.hPoints(i+1).Position(2)=vq(i);
            end
        end


        function endControlPointDrag(this)

            this.MainFigure.WindowButtonMotionFcn='';
            this.MainFigure.WindowButtonUpFcn='';
            this.reactToColormapChange();
        end




        function wireDragConstraint(this,~,evt)

            if isa(evt.HitObject.Parent,'images.roi.Point')
                hPoint=evt.HitObject.Parent;

                idx=find(this.hPoints==hPoint);
                if numel(idx)>1
                    idx=idx(1);
                end
                internalControlPoint=(idx==1)||(idx==length(this.hPoints));
                if~internalControlPoint
                    this.hPoints(idx).DrawingArea=this.getDrawingAreaForPoint(this.hPoints(idx));
                end
            end

        end


        function drawingArea=getDrawingAreaForPoint(this,hPoint)

            idx=find(hPoint==this.hPoints);

            leftNeighborPos=this.hPoints(idx-1).Position;
            leftNeighborX=leftNeighborPos(1);
            minLeftX=leftNeighborX+1e-4;

            rightNeighborPos=this.hPoints(idx+1).Position;
            rightNeighborX=rightNeighborPos(1);
            maxRightX=rightNeighborX-1e-4;

            drawingArea=[1+minLeftX,1,maxRightX-minLeftX,256];

            if drawingArea(3)<0||drawingArea(4)<0
                drawingArea=hPoint.DrawingArea;
            end
        end


        function createNewPoint(this,pos,idx)

            newPoint=images.roi.Point('Parent',this.PlotAxes,...
            'Position',pos,...
            'MarkerSize',4,...
            'Color',this.Color,...
            'Tag','ColormapLineVertex');
            addlistener(newPoint,'MovingROI',@(~,evt)this.vertexDrag(evt));

            this.hPoints(idx)=newPoint;



            addlistener(newPoint,'ObjectBeingDestroyed',@(hObj,evt)this.vertexDeleted(newPoint));

            if idx==1||idx==length(this.hPoints)
                return;
            end

            if~isempty(this.LastYDataAfterColorModify)
                xdata=[1:256,this.PlotPosition(2:end-1,1)'];
            else
                xdata=this.PlotPosition(:,1);
            end
            [xdata_sorted,indices]=sort(xdata);
            if~isempty(this.LastYDataAfterColorModify)
                ydata=[this.LastYDataAfterColorModify,this.PlotPosition(2:end-1,2)'];
            else
                ydata=this.PlotPosition(:,2);
            end

            ydata_sorted=ydata(indices);
            this.hLine.XData=xdata_sorted;
            this.hLine.YData=ydata_sorted;

            try
                map=interp1(xdata_sorted,ydata_sorted,1:256);
                this.Colormap=this.ColormapInDisplay(fix(map),:);
                reactToColormapChange(this);
            catch
            end
        end


        function addControlPointToLine(this,evt)

            hitPos=evt.IntersectionPoint(1:2);
            hitPos(hitPos<1)=1;
            hitPos(hitPos>256)=256;


            leftIdx=find(this.PlotPosition(:,1)<hitPos(1),1,'last');
            rightIdx=leftIdx+1;


            this.hPoints((rightIdx+1):(end+1))=this.hPoints(rightIdx:end);

            this.createNewPoint(hitPos,leftIdx+1);

            this.addMarker(evt.IntersectionPoint(1)/256);

            this.customColorMap(true);

        end


        function vertexDrag(this,evt)

            this.updateLine();
            this.LastYDataAfterColorModify=[];

            hPoint=evt.Source;

            idx=find(this.hPoints==hPoint);
            if numel(idx)>1
                idx=idx(1);
            end
            internalControlPoint=(idx==1)||(idx==length(this.hPoints));
            if~internalControlPoint

                this.hMarkers(idx).XData=hPoint.Position(1);
            end
        end


        function updateLine(this)
            try
                map=interp1(this.PlotPosition(:,1),this.PlotPosition(:,2),1:256);
                this.hLine.XData=this.PlotPosition(:,1);
                this.hLine.YData=this.PlotPosition(:,2);


                this.Colormap=this.ColormapInDisplay(fix(map),:);
                reactToColormapChange(this);
            catch
            end

        end


        function vertexDeleted(this,hPoint)







            if~isvalid(this)||~isvalid(this.PlotAxes)||this.SettingNewPosition
                return
            end

            idx=find(this.hPoints==hPoint);
            leftNeighbor=this.hPoints(idx-1);
            rightNeighbor=this.hPoints(idx+1);
            this.hPoints(idx)=[];




            leftNeighborIsFirstPoint=find(leftNeighbor==this.hPoints(1));
            if~leftNeighborIsFirstPoint
                leftNeighbor.DrawingArea=this.getDrawingAreaForPoint(leftNeighbor);
            end

            rightNeighborIsLastPoint=find(rightNeighbor==this.hPoints(end));
            if~rightNeighborIsLastPoint
                rightNeighbor.DrawingArea=this.getDrawingAreaForPoint(rightNeighbor);
            end


            hMarker=this.hMarkers(idx);
            this.hMarkers(idx)=[];
            delete(hMarker);
        end
    end

    methods(Hidden,Access=?matlab.uitest.TestCase)
        function[cmap_out,map_fcn]=getColormap(this,cmap_in,fcn)
            map_fcn=[];
            if isa(fcn,'matlab.graphics.primitive.Line')
                line=fcn;
                map_fcn=interp1(line.XData,line.YData,1:256);
                cmap_out=cmap_in(fix(map_fcn),:);

            elseif isvector(fcn)&&~ischar(fcn)

                xPos=fcn(1:end-2);
                idx=fcn(end-1);
                newX=floor(fcn(end));

                cmap_out=cmap_in;

                oldX=floor(xPos(idx));
                leftX=floor(xPos(idx-1));
                rightX=floor(xPos(idx+1));

                xLhs=leftX:oldX;
                vLhs=cmap_in(xLhs,:);
                newLhsSize=newX-leftX+1;
                xqLhs=linspace(leftX,oldX,newLhsSize);
                vqLhs=interp1(xLhs,vLhs,xqLhs);

                xRhs=oldX+1:rightX;
                vRhs=cmap_in(xRhs,:);
                newRhsSize=rightX-(newX+1)+1;
                xqRhs=linspace(oldX+1,rightX,newRhsSize);
                vqRhs=interp1(xRhs,vRhs,xqRhs);

                cmap_out(leftX:rightX,:)=[vqLhs;vqRhs];

            else
                switch fcn
                case getString(message('lidar:lidarViewer:Linear'))
                    map_fcn=1:256;
                case getString(message('lidar:lidarViewer:Log'))
                    map_fcn=255*rescale(log(1:256))+1;
                case getString(message('lidar:lidarViewer:Exp'))
                    map_fcn=255*rescale(exp(1:256))+1;
                case getString(message('lidar:lidarViewer:Sigmoid'))
                    map_fcn=255*rescale(1./(1+exp(-[1:256])))+1;
                end
                cmap_out=cmap_in(fix(map_fcn),:);

            end
        end
    end

    methods(Hidden)
        function customColorMap(this,TF)
            if TF
                dropdownItems=this.ColorMappingDropdown.Items;
                if~strcmp(dropdownItems{end},getString(message('lidar:lidarViewer:Custom')))
                    dropdownItems{end+1}=getString(message('lidar:lidarViewer:Custom'));
                end
                this.ColorMappingDropdown.Items=dropdownItems;
                this.ColorMappingDropdown.Value=dropdownItems{end};
            else
                dropdownItems=this.ColorMappingDropdown.Items;
                if any(ismember(dropdownItems,getString(message('lidar:lidarViewer:Custom'))))
                    currentVal=this.ColorMappingDropdown.Value;
                    dropdownItems=dropdownItems(1:end-1);
                    this.ColorMappingDropdown.Items=dropdownItems;
                    this.ColorMappingDropdown.Value=currentVal;
                end
            end
        end
    end

    methods(Access=protected)
        function okClicked(this)
            this.ColormapInDisplay=this.Colormap;
            xdata=this.hLine.XData;
            ydata=this.hLine.YData;
            [~,uniqueXIdx,~]=unique(xdata);
            [~,uniqueYIdx,~]=unique(ydata);
            uniqueIdx=intersect(uniqueXIdx,uniqueYIdx);
            vq=nonzeros(interp1(xdata(uniqueIdx),ydata(uniqueIdx),1:256))';
            if any(isnan(vq))





                if~any(ismember(uniqueIdx,1))
                    uniqueIdx=[uniqueIdx;1];
                end
                if~any(ismember(uniqueIdx,numel(xdata)))
                    uniqueIdx=[uniqueIdx;numel(xdata)];
                end
                vq=nonzeros(interp1(xdata(uniqueIdx),ydata(uniqueIdx),1:256,"nearest"))';
            end
            evt=lidar.internal.lidarViewer.events.CustomColormapRequestEventData(this.Colormap,vq,2);
            notify(this,'CustomColormapRequest',evt);
            set(this.MainFigure,'CloseRequestFcn','closereq');
            this.close();
        end

        function cancelClicked(this)
            this.Colormap=this.ColormapInDisplay;
            xdata=this.hLine.XData;
            ydata=this.hLine.YData;
            vq=interp1(xdata,ydata,1:256);
            evt=lidar.internal.lidarViewer.events.CustomColormapRequestEventData(this.Colormap,vq,3);
            notify(this,'CustomColormapRequest',evt);
            set(this.MainFigure,'CloseRequestFcn','closereq');
            close(this);
        end
    end
end

function setMarkerColor(hMarker,newColor)
    setappdata(hMarker,'MarkerColor',newColor);
end

function c=getMarkerColor(hMarker)
    c=getappdata(hMarker,'MarkerColor');
end






classdef AlphamapEditor<handle




    properties(Dependent)




ControlPointsPos

VolumeBounds

    end

    properties

BackgroundColormap

    end

    properties(Access=private,Dependent)

SelectedPointIdx

    end

    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)

Panel
Axes

        ControlPoints images.roi.Point
Line

DataBoundsMinLine
DataBoundsMaxLine

PointSpinner

IntensityEditfield

OpacityEditfield

AlphamapUpdatedEventCoalescer

    end

    properties(Access=private)

ColormapPatch
BackgroundColorImage

    end

    properties(Access=private,Constant)

        Color=[0,0.4470,0.7410];

        SelectedColor=[0,1,0];

        NeighborPointDelta=1e-6;

    end

    events

AlphaControlPtsUpdated

    end

    methods

        function self=AlphamapEditor(hPanel)

            self.Panel=hPanel;

            self.create();

            self.createImagePatchLine();

            self.AlphamapUpdatedEventCoalescer=images.internal.app.utilities.EventCoalescerPeriodic();
            addlistener(self.AlphamapUpdatedEventCoalescer,'EventTriggered',@(src,evt)self.triggerAlphamapUpdate());

        end

        function delete(self)
            delete(self.AlphamapUpdatedEventCoalescer);
        end

        function clear(self)

            delete(self.ControlPoints);

            img=1:256;
            img=repmat(img,[diff(self.Axes.YLim),1]);
            set(self.BackgroundColorImage,...
            'CData',img);

            set(self.Line,'XData',0,'YData',0);

            set(self.ColormapPatch,...
            'XData',0,...
            'YData',0,...
            'CData',self.Axes.Color)

        end

    end


    methods




        function set.ControlPointsPos(self,pos)









            delete(self.ControlPoints);
            self.ControlPoints=images.roi.Point.empty();
            numPoints=size(pos,1);

            xLim=[pos(1,1),pos(numPoints,1)];
            self.Axes.XLim=xLim;

            yLim=self.Axes.YLim;


            set(self.Line,'XData',pos(:,1),'YData',pos(:,2));


            set(self.BackgroundColorImage,'XData',xLim,'YData',yLim);



            self.updatePatchCordinates();


            for idx=1:numPoints
                hPoint=self.createPoint(pos(idx,:));
                self.ControlPoints(idx)=hPoint;
            end


            for idx=1:numPoints
                self.ControlPoints(idx).DrawingArea=self.getDragConstraintForPoint(idx);
            end



            self.ControlPoints(1).ContextMenu=[];
            self.ControlPoints(end).ContextMenu=[];

            self.PointSpinner.Limits=[1,numPoints];


            self.SelectedPointIdx=1;

        end

        function pos=get.ControlPointsPos(self)

            numPoints=length(self.ControlPoints);
            pos=zeros(numPoints,2);

            for idx=1:numPoints
                pos(idx,:)=self.ControlPoints(idx).Position;
            end

        end




        function set.SelectedPointIdx(self,idx)


            set(self.ControlPoints,'Selected',false);
            self.ControlPoints(idx).Selected=idx;

            controlPointPos=self.ControlPointsPos(idx,:);


            self.PointSpinner.Value=idx;
            self.IntensityEditfield.Value=controlPointPos(1);
            self.OpacityEditfield.Value=controlPointPos(2);



            if idx==1||idx==numel(self.ControlPoints)
                self.IntensityEditfield.Editable='off';
                self.IntensityEditfield.Enable='off';
            else
                self.IntensityEditfield.Editable='on';
                self.IntensityEditfield.Enable='on';
            end

        end

        function idx=get.SelectedPointIdx(self)

            selectedValues=get(self.ControlPoints,'Selected');
            idx=find(selectedValues);

        end




        function set.BackgroundColormap(self,cmap)

            self.BackgroundColormap=cmap;
            colormap(self.Axes,cmap);%#ok<MCSUP> 

        end




        function set.VolumeBounds(self,volumeBounds)







            self.DataBoundsMinLine.Position=[volumeBounds(1),-1;volumeBounds(1),2];
            self.DataBoundsMaxLine.Position=[volumeBounds(2),-1;volumeBounds(2),2];

            self.DataBoundsMinLine.Label=['Data Min: ',num2str(volumeBounds(1))];
            self.DataBoundsMaxLine.Label=['Data Max: ',num2str(volumeBounds(2))];

        end

    end

    methods(Access=private)

        function create(self)








            grid=uigridlayout('Parent',self.Panel,...
            'RowHeight',{'1x',45},...
            'ColumnWidth',{'1x'},...
            'RowSpacing',10,...
            'ColumnSpacing',5,...
            'Padding',20,...
            'Scrollable','off');

            self.Axes=axes('Parent',grid,...
            'Units','pixels',...
            'XTick',[],'YTick',[],...
            'TickDir','in',...
            'Clipping','on',...
            'XLimMode','manual',...
            'YLimMode','manual',...
            'XAxisLocation','top');
            self.Axes.Layout.Row=1;
            self.Axes.Layout.Column=1;

            spacing=10;
            uicontrolsGrid=uigridlayout('Parent',grid,...
            'RowHeight',{20,'1x'},...
            'ColumnWidth',{spacing,0,50,spacing,'fit',60,spacing,'fit',40,'1x'},...
            'RowSpacing',0,...
            'ColumnSpacing',2,...
            'Padding',0,...
            'Scrollable','on');
            uicontrolsGrid.Layout.Row=2;
            uicontrolsGrid.Layout.Column=1;

            pointLabel=uilabel('Parent',uicontrolsGrid,...
            'Text',getString(message('medical:medicalLabeler:point')),...
            'Tag','Point',...
            'HandleVisibility','off');
            pointLabel.Layout.Row=1;
            pointLabel.Layout.Column=2;

            self.PointSpinner=uispinner('Parent',uicontrolsGrid,...
            'Step',1,...
            'Limits',[1,2],...
            'ValueChangedFcn',@(src,evt)self.pointSpinnerUpdated(evt.Value),...
            'Tooltip',getString(message('medical:medicalLabeler:selectedPointIndex')),...
            'HandleVisibility','off');
            self.PointSpinner.Layout.Row=1;
            self.PointSpinner.Layout.Column=3;

            intensityLabel=uilabel('Parent',uicontrolsGrid,...
            'Text',getString(message('medical:medicalLabeler:intensity')),...
            'Tag','IntensityLabel',...
            'Tooltip',getString(message('medical:medicalLabeler:intensitySelectedPoint')),...
            'HandleVisibility','off');
            intensityLabel.Layout.Row=1;
            intensityLabel.Layout.Column=5;

            self.IntensityEditfield=uieditfield('numeric',...
            'Parent',uicontrolsGrid,...
            'Value',0,...
            'ValueDisplayFormat','%11.2f',...
            'Tag','IntensityEditField',...
            'ValueChangedFcn',@(src,evt)self.pointIntensityChanged(evt.Value),...
            'Tooltip',getString(message('medical:medicalLabeler:intensitySelectedPoint')),...
            'HandleVisibility','off');
            self.IntensityEditfield.Layout.Row=1;
            self.IntensityEditfield.Layout.Column=6;

            opacityLabel=uilabel('Parent',uicontrolsGrid,...
            'Text',getString(message('medical:medicalLabeler:opacity')),...
            'Tag','OpacityLabel',...
            'Tooltip',getString(message('medical:medicalLabeler:opacitySelectedPoint')),...
            'HandleVisibility','off');
            opacityLabel.Layout.Row=1;
            opacityLabel.Layout.Column=8;

            self.OpacityEditfield=uieditfield('numeric',...
            'Parent',uicontrolsGrid,...
            'Value',0,...
            'Limits',[0,1],...
            'ValueDisplayFormat','%11.2g',...
            'Tag','OpacityEditField',...
            'Tooltip',getString(message('medical:medicalLabeler:opacitySelectedPoint')),...
            'ValueChangedFcn',@(src,evt)self.pointOpacityChanged(evt.Value),...
            'HandleVisibility','off');
            self.OpacityEditfield.Layout.Row=1;
            self.OpacityEditfield.Layout.Column=9;


        end

        function createImagePatchLine(self)










            img=1:256;
            img=repmat(img,[diff(self.Axes.YLim),1]);
            self.BackgroundColorImage=image('CData',img,...
            'Tag','BackgroundImage',...
            'Parent',self.Axes,...
            'XData',self.Axes.XLim,...
            'YData',self.Axes.YLim);


            self.ColormapPatch=patch(0,0,self.Axes.Color,...
            'Parent',self.Axes,...
            'EdgeAlpha',0,...
            'EdgeLighting','none',...
            'FaceAlpha',1,...
            'FaceLighting','flat',...
            'Selected','off',...
            'SelectionHighlight','off',...
            'PickableParts','none',...
            'HitTest','off',...
            'HandleVisibility','off');



            self.Line=line('Parent',self.Axes,...
            'XData',0,'YData',0,...
            'LineWidth',3,...
            'Color',self.Color,...
            'ButtonDownFcn',@(hObj,evt)self.addControlPointToLine(evt),...
            'Tag','AlphamapEditorLine');





            hFig=ancestor(self.Axes,'figure');
            if~isempty(hFig.Theme)
                labelColor=hFig.Theme.BaseTextColor;
            else
                labelColor=[0,0,0];
            end

            self.DataBoundsMinLine=images.roi.Line('Parent',self.Axes,...
            'LineWidth',1,...
            'MarkerSize',0.05,...
            'Selected',false,...
            'InteractionsAllowed','reshape',...
            'LabelVisible','hover',...
            'LabelAlpha',0,...
            'LabelTextColor',labelColor,...
            'Color',[1,0,0],...
            'Tag','DataBoundsMinLine');

            self.DataBoundsMaxLine=images.roi.Line('Parent',self.Axes,...
            'LineWidth',1,...
            'MarkerSize',0.05,...
            'Selected',false,...
            'InteractionsAllowed','reshape',...
            'LabelVisible','hover',...
            'LabelAlpha',0,...
            'LabelTextColor',labelColor,...
            'Color',[1,0,0],...
            'Tag','DataBoundsMaxLine');


            axtoolbar(self.Axes,{'zoomin','zoomout','restoreview','pan'});

            xlabel(self.Axes,getString(message('medical:medicalLabeler:intensity')),'FontWeight','bold');
            ylabel(self.Axes,getString(message('medical:medicalLabeler:opacity')),'FontWeight','bold')

        end

        function hPoint=createPoint(self,pos)

            hPoint=images.roi.Point('Parent',self.Axes,...
            'Position',pos,...
            'MarkerSize',5,...
            'Color',self.Color,...
            'Selected',false,...
            'SelectedColor',self.SelectedColor,...
            'Tag','AlphamapEditorVertex',...
            'HandleVisibility','off');

            addlistener(hPoint,'ROIClicked',@(src,evt)self.controlPointSelected(src));
            addlistener(hPoint,'MovingROI',@(src,evt)self.controlPointMoving(evt.CurrentPosition));
            addlistener(hPoint,'ROIMoved',@(src,evt)self.controlPointMoved(src));
            addlistener(hPoint,'DeletingROI',@(src,evt)self.controlPointDeleted(src));

        end

        function dragArea=getDragConstraintForPoint(self,idx)






            intensityRange=self.Axes.XLim;

            if idx==1
                dragArea=[intensityRange(1),0,0,1];

            elseif idx==length(self.ControlPoints)
                dragArea=[intensityRange(2),0,0,1];

            else
                leftNeighborX=self.ControlPoints(idx-1).Position(1);
                minLeftX=leftNeighborX+self.NeighborPointDelta;

                rightNeighborX=self.ControlPoints(idx+1).Position(1);
                maxRightX=rightNeighborX-self.NeighborPointDelta;

                dragArea=[minLeftX,0,maxRightX-minLeftX,1];

            end

        end

        function updatePatchCordinates(self)





















            xLim=self.Line.XData([1,end]);
            yLim=[1,1];
            xData=[self.Line.XData,xLim(2),xLim(1)];
            yData=[self.Line.YData,yLim(2),yLim(2)];

            set(self.ColormapPatch,'XData',xData,'YData',yData);

        end

        function updateLine(self)

            controlPointsPos=self.ControlPointsPos;
            xData=controlPointsPos(:,1);
            yData=controlPointsPos(:,2);


            set(self.Line,'XData',xData,'YData',yData);



            self.updatePatchCordinates();

            self.AlphamapUpdatedEventCoalescer.trigger();

        end

        function triggerAlphamapUpdate(self)

            evtData=medical.internal.app.labeler.events.ValueEventData(self.ControlPointsPos);
            self.notify('AlphaControlPtsUpdated',evtData);

        end

    end


    methods(Access=private)

        function controlPointMoving(self,newPos)


            self.IntensityEditfield.Value=newPos(1);
            self.OpacityEditfield.Value=newPos(2);

            self.updateLine();

        end

        function controlPointMoved(self,hPoint)

            idx=find(self.ControlPoints==hPoint);

            if idx==1||idx==numel(self.ControlPoints)


                return
            end



            leftNeighborIdx=idx-1;
            rightNeighborIdx=idx+1;

            self.ControlPoints(leftNeighborIdx).DrawingArea=self.getDragConstraintForPoint(leftNeighborIdx);
            self.ControlPoints(rightNeighborIdx).DrawingArea=self.getDragConstraintForPoint(rightNeighborIdx);

        end

        function controlPointSelected(self,hPoint)

            idx=find(self.ControlPoints==hPoint);
            self.SelectedPointIdx=idx;

        end

        function controlPointDeleted(self,hPoint)




            idx=find(self.ControlPoints==hPoint);
            self.ControlPoints(idx)=[];
            leftNeighborIdx=idx-1;
            rightNeighborIdx=idx;



            self.ControlPoints(leftNeighborIdx).DrawingArea=self.getDragConstraintForPoint(leftNeighborIdx);
            self.ControlPoints(rightNeighborIdx).DrawingArea=self.getDragConstraintForPoint(rightNeighborIdx);


            self.PointSpinner.Limits=[1,length(self.ControlPoints)];


            self.SelectedPointIdx=leftNeighborIdx;

            self.updateLine();

        end

        function addControlPointToLine(self,evt)

            xLim=self.Axes.XLim;

            hitPosX=evt.IntersectionPoint(1);
            hitPosX(hitPosX<xLim(1))=xLim(1);
            hitPosX(hitPosX>xLim(2))=xLim(2);

            hitPosY=evt.IntersectionPoint(2);
            hitPosY(hitPosY<0)=0;
            hitPosY(hitPosY>1)=1;


            leftIdx=find(self.ControlPointsPos(:,1)<hitPosX,1,'last');
            rightIdx=leftIdx+1;


            self.ControlPoints((rightIdx+1):(end+1))=self.ControlPoints(rightIdx:end);



            hPoint=self.createPoint([hitPosX,hitPosY]);
            self.ControlPoints(leftIdx+1)=hPoint;



            currentIdx=leftIdx+1;
            rightIdx=currentIdx+1;
            self.ControlPoints(leftIdx).DrawingArea=self.getDragConstraintForPoint(leftIdx);
            self.ControlPoints(currentIdx).DrawingArea=self.getDragConstraintForPoint(currentIdx);
            self.ControlPoints(rightIdx).DrawingArea=self.getDragConstraintForPoint(rightIdx);


            self.PointSpinner.Limits=[1,length(self.ControlPoints)];


            self.SelectedPointIdx=currentIdx;

            self.updateLine();

        end

        function pointSpinnerUpdated(self,val)
            self.SelectedPointIdx=val;
        end

        function pointIntensityChanged(self,intensity)

            pointIdx=self.PointSpinner.Value;

            drawingArea=self.getDragConstraintForPoint(pointIdx);

            minAllowed=drawingArea(1);
            maxAllowed=drawingArea(1)+drawingArea(3);

            intensityNew=max(minAllowed,intensity);
            intensityNew=min(maxAllowed,intensityNew);

            self.ControlPoints(pointIdx).Position(1)=intensityNew;

            if intensity~=intensityNew
                self.IntensityEditfield.Value=intensityNew;
            end

            self.updateLine();
        end

        function pointOpacityChanged(self,opacity)

            pointIdx=self.PointSpinner.Value;

            self.ControlPoints(pointIdx).Position(2)=opacity;

            self.updateLine();

        end

    end

end

classdef ColormapEditor<handle




    properties(Dependent)




ControlPointsValue

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
ControlPointsColor

PointSpinner

IntensityEditfield

ColorImage

ColormapUpdatedEventCoalescer

    end

    properties(Access=private)

BackgroundColorImage

    end

    properties(Access=private,Constant)

        Color=[0,0.4470,0.7410];

        SelectedColor=[0,1,0];

        AxesYLength=256;

    end

    events

ColorControlPtsUpdated
BringAppToFront

    end

    methods

        function self=ColormapEditor(hPanel)

            self.Panel=hPanel;

            self.create();


            img=1:256;
            img=repmat(img,[self.AxesYLength,1]);
            self.BackgroundColorImage=image('CData',img,...
            'Tag','BackgroundColorImage',...
            'Parent',self.Axes,...
            'XData',self.Axes.XLim,...
            'YData',self.Axes.YLim);
            self.BackgroundColorImage.ButtonDownFcn=@(hobj,evt)self.addControlPoint(evt);


            self.Axes.Toolbar=[];
            disableDefaultInteractivity(self.Axes);

            self.ColormapUpdatedEventCoalescer=images.internal.app.utilities.EventCoalescerPeriodic();
            addlistener(self.ColormapUpdatedEventCoalescer,'EventTriggered',@(src,evt)self.triggerColormapUpdate());



        end

        function delete(self)
            delete(self.ColormapUpdatedEventCoalescer);
        end

        function clear(self)

            delete(self.ControlPoints);

            img=1:256;
            img=repmat(img,[diff(self.Axes.YLim),1]);
            set(self.BackgroundColorImage,...
            'CData',img);

        end

    end


    methods




        function set.ControlPointsValue(self,cpValue)

            delete(self.ControlPoints);
            self.ControlPoints=images.roi.Point.empty();

            numPoints=size(cpValue,1);
            self.ControlPointsColor=cpValue(:,2:4);


            self.Axes.XLim=[cpValue(1,1),cpValue(numPoints,1)];

            for idx=1:numPoints
                posX=cpValue(idx,1);
                hPoint=self.createPoint(posX);
                self.ControlPoints(idx)=hPoint;
            end



            self.ControlPoints(1).ContextMenu=[];
            self.ControlPoints(end).ContextMenu=[];



            for idx=1:numPoints
                self.ControlPoints(idx).DrawingArea=self.getDragConstraintForPoint(idx);
            end












            set(self.BackgroundColorImage,'XData',self.Axes.XLim,'YData',self.Axes.YLim);

            self.PointSpinner.Limits=[1,numPoints];


            self.SelectedPointIdx=1;

        end

        function pos=get.ControlPointsValue(self)

            numPoints=length(self.ControlPoints);
            pos=zeros(numPoints,4);

            for idx=1:numPoints
                intensity=self.ControlPoints(idx).Position(1);
                color=self.ControlPointsColor(idx,:);
                pos(idx,:)=[intensity,color];
            end

        end




        function set.SelectedPointIdx(self,idx)


            set(self.ControlPoints,'Selected',false);
            self.ControlPoints(idx).Selected=idx;

            controlPointPos=self.ControlPointsValue(idx,:);


            self.PointSpinner.Value=idx;
            self.IntensityEditfield.Value=controlPointPos(1);
            self.ColorImage.ImageSource=self.computeColorPatch(self.ControlPointsColor(idx,:));



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

        function cmap=get.BackgroundColormap(self)

            cmap=self.BackgroundColormap;

        end

    end

    methods(Access=private)

        function create(self)








            grid=uigridlayout('Parent',self.Panel,...
            'RowHeight',{'1x',45},...
            'ColumnWidth',{'1x'},...
            'RowSpacing',5,...
            'ColumnSpacing',5,...
            'Padding',20);


            self.Axes=axes('Parent',grid,...
            'Units','pixels',...
            'XTick',[],'YTick',[],...
            'TickDir','in',...
            'Clipping','on',...
            'XLimMode','manual',...
            'YLimMode','manual',...
            'XLim',[0,255],...
            'YLim',[0,self.AxesYLength],...
            'HandleVisibility','off');
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
            'ValueChangedFcn',@(src,evt)self.pointIntensityChanged(evt.Value),...
            'Tag','IntensityEditField',...
            'Tooltip',getString(message('medical:medicalLabeler:intensitySelectedPoint')),...
            'HandleVisibility','off');
            self.IntensityEditfield.Layout.Row=1;
            self.IntensityEditfield.Layout.Column=6;

            colorLabel=uilabel('Parent',uicontrolsGrid,...
            'Text',getString(message('medical:medicalLabeler:color')),...
            'Tag','ColorLabel',...
            'HandleVisibility','off');
            colorLabel.Layout.Row=1;
            colorLabel.Layout.Column=8;

            self.ColorImage=uiimage('Parent',uicontrolsGrid,...
            'Tag','ColorButton',...
            'ImageClickedFcn',@(src,evt)self.pointColorChangeRequested(),...
            'Tooltip',getString(message('medical:medicalLabeler:colorSelectedPoint')),...
            'HandleVisibility','off');
            self.ColorImage.Layout.Row=1;
            self.ColorImage.Layout.Column=9;

        end

        function hPoint=createPoint(self,posX)

            posY=diff(self.Axes.YLim)/2;
            hPoint=images.roi.Point('Parent',self.Axes,...
            'Position',[posX,posY],...
            'MarkerSize',8,...
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






            yPos=diff(self.Axes.YLim)/2;

            intensityRange=self.Axes.XLim;

            if idx==1
                dragArea=[intensityRange(1),yPos,0,0];

            elseif idx==length(self.ControlPoints)
                dragArea=[intensityRange(2),yPos,0,0];

            else
                leftNeighborX=self.ControlPoints(idx-1).Position(1);
                minLeftX=leftNeighborX+1e-6;

                rightNeighborX=self.ControlPoints(idx+1).Position(1);
                maxRightX=rightNeighborX-1e-6;

                dragArea=[minLeftX,yPos,maxRightX-minLeftX,0];

            end

        end

        function img=computeColorPatch(~,rgbValue)
            img=repmat(permute(rgbValue,[1,3,2]),[20,20,1]);
        end

        function cmap=computeColormapFromMarkers(self)

            pos=cell2mat(get(self.ControlPoints,'Position'));
            intensityValues=pos(:,1);
            colorValues=self.ControlPointsColor;

            intensityRange=self.Axes.XLim;
            queryPoints=intensityRange(1):intensityRange(2);
            cmap=interp1(intensityValues,colorValues,queryPoints);

        end

    end


    methods(Access=private)

        function controlPointMoving(self,newPos)


            self.IntensityEditfield.Value=newPos(1);

            self.updateImage();

        end

        function controlPointMoved(self,~)

            idx=self.PointSpinner.Value;

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
            self.ControlPointsColor(idx,:)=[];
            leftNeighborIdx=idx-1;
            rightNeighborIdx=idx;



            self.ControlPoints(leftNeighborIdx).DrawingArea=self.getDragConstraintForPoint(leftNeighborIdx);
            self.ControlPoints(rightNeighborIdx).DrawingArea=self.getDragConstraintForPoint(rightNeighborIdx);


            self.PointSpinner.Limits=[1,length(self.ControlPoints)];


            self.SelectedPointIdx=leftNeighborIdx;

            self.updateImage();

        end

        function addControlPoint(self,evt)

            xLim=self.Axes.XLim;

            hitPosX=evt.IntersectionPoint(1);
            hitPosX(hitPosX<xLim(1))=xLim(1);
            hitPosX(hitPosX>xLim(2))=xLim(2);

            currentControlPointsValue=self.ControlPointsValue(:,1);


            leftIdx=find(currentControlPointsValue(:,1)<hitPosX,1,'last');
            rightIdx=leftIdx+1;


            self.ControlPoints((rightIdx+1):(end+1))=self.ControlPoints(rightIdx:end);
            self.ControlPointsColor((rightIdx+1):(end+1),:)=self.ControlPointsColor(rightIdx:end,:);



            hPoint=self.createPoint(hitPosX);
            self.ControlPoints(leftIdx+1)=hPoint;
            cmapIndex=abs(((hitPosX)/diff(self.BackgroundColorImage.XData))*256);
            self.ControlPointsColor(leftIdx+1,:)=self.BackgroundColormap(round(cmapIndex),:);



            currentIdx=leftIdx+1;
            rightIdx=currentIdx+1;
            self.ControlPoints(leftIdx).DrawingArea=self.getDragConstraintForPoint(leftIdx);
            self.ControlPoints(currentIdx).DrawingArea=self.getDragConstraintForPoint(currentIdx);
            self.ControlPoints(rightIdx).DrawingArea=self.getDragConstraintForPoint(rightIdx);


            self.PointSpinner.Limits=[1,length(self.ControlPoints)];


            self.SelectedPointIdx=currentIdx;

            self.updateImage();


        end

        function updateImage(self)




            self.ColormapUpdatedEventCoalescer.trigger();

        end

        function triggerColormapUpdate(self)

            evtData=medical.internal.app.labeler.events.ValueEventData(self.ControlPointsValue);
            self.notify('ColorControlPtsUpdated',evtData);

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

            self.updateImage();
        end

        function pointColorChangeRequested(self)

            pointIdx=self.PointSpinner.Value;
            currColor=self.ControlPointsColor(pointIdx,:);

            newColor=uisetcolor(currColor);
            self.notify('BringAppToFront');

            if isequal(currColor,newColor)
                return
            end

            self.ControlPointsColor(pointIdx,:)=newColor;

            self.updateImage();

        end

    end

end

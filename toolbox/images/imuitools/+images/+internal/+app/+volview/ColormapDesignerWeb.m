classdef ColormapDesignerWeb<handle





    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)

hFig
hPanel
hAx
hIm
hMarkers

ColormapLabel
ColormapButtonGroup
BuiltinRadioBtn
BuiltinPopup
WorkspaceRadioBtn
WorkspacePopup

    end

    properties(Access=private)

ColormapList

hContextMenu
hSetColorContextMenu

AxSizeInPixels
YMiddle

StartDragX
PrevDragX
MarkerBeingDragged
DragLeftNeighborX
DragRightNeighborX
ColormapInternal

ColormapSourceChangeListener

Timer

    end

    properties(Dependent)

Colormap
Position
Enable

    end

    properties(Constant)

        ColormapLength=256

    end


    events
ColormapEdit
ColormapChange
BringAppInFocus
    end

    methods

        function self=ColormapDesignerWeb(hPanel,colorControlPoints)

            self.hFig=ancestor(hPanel,'figure');

            self.hContextMenu=uicontextmenu(self.hFig,'Tag','ControlPointContextMenu');
            self.hSetColorContextMenu=uicontextmenu(self.hFig,'Tag','ColormapEditor');
            uimenu(self.hContextMenu,'Label',getString(message('images:roiContextMenuUIString:setColorContextMenuLabel')),'Callback',@(hobj,evt)self.setControlPointColor(self.hFig.CurrentObject));
            uimenu(self.hSetColorContextMenu,'Label',getString(message('images:roiContextMenuUIString:setColorContextMenuLabel')),'Callback',@(hobj,evt)self.setControlPointColor(self.hFig.CurrentObject));
            uimenu(self.hContextMenu,'Label',getString(message('images:roiContextMenuUIString:deleteRoiLabel')),'Callback',@(hobj,evt)self.removeMarker());

            self.ColormapList=images.internal.app.volview.MapListManager('volumeColormap');

            self.layoutColormapPanel(hPanel);

            self.Position=colorControlPoints;

            self.Timer=images.internal.app.utilities.eventCoalescer.Periodic();
            addlistener(self.Timer,'PeriodicEventTriggered',@(~,~)timerCallback(self));

        end

        function delete(self)
            delete(self.Timer);
        end

    end


    methods

        function set.Colormap(self,cmap)
            self.ColormapInternal=cmap;
            colormap(self.hAx,self.Colormap)
        end

        function cmapNew=get.Colormap(self)
            cmapNew=self.ColormapInternal;
        end

        function set.Position(self,colorControlPoints)


            numMarkers=size(colorControlPoints,1);
            self.YMiddle=1+diff(self.hIm.YData)/2;
            delete(self.hMarkers);
            self.hMarkers=matlab.graphics.primitive.Line.empty();
            self.hMarkers(1)=self.createMarker(1,self.YMiddle);
            self.hMarkers(numMarkers)=self.createMarker(self.hIm.XData(2),self.YMiddle);
            setMarkerColor(self.hMarkers(1),colorControlPoints(1,2:end));
            setMarkerColor(self.hMarkers(numMarkers),colorControlPoints(numMarkers,2:end));
            self.hMarkers(1).Tag='endpoint';
            self.hMarkers(numMarkers).Tag='endpoint';
            self.hMarkers(1).UIContextMenu=self.hSetColorContextMenu;
            self.hMarkers(numMarkers).UIContextMenu=self.hSetColorContextMenu;


            for p=2:(numMarkers-1)
                xPos=1+255*colorControlPoints(p,1);
                self.hMarkers(p)=self.createMarker(xPos,self.YMiddle);
                setMarkerColor(self.hMarkers(p),colorControlPoints(p,2:end));
                self.hMarkers(p).UIContextMenu=self.hContextMenu;
                iptSetPointerBehavior(self.hMarkers(p),@(varargin)setptr(self.hFig,'lrdrag'));
            end



            cmap=self.computeColormapFromMarkers();
            self.Colormap=cmap;

        end

        function colorControlPoints=get.Position(self)

            numMarkers=length(self.hMarkers);
            colorControlPoints=zeros(numMarkers,4);

            for i=1:length(self.hMarkers)
                colorControlPoints(i,1)=self.hMarkers(i).XData;
                colorControlPoints(i,2:4)=getMarkerColor(self.hMarkers(i));
            end

        end

        function set.Enable(self,TF)

            if TF
                self.hIm.HitTest='on';
                colormap(self.hAx,self.Colormap)
                for i=1:length(self.hMarkers)
                    self.hMarkers(i).Visible='on';
                end
                self.ColormapLabel.Enable='on';
                self.BuiltinRadioBtn.Enable='on';
                self.WorkspaceRadioBtn.Enable='on';
                if self.BuiltinRadioBtn.Value==1
                    self.BuiltinPopup.Enable='on';
                else
                    if~isempty(self.WorkspacePopup.Items)
                        self.WorkspacePopup.Enable='on';
                    end
                end
            else
                self.hIm.HitTest='off';
                allGrayColormap=repmat([0.7,0.7,0.7],[self.ColormapLength,1]);
                colormap(self.hAx,allGrayColormap);
                for i=1:length(self.hMarkers)
                    self.hMarkers(i).Visible='off';
                end
                self.ColormapLabel.Enable='off';
                self.BuiltinRadioBtn.Enable='off';
                self.WorkspaceRadioBtn.Enable='off';
                self.BuiltinPopup.Enable='off';
                self.WorkspacePopup.Enable='off';
            end

        end

        function setDefaults(self)
            self.BuiltinRadioBtn.Value=1;
            self.WorkspacePopup.Enable='off';
            colormaps=self.BuiltinPopup.Items;
            if strcmp(colormaps{end},getString(message('images:volumeViewer:custom')))
                self.BuiltinPopup.Items=colormaps(1:end-1);
            end
            self.BuiltinPopup.Value=self.ColormapList.getDefaultIdx;
            self.BuiltinPopup.Enable='on';
        end

    end

    methods(Access=private)

        function layoutColormapPanel(self,hPanel)

            grid=uigridlayout('Parent',hPanel,...
            'ColumnWidth',{150,'1x'},...
            'RowHeight',{0,30,30,34},...
            'ColumnSpacing',0);

            self.ColormapLabel=uilabel('Parent',grid,...
            'Text',getString(message('images:volumeViewer:colormap')),...
            'FontWeight','bold',...
            'FontSize',12);
            self.ColormapLabel.Layout.Row=1;
            self.ColormapLabel.Layout.Column=1;

            self.ColormapButtonGroup=uibuttongroup(grid,...
            'BorderType','none',...
            'Units','normalized',...
            'SelectionChangedFcn',@self.colormapSourceChange);
            self.ColormapButtonGroup.Layout.Row=[2,3];
            self.ColormapButtonGroup.Layout.Column=1;
            self.ColormapButtonGroup.AutoResizeChildren='off';

            self.BuiltinRadioBtn=uiradiobutton('Parent',self.ColormapButtonGroup,...
            'Tag','cmapFcnButton',...
            'Position',[5,40,150,20],...
            'Text',getString(message('images:volumeViewer:builtinColormap')),...
            'Tooltip',getString(message('images:volumeViewer:builtinColormapTooltip')));

            self.WorkspaceRadioBtn=uiradiobutton('Parent',self.ColormapButtonGroup,...
            'Tag','cmapVarButton',...
            'Position',[5,5,150,30],...
            'Text',getString(message('images:volumeViewer:wkspVariables')),...
            'Tooltip',getString(message('images:volumeViewer:workspaceColormapTooltip')));

            panel=uipanel('Parent',grid,...
            'BorderType','none',...
            'AutoResizeChildren','on');
            panel.Layout.Row=[2,3];
            panel.Layout.Column=2;

            self.BuiltinPopup=uidropdown('parent',panel,...
            'Items',self.ColormapList.List,...
            'ItemsData',1:numel(self.ColormapList.List),...
            'Value',self.ColormapList.getDefaultIdx,...
            'Tag','BuiltinPopup',...
            'ValueChangedFcn',@self.setColormapFromPopup,...
            'Tooltip',getString(message('images:volumeViewer:builtinColormapTooltip')));
            self.BuiltinPopup.Position=[1,40,125,20];

            self.WorkspacePopup=uidropdown('parent',panel,...
            'Items',{''},...
            'Tag','WorkspacePopup',...
            'ValueChangedFcn',@self.setColormapFromPopup,...
            'Enable','off',...
            'Tooltip',getString(message('images:volumeViewer:workspaceColormapTooltip')));
            self.WorkspacePopup.Position=[1,10,125,20];

            grid2=uigridlayout(grid,[1,1],...
            'Padding',0,...
            'ColumnSpacing',0);
            grid2.Layout.Row=4;
            grid2.Layout.Column=[1,2];

            self.hAx=axes('Parent',grid2,...
            'Visible','off',...
            'Clipping','off',...
            'Tag','Colorbar');

            img=1:self.ColormapLength;
            img=repmat(img,[self.ColormapLength,1]);

            self.hIm=image('CData',img,'Parent',self.hAx);
            self.hIm.ButtonDownFcn=@(hobj,evt)self.axesClickAddMarker(evt);

            self.hAx.XLim=[0,255];
            self.hAx.YLim=[0,255];
            self.hAx.OuterPosition=[0,0,1,0.3];
            self.hAx.Clipping='off';
            self.hAx.Toolbar=[];
            disableDefaultInteractivity(self.hAx);

            self.hPanel.Clipping='off';


            iptPointerManager(self.hFig);
            iptSetPointerBehavior(self.hIm,@(varargin)setptr(self.hFig,'add'));

        end

        function axesClickAddMarker(self,evt)

            self.addMarker(evt.IntersectionPoint(1)/self.ColormapLength);

        end

        function hMarker=createMarker(self,xPos,yPos)
            hMarker=line(xPos,yPos,'Marker','o','Parent',self.hAx);
            hMarker.MarkerSize=15;
            hMarker.MarkerFaceColor='white';
            hMarker.MarkerEdgeColor='black';
            hMarker.ButtonDownFcn=@(hObj,evt)self.manageMarkerButtonDown(hObj,evt);
            hMarker.PickableParts='all';
        end

        function removeMarker(self)

            hMarker=self.hFig.CurrentObject;
            self.hMarkers(self.hMarkers==hMarker)=[];

            delete(hMarker);
            self.Colormap=self.computeColormapFromMarkers();

            self.reactToColormapEdit();
        end

        function addMarker(self,xNormalizedPos)

            currentColormap=self.Colormap;


            xPos=round(1+xNormalizedPos*diff(self.hIm.XData));
            xPos=max(1,xPos);
            xPos=min(xPos,self.ColormapLength);

            insertIdx=1;
            for i=1:length(self.hMarkers)
                if xPos<self.hMarkers(i).XData
                    insertIdx=i;
                    break;
                end
            end

            hMarkerNew=self.hMarkers;
            hMarkerNew(end+1)=hMarkerNew(end);
            hMarkerNew(1:(insertIdx-1))=self.hMarkers(1:(insertIdx-1));
            hAddedMarker=self.createMarker(xPos,self.YMiddle);
            hMarkerNew(insertIdx)=hAddedMarker;
            hMarkerNew((insertIdx+1):end)=self.hMarkers(insertIdx:end);
            self.hMarkers=hMarkerNew;

            setMarkerColor(hAddedMarker,currentColormap(xPos,:));
            hAddedMarker.UIContextMenu=self.hContextMenu;
            iptSetPointerBehavior(hAddedMarker,@(varargin)setptr(self.hFig,'lrdrag'));

            self.reactToColormapEdit();

        end

        function setControlPointColor(self,hMarker)

            newColor=uisetcolor(getMarkerColor(hMarker));
            setMarkerColor(hMarker,newColor);
            cmap=self.computeColormapFromMarkers();
            self.Colormap=cmap;

            self.notify('BringAppInFocus');

            self.reactToColormapEdit();
        end

        function manageMarkerButtonDown(self,hObj,~)

            doubleClick=strcmp(self.hFig.SelectionType,'open');
            if doubleClick

                self.setControlPointColor(hObj);
            else

                if~strcmp(hObj.Tag,'endpoint')
                    idx=find(hObj==self.hMarkers);
                    self.DragLeftNeighborX=self.hMarkers(idx-1).XData;
                    self.DragRightNeighborX=self.hMarkers(idx+1).XData;
                    self.hFig.WindowButtonMotionFcn=@(hObj,evt)self.dragControlPoint();
                    self.hFig.WindowButtonUpFcn=@(hObj,evt)self.endControlPointDrag();
                    self.PrevDragX=self.hAx.CurrentPoint(1);
                    self.StartDragX=self.hAx.CurrentPoint(1);
                    self.MarkerBeingDragged=hObj;


                end


            end
        end

        function dragControlPoint(self)

            deltaX=self.hAx.CurrentPoint(1)-self.StartDragX;
            newPosX=self.StartDragX+deltaX;



            newPosX=max(newPosX,self.DragLeftNeighborX+1);
            newPosX=min(newPosX,self.DragRightNeighborX-1);
            self.PrevDragX=max(self.PrevDragX,self.DragLeftNeighborX+1);
            self.PrevDragX=min(self.PrevDragX,self.DragRightNeighborX-1);


            self.MarkerBeingDragged.XData=newPosX;
            cmap=self.Colormap;


            leftX=floor(self.DragLeftNeighborX);
            rightX=floor(self.DragRightNeighborX);
            oldX=floor(self.PrevDragX);
            newX=floor(newPosX);



            xLhs=leftX:oldX;
            vLhs=cmap(xLhs,:);
            newLhsSize=newX-leftX+1;
            if isscalar(xLhs)
                vqLhs=repmat(vLhs,[newLhsSize,1]);
            else
                xqLhs=linspace(leftX,oldX,newLhsSize);
                vqLhs=interp1(xLhs,vLhs,xqLhs);
            end


            xRhs=oldX+1:rightX;
            vRhs=cmap(xRhs,:);
            newRhsSize=rightX-(newX+1)+1;
            if isscalar(xRhs)
                vqRhs=repmat(vRhs,[newRhsSize,1]);
            else
                xqRhs=linspace(oldX+1,rightX,newRhsSize);
                vqRhs=interp1(xRhs,vRhs,xqRhs);
            end

            cmap(leftX:rightX,:)=[vqLhs;vqRhs];

            self.PrevDragX=floor(newPosX);
            self.Colormap=cmap;

            self.Timer.trigger();

        end

        function endControlPointDrag(self)

            self.hFig.WindowButtonMotionFcn='';
            self.hFig.WindowButtonUpFcn='';

            self.Timer.stop();

        end

        function reactToColormapEdit(self)

            import images.internal.app.volview.events.*
            self.WorkspacePopup.Enable='off';
            self.BuiltinPopup.Enable='on';
            self.BuiltinRadioBtn.Value=1;

            colormapList=self.BuiltinPopup.Items;
            if~strcmp(colormapList{end},getString(message('images:volumeViewer:custom')))
                colormapList{end+1}=getString(message('images:volumeViewer:custom'));
            end
            self.BuiltinPopup.Items=colormapList;
            self.BuiltinPopup.ItemsData=1:numel(colormapList);
            self.BuiltinPopup.Value=length(colormapList);

            self.notify('ColormapEdit',ColormapChangeEventData(self.Colormap));

        end

        function colormapSourceChange(self,~,event)

            if isempty(self.BuiltinPopup.Items{end})
                self.BuiltinPopup.Items=self.ColormapList.List;
                self.BuiltinPopup.ItemsData=1:numel(self.ColormapList.List);
                self.BuiltinPopup.Value=1;
            end

            if isequal(event.NewValue,self.BuiltinRadioBtn)
                self.WorkspacePopup.Enable='off';
                self.BuiltinPopup.Enable='on';


                colormaps=self.BuiltinPopup.Items;
                self.setNewColormap('BuiltinPopup',colormaps{self.BuiltinPopup.Value});
            else
                workspaceVariables=evalin('base','whos');
                varInd=iptui.internal.filterWorkspaceVars(workspaceVariables,'colormap');
                varList={workspaceVariables(varInd).name};
                self.BuiltinPopup.Enable='off';
                self.WorkspacePopup.Enable='on';

                if isempty(varList)
                    self.WorkspacePopup.Items={'NA'};
                    self.WorkspacePopup.ItemsData=1;
                    self.WorkspacePopup.Value=1;
                    self.WorkspacePopup.Enable='off';
                else

                    previousCmap=[];
                    if~isempty(self.WorkspacePopup.Value)
                        previousCmap=self.WorkspacePopup.Items{self.WorkspacePopup.Value};
                    end

                    self.WorkspacePopup.Items=varList;
                    self.WorkspacePopup.ItemsData=1:numel(varList);

                    if~isempty(previousCmap)&&any(strcmp(previousCmap,varList))
                        idx=find(strcmp(previousCmap,self.WorkspacePopup.Items));
                        self.WorkspacePopup.Value=idx;
                        self.setNewColormap('WorkspacePopup',previousCmap);
                    else
                        self.WorkspacePopup.Value=1;
                        self.setNewColormap('WorkspacePopup',self.WorkspacePopup.Items{1});
                    end

                end
            end
        end

        function setColormapFromPopup(self,source,event)

            val=source.Value;
            maps=source.Items;
            newColormapName=maps{val};
            self.setNewColormap(event.Source.Tag,newColormapName);
        end

        function setNewColormap(self,sourcePopup,newColormapName)

            import images.internal.app.volview.events.*
            colorCP=[];
            switch sourcePopup
            case 'WorkspacePopup'
                newColormap=evalin('base',newColormapName);
                numColors=size(newColormap,1);
                if(numColors~=256)
                    xq=linspace(1,numColors,256);
                    newColormap=interp1(1:numColors,newColormap,xq);
                end

            case 'BuiltinPopup'
                if strcmp(newColormapName,getString(message('images:volumeViewer:custom')))
                    return
                else
                    colormaps=self.BuiltinPopup.Items;
                    if strcmp(colormaps{end},getString(message('images:volumeViewer:custom')))
                        self.BuiltinPopup.Items=colormaps(1:end-1);
                        self.BuiltinPopup.ItemsData=1:numel(colormaps(1:end-1));
                    end
                end

                [newColormap,colorCP]=self.ColormapList.getColormap(newColormapName);

            otherwise
                assert(false,'Invalid User data');
            end

            if isempty(colorCP)
                colorCP=[0,0,0,0;1.0,1.0,1.0,1.0];
            end

            self.Position=colorCP;
            self.Colormap=newColormap;

            self.notify('ColormapChange',ColormapChangeEventData(newColormap,colorCP));

        end

        function cmap=computeColormapFromMarkers(self)

            colorControlPoints=self.Position;
            intensityValues=colorControlPoints(:,1);





            [uniqueIntensities,indexOfUniqueIntensities]=unique(intensityValues);
            uniqueColors=colorControlPoints(indexOfUniqueIntensities,2:4);

            queryPoints=linspace(1,self.ColormapLength,self.ColormapLength);
            cmap=interp1(uniqueIntensities,uniqueColors,queryPoints);
        end

        function timerCallback(self)
            self.reactToColormapEdit();
        end

    end

end

function setMarkerColor(hMarker,newColor)
    setappdata(hMarker,'MarkerColor',newColor);
end

function c=getMarkerColor(hMarker)
    c=getappdata(hMarker,'MarkerColor');
end

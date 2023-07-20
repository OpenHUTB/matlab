classdef AlphamapEditorWeb<handle





    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)
hParent
hPoints
hLine
    end

    properties(Dependent)
Position
Enable
    end

    properties(Access=private)

SettingNewPosition
        Color=[0,0.4470,0.7410];

    end

    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)
AlphamapList
AlphamapLabel
AlphamapPopup
    end

    properties(Access=private)
PositionChangedEventCoalescer
    end

    events
PositionChange
AlphamapChange
    end

    methods

        function obj=AlphamapEditorWeb(hPanel,posInit)

            obj.AlphamapList=images.internal.app.volview.MapListManager('volumeAlphamap');

            obj.PositionChangedEventCoalescer=images.internal.app.utilities.eventCoalescer.Periodic();
            addlistener(obj.PositionChangedEventCoalescer,'PeriodicEventTriggered',@(~,~)posChangedCallback(obj));

            grid1=uigridlayout('Parent',hPanel,...
            'ColumnWidth',{'fit','1x'},...
            'RowHeight',{'fit',310},...
            'RowSpacing',0);

            obj.AlphamapLabel=uilabel('Parent',grid1,...
            'Text',getString(message('images:volumeViewer:alphamap')),...
            'FontSize',12,...
            'FontWeight','normal',...
            'Tooltip',getString(message('images:volumeViewer:alphamapPopupTooltip')));
            obj.AlphamapLabel.Layout.Row=1;
            obj.AlphamapLabel.Layout.Column=1;

            obj.AlphamapPopup=uidropdown('Parent',grid1,...
            'Items',obj.AlphamapList.List,...
            'ItemsData',1:numel(obj.AlphamapList.List),...
            'Value',obj.AlphamapList.getDefaultIdx,...
            'ValueChangedFcn',@obj.setAlphamap,...
            'Tag','AlphamapPopup',...
            'Tooltip',getString(message('images:volumeViewer:alphamapPopupTooltip')));
            obj.AlphamapPopup.Layout.Row=1;
            obj.AlphamapPopup.Layout.Column=2;


            grid2=uigridlayout(grid1,[1,1],...
            'RowSpacing',0);
            grid2.Layout.Row=2;
            grid2.Layout.Column=[1,2];

            hAx=axes('Parent',grid2,...
            'Units','Normalized',...
            'InnerPosition',[0,0,1,1],...
            'XTickLabel','',...
            'YTickLabel','',...
            'XLimMode','manual',...
            'YLimMode','manual',...
            'Box','on');
            hAx.Toolbar=[];
            disableDefaultInteractivity(hAx);

            xlabel(hAx,getString(message('images:volumeViewer:imageIntensity')));
            ylabel(hAx,getString(message('images:volumeViewer:opacity')));

            obj.SettingNewPosition=false;
            obj.hParent=hAx;
            obj.hPoints=images.roi.Point.empty();
            obj.hLine=matlab.graphics.primitive.Line.empty();
            obj.Position=posInit;

            hFig=ancestor(hPanel,'figure');
            addlistener(hFig,'WindowMousePress',@(src,evt)obj.wireDragConstraint(src,evt));
        end

        function delete(self)
            delete(self.PositionChangedEventCoalescer)
        end

    end

    methods(Access=private)

        function createNewPoint(obj,pos,idx)

            newPoint=images.roi.Point('Parent',obj.hParent,...
            'Position',pos,...
            'MarkerSize',4,...
            'Color',obj.Color,...
            'Tag','alphamapEditorVertex');
            addlistener(newPoint,'MovingROI',@(~,~)obj.vertexDrag());
            addlistener(newPoint,'ROIMoved',@(~,~)obj.finishMoving());

            obj.hPoints(idx)=newPoint;



            addlistener(newPoint,'ObjectBeingDestroyed',@(hObj,evt)obj.vertexDeleted(newPoint));

        end

        function vertexDeleted(obj,hPoint)







            if~isvalid(obj)||~isvalid(obj.hParent)||obj.SettingNewPosition
                return
            end

            idx=find(obj.hPoints==hPoint);
            leftNeighbor=obj.hPoints(idx-1);
            rightNeighbor=obj.hPoints(idx+1);
            obj.hPoints(idx)=[];




            leftNeighborIsFirstPoint=find(leftNeighbor==obj.hPoints(1));
            if~leftNeighborIsFirstPoint
                leftNeighbor.DrawingArea=obj.getDrawingAreaForPoint(leftNeighbor);
            end

            rightNeighborIsLastPoint=find(rightNeighbor==obj.hPoints(end));
            if~rightNeighborIsLastPoint
                rightNeighbor.DrawingArea=obj.getDrawingAreaForPoint(rightNeighbor);
            end

            obj.updateLine();
            notify(obj,'PositionChange');

        end

        function addControlPointToLine(obj,evt)

            hitPos=evt.IntersectionPoint(1:2);
            hitPos(hitPos<0)=0;
            hitPos(hitPos>1)=1;


            leftIdx=find(obj.Position(:,1)<hitPos(1),1,'last');
            rightIdx=leftIdx+1;


            obj.hPoints((rightIdx+1):(end+1))=obj.hPoints(rightIdx:end);

            obj.createNewPoint(hitPos,leftIdx+1);
            obj.updateLine();

        end

        function vertexDrag(obj)

            obj.updateLine();

        end

        function updateLine(obj)

            obj.hLine.XData=obj.Position(:,1);
            obj.hLine.YData=obj.Position(:,2);

            obj.editAlphamapPopup();
            obj.triggerPosChangedEventCoalescer();

        end

        function wireDragConstraint(obj,~,evt)

            if isa(evt.HitObject.Parent,'images.roi.Point')
                hPoint=evt.HitObject.Parent;

                idx=find(obj.hPoints==hPoint);
                internalControlPoint=(idx==1)||(idx==length(obj.hPoints));
                if~internalControlPoint
                    obj.hPoints(idx).DrawingArea=obj.getDrawingAreaForPoint(obj.hPoints(idx));
                end

            end

        end

        function drawingArea=getDrawingAreaForPoint(obj,hPoint)

            idx=find(hPoint==obj.hPoints);

            leftNeighborPos=obj.hPoints(idx-1).Position;
            leftNeighborX=leftNeighborPos(1);
            minLeftX=leftNeighborX+1e-6;

            rightNeighborPos=obj.hPoints(idx+1).Position;
            rightNeighborX=rightNeighborPos(1);
            maxRightX=rightNeighborX-1e-6;

            drawingArea=[minLeftX,0,maxRightX-minLeftX,1];

        end

        function editAlphamapPopup(self)
            alphamapList=self.AlphamapPopup.Items;
            if~strcmp(alphamapList{end},getString(message('images:volumeViewer:custom')))
                alphamapList{end+1}=getString(message('images:volumeViewer:custom'));
            end
            self.AlphamapPopup.Items=alphamapList;
            self.AlphamapPopup.ItemsData=1:numel(alphamapList);
            self.AlphamapPopup.Value=length(alphamapList);
        end

        function setAlphamap(self,source,~)
            import images.internal.app.volview.events.*

            val=source.Value;
            maps=source.Items;
            newAlphamapName=maps{val};
            if strcmp(newAlphamapName,getString(message('images:volumeViewer:custom')))
                return
            else
                if strcmp(maps{end},getString(message('images:volumeViewer:custom')))
                    self.AlphamapPopup.Items=maps(1:end-1);
                    self.AlphamapPopup.ItemsData=1:numel(maps(1:end-1));
                end
            end

            [newAlphamap,alphaCP]=self.AlphamapList.getAlphamap(newAlphamapName);
            self.Position=alphaCP;
            self.notify('AlphamapChange',AlphamapChangeEventData(newAlphamap,alphaCP));
        end

        function finishMoving(self)
            self.PositionChangedEventCoalescer.stop();
        end

        function triggerPosChangedEventCoalescer(self)

            trigger(self.PositionChangedEventCoalescer);

        end

        function posChangedCallback(obj)

            if~isvalid(obj)
                return;
            end

            notify(obj,'PositionChange');

        end

    end


    methods

        function pos=get.Position(obj)

            numPoints=length(obj.hPoints);
            pos=zeros(numPoints,2);
            for p=1:numPoints
                pos(p,:)=obj.hPoints(p).Position;
            end

            if any(pos<0,'all')
                pos(pos<0)=0;
            elseif any(pos>1,'all')
                pos(pos>1)=1;
            end

        end

        function set.Position(obj,posInit)

            obj.SettingNewPosition=true;
            delete(obj.hPoints);
            obj.SettingNewPosition=false;
            obj.hPoints=images.roi.Point.empty();

            delete(obj.hLine);

            obj.hLine=line('Parent',obj.hParent,'XData',posInit(:,1),...
            'YData',posInit(:,2),'Color',obj.Color,'ButtonDownFcn',@(hObj,evt)obj.addControlPointToLine(evt),...
            'Tag','alphamapEditorLine');

            for p=1:size(posInit,1)
                obj.createNewPoint(posInit(p,:),p);
            end

            obj.hPoints(1).DrawingArea=[0,0,0,1];
            obj.hPoints(end).DrawingArea=[1,0,0,1];

            obj.hPoints(1).ContextMenu=[];
            obj.hPoints(end).ContextMenu=[];

        end

        function set.Enable(self,TF)

            if TF
                self.hLine.Color='blue';
                self.hLine.HitTest='on';
                for i=1:length(self.hPoints)
                    set(self.hPoints,'Visible','on');
                end
                self.AlphamapLabel.Enable='on';
                self.AlphamapPopup.Enable='on';
                self.hParent.XColor=[0,0,0];
                self.hParent.YColor=[0,0,0];

            else
                self.hLine.Color=[0.7,0.7,0.7];
                self.hLine.HitTest='off';
                for i=1:length(self.hPoints)
                    set(self.hPoints,'Visible','off');
                end
                self.AlphamapLabel.Enable='off';
                self.AlphamapPopup.Enable='off';
                self.hParent.XColor=[0.7,0.7,0.7];
                self.hParent.YColor=[0.7,0.7,0.7];
            end
        end

        function setDefaults(self)
            alphamaps=self.AlphamapPopup.Items;
            if strcmp(alphamaps{end},getString(message('images:volumeViewer:custom')))
                self.AlphamapPopup.Items=alphamaps(1:end-1);
                self.AlphamapPopup.ItemsData=1:numel(alphamaps(1:end-1));
            end
            self.AlphamapPopup.Value=self.AlphamapList.getDefaultIdx;
        end
    end
end

classdef AlphamapEditor<handle



    properties(Access=private)
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
    end

    properties
AlphamapList
AlphamapLabel
AlphamapPopup
    end

    events
PositionChange
AlphamapChange
    end

    methods

        function obj=AlphamapEditor(hPanel,posInit)

            obj.AlphamapList=images.internal.app.volviewToolgroup.MapListManager('volumeAlphamap');

            obj.AlphamapLabel=uicontrol(hPanel,'Style','text',...
            'String',getString(message('images:volumeViewerToolgroup:alphamap')),...
            'FontWeight','bold',...
            'Units','Normalized',...
            'Position',[0.0343,0.8,0.35,0.1],...
            'TooltipString',getString(message('images:volumeViewerToolgroup:alphamapPopupTooltip')));
            obj.AlphamapLabel.FontSize=obj.AlphamapLabel.FontSize+1;

            obj.AlphamapPopup=uicontrol(hPanel,...
            'Style','popup',...
            'Tag','AlphamapPopup',...
            'String',obj.AlphamapList.List,...
            'Units','normalized',...
            'Callback',@obj.setAlphamap,...
            'TooltipString',getString(message('images:volumeViewerToolgroup:alphamapPopupTooltip')));
            obj.AlphamapPopup.Position=[0.45,0.82,0.45,0.1];
            obj.AlphamapPopup.Value=obj.AlphamapList.getDefaultIdx;

            hAx=axes('Parent',hPanel,'Units','Normalized');
            hAx.OuterPosition=[0,0,1,0.85];
            hAx.XTickLabel='';
            hAx.YTickLabel='';
            hAx.XLimMode='manual';
            hAx.YLimMode='manual';
            hAx.Box='on';
            xlabel(hAx,getString(message('images:volumeViewerToolgroup:imageIntensity')));
            ylabel(hAx,getString(message('images:volumeViewerToolgroup:opacity')));

            obj.SettingNewPosition=false;
            obj.hParent=hAx;
            obj.hPoints=impoint.empty();
            obj.hLine=matlab.graphics.primitive.Line.empty();
            obj.Position=posInit;
        end

        function createNewPoint(obj,pos,idx)

            newPoint=impoint(obj.hParent,pos);%#ok<IMPNT>
            pointHGGroup=findobj(newPoint,'type','hggroup');
            pointHGGroup.Tag='alphamapEditorVertex';
            newPoint.addNewPositionCallback(@(newPos)obj.vertexDrag());
            addlistener(newPoint,'ImpointButtonDown',@(varargin)obj.wireDragConstraint(newPoint));
            obj.hPoints(idx)=newPoint;



            addlistener(newPoint,'ObjectBeingDestroyed',@(hObj,evt)obj.vertexDeleted(newPoint));

            customizeVertexContextMenu(newPoint);

        end

        function vertexDeleted(obj,hPoint)







            if~isvalid(obj.hParent)||obj.SettingNewPosition
                return
            end

            idx=find(obj.hPoints==hPoint);
            leftNeighbor=obj.hPoints(idx-1);
            rightNeighbor=obj.hPoints(idx+1);
            obj.hPoints(idx)=[];




            leftNeighborIsFirstPoint=find(leftNeighbor==obj.hPoints(1));
            if~leftNeighborIsFirstPoint
                leftNeighbor.setPositionConstraintFcn(obj.internalConstraintFcn(leftNeighbor));
            end

            rightNeighborIsLastPoint=find(rightNeighbor==obj.hPoints(end));
            if~rightNeighborIsLastPoint
                rightNeighbor.setPositionConstraintFcn(obj.internalConstraintFcn(rightNeighbor));
            end

            obj.updateLine();

        end

        function addControlPointToLine(obj,evt)

            hitPos=evt.IntersectionPoint(1:2);

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
            notify(obj,'PositionChange');

        end

        function pos=get.Position(obj)

            numPoints=length(obj.hPoints);
            pos=zeros(numPoints,2);
            for p=1:numPoints
                pos(p,:)=obj.hPoints(p).getPosition();
            end

        end

        function set.Position(obj,posInit)

            obj.SettingNewPosition=true;
            delete(obj.hPoints);
            obj.SettingNewPosition=false;
            obj.hPoints=impoint.empty();

            delete(obj.hLine);

            obj.hLine=line('Parent',obj.hParent,'XData',posInit(:,1),...
            'YData',posInit(:,2),'Color','blue','ButtonDownFcn',@(hObj,evt)obj.addControlPointToLine(evt),...
            'Tag','alphamapEditorLine');

            for p=1:size(posInit,1)
                obj.createNewPoint(posInit(p,:),p);
            end


            obj.hPoints(1).setPositionConstraintFcn(@(p)[0.0,min(max(0,p(2)),1.0)]);
            obj.hPoints(end).setPositionConstraintFcn(@(p)[1.0,min(max(0,p(2)),1.0)]);



            customizeDeleteContextMenuItem(obj.hPoints(1));
            customizeDeleteContextMenuItem(obj.hPoints(end));

        end

        function wireDragConstraint(obj,hPoint)

            idx=find(obj.hPoints==hPoint);
            internalControlPoint=(idx==1)||(idx==length(obj.hPoints));
            if~internalControlPoint
                obj.hPoints(idx).setPositionConstraintFcn(obj.internalConstraintFcn(hPoint));
            end
        end

        function fcn=internalConstraintFcn(obj,hPoint)

            idx=find(hPoint==obj.hPoints);

            leftNeighborPos=obj.hPoints(idx-1).getPosition();
            leftNeighborX=leftNeighborPos(1);

            rightNeighborPos=obj.hPoints(idx+1).getPosition();
            rightNeighborX=rightNeighborPos(1);

            fcn=@(p)[min(max(leftNeighborX+1e-6,p(1)),rightNeighborX-1e-6),...
            min(max(0.0,p(2)),1.0)];

        end

        function editAlphamapPopup(self)
            alphamapList=self.AlphamapPopup.String;
            if~strcmp(alphamapList{end},getString(message('images:volumeViewerToolgroup:custom')))
                alphamapList{end+1}=getString(message('images:volumeViewerToolgroup:custom'));
            end
            self.AlphamapPopup.String=alphamapList;
            self.AlphamapPopup.Value=length(alphamapList);
        end

        function setAlphamap(self,source,~)
            import images.internal.app.volviewToolgroup.*

            val=source.Value;
            maps=source.String;
            newAlphamapName=maps{val};
            if strcmp(newAlphamapName,getString(message('images:volumeViewerToolgroup:custom')))
                return
            else
                if strcmp(maps{end},getString(message('images:volumeViewerToolgroup:custom')))
                    self.AlphamapPopup.String=maps(1:end-1);
                end
            end

            [newAlphamap,alphaCP]=self.AlphamapList.getAlphamap(newAlphamapName);
            self.Position=alphaCP;
            self.notify('AlphamapChange',AlphamapChangeEventData(newAlphamap,alphaCP));
        end

        function set.Enable(self,TF)

            if TF
                self.hLine.Color='blue';
                self.hLine.HitTest='on';
                for i=1:length(self.hPoints)
                    hgroup=findobj(self.hPoints(i),'type','hggroup');
                    hgroup.Visible='on';
                end
                self.AlphamapLabel.Enable='on';
                self.AlphamapPopup.Enable='on';
                self.hParent.XColor=[0,0,0];
                self.hParent.YColor=[0,0,0];

            else
                self.hLine.Color=[0.7,0.7,0.7];
                self.hLine.HitTest='off';
                for i=1:length(self.hPoints)
                    hgroup=findobj(self.hPoints(i),'type','hggroup');
                    hgroup.Visible='off';
                end
                self.AlphamapLabel.Enable='off';
                self.AlphamapPopup.Enable='off';
                self.hParent.XColor=[0.7,0.7,0.7];
                self.hParent.YColor=[0.7,0.7,0.7];
            end
        end

        function setDefaults(self)
            alphamaps=self.AlphamapPopup.String;
            if strcmp(alphamaps{end},getString(message('images:volumeViewerToolgroup:custom')))
                self.AlphamapPopup.String=alphamaps(1:end-1);
            end
            self.AlphamapPopup.Value=self.AlphamapList.getDefaultIdx;
        end
    end
end

function customizeVertexContextMenu(newPoint)

    hgroup=findobj(newPoint,'type','hggroup');
    api=iptgetapi(hgroup);
    cmenu=api.getContextMenu();

    setColorMenuItem=findobj(cmenu,'tag','set color cmenu item');
    delete(setColorMenuItem);
    copyPositionMenuItem=findobj(cmenu,'tag','copy position cmenu item');
    delete(copyPositionMenuItem);

end

function customizeDeleteContextMenuItem(newPoint)

    hgroup=findobj(newPoint,'type','hggroup');
    api=iptgetapi(hgroup);
    cmenu=api.getContextMenu();

    deleteMenuItem=findobj(cmenu,'tag','delete cmenu item');
    delete(deleteMenuItem);

end

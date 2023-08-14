classdef PCBDesignerCanvas<cad.Cad2DCanvas




    properties
CurrentLayer
LayerViewStack
Legend
        OverlayObj={}
        FeedOverlay={}
        ViaOverlay={}
        LoadOverlay={}
OverlayId
DielectricView
ModelSelection
    end

    methods

        function set.CurrentLayer(self,val)
            self.CurrentLayer=val;
        end
        function self=PCBDesignerCanvas(Parent)
            self@cad.Cad2DCanvas(Parent)
        end
        function color=getColor(self)
            color=self.CurrentLayer.Color;
        end
        function addLayer(self,Type)
            self.notify('AddLayer',cad.events.AddEventData('Layer',Type));
        end

        function addFeed(self,src,evt,varargin)
            if~strcmpi(self.CurrentLayer.MaterialType,'Metal')

                errordlg('Feed can only be added to a Metal layer.');
                return;
            end
            if isempty(varargin)
                BBox=getBBoxFromAxLim(self);
                BBox(3:4)=BBox(3:4)/2;
            else
                BBox=varargin{1};
            end

            self.notify('AddFeed',cad.events.AddEventData('Feed','Feed',BBox));
        end

        function addVia(self,src,evt,varargin)
            if~strcmpi(self.CurrentLayer.MaterialType,'Metal')

                errordlg('Via can only be added to a Metal layer.');
                return;
            end
            if isempty(varargin)
                BBox=getBBoxFromAxLim(self);
            else
                BBox=varargin{1};
            end
            self.notify('AddVia',cad.events.AddEventData('Via','Via',BBox));
        end

        function addLoad(self,src,evt,varargin)
            if~strcmpi(self.CurrentLayer.MaterialType,'Metal')

                errordlg('Load can only be added to a Metal layer.');
                return;
            end
            if isempty(varargin)
                BBox=getBBoxFromAxLim(self);
            else
                BBox=varargin{1};
            end
            self.notify('AddLoad',cad.events.AddEventData('Load','Load',BBox));
        end

        function paste(self)
            if~self.ModelInfo.ActionsStatus(3)
                return;
            end
            data.LayerId=self.CurrentLayer.Id;
            data.AxesLim=[self.Axes.XLim;self.Axes.YLim];
            self.notify('Paste',cad.events.ValueChangedEventData(data));
        end

        function setModel(self,Model)
            self.Controller=em.internal.pcbDesigner.PCBDesignerCanvasController(self,Model);
            addListeners(self.Controller);
        end
        function moved(self,objVal,id,startpt,endpt)
            if strcmpi(objVal.Type,'Feed')
                Data.Type='Feed';
                Data.Id=objVal.Id;
                Data.PreviousValue=objVal.Info.Args.Center;
                Data.Value=objVal.Info.Args.Center+endpt(1:2)-startpt(1:2);
                Data.Property='Center';
                self.notify('MoveFeed',cad.events.ValueChangedEventData(...
                Data))
            elseif strcmpi(objVal.Type,'Via')
                Data.Type='Via';
                Data.Id=objVal.Id;
                Data.PreviousValue=objVal.Info.Args.Center;
                Data.Value=objVal.Info.Args.Center+endpt(1:2)-startpt(1:2);
                Data.Property='Center';
                self.notify('MoveVia',cad.events.ValueChangedEventData(...
                Data))
            elseif strcmpi(objVal.Type,'Load')
                Data.Type='Load';
                Data.Id=objVal.Id;
                Data.PreviousValue=objVal.Info.Args.Center;
                Data.Value=objVal.Info.Args.Center+endpt(1:2)-startpt(1:2);
                Data.Property='Center';
                self.notify('MoveLoad',cad.events.ValueChangedEventData(...
                Data))
            else
                self.notify('MoveShape',cad.events.AddEventData(...
                'Operation','Move',id,startpt,endpt))
            end
        end
        function resized(self,objVal,id,data)
            if strcmpi(objVal.Type,'Feed')
                Data.Type='Feed';
                Data.Id=objVal.Id;
                idVal=objVal.Id;
                Data.Property='Diameter';
                bounds=data{end};
                xdiff=abs(bounds(1,2)-bounds(1,1));
                ydiff=abs(bounds(2,2)-bounds(2,1));
                widthval=min([ydiff,xdiff]);
                Data.PreviousValue=objVal.Info.Args.Diameter;
                Data.Value=widthval;
                idVal=objVal.Id;
                Data.Type='PCBAntenna';
                Data.Id=0;
                Data.Property='FeedDiameter';
                self.notify('ResizeFeed',cad.events.ValueChangedEventData(...
                Data))








            elseif strcmpi(objVal.Type,'Via')
                Data.Type='Via';
                Data.Id=objVal.Id;
                Data.Property='Diameter';
                bounds=data{end};
                xdiff=abs(bounds(1,2)-bounds(1,1));
                ydiff=abs(bounds(2,2)-bounds(2,1));
                widthval=min([ydiff,xdiff]);
                Data.PreviousValue=objVal.Info.Args.Diameter;
                Data.Value=widthval;
                idVal=objVal.Id;
                Data.Type='PCBAntenna';
                Data.Id=0;
                Data.Property='ViaDiameter';
                self.notify('ResizeVia',cad.events.ValueChangedEventData(...
                Data))






            elseif strcmpi(objVal.Type,'Load')
                Data.Type='Load';
                Data.Id=objVal.Id;
                Data.Property='Diameter';
                bounds=data{end};
                xdiff=abs(bounds(1,2)-bounds(1,1));
                ydiff=abs(bounds(2,2)-bounds(2,1));
                widthval=min([ydiff,xdiff]);
                Data.PreviousValue=objVal.Info.Args.Diameter;
                Data.Value=widthval;
                idVal=objVal.Id;
                self.notify('ResizeLoad',cad.events.ValueChangedEventData(...
                Data))






            else
                self.notify('ResizeShape',cad.events.AddEventData(...
                'Operation','Resize',id,data));
            end
        end

        function rotated(self,objVal,id,angles,axis)
            self.notify('RotateShape',cad.events.AddEventData(...
            'Operation','Rotate',id,angles,axis));
        end

        function resetCurrentLayer(self)
            if~isempty(self.CurrentLayer)
                idx=[self.LayerViewStack.Id]==self.CurrentLayer.Id;
                if any(idx)
                    self.CurrentLayer=self.LayerViewStack(idx);
                end
            end
        end


        function updateView(self,vm)



            self.ModelInfo=getModelInfo(vm);
            currentLayerInfo=vm.getCurrentLayerInfo();
            prevCurrentLayer=self.CurrentLayer;
            self.CurrentLayer=currentLayerInfo;
            currentLayerUpdated=0;

            layersInfo=vm.getLayersInfo();

            self.HoverObject=[];


            if~isempty(self.CurrentLayer)&&isstruct(self.CurrentLayer)&&...
                isempty(self.CurrentLayer.ChildrenId)&&~strcmpi(self.CurrentLayer.MaterialType,'Dielectric')
                self.InstructionalText.String=getString(message('antenna:pcbantennadesigner:SelectShapeFromGallery',newline));
                self.InstructionalText.Visible='on';
            else
                self.InstructionalText.Visible='off';
            end

            overlayId=self.OverlayId;
            for i=1:numel(overlayId)
                removeOverlay(self,struct('Id',overlayId(i)));
            end

            if~isempty(self.DielectricView)
                f=fields(self.DielectricView);
                for i=1:numel(f)
                    self.DielectricView.(f{i}).delete;
                end
                self.DielectricView=[];
            end


            updateCurrentLayer(self,currentLayerInfo);
            for i=1:numel(layersInfo)
                updateOverlay(self,layersInfo{i});
            end

            self.SelectedObject=[];


            updateSettings(self,vm);


            updateSelection(self,vm.getSelectedObjInfo());


            groupAxesChildren(self);
        end

        function updateSettings(self,vm)


            info=vm.getSettings;
            self.Grid=info.Grid;
            self.Units=info.Units;

            ax=getAxes(self);

            xlabel(ax,['X (',self.Units,')']);
            ylabel(ax,['Y (',self.Units,')']);
            self.updateLimits(ax);
        end

        function updateCurrentLayer(self,currentLayerInfo)

            deleteObjectStack(self);

            addShapeViewForLayer(self,currentLayerInfo);

            self.setTitle(currentLayerInfo);



        end

        function restoreSelection(self)
            selectedid=[];
            selectedTypes={};
            if~isempty(self.SelectedObject)
                selectedid=[self.SelectedObject.Id];
                selectedTypes={self.SelectedObject.Type};
            end
            for i=1:numel(selectedid)
                objVal=findObject(self,selectedid(i),selectedTypes{i});
                if~isempty(objVal)
                    selectShape(self,objVal,1);
                end
            end
        end


        function updateLimits(self,varargin)
            if isempty(varargin)
                ax=getAxes(self);
            else
                ax=varargin{1};
            end
            updateLimits@cad.Cad2DCanvas(self,ax);
            if self.Grid.SnapToGrid
                ax.XMinorGrid='off';
                ax.YMinorGrid='off';
                xdim=ax.XLim(2)-ax.XLim(1);
                ydim=ax.YLim(2)-ax.YLim(1);


                if ax.XLim(1)>0
                    xgridstartpt=ax.XLim(1)-mod(abs(ax.XLim(1)),self.Grid.GridSize);
                else
                    xgridstartpt=ax.XLim(1)+mod(abs(ax.XLim(1)),self.Grid.GridSize);
                end

                if ax.XLim(2)>0
                    xgridstoppt=ax.XLim(2)-mod(abs(ax.XLim(2)),self.Grid.GridSize);
                else
                    xgridstoppt=ax.XLim(2)+mod(abs(ax.XLim(2)),self.Grid.GridSize);
                end

                xgridtick=xgridstartpt:self.Grid.GridSize:xgridstoppt;
                ax.XTick=xgridtick;
                tmp=arrayfun(@(x){num2str(x)},xgridtick');
                xticklabel=cell(numel(xgridtick),1);
                dist=floor(numel(xgridtick)/10);
                xticklabel(1:dist:end)=tmp(1:dist:end);
                ax.XTickLabel=xticklabel;
                if ax.YLim(1)>0
                    ygridstartpt=ax.YLim(1)-mod(abs(ax.YLim(1)),self.Grid.GridSize);
                else
                    ygridstartpt=ax.YLim(1)+mod(abs(ax.YLim(1)),self.Grid.GridSize);
                end

                if ax.YLim(2)>0
                    ygridstoppt=ax.YLim(2)-mod(abs(ax.YLim(2)),self.Grid.GridSize);
                else
                    ygridstoppt=ax.YLim(2)+mod(abs(ax.YLim(2)),self.Grid.GridSize);
                end

                ygridtick=ygridstartpt:self.Grid.GridSize:ygridstoppt;
                ax.YTick=ygridtick;
                tmp=arrayfun(@(x){num2str(x)},ygridtick');
                yticklabel=cell(numel(ygridtick),1);
                dist=floor(numel(ygridtick)/10);
                yticklabel(1:dist:end)=tmp(1:dist:end);
                ax.YTickLabel=yticklabel;


            else








                ax.XTickMode='auto';
                ax.YTickMode='auto';
                ax.XTickLabelMode='auto';
                ax.YTickLabelMode='auto';
                ax.XMinorGrid='on';
                ax.YMinorGrid='on';
            end
        end

        function setTitle(self,info)
            ax=getAxes(self);
            if isempty(info.Index)||info.Index==1
                materialType='';
            else
                materialType=[' - ',info.MaterialType];
            end
            title(ax,[info.Name,materialType],'Interpreter','none');
        end
        function feedPropertyChanged(self,evt)
            id=cellfun(@(x)x.Id,self.CurrentLayer.FeedInfo,'UniformOutput',false);
            id=cell2mat(id);
            if isempty(id)
                id=-1;
            end
            if any(id==evt.Data.Id)
                addShapeView(self,evt.Data);

            end
        end

        function viaPropertyChanged(self,evt)
            id=cellfun(@(x)x.Id,self.CurrentLayer.ViaInfo,'UniformOutput',false);
            id=cell2mat(id);
            if isempty(id)
                id=-1;
            end
            if any(id==evt.Data.Id)
                addShapeView(self,evt.Data);

            else
            end
        end

        function loadPropertyChanged(self,evt)
            id=cellfun(@(x)x.Id,self.CurrentLayer.LoadInfo,'UniformOutput',false);
            id=cell2mat(id);
            if isempty(id)
                id=-1;
            end
            if any(id==evt.Data.Id)
                addShapeView(self,evt.Data);

            end
        end

        function shapePropertyChanged(self,evt)
            if evt.Data.ParentId==self.CurrentLayer.Id
                sobj=addShapeView(self,evt.Data);
            end
        end

        function layerPropertyChanged(self,evt)
            idx=[self.LayerViewStack.Id]==evt.Data.Id;
            self.LayerViewStack(idx)=evt.Data;
            if evt.Data.Id==self.CurrentLayer.Id
                self.CurrentLayer=evt.Data;
                hideShapeViewForLayer(self,self.CurrentLayer);
                addShapeViewForLayer(self,self.CurrentLayer);
                setTitle(self,evt.Data);
            end
            updateOverlay(self,evt.Data);
        end

        function updateOverlay(self,inf)
            if~inf.Overlay
                removeOverlay(self,inf);
                if inf.Id==1
                    overlayLayer(self,inf)
                end
            else
                overlayLayer(self,inf);
            end
        end
        function overlayLayer(self,info)
            removeOverlay(self,info);
            if self.CurrentLayer.Id~=info.Id
                overlayShape(self,info);
                overlayFeed(self,info);
                overlayVia(self,info);
                overlayLoad(self,info);
                self.OverlayId=[self.OverlayId,info.Id];
            end
        end

        function overlayFeed(self,info)
            feedobj=[];

            id=cellfun(@(x)x.Id,self.CurrentLayer.FeedInfo,'UniformOutput',false);
            id=cell2mat(id);
            if isempty(id)
                id=-1;
            end
            for i=1:numel(info.FeedInfo)
                if any(info.FeedInfo{i}.Id==id)
                    continue;
                end

                objinf.ParentId=info.Id;
                objinf.Id=info.FeedInfo{i}.Id;
                objinf.Type='Feed';
                objinf.Args=info.FeedInfo{i}.Args;
                pts=info.FeedInfo{i}.ShapeObj.Vertices;
                faces=1:size(pts,1);
                zval=info.Index;
                zval=0;
                if isempty(zval)
                    zval=1.5;
                end
                pts(:,3)=ones(size(pts,1),1).*zval*-1;
                tmp=patch(getAxes(self),'Faces',faces,'vertices',...
                pts,'FaceColor',info.FeedInfo{i}.GroupInfo.Color,'faceAlpha',0.5,'UserData',objinf,...
                'EdgeColor','k','EdgeAlpha',0.2,'HitTest','off','Tag','Feed');
                feedobj=[feedobj,tmp];
            end
            if~isempty(feedobj)
                self.FeedOverlay=[self.FeedOverlay,{feedobj}];
            end
        end

        function overlayVia(self,info)
            viaobj=[];

            id=cellfun(@(x)x.Id,self.CurrentLayer.ViaInfo,'UniformOutput',false);
            id=cell2mat(id);
            if isempty(id)
                id=-1;
            end
            for i=1:numel(info.ViaInfo)
                if any(info.ViaInfo{i}.Id==id)
                    continue;
                end

                pts=info.ViaInfo{i}.ShapeObj.Vertices;
                faces=1:size(pts,1);
                zval=info.Index;
                if isempty(zval)
                    zval=1.5;
                end
                zval=0;
                objinf.ParentId=info.Id;
                objinf.Id=info.ViaInfo{i}.Id;
                objinf.Type='Via';
                objinf.Args=info.ViaInfo{i}.Args;
                pts(:,3)=ones(size(pts,1),1).*zval*-1;
                tmp=patch(getAxes(self),'Faces',faces,'vertices',...
                pts,'FaceColor',info.ViaInfo{i}.GroupInfo.Color,'faceAlpha',0.5,'UserData',objinf,...
                'EdgeColor','k','EdgeAlpha',0.2,'HitTest','off','Tag','Via');
                viaobj=[viaobj,tmp];
            end
            if~isempty(viaobj)
                self.ViaOverlay=[self.ViaOverlay,{viaobj}];
            end
        end

        function overlayLoad(self,info)
            loadobj=[];

            id=cellfun(@(x)x.Id,self.CurrentLayer.LoadInfo,'UniformOutput',false);
            id=cell2mat(id);
            if isempty(id)
                id=-1;
            end
            for i=1:numel(info.LoadInfo)
                if any(info.LoadInfo{i}.Id==id)
                    continue;
                end

                pts=info.LoadInfo{i}.ShapeObj.Vertices;
                faces=1:size(pts,1);
                zval=info.Index;
                if isempty(zval)
                    zval=1.5;
                end
                zval=0;
                objinf.ParentId=info.Id;
                objinf.Id=info.LoadInfo{i}.Id;
                objinf.Type='Load';
                objinf.Args=info.LoadInfo{i}.Args;
                pts(:,3)=ones(size(pts,1),1).*zval*-1;
                tmp=patch(getAxes(self),'Faces',faces,'vertices',...
                pts,'FaceColor',info.LoadInfo{i}.GroupInfo.Color,'faceAlpha',0.5,'UserData',objinf,...
                'EdgeColor','k','EdgeAlpha',0.2,'HitTest','off','Tag','Load');
                loadobj=[loadobj,tmp];
            end
            if~isempty(loadobj)
                self.LoadOverlay=[self.LoadOverlay,{loadobj}];
            end
        end

        function overlayShape(self,info)
            if isempty(info.ChildrenInfo)
                return;
            end
            s=info.LayerShape;
            createGeometry(s);
            zval=info.Index;
            if isempty(zval)
                zval=1.5;
            end
            zval=0;
            s=translate(s,[0,0,-1*zval]);
            info.ShapeObj=s;
            info.GroupInfo.Color=info.Color;
            info.GroupInfo.Transparency=info.Transparency;
            info.GroupInfo.Id=-10;
            layershapeobj=cad.ShapeView(self,info);
            layershapeobj.PositionMarker.delete;
            self.OverlayObj=[self.OverlayObj,{layershapeobj}];
            layershapeobj.Interactive=0;
            ax=getAxes(self);
            if zval*-1<ax.ZLim(1)
                ax.ZLim(1)=zval*-1;
            end

            layershapeobj.PatchObj.FaceAlpha=0.2;
            layershapeobj.PatchObj.EdgeAlpha=0.2;

            if info.Id==1&&~info.Overlay
                layershapeobj.PatchObj.FaceColor='none';
                layershapeobj.PatchObj.LineStyle='--';
                layershapeobj.PatchObj.LineWidth=1;
                layershapeobj.PatchObj.EdgeAlpha=1;
            end
            set(layershapeobj.LineObj,'LineStyle','--');
            set(layershapeobj.LineObj,'LineWidth',0.5);
        end

        function removeOverlay(self,Info)

            if~isempty(self.OverlayId)
                idx=self.OverlayId==Info.Id;
                if any(idx)
                    removeShapeOverlay(self,Info.Id);
                    removeFeedOverlay(self,Info.Id);
                    removeViaOverlay(self,Info.Id);
                    removeLoadOverlay(self,Info.Id);
                    self.OverlayId(idx)=[];
                end
            end
        end

        function removeShapeOverlay(self,id)

            for i=1:numel(self.OverlayObj)
                if self.OverlayObj{i}.Info.Id==id
                    self.OverlayObj{i}.delete;
                    self.OverlayObj(i)=[];
                    try
                        self.ObjectStack=self.ObjectStack(isvalid(self.ObjectStack));
                    catch
                    end
                    break;
                end
            end
        end

        function removeFeedOverlay(self,id)
            for i=1:numel(self.FeedOverlay)
                if self.FeedOverlay{i}(1).UserData.ParentId==id
                    feedoverlayobj=self.FeedOverlay{i};
                    for j=1:numel(feedoverlayobj)
                        feedoverlayobj(j).delete;
                    end
                    self.FeedOverlay(i)=[];
                    break;
                end
            end

        end

        function removeViaOverlay(self,id)
            for i=1:numel(self.ViaOverlay)
                if self.ViaOverlay{i}(1).UserData.ParentId==id
                    viaoverlayobj=self.ViaOverlay{i};
                    for j=1:numel(viaoverlayobj)
                        viaoverlayobj(j).delete;
                    end
                    self.ViaOverlay(i)=[];
                    break;
                end
            end

        end

        function removeLoadOverlay(self,id)
            for i=1:numel(self.LoadOverlay)
                if self.LoadOverlay{i}(1).UserData.ParentId==id
                    loadoverlayobj=self.LoadOverlay{i};
                    for j=1:numel(loadoverlayobj)
                        loadoverlayobj(j).delete;
                    end
                    self.LoadOverlay(i)=[];
                    break;
                end
            end

        end

        function updateSelection(self,data)
            self.ModelSelection=data;
            unselectAllSelection(self);
            if~isempty(data)
                for i=1:numel(data{1})
                    if strcmpi(data{1}{i},'Shape')||strcmpi(data{1}{i},'Feed')||strcmpi(data{1}{i},'Via')||strcmpi(data{1}{i},'Load')
                        idx=[self.ObjectStack.Id]==data{2}(i);
                        shapeObj=self.ObjectStack(idx);
                        if~isempty(shapeObj)
                            selectShape(self,shapeObj,1);
                        end
                    end
                end
            end
        end

        function addShapeViewForLayer(self,Info)
            if strcmpi(Info.MaterialType,'Dielectric')
                dshape=Info.DielectricShape;
                if dshape.NumChildren>0






                    s=dshape.LayerShape;
                    objinf.Type='Layer';
                    objinf.Id=Info.Id;
                    polyobj=matlab.graphics.primitive.Polygon('parent',getAxes(self),'Shape',s.InternalPolyShape,...
                    'FaceColor',Info.Color,'FaceAlpha',Info.Transparency,'UserData',objinf);
                    self.DielectricView.(['Layer',num2str(Info.Id)])=polyobj;
                end
            else
                for i=1:numel(Info.ChildrenInfo)
                    addShapeView(self,Info.ChildrenInfo{i});
                end
                for i=1:numel(Info.FeedInfo)
                    addShapeView(self,Info.FeedInfo{i});
                end
                for i=1:numel(Info.ViaInfo)
                    addShapeView(self,Info.ViaInfo{i});
                end
                for i=1:numel(Info.LoadInfo)
                    addShapeView(self,Info.LoadInfo{i});
                end
            end
        end

        function hideShapeViewForLayer(self,layerinfo)
            Info=layerinfo;
            if strcmpi(Info.MaterialType,'Dielectric')
                if~isempty(self.DielectricView)&&isfield(self.DielectricView,['Layer',num2str(Info.Id)])&&...
                    ~isempty(self.DielectricView.(['Layer',num2str(Info.Id)]))
                    self.DielectricView.(['Layer',num2str(Info.Id)]).delete;
                    self.DielectricView.(['Layer',num2str(Info.Id)])=[];
                end
            else
                inf=layerinfo;
                for i=1:numel(inf.ChildrenInfo)
                    deleteShapeView(self,inf.ChildrenInfo{i});
                end
                for i=1:numel(inf.FeedInfo)
                    deleteShapeView(self,inf.FeedInfo{i});
                end
                for i=1:numel(inf.ViaInfo)
                    deleteShapeView(self,inf.ViaInfo{i});
                end
                for i=1:numel(inf.LoadInfo)
                    deleteShapeView(self,inf.LoadInfo{i});
                end
            end
        end

        function delete(self)
            fig=getFigure(self);
            if self.checkValid(fig)


                clf(fig);

                p=pan(fig);
                z=zoom(fig);
                p.Enable='off';
                z.Enable='off';
                fig.WindowButtonMotionFcn=[];
                fig.WindowButtonDownFcn=[];
                fig.WindowButtonUpFcn=[];
                finishMouseCallback(self);
            end
        end
        function setlegend(self)










        end

        function sessionCleared(self)


            self.HoverObject=[];
            self.SelectedObject=[];
        end
    end

    events
AddLayer
AddFeed
AddVia
AddLoad
MoveFeed
ResizeFeed
MoveVia
ResizeVia
MoveLoad
ResizeLoad
CanvasObjectsSelected
    end
end

classdef Layer3DView<cad.View&...
    cad.MouseBehaviour




    properties
LayerObj
LayerPatchObj
LayerLineObj
ConnectionPatchObj
ConnectionObj
ConnectionLineObj
Axes
Figure
        CurrentLayer=[];
        SelectionColor=[[0,153,255]/255,1];
        HoverObject=[];
        SelectedObject=[];
        DielectricThicknessOffset=0.1;
        HideDielectric=0;
HideDielectricChkBox
OrientationQuiver
    end

    methods
        function self=Layer3DView(fig)
            ax=uiaxes(fig);
            self.Axes=ax;
            self.Figure=fig;
            decorateAxes(self)
            self.initializeMouseBehaviour();
            self.HideDielectricChkBox=uicheckbox('Parent',getFigure(self),'Value',...
            0,'ValueChangedFcn',@(src,evt)hideDielectric(self,src,evt),'text','Hide Dielectric');
            self.HideDielectricChkBox.Position(1:3)=[10,10,200];
        end

        function moveLayer(self,val)
            if~isempty(self.SelectedObject)
                self.notify('MoveLayer',cad.events.MoveLayerEventData(self.CurrentLayer,val));
            end
        end
        function hideDielectric(self,src,~)
            self.HideDielectric=src.Value;

            materialType=cellfun(@(x)x.MaterialType,self.LayerObj,'UniformOutput',false);
            layerid=cell2mat(cellfun(@(x)x.Id,self.LayerObj,'UniformOutput',false));
            idx=strcmpi(materialType,'Dielectric');
            id=find(idx);
            if src.Value
                for i=1:numel(id)
                    deleteLayerView(self,self.LayerObj{id(i)});
                end
            else
                for i=1:numel(id)
                    updateLayerView(self,self.LayerObj{id(i)},layerid);
                end
            end
        end

        function updateView(self,vm)

            self.HoverObject=[];
            self.SelectedObject=[];
            currLayerInfo=vm.getCurrentLayerInfo();

            layerInfo=vm.getLayersInfo();
            self.LayerObj=layerInfo;

            for i=1:numel(layerInfo)
                if layerInfo{i}.Id~=1
                    updateLayerView(self,layerInfo{i});
                    updateConnectionView(self,layerInfo{i},layerInfo{i}.Id);
                    if layerInfo{i}.Id==currLayerInfo.Id

                        setSelection(self,'Layer',layerInfo{i}.Id);
                        self.SelectedObject=currLayerInfo;
                        self.CurrentLayer=currLayerInfo;
                    end
                end
            end

        end
        function hover(self,evt)
            if~isempty(evt.HitObject)&&any(strcmpi(evt.HitObject.Type,{'Patch','Line'}))
                if~isempty(self.HoverObject)
                    if strcmpi(self.HoverObject.Tag,'Layer')
                        if self.HoverObject.UserData~=self.CurrentLayer.Id
                            removeSelection(self,self.HoverObject.Tag,self.HoverObject.UserData);
                            self.HoverObject=[];
                        end
                    else
                        removeSelection(self,self.HoverObject.Tag,self.HoverObject.UserData);
                        self.HoverObject=[];
                    end
                end
                setSelection(self,evt.HitObject.Tag,evt.HitObject.UserData);
                self.HoverObject.Tag=evt.HitObject.Tag;
                self.HoverObject.UserData=evt.HitObject.UserData;
            else
                if~isempty(self.HoverObject)
                    if strcmpi(self.HoverObject.Tag,'Layer')
                        if self.HoverObject.UserData~=self.CurrentLayer.Id
                            removeSelection(self,self.HoverObject.Tag,self.HoverObject.UserData);
                            self.HoverObject=[];
                        end
                    else
                        removeSelection(self,self.HoverObject.Tag,self.HoverObject.UserData);
                        self.HoverObject=[];
                    end

                end
            end
        end
        function rightClick(self,evt)
        end

        function leftClick(self,evt)
            if~isempty(evt.HitObject)&&any(strcmpi(evt.HitObject.Type,{'Patch','Line'}))
                data={{evt.HitObject.Tag},[evt.HitObject.UserData]};
                self.notify('Selected',cad.events.SelectionEventData(data,'Canvas'));
            end
        end

        function doubleClick(self,evt)
        end

        function dragStarted(self,evt1,evt2)
        end

        function dragEnded(self,evt1,evt2)
        end

        function drag(self,evt1,evt2)
        end
        function ax=getAxes(self)
            ax=self.Axes;
        end

        function fig=getFigure(self)
            fig=self.Figure;
        end

        function decorateAxes(self)
            ax=getAxes(self);
            view(ax,[-10,10]);
            grid(ax,'on');
            axis(ax,'vis3d');
            box(ax,'on');
            ax.Units='normalized';
            ax.Position=[0.1,0.1,0.8,0.8];
            xlabel(ax,'X (mm)');
            ylabel(ax,'Y (mm)');
            zlabel(ax,'Z (mm)');
        end


        function setlegend(self)
            [patchobj,names]=getLayerPatchObjAndNames(self);
            feedpatchobj=getConnectionPatchObj(self);
            if isempty(feedpatchobj)&&isempty(patchobj)
                legend(self.Axes,'off');
            end
            legend(self.Axes,patchobj,names);
        end
        function[patchobj,names]=getLayerPatchObjAndNames(self)

            patchobj=[];
            names={};
            index=[];
            if isempty(self.LayerPatchObj)
                return;
            end
            f=fields(self.LayerPatchObj);
            for i=1:numel(f)
                if~isempty(self.LayerPatchObj.(f{i}))&&all(isvalid(self.LayerPatchObj.(f{i})))
                    patchobj=[patchobj,self.LayerPatchObj.(f{i})(1)];
                    idx=self.LayerPatchObj.(f{i})(1).UserData==[self.LayerObj.Id];
                    names=[names,self.LayerObj(idx).Name];
                    index=[index,self.LayerObj(idx).Index];
                end
            end
            [~,id]=sort(index,'descend');
            patchobj=patchobj(id);
            names=names(id);
        end

        function patchobj=getConnectionPatchObj(self)

            patchobj=[];
            if isempty(self.ConnectionPatchObj)
                return;
            end
            f=fields(self.ConnectionPatchObj);
            for i=1:numel(f)
                if~isempty(self.ConnectionPatchObj.(f{i}))&&all(isvalid(self.ConnectionPatchObj.(f{i})))
                    patchobj=[patchobj,self.ConnectionPatchObj.(f{i})(1)];
                end
            end
        end

        function[faces,vertices]=generateDielectricBoundaries(self,shapeobj,offset,thickness,info)
            bound=generateBoundaries(self,shapeobj,info);
            n=numel(bound);
            faces=cell(1,n);
            vertices=cell(1:n);
            for i=1:numel(bound)
                boundvert=bound{i};
                m=size(bound{i},1);
                boundvert=[[boundvert(:,1:2),ones(m,1).*(info.ZVal(1)+offset)];...
                [boundvert(end:-1:1,1:2),ones(m,1).*(info.ZVal(2)-offset)]];
                vertices{i}=boundvert;
                facesval=[];
                for j=1:m-1
                    pt=[j,j+1];
                    facesval=[facesval;[pt(2:-1:1),2*m-pt+1]];
                end
                faces{i}=facesval;
            end
        end

        function[PatchObj,LineObj]=drawVolumetricPatch(self,info,shapeobj,thickness,offset)

            if any(strcmpi(info.Type,{'feed','Via','Load'}))


                p=shapeobj.Vertices;
                n=size(p,1);
                p=[p;mean(p)];
                t=[(1:n)',[2:n,1]',ones(n,1).*n+1];
            else

                [p,t]=getInitialMesh(shapeobj);
            end

            index=-1;
            numpt=size(p,1);
            if isempty(index)
                index=-1;
            end

            p(:,3)=ones(numpt,1).*(info.ZVal(2)-offset);
            patchobj=patch(getAxes(self),'vertices',p,'Faces',t(:,1:3),'FaceAlpha',...
            info.Transparency,'faceColor',info.Color,'EdgeColor','none',...
            'Userdata',info.Id,'Tag',info.Type);
            PatchObj=patchobj;
            p(:,3)=ones(numpt,1).*(info.ZVal(1)+offset);
            patchobj=patch(getAxes(self),'vertices',p,'Faces',t(:,1:3),'FaceAlpha',...
            info.Transparency,'faceColor',info.Color,'EdgeColor','none',...
            'Userdata',info.Id,'Tag',info.Type);
            PatchObj=[PatchObj,...
            patchobj];
            [facesval,vertval]=generateDielectricBoundaries(self,shapeobj,offset,thickness,info);
            for i=1:numel(facesval)
                patchobj=patch(getAxes(self),'vertices',vertval{i},'Faces',facesval{i},'FaceAlpha',...
                info.Transparency,'faceColor',info.Color,'EdgeColor','none',...
                'Userdata',info.Id,'Tag',info.Type);
                PatchObj=[PatchObj,...
                patchobj];
            end
            LineObj=generateLineObj(self,info,shapeobj,index,offset,info.Type);

        end

        function[patchobj,lineobj]=drawPlanarPatch(self,info,shapeobj)
            [p,t]=getInitialMesh(shapeobj);
            index=info.Index;
            numpt=size(p,1);
            if isempty(index)
                index=-1;
            end
            p(:,3)=ones(numpt,1).*info.ZVal;
            patchobj=patch(getAxes(self),'vertices',p,'Faces',t(:,1:3),'FaceAlpha',...
            info.Transparency,'faceColor',info.Color,'EdgeColor','none',...
            'Userdata',info.Id,'Tag',info.Type);
            lineobj=generateLineObj(self,info,shapeobj,index,0,info.Type);
        end

        function shapeobj=generateShapeFromInfo(self,info)
            shapeobj=info.ChildrenInfo{1}.ShapeObj;
            n=numel(info.ChildrenInfo);
            if n>1
                for i=2:n
                    shapeobj=shapeobj+info.ChildrenInfo{i}.ShapeObj;
                end
            end
        end

        function updateLayerView(self,info,layerid)
            deleteLayerView(self,info);
            if isempty(info.Index)||info.Index==1
                return;
            end
            if strcmpi(info.MaterialType,'Dielectric')
                if self.HideDielectric
                    return;
                end
                dShape=info.DielectricShape;
                if dShape.NumChildren>0


                    shapeobj=dShape.LayerShape;
                    offset=(info.ZVal(2)-info.ZVal(1))*self.DielectricThicknessOffset;
                    [patchobj,lineobj]=drawVolumetricPatch(self,info,shapeobj,info.Args.Thickness,offset);
                    self.LayerPatchObj.(['Layer',num2str(info.Id)])=patchobj;
                    self.LayerLineObj.(['Layer',num2str(info.Id)])=lineobj;

                end
            else
                if~isempty(info.ChildrenInfo)
                    shapeobj=info.LayerShape;
                    [patchobj,lineobj]=drawPlanarPatch(self,info,shapeobj);
                    self.LayerPatchObj.(['Layer',num2str(info.Id)])=patchobj;
                    self.LayerLineObj.(['Layer',num2str(info.Id)])=lineobj;
                end
            end

        end

        function updateConnectionView(self,info,layerid)
            deleteConnectionView(self,info,layerid);
            feedinf=info.FeedInfo;
            viainf=info.ViaInfo;
            loadinf=info.LoadInfo;
            for i=1:numel(feedinf)
                zval=[feedinf{i}.Args.StartLayer.ZVal,feedinf{i}.Args.StopLayer.ZVal];
                feedinf{i}.ZVal=[min(zval),max(zval)];
                feedinf{i}.Color=feedinf{i}.GroupInfo.Color;
                feedinf{i}.Transparency=feedinf{i}.GroupInfo.Transparency;
                shapeobj=feedinf{i}.ShapeObj;
                [patchobj,lineobj]=drawVolumetricPatch(self,feedinf{i},shapeobj,(feedinf{i}.ZVal(2)-...
                feedinf{i}.ZVal(1)),0);
                self.ConnectionPatchObj.(['Feed',num2str(feedinf{i}.Id)])=patchobj;
                self.ConnectionLineObj.(['Feed',num2str(feedinf{i}.Id)])=lineobj;
            end
            for i=1:numel(viainf)
                zval=[viainf{i}.Args.StartLayer.ZVal,viainf{i}.Args.StopLayer.ZVal];
                viainf{i}.ZVal=[min(zval),max(zval)];
                viainf{i}.Color=viainf{i}.GroupInfo.Color;
                viainf{i}.Transparency=viainf{i}.GroupInfo.Transparency;
                shapeobj=viainf{i}.ShapeObj;
                [patchobj,lineobj]=drawVolumetricPatch(self,viainf{i},shapeobj,(viainf{i}.ZVal(2)-...
                viainf{i}.ZVal(1)),0);
                self.ConnectionPatchObj.(['Via',num2str(viainf{i}.Id)])=patchobj;
                self.ConnectionLineObj.(['Via',num2str(viainf{i}.Id)])=lineobj;
            end
            for i=1:numel(loadinf)
                zval=[loadinf{i}.Args.StartLayer.ZVal,loadinf{i}.Args.StopLayer.ZVal];
                loadinf{i}.ZVal=[min(zval),max(zval)];
                loadinf{i}.Color=loadinf{i}.GroupInfo.Color;
                loadinf{i}.Transparency=loadinf{i}.GroupInfo.Transparency;
                shapeobj=loadinf{i}.ShapeObj;
                [patchobj,lineobj]=drawVolumetricPatch(self,loadinf{i},shapeobj,(loadinf{i}.ZVal(2)-...
                loadinf{i}.ZVal(1)),0);
                self.ConnectionPatchObj.(['Load',num2str(loadinf{i}.Id)])=patchobj;
                self.ConnectionLineObj.(['Load',num2str(loadinf{i}.Id)])=lineobj;
            end
        end

        function deleteConnectionView(self,info,layerid)
            feedinf=info.FeedInfo;
            viainf=info.ViaInfo;
            loadinf=info.LoadInfo;
            for j=1:numel(feedinf)
                if~isempty(self.ConnectionPatchObj)&&isfield(self.ConnectionPatchObj,['Feed',num2str(feedinf{j}.Id)])
                    if~isempty(self.ConnectionPatchObj.(['Feed',num2str(feedinf{j}.Id)]))
                        self.ConnectionPatchObj.(['Feed',num2str(feedinf{j}.Id)]).delete;
                        self.ConnectionPatchObj.(['Feed',num2str(feedinf{j}.Id)])=[];
                        for i=1:numel(self.ConnectionLineObj.(['Feed',num2str(feedinf{j}.Id)]))
                            self.ConnectionLineObj.(['Feed',num2str(feedinf{j}.Id)])(i).delete;
                        end
                    end
                    self.ConnectionLineObj.(['Feed',num2str(feedinf{j}.Id)])=[];

                end
            end
            for j=1:numel(viainf)
                if~isempty(self.ConnectionPatchObj)&&isfield(self.ConnectionPatchObj,['Via',num2str(viainf{j}.Id)])
                    if~isempty(self.ConnectionPatchObj.(['Via',num2str(viainf{j}.Id)]))
                        self.ConnectionPatchObj.(['Via',num2str(viainf{j}.Id)]).delete;
                        self.ConnectionPatchObj.(['Via',num2str(viainf{j}.Id)])=[];
                        for i=1:numel(self.ConnectionLineObj.(['Via',num2str(viainf{j}.Id)]))
                            self.ConnectionLineObj.(['Via',num2str(viainf{j}.Id)])(i).delete;
                        end
                    end
                    self.ConnectionLineObj.(['Via',num2str(viainf{j}.Id)])=[];

                end
            end
            for j=1:numel(loadinf)
                if~isempty(self.ConnectionPatchObj)&&isfield(self.ConnectionPatchObj,['Load',num2str(loadinf{j}.Id)])
                    if~isempty(self.ConnectionPatchObj.(['Load',num2str(loadinf{j}.Id)]))
                        self.ConnectionPatchObj.(['Load',num2str(loadinf{j}.Id)]).delete;
                        self.ConnectionPatchObj.(['Load',num2str(loadinf{j}.Id)])=[];
                        for i=1:numel(self.ConnectionLineObj.(['Load',num2str(loadinf{j}.Id)]))
                            self.ConnectionLineObj.(['Load',num2str(loadinf{j}.Id)])(i).delete;
                        end
                    end
                    self.ConnectionLineObj.(['Load',num2str(loadinf{j}.Id)])=[];

                end
            end
        end

        function oplineobj=generateLineObj(self,info,shapeobj,index,offset,Type)
            bound=generateBoundaries(self,shapeobj,info);
            oplineobj=[];
            if any(strcmpi(info.Type,{'Feed','Via','Load'}))||...
                strcmpi(info.MaterialType,{'Dielectric'})

                oplineobjtmp1=[];
                oplineobjtmp2=[];
                for i=1:numel(bound)
                    lineObj=line('Parent',getAxes(self),'XData',bound{i}(:,1),'YData',bound{i}(:,2),...
                    'ZData',ones(numel(bound{i}(:,3)),1).*(info.ZVal(2)-offset),'Color',[0,0,0],'userdata',info.Id,'Tag',Type);
                    oplineobjtmp1=[lineObj,oplineobjtmp1];
                end
                for i=1:numel(bound)
                    lineObj=line('Parent',getAxes(self),'XData',bound{i}(:,1),'YData',bound{i}(:,2),...
                    'ZData',ones(numel(bound{i}(:,3)),1).*(info.ZVal(1)+offset),'Color',[0,0,0],'userdata',info.Id,'Tag',Type);
                    oplineobjtmp2=[lineObj,oplineobjtmp2];
                end
                oplineobj=[oplineobjtmp1,oplineobjtmp2];
            else
                for i=1:numel(bound)
                    lineObj=line('Parent',getAxes(self),'XData',bound{i}(:,1),'YData',bound{i}(:,2),...
                    'ZData',ones(numel(bound{i}(:,3)),1).*info.ZVal,'Color',[0,0,0],'userdata',info.Id,'Tag',Type);
                    oplineobj=[lineObj,oplineobj];
                end
            end
        end

        function boundary=generateBoundaries(self,shapeobj,info)
            if any(strcmpi(info.Type,{'feed','Via','Load'}))


                boundval(:,1)=shapeobj.Vertices(:,1);
                boundval(:,2)=shapeobj.Vertices(:,2);
            else

                pg=shapeobj.InternalPolyShape;
                [boundval(:,1),boundval(:,2)]=pg.boundary;
            end
            boundval=[NaN,NaN;boundval;NaN,NaN];
            idx=isnan(boundval(:,1));
            numbounds=sum(idx)-1;
            bound=cell(numbounds,1);
            idx=find(idx);
            for i=1:numbounds
                bound{i}=[boundval(idx(i)+1:idx(i+1)-1,:),zeros(numel(idx(i)+1:idx(i+1)-1),1)];
            end
            boundary=bound;
        end

        function deleteLayerView(self,info)
            if~isempty(self.LayerPatchObj)&&isfield(self.LayerPatchObj,['Layer',num2str(info.Id)])
                if~isempty(self.LayerPatchObj.(['Layer',num2str(info.Id)]))
                    self.LayerPatchObj.(['Layer',num2str(info.Id)]).delete;
                    self.LayerPatchObj.(['Layer',num2str(info.Id)])=[];
                    for i=1:numel(self.LayerLineObj.(['Layer',num2str(info.Id)]))
                        self.LayerLineObj.(['Layer',num2str(info.Id)])(i).delete;
                    end
                end
                self.LayerLineObj.(['Layer',num2str(info.Id)])=[];

            end
        end

        function setModel(self,Model)


            addlistener(self,'Selected',@(src,evt)Model.selectedAction(evt));
            addlistener(self,'MoveLayer',@(src,evt)Model.moveLayer(evt));
        end

        function setSelection(self,Type,id)
            if strcmpi(Type,'Layer')
                if~isempty(self.LayerLineObj)&&isfield(self.LayerLineObj,['Layer',num2str(id)])
                    set(self.LayerLineObj.(['Layer',num2str(id)]),'Color',self.SelectionColor);
                    set(self.LayerLineObj.(['Layer',num2str(id)]),'LineWidth',1);
                    if numel(self.LayerPatchObj.(['Layer',num2str(id)]))>1
                        self.LayerPatchObj.(['Layer',num2str(id)])(3).EdgeColor=self.SelectionColor(1:3);
                    end
                end
            elseif any(strcmpi(Type,{'Feed','Via','Load'}))
                if~isempty(self.ConnectionLineObj)&&isfield(self.ConnectionLineObj,[Type,num2str(id)])
                    set(self.ConnectionLineObj.([Type,num2str(id)]),'Color',self.SelectionColor);
                    set(self.ConnectionLineObj.([Type,num2str(id)]),'LineWidth',1);
                end
            end
        end
        function removeSelection(self,Type,id)
            if strcmpi(Type,'Layer')

                if~isempty(self.LayerLineObj)&&isfield(self.LayerLineObj,['Layer',num2str(id)])
                    set(self.LayerLineObj.(['Layer',num2str(id)]),'Color',[0,0,0]);
                    set(self.LayerLineObj.(['Layer',num2str(id)]),'LineWidth',0.5);
                end
            elseif any(strcmpi(Type,{'Feed','Via','Load'}))
                if~isempty(self.ConnectionLineObj)&&isfield(self.ConnectionLineObj,[Type,num2str(id)])
                    set(self.ConnectionLineObj.([Type,num2str(id)]),'Color',[0,0,0]);
                    set(self.ConnectionLineObj.([Type,num2str(id)]),'LineWidth',0.5);
                end
            end
        end

        function delete(self)
            if self.checkValid(self.Figure)
                clf(self.Figure);
            end
        end

        function sessionCleared(self)

            for i=1:numel(self.LayerObj)
                deleteConnectionView(self,self.LayerObj{i},self.LayerObj{i}.Id);
                deleteLayerView(self,self.LayerObj{i});
            end
        end
    end

    events
Selected
MoveLayer
    end
end

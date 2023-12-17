classdef ShapeView<handle

    properties
PatchObj
Id
        HoverTransparency=0.6
        Canvas;
Triangulation
        FaceColor='b';
        EdgeColor='k';
        Transparency=0.2;
ShapeObj
LineObj
Boundary
        Selected=0;
ResizeView
Info
GroupId
Type
        SelectionColor=[[0,153,255]/255,1];
PositionMarker
        Interactive=1;
    end


    methods
        function set.Transparency(self,val)
            self.Transparency=val;
        end


        function self=ShapeView(Canvas,info)
            self.Info=info;
            self.Id=info.Id;
            self.Canvas=Canvas;
            sObj=info.ShapeObj;
            self.FaceColor=info.GroupInfo.Color;
            self.FaceColor=self.FaceColor;
            self.Transparency=info.GroupInfo.Transparency;
            self.GroupId=info.GroupInfo.Id;
            self.Type='Shape';
            if strcmpi(info.Type,'Feed')||strcmpi(info.Type,'Via')||strcmpi(info.Type,'Load')||strcmpi(info.Type,'Layer')
                self.Type=info.Type;
            end
            self.ShapeObj=sObj;
            if strcmpi(self.Type,'Layer')
                self.Info.VertZVal=sObj.Vertices(:,3);
            end

            if any(strcmpi(self.Info.Type,{'feed','Via','Load'}))
                p=self.Info.ShapeObj.Vertices;
                n=size(p,1);
                p=[p;mean(p)];
                t=[(1:n)',[2:n,1]',ones(n,1).*n+1];
            else
                createGeometry(sObj);

                [p,t]=getInitialMesh(sObj);
            end
            if strcmpi(self.Type,'Layer')
                try
                    p(:,3)=self.Info.VertZVal;
                catch

                    p(:,3)=ones(1,numel(p(:,3))).*self.Info.VertZVal(1);
                end
            elseif strcmpi(self.Type,'Shape')
                p(:,3)=0;
            end
            self.Triangulation=triangulation(t(:,1:3),p);
            faces=t(:,1:3);
            objinf.Id=info.Id;
            objinf.Type=self.Type;
            objinf.Args=info.Args;
            if isfield(info,'EnableMove')
                objinf.EnableMove=info.EnableMove;
            end
            if isfield(info,'EnableResize')
                objinf.EnableResize=info.EnableResize;
            end
            if isfield(info,'EnableRotate')
                objinf.EnableRotate=info.EnableRotate;
            end
            cm=uicontextmenu(self.Canvas.Figure);
            cm.ContextMenuOpeningFcn=@(src,evt)createContextMenu(self.Canvas,src,evt,self.Id);
            self.PatchObj=patch('Parent',self.Canvas.Axes,'Faces',faces,'Vertices',p,...
            'UserData',objinf,'FaceColor',self.FaceColor,'EdgeColor','none','FaceAlpha',self.Transparency,...
            'ContextMenu',cm,'Tag',self.Type,'DisplayName',info.Name);
            meanVal=mean(p);

            objinf.MarkerType='Position';

            self.PositionMarker=line('Parent',self.Canvas.Axes,'XData',meanVal(1),'YData',meanVal(2),...
            'MarkerSize',8,'MarkerFaceColor','w','Marker','+','MarkerEdgeColor','k','Tag',self.Type,'UserData',objinf);
            cm.Tag='patch';
            self.PatchObj.DeleteFcn=@(src,evt)self.patchDeleted(src);
            generateLineObj(self);
            self.ResizeView=cad.ResizeView(self);

        end


        function update(self,info)
            self.FaceColor=info.GroupInfo.Color;
            self.FaceColor=self.FaceColor;
            self.Transparency=info.GroupInfo.Transparency;
            self.Info=info;
            self.Id=info.Id;
            sObj=info.ShapeObj;
            if strcmpi(self.Type,'Layer')
                self.Info.VertZVal=sObj.Vertices(:,3);
            end
            self.ShapeObj=sObj;
            if any(strcmpi(self.Info.Type,{'feed','Via','Load'}))
                p=self.Info.ShapeObj.Vertices;
                n=size(p,1);
                p=[p;mean(p)];
                t=[(1:n)',[2:n,1]',ones(n,1).*n+1];
            else
                createGeometry(sObj);
                [p,t]=getInitialMesh(sObj);
            end
            if strcmpi(self.Type,'Layer')
                p(:,3)=self.Info.VertZVal;
            elseif strcmpi(self.Type,'Shape')
                p(:,3)=0;
            end
            self.Triangulation=triangulation(t(:,1:3),p);
            faces=t(:,1:3);
            self.PatchObj.Vertices=p;
            self.PatchObj.Faces=faces;
            self.PatchObj.DisplayName=info.Name;

            meanVal=mean(p);
            self.PositionMarker.XData=meanVal(1);
            self.PositionMarker.YData=meanVal(2);
            bound=generateBoundaries(self);

            objinf.Id=info.Id;
            objinf.Type=info.Type;
            objinf.Args=info.Args;

            if numel(bound)<numel(self.LineObj)
                self.LineObj(numel(bound)+1:numel(self.LineObj)).delete;
                self.LineObj(numel(bound)+1:numel(self.LineObj))=[];
            elseif numel(bound)>numel(self.LineObj)
                for i=numel(self.LineObj)+1:numel(bound)
                    lineObj=line('Parent',self.Canvas.Axes,...
                    'Color',self.EdgeColor,'Tag',self.Type,'UserData',objinf);
                    self.LineObj=[lineObj,self.LineObj];
                end
            end

            if isfield(info,'EnableMove')
                objinf.EnableMove=info.EnableMove;
            end
            if isfield(info,'EnableResize')
                objinf.EnableResize=info.EnableResize;
            end
            if isfield(info,'EnableRotate')
                objinf.EnableRotate=info.EnableRotate;
            end
            self.PatchObj.UserData=objinf;

            for i=1:numel(self.LineObj)
                set(self.LineObj(i),'XData',bound{i}(:,1),'YData',bound{i}(:,2),...
                'ZData',bound{i}(:,3));
                if strcmpi(self.Info.Type,'Layer')
                    self.LineObj(i).ZData=ones(numel(self.LineObj(i).ZData),1).*self.Info.VertZVal(1);
                end
            end
            update(self.ResizeView)
        end


        function set.Selected(self,val)
            self.Selected=val;
            self.notify('SelectionChanged');
        end


        function generateLineObj(self)
            bound=generateBoundaries(self);
            objinf.Id=self.Info.Id;
            objinf.Type=self.Info.Type;
            objinf.Args=self.Info.Args;
            for i=1:numel(bound)
                lineObj=line('Parent',self.Canvas.Axes,'XData',bound{i}(:,1),'YData',bound{i}(:,2),...
                'ZData',bound{i}(:,3),'Color',self.EdgeColor,'Tag',self.Type,'UserData',objinf);
                if strcmpi(self.Info.Type,'Layer')
                    lineObj.ZData=ones(numel(lineObj.ZData),1).*self.Info.VertZVal(1);
                end
                self.LineObj=[lineObj,self.LineObj];
            end
        end


        function bound=generateBoundaries(self)
            if any(strcmpi(self.Info.Type,{'feed','Via','Load'}))

                boundval(:,1)=self.Info.ShapeObj.Vertices(:,1);
                boundval(:,2)=self.Info.ShapeObj.Vertices(:,2);
            else
                pg=self.ShapeObj.InternalPolyShape;
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
            self.Boundary=bound;
        end


        function hover(self)
            if~self.Interactive
                return;
            end
            set(self.LineObj,'Color',self.SelectionColor);
            set(self.LineObj,'LineWidth',2);
        end


        function unhover(self)
            if~self.Interactive
                return;
            end
            if~self.Selected
                set(self.LineObj,'Color',[0,0,0]);
                set(self.LineObj,'LineWidth',0.5);
            end
        end


        function drag(self,evt1,evt2)
            if~self.Interactive
                return;
            end
            if~self.Info.EnableMove
                return;
            end

            try
                meanVal=mean(self.ShapeObj.Vertices(~isnan(self.ShapeObj.Vertices(:,1)),:));
            catch me
            end
            diffBetMean=evt1.IntersectionPoint-meanVal;
            diffBetEvent=evt2.IntersectionPoint;
            vert=self.Triangulation.Points-meanVal;
            diffMove=diffBetEvent-diffBetMean;
            vert=vert+[diffMove(1:2),0];
            meanVal+[diffMove(1:2),0];
            self.PatchObj.Vertices=vert;
            meanValp=mean(vert);
            self.PositionMarker.XData=meanValp(1);
            self.PositionMarker.YData=meanValp(2);
            for i=1:numel(self.Boundary)
                XData=self.Boundary{i}(:,1)-meanVal(1)+diffMove(1);
                YData=self.Boundary{i}(:,2)-meanVal(2)+diffMove(2);
                ZData=self.Boundary{i}(:,3)+0;
                self.LineObj(i).XData=XData;
                self.LineObj(i).YData=YData;
                self.LineObj(i).ZData=ZData;
            end
            update(self.ResizeView);
        end


        function select(self)
            if~self.Interactive
                return;
            end
            set(self.LineObj,'Color',self.SelectionColor);
            set(self.LineObj,'LineWidth',2);
            self.Selected=1;
        end


        function unselect(self)
            if~self.Interactive
                return;
            end
            self.Selected=0;
            set(self.LineObj,'Color',[0,0,0]);
            set(self.LineObj,'LineWidth',0.5);
        end


        function delete(self)
            self.PatchObj.delete;
            self.PositionMarker.delete;
            for i=1:numel(self.LineObj)
                self.LineObj(i).delete;
            end
        end


        function resize(self,bound)
            vert=self.Triangulation.Points;
            xmin=min(vert(:,1));
            xmax=max(vert(:,1));
            ymin=min(vert(:,2));
            ymax=max(vert(:,2));
            boxcenter=[(xmin+xmax)/2,(ymin+ymax)/2,0];
            vert=vert-boxcenter;
            xsize=xmax-xmin;
            ysize=ymax-ymin;
            boundysize=bound(2,2)-bound(2,1);
            boundxsize=bound(1,2)-bound(1,1);
            boundCenter=mean(bound');

            vert(:,2)=vert(:,2)*boundysize/ysize;
            vert(:,1)=vert(:,1)*boundxsize/xsize;
            vert=vert+[boundCenter,0];
            meanValp=mean(vert);
            self.PositionMarker.XData=meanValp(1);
            self.PositionMarker.YData=meanValp(2);
            self.PatchObj.Vertices=vert;
            for i=1:numel(self.Boundary)
                XData=self.Boundary{i}(:,1)-boxcenter(1);
                YData=self.Boundary{i}(:,2)-boxcenter(2);
                ZData=self.Boundary{i}(:,3)+0;
                self.LineObj(i).XData=(XData*boundxsize/xsize)+boundCenter(1);
                self.LineObj(i).YData=(YData*boundysize/ysize)+boundCenter(2);
                self.LineObj(i).ZData=ZData;
            end
        end


        function rotate(self,iniAngle,finAngle)
            vert=self.Triangulation.Points;
            angle=finAngle-90;
            rotmatrix=[cosd(angle),-1*sind(angle);sind(angle),cosd(angle)];
            meanval=mean(vert);
            vert=vert-mean(vert);
            newvert=transpose(rotmatrix*vert(:,1:2)');
            vert=[newvert,vert(:,3)];
            self.PatchObj.Vertices=vert+meanval;

            for i=1:numel(self.Boundary)
                linevert=self.Boundary{i}(:,1:2);
                linevert=linevert-meanval(1:2);
                linevert=transpose(rotmatrix*linevert');
                linevert=linevert+meanval(1:2);
                set(self.LineObj(i),'XData',linevert(:,1),'YData',linevert(:,2),...
                'ZData',zeros(1,numel(linevert(:,1))));
            end
        end


        function val=getBounds(self)

            xmin=self.ResizeView.Xmin;
            xmax=self.ResizeView.Xmax;
            ymin=self.ResizeView.Ymin;
            ymax=self.ResizeView.Ymax;
            val=[xmin,xmax;ymin,ymax];
        end


        function patchDeleted(self,src)
        end


        function dragMarker(self,evt1,evt2)
            dragMarker(self.ResizeView,evt1,evt2);
        end
    end


    events
SelectionChanged
    end
end

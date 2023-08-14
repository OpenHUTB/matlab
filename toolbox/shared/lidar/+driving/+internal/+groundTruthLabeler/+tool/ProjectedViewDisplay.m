classdef ProjectedViewDisplay<handle




    properties(GetAccess=public,SetAccess=private)






Figure
Fig

ProjectedView

    end

    properties(Access=private)
        DebugMode=false;
    end

    properties(Access=public,Hidden)


DockableFigure
CLimProjectedView


Cuboidx
RectX
CenValX
RectXPosition
Cuboidy
RectY
CenValY
RectYPosition
Cuboidz
RectZ


LineIconX
PointIconX
CircleIconX


LineIconY
PointIconY
CircleIconY


LineIconZ
PointIconZ
CircleIconZ


Panelx
AxesX
Handlex

Toolbarx
PreviewScatterx

Panely
AxesY
Handley

Toolbary
PreviewScattery

Panelz
AxesZ
Handlez

Toolbarz
PreviewScatterz


Line3Dx
Line3Dy
Line3Dz

Line2Dx
Line2Dy
Line2Dz
    end

    properties(Access=private)
CVal
CMap
BgColor
    end

    properties(Dependent)


Name
    end

    events


FigureDocked
FigureUndocked
FigureClosed

ROIDeleted
    end
    methods

        function hFig=get.Figure(this)
            hFig=this.DockableFigure.Figure;
        end


        function hFig=get.Fig(this)
            hFig=this.DockableFigure.Figure;
        end


        function TF=isDocked(this)
            TF=isDocked(this.DockableFigure);
        end
    end

    methods
        function this=ProjectedViewDisplay(enable)

            if enable
                layoutDockableFigure(this);
            end

        end


        function CreateProjectedViews(this)

            createCuboidProjectedView(this);

            createLineProjectedView(this);
        end


        function createCuboidProjectedView(this)


            this.Cuboidx=images.roi.Cuboid(...
            'Label','',...
            'Tag','Cuboidx',...
            'SelectedColor',[1,1,0],...
            'Rotatable','none',...
            'LabelVisible','off',...
            'UserData',{'cuboid','','',''});
            this.removeContextmenu(this.Cuboidx);
            this.Cuboidy=images.roi.Cuboid(...
            'Label','',...
            'Tag','Cuboidy',...
            'SelectedColor',[1,1,0],...
            'Rotatable','none',...
            'LabelVisible','off',...
            'UserData',{'cuboid','','',''});
            this.removeContextmenu(this.Cuboidy);
            this.Cuboidz=images.roi.Cuboid(...
            'Label','',...
            'Tag','Cuboidz',...
            'SelectedColor',[1,1,0],...
            'Rotatable','none',...
            'LabelVisible','off',...
            'UserData',{'cuboid','','',''});
            this.removeContextmenu(this.Cuboidz);

            this.RectZ=images.roi.Rectangle(...
            'Label','',...
            'Tag','rectz',...
            'SelectedColor',[1,1,0],...
            'FaceSelectable',false,...
            'FaceAlpha',0,...
            'UserData',{'rect','','',''},...
            'LabelVisible','off');
            this.RectZ.Rotatable=1;
            this.RectZ.Layer='front';
            this.removeContextmenu(this.RectZ);

            this.RectY=images.roi.Rectangle(...
            'Label','',...
            'Tag','recty',...
            'SelectedColor',[1,1,0],...
            'FaceSelectable',false,...
            'FaceAlpha',0,...
            'UserData',{'rect','','',''},...
            'LabelVisible','off');
            this.RectY.Layer='front';
            this.RectY.Rotatable=1;
            this.removeContextmenu(this.RectY);

            this.RectX=images.roi.Rectangle(...
            'Label','',...
            'Tag','rectx',...
            'SelectedColor',[1,1,0],...
            'FaceSelectable',false,...
            'FaceAlpha',0,...
            'UserData',{'rect','','',''},...
            'LabelVisible','off');
            this.RectX.Layer='front';
            this.RectX.Rotatable=1;
            this.removeContextmenu(this.RectX);


            this.LineIconZ=images.roi.Line(...
            'Label','',...
            'Tag','',...
            'SelectedColor',[1,1,0],...
            'UserData',{'icon','','',''},...
            'LabelVisible','off');
            this.PointIconZ=images.roi.Point(...
            'Label','',...
            'Tag','pointIconZ',...
            'SelectedColor',[1,1,0],...
            'UserData',{'icon','','',''},...
            'LabelVisible','off');
            this.PointIconZ.Layer='front';
            this.removeContextmenu(this.PointIconZ);

            this.CircleIconZ=images.roi.Circle(...
            'Label','',...
            'Tag','',...
            'SelectedColor',[1,1,0],...
            'UserData',{'icon','','',''},...
            'LabelVisible','off');


            this.LineIconX=images.roi.Line(...
            'Label','',...
            'Tag','',...
            'SelectedColor',[1,1,0],...
            'UserData',{'icon','','',''},...
            'LabelVisible','off');
            this.PointIconX=images.roi.Point(...
            'Label','',...
            'Tag','pointIconX',...
            'SelectedColor',[1,1,0],...
            'UserData',{'icon','','',''},...
            'LabelVisible','off');
            this.PointIconX.Layer='front';
            this.removeContextmenu(this.PointIconX);

            this.CircleIconX=images.roi.Circle(...
            'Label','',...
            'Tag','',...
            'SelectedColor',[1,1,0],...
            'UserData',{'icon','','',''},...
            'LabelVisible','off');


            this.LineIconY=images.roi.Line(...
            'Label','',...
            'Tag','',...
            'SelectedColor',[1,1,0],...
            'UserData',{'icon','','',''},...
            'LabelVisible','off');
            this.PointIconY=images.roi.Point(...
            'Label','',...
            'Tag','pointIconY',...
            'SelectedColor',[1,1,0],...
            'UserData',{'icon','','',''},...
            'LabelVisible','off');
            this.PointIconY.Layer='front';
            this.removeContextmenu(this.PointIconY);

            this.CircleIconY=images.roi.Circle(...
            'Label','',...
            'Tag','',...
            'SelectedColor',[1,1,0],...
            'UserData',{'icon','','',''},...
            'LabelVisible','off');
        end


        function createLineProjectedView(this)


            this.Line3Dx=vision.roi.Polyline3D(...
            'Label','',...
            'Tag','Line3Dx',...
            'SelectedColor',[1,1,0],...
            'LabelVisible','off',...
            'UserData',{'line','','',''});
            this.removeContextmenu(this.Line3Dx);
            this.Line3Dy=vision.roi.Polyline3D(...
            'Label','',...
            'Tag','Line3Dx',...
            'SelectedColor',[1,1,0],...
            'LabelVisible','off',...
            'UserData',{'line','','',''});
            this.removeContextmenu(this.Line3Dy);
            this.Line3Dz=vision.roi.Polyline3D(...
            'Label','',...
            'Tag','Line3Dx',...
            'SelectedColor',[1,1,0],...
            'LabelVisible','off',...
            'UserData',{'line','','',''});
            this.removeContextmenu(this.Line3Dz);

            this.Line2Dx=images.roi.Polyline(...
            'Label','',...
            'Tag','Line2Dx',...
            'SelectedColor',[1,1,0],...
            'UserData',{'line','','',''},...
            'LabelVisible','off');
            this.Line2Dx.Layer='front';
            this.removeContextmenu(this.Line2Dx);

            this.Line2Dy=images.roi.Polyline(...
            'Label','',...
            'Tag','Line2Dy',...
            'SelectedColor',[1,1,0],...
            'UserData',{'line','','',''},...
            'LabelVisible','off');
            this.Line2Dy.Layer='front';
            this.removeContextmenu(this.Line2Dy);

            this.Line2Dz=images.roi.Polyline(...
            'Label','',...
            'Tag','Line2Dz',...
            'SelectedColor',[1,1,0],...
            'UserData',{'line','','',''},...
            'LabelVisible','off');
            this.Line2Dz.Layer='front';
            this.removeContextmenu(this.Line2Dz);
        end


        function removeContextmenu(~,obj)

            cMenu=obj.UIContextMenu;
            h1=findobj(cMenu,'Tag','IPTROIContextMenuDelete');
            delete(h1);

            if isa(obj,'images.roi.Polyline')
                h2=findobj(cMenu,'Tag','IPTROIContextMenuAddPoint');
                delete(h2);
            end

            if isa(obj,'images.roi.Cuboid')||isa(obj,'vision.roi.Polyline3D')
                h1=findobj(cMenu,'Tag','IPTROIContextMenuLock');
            else
                h1=findobj(cMenu,'Tag','IPTROIContextMenuAspectRatio');
            end
            delete(h1);
        end


        function[panel,pcAxes,handle,toolbar,previewScatter]=setProjectedViewPanel(this,title)

            panel=uipanel(this.Figure,'Position',[0,0,1,.325]);
            panel.Title=title;
            panel.ForegroundColor=[1,1,1];
            pcAxes=axes('Parent',panel,...
            'Units','Normalized',...
            'position',[0,0,1,1],...
            'Visible','off',...
            'Color',[0,0,40/255]);
            pcshow([NaN,NaN,NaN],Parent=pcAxes,MarkerSize=10,AxesVisibility='on',...
            Projection="orthographic");
            set(pcAxes,'Color',[0,0,40/255]);
            set(panel,'BackgroundColor',[0,0,40/255]);
            handle=findobj(pcAxes,'Tag','pcviewer');
            set(handle,'HitTest','on','PickableParts','visible');
            if this.DebugMode
                toolbar=axtoolbar(pcAxes,{'rotate','pan','zoomin','zoomout','restoreview'},'Visible','on');
            else
                toolbar=axtoolbar(pcAxes,{'rotate','pan','zoomin','zoomout','restoreview'},'Visible','off');
                pcAxes.Visible='off';
            end
            rotate3d(pcAxes,'off');

            hold(pcAxes,'on');
            previewScatter=scatter3(NaN,NaN,NaN,10,[1,1,0],'.',...
            'HitTest','off',...
            'PickableParts','none',...
            'Parent',pcAxes,...
            'HandleVisibility','off');
            hold(pcAxes,'off');
            if this.DebugMode

                pcAxes.XLabel.String='X-axis';
                pcAxes.YLabel.String='Y-axis';
                pcAxes.ZLabel.String='Z-axis';
            end
        end


        function setProjectedView(this,enable)

            this.ProjectedView=enable;

            if enable
                [this.Panelx,this.AxesX,this.Handlex,this.Toolbarx,this.PreviewScatterx]=setProjectedViewPanel(this,...
                vision.getMessage('vision:labeler:FrontView'));

                [this.Panely,this.AxesY,this.Handley,this.Toolbary,this.PreviewScattery]=setProjectedViewPanel(this,...
                vision.getMessage('vision:labeler:SideView'));
                this.Panely.Position=[0,0.325,1,.325];

                [this.Panelz,this.AxesZ,this.Handlez,this.Toolbarz,this.PreviewScatterz]=setProjectedViewPanel(this,...
                vision.getMessage('vision:labeler:TopView'));
                this.Panelz.Position=[0,0.65,1,.325];
            end
        end


        function disableProjectedView(this)
            if this.ProjectedView
                this.AxesX.Parent=gobjects(0);
                this.AxesY.Parent=gobjects(0);
                this.AxesZ.Parent=gobjects(0);
            end
        end


        function bringIconFront(this)
            bringIconFront(this.DockableFigure);
        end


        function[activate,selectedROI,position]=checkActivation(this,src)
            selectedROI=[];
            position=[];
            activate=true;
            if numel(src.CurrentROIs)==0

                disableProjectedView(this);
                activate=false;
                return;
            else
                this.AxesX.Parent=this.Panelx;
                this.AxesY.Parent=this.Panely;
                this.AxesZ.Parent=this.Panelz;
            end

            anyROISelected=false;
            for i=1:numel(src.CurrentROIs)
                if src.CurrentROIs{i}.Selected==1
                    if anyROISelected==true


                        disableProjectedView(this);
                        activate=false;
                        return;
                    end

                    selectedROI=src.CurrentROIs{i};
                    position=src.CurrentROIs{i}.Position;

                    if isequal(class(selectedROI),'images.roi.Cuboid')
                        position(1:3)=position(1:3)+position(4:6)/2;
                    end

                    anyROISelected=true;
                end
            end
            if~anyROISelected

                disableProjectedView(this);
                activate=false;
                return;
            end
        end


        function activateProjectedViewCuboid(this,src,pointCloud,cVal,cMap,bgColor)




            this.updateROIVisibility("Cuboid");

            if this.ProjectedView
                this.CVal=cVal;
                this.CMap=cMap;
                this.BgColor=bgColor;

                [activate,selectedROI,pos]=checkActivation(this,src);
                if~activate
                    return;
                end

                rot=selectedROI.RotationAngle;
                cen=pos(1:3);


                start=cen-1.5*pos(4:6);
                endx=cen+1.5*pos(4:6);
                start(1)=cen(1)-sqrt(pos(4)*pos(4)+pos(5)*pos(5));
                endx(1)=cen(1)+sqrt(pos(4)*pos(4)+pos(5)*pos(5));
                start(2)=cen(2)-sqrt(pos(4)*pos(4)+pos(5)*pos(5));
                endx(2)=cen(2)+sqrt(pos(4)*pos(4)+pos(5)*pos(5));

                roi=[start(1),endx(1),start(2),endx(2),start(3),endx(3)];

                limits=double(horzcat(pointCloud.XLimits',pointCloud.YLimits',...
                pointCloud.ZLimits'));

                indices=findPointsInROI(pointCloud,roi);
                newPointCloud=select(pointCloud,indices);

                updateLimits=true;




                matx=[0,0,1,0;...
                1,0,0,0;...
                0,1,0,0;...
                0,0,0,1];
                tformx=affine3d(matx);
                s=start*matx(1:3,1:3);
                e=endx*matx(1:3,1:3);
                t=vertcat(s,e);
                sx=[min(t(:,1)),min(t(:,2)),min(t(:,3))];
                ex=[max(t(:,1)),max(t(:,2)),max(t(:,3))];
                pointCloudX=pctransform(newPointCloud,tformx);
                xLims=limits*matx(1:3,1:3);

                if rot(3)

                    theta=rot(3);
                    theta=theta*2*pi/360;

                    matxrotateZ=[cos(theta),0,sin(theta),0;...
                    0,1,0,0;...
                    -sin(theta),0,cos(theta),0;...
                    0,0,0,1];
                    tformxrotate=affine3d(matxrotateZ);

                    pointCloudX=pctransform(pointCloudX,tformxrotate);
                    s=sx*matxrotateZ(1:3,1:3);
                    e=ex*matxrotateZ(1:3,1:3);
                    t=vertcat(s,e);
                    sx=[min(t(:,1)),min(t(:,2)),min(t(:,3))];
                    ex=[max(t(:,1)),max(t(:,2)),max(t(:,3))];
                    xLims=xLims*matxrotateZ(1:3,1:3);
                end

                if rot(2)

                    theta=rot(2);
                    theta=theta*2*pi/360;

                    matxrotateY=[1,0,0,0;...
                    0,cos(theta),-sin(theta),0;...
                    0,sin(theta),cos(theta),0;...
                    0,0,0,1];
                    tformxrotate=affine3d(matxrotateY);

                    pointCloudX=pctransform(pointCloudX,tformxrotate);
                    s=sx*matxrotateY(1:3,1:3);
                    e=ex*matxrotateY(1:3,1:3);
                    t=vertcat(s,e);
                    sx=[min(t(:,1)),min(t(:,2)),min(t(:,3))];
                    ex=[max(t(:,1)),max(t(:,2)),max(t(:,3))];
                    xLims=xLims*matxrotateY(1:3,1:3);
                end




                if newPointCloud.Count

                    [X,Y,Z,cdata]=updateColormapProjectedView(this,pointCloudX.Location,...
                    updateLimits,this.AxesX,sx,ex);
                    xLim=[min(sx(3),min(Z,[],'omitnan')),max(ex(3),max(Z,[],'omitnan'))];
                    this.CenValX=-1*mean(xLim);

                    set(this.Handlex,'XData',X,'YData',Y,'ZData',Z+this.CenValX,'CData',cdata);
                else


                    if updateLimits
                        xLim=[sx(1),ex(1)];
                        yLim=[sx(2),ex(2)];
                        zLim=[sx(3),ex(3)];
                        cen_valz=-1*mean(zLim);
                        new_zLim=zLim+[cen_valz,cen_valz];
                        set(this.AxesX,'XLim',xLim,'YLim',yLim,'ZLim',new_zLim,'Colormap',this.CMap,'Color',this.BgColor);
                        set(this.AxesX.Parent,'BackgroundColor',this.BgColor);
                    end

                    xLim=[sx(3),ex(3)];
                    this.CenValX=-1*mean(xLim);
                    set(this.Handlex,'XData',[],'YData',[],'ZData',[]+this.CenValX,'CData',[]);
                end



                cuboidPosX=[pos(1:3)*matx(1:3,1:3),pos(4:6)*matx(1:3,1:3)];

                cuboidPosX(4:6)=abs(cuboidPosX(4:6));

                this.RectX.Position=[cuboidPosX(1)-cuboidPosX(4)/2...
                ,cuboidPosX(2)-cuboidPosX(5)/2,cuboidPosX(4),cuboidPosX(5)];



                this.RectXPosition=this.RectX.Position;

                if rot(3)

                    cuboidPosX(1:3)=cuboidPosX(1:3)*matxrotateZ(1:3,1:3);
                    cuboidPosX(4:6)=abs(cuboidPosX(4:6));
                end
                if rot(2)

                    cuboidPosX(1:3)=cuboidPosX(1:3)*matxrotateY(1:3,1:3);
                    cuboidPosX(4:6)=abs(cuboidPosX(4:6));
                end
                cuboidPosX(3)=cuboidPosX(3)+this.CenValX;



                this.assignCuboidDimensions(this.Cuboidx,this.AxesX,selectedROI,...
                cuboidPosX,this.Handlex,this.RectX,this.PreviewScatterx,...
                xLims,[0,0,rot(1)]);
                this.RectX.Position=[cuboidPosX(1)-cuboidPosX(4)/2...
                ,cuboidPosX(2)-cuboidPosX(5)/2,cuboidPosX(4),cuboidPosX(5)];

                this.RectX.RotationAngle=360-rot(1);
                validateBoundingLocation(this,this.RectX.Position,this.AxesX);







                maty=[1,0,0,0;...
                0,0,1,0;...
                0,1,0,0;...
                0,0,0,1];
                tformy=affine3d(maty);
                s=start*maty(1:3,1:3);
                e=endx*maty(1:3,1:3);
                t=vertcat(s,e);
                sy=[min(t(:,1)),min(t(:,2)),min(t(:,3))];
                ey=[max(t(:,1)),max(t(:,2)),max(t(:,3))];
                pointCloudY=pctransform(newPointCloud,tformy);
                yLims=limits*maty(1:3,1:3);

                if rot(3)

                    theta=rot(3);
                    theta=-1*theta;
                    theta=theta*2*pi/360;

                    matyrotateZ=[cos(theta),0,sin(theta),0;...
                    0,1,0,0;...
                    -sin(theta),0,cos(theta),0;...
                    0,0,0,1];
                    tformyrotate=affine3d(matyrotateZ);
                    pointCloudY=pctransform(pointCloudY,tformyrotate);
                    s=sy*matyrotateZ(1:3,1:3);
                    e=ey*matyrotateZ(1:3,1:3);
                    t=vertcat(s,e);
                    sy=[min(t(:,1)),min(t(:,2)),min(t(:,3))];
                    ey=[max(t(:,1)),max(t(:,2)),max(t(:,3))];
                    yLims=yLims*matyrotateZ(1:3,1:3);
                end

                if rot(1)

                    theta=rot(1);
                    theta=-1*theta;
                    theta=theta*2*pi/360;

                    matyrotateX=[1,0,0,0;...
                    0,cos(theta),-sin(theta),0;...
                    0,sin(theta),cos(theta),0;...
                    0,0,0,1];
                    tformyrotate=affine3d(matyrotateX);
                    pointCloudY=pctransform(pointCloudY,tformyrotate);
                    s=sy*matyrotateX(1:3,1:3);
                    e=ey*matyrotateX(1:3,1:3);
                    t=vertcat(s,e);
                    sy=[min(t(:,1)),min(t(:,2)),min(t(:,3))];
                    ey=[max(t(:,1)),max(t(:,2)),max(t(:,3))];
                    yLims=yLims*matyrotateX(1:3,1:3);
                end





                if newPointCloud.Count
                    [X,Y,Z,cdata]=updateColormapProjectedView(this,pointCloudY.Location,updateLimits,this.AxesY,sy,ey);
                    yLim=[min(sy(3),min(Z,[],'omitnan')),max(ey(3),max(Z,[],'omitnan'))];
                    this.CenValY=-1*mean(yLim);


                    set(this.Handley,'XData',X,'YData',Y,'ZData',Z+this.CenValY,'CData',cdata);
                else


                    if updateLimits
                        xLim=[sy(1),ey(1)];
                        yLim=[sy(2),ey(2)];
                        zLim=[sy(3),ey(3)];
                        cen_valz=-1*mean(zLim);
                        new_zLim=zLim+[cen_valz,cen_valz];
                        set(this.AxesY,'XLim',xLim,'YLim',yLim,'ZLim',new_zLim,'Colormap',this.CMap,'Color',this.BgColor);
                        set(this.AxesY.Parent,'BackgroundColor',this.BgColor);
                    end

                    yLim=[sy(3),ey(3)];
                    this.CenValY=-1*mean(yLim);
                    set(this.Handley,'XData',[],'YData',[],'ZData',[]+this.CenValY,'CData',[]);
                end



                cuboidPosY=[pos(1:3)*maty(1:3,1:3),pos(4:6)*maty(1:3,1:3)];

                this.RectY.Position=[cuboidPosY(1)-cuboidPosY(4)/2...
                ,cuboidPosY(2)-cuboidPosY(5)/2,cuboidPosY(4),cuboidPosY(5)];



                this.RectYPosition=this.RectY.Position;

                cuboidPosY(4:6)=abs(cuboidPosY(4:6));
                if rot(3)
                    cuboidPosY(1:3)=cuboidPosY(1:3)*matyrotateZ(1:3,1:3);
                    cuboidPosY(4:6)=abs(cuboidPosY(4:6));
                end
                if rot(1)
                    cuboidPosY(1:3)=cuboidPosY(1:3)*matyrotateX(1:3,1:3);
                    cuboidPosY(4:6)=abs(cuboidPosY(4:6));
                end
                cuboidPosY(3)=cuboidPosY(3)+this.CenValY;



                this.assignCuboidDimensions(this.Cuboidy,this.AxesY,selectedROI,...
                cuboidPosY,this.Handley,this.RectY,this.PreviewScattery,...
                yLims,[0,0,rot(2)]);
                this.RectY.Position=[cuboidPosY(1)-cuboidPosY(4)/2...
                ,cuboidPosY(2)-cuboidPosY(5)/2,cuboidPosY(4),cuboidPosY(5)];

                this.RectY.RotationAngle=360-rot(2);

                validateBoundingLocation(this,this.RectY.Position,this.AxesY);






                pointCloudZ=newPointCloud;



                sz=start;
                ez=endx;

                if rot(1)

                    theta=rot(1);
                    theta=theta*2*pi/360;

                    matzrotateX=[1,0,0,0;...
                    0,cos(theta),-sin(theta),0;...
                    0,sin(theta),cos(theta),0;...
                    0,0,0,1];
                    tformzrotate=affine3d(matzrotateX);

                    pointCloudZ=pctransform(pointCloudZ,tformzrotate);
                    s=sz*matzrotateX(1:3,1:3);
                    e=ez*matzrotateX(1:3,1:3);
                    t=vertcat(s,e);
                    sz=[min(t(:,1)),min(t(:,2)),min(t(:,3))];
                    ez=[max(t(:,1)),max(t(:,2)),max(t(:,3))];
                    limits=limits*matzrotateX(1:3,1:3);
                end

                if rot(2)

                    theta=rot(2);
                    theta=theta*2*pi/360;

                    matzrotateY=[cos(theta),0,sin(theta),0;...
                    0,1,0,0;...
                    -sin(theta),0,cos(theta),0;...
                    0,0,0,1];
                    tformzrotate=affine3d(matzrotateY);

                    pointCloudZ=pctransform(pointCloudZ,tformzrotate);
                    s=sz*matzrotateY(1:3,1:3);
                    e=ez*matzrotateY(1:3,1:3);
                    t=vertcat(s,e);
                    sz=[min(t(:,1)),min(t(:,2)),min(t(:,3))];
                    ez=[max(t(:,1)),max(t(:,2)),max(t(:,3))];
                    limits=limits*matzrotateY(1:3,1:3);
                end


                if newPointCloud.Count
                    [X,Y,Z,cdata,xLim,yLim,zLim]=updateColormapProjectedView(this,pointCloudZ.Location,...
                    updateLimits,this.AxesZ,sz,ez);
                    zLim=[min(sz(3),min(Z,[],'omitnan')),max(ez(3),max(Z,[],'omitnan'))];
                    cen_valz=-1*mean(zLim);


                    set(this.Handlez,'XData',X,'YData',Y,'ZData',Z+cen_valz,'CData',cdata);
                else


                    if updateLimits
                        xLim=[sz(1),ez(1)];
                        yLim=[sz(2),ez(2)];
                        zLim=[sz(3),ez(3)];
                        cen_valz=-1*mean(zLim);
                        new_zLim=zLim+[cen_valz,cen_valz];
                        set(this.AxesZ,'XLim',xLim,'YLim',yLim,'ZLim',new_zLim,'Colormap',this.CMap,'Color',this.BgColor);
                        set(this.AxesZ.Parent,'BackgroundColor',this.BgColor);
                    end

                    zLim=[sz(3),ez(3)];
                    cen_valz=-1*mean(zLim);
                    set(this.Handlez,'XData',[],'YData',[],'ZData',[]+cen_valz,'CData',[]);
                end

                pos_1=pos(1:3)-pos(4:6)/2;

                cuboidPosZ=pos(1:6);

                this.RectZ.Position=[pos_1(1),pos_1(2),pos(4),pos(5)];

                cuboidPosZ(3)=cuboidPosZ(3)+cen_valz;


                this.assignCuboidDimensions(this.Cuboidz,this.AxesZ,selectedROI,...
                cuboidPosZ,this.Handlez,this.RectZ,this.PreviewScatterz,...
                limits,[0,0,rot(3)]);

                this.RectZ.Position=[cuboidPosZ(1)-cuboidPosZ(4)/2...
                ,cuboidPosZ(2)-cuboidPosZ(5)/2,cuboidPosZ(4),cuboidPosZ(5)];
                this.RectZ.RotationAngle=360-rot(3);
                validateBoundingLocation(this,this.RectZ.Position,this.AxesZ);






                this.LineIconZ.Parent=this.AxesZ;
                this.LineIconZ.Color=selectedROI.SelectedColor;
                this.LineIconZ.UserData=selectedROI.UserData;
                this.LineIconZ.InteractionsAllowed='none';



                this.CircleIconZ.Parent=this.AxesZ;
                this.CircleIconZ.Color=selectedROI.SelectedColor;
                this.CircleIconZ.UserData=selectedROI.UserData;
                this.CircleIconZ.InteractionsAllowed='none';


                this.PointIconZ.Parent=this.AxesZ;
                this.PointIconZ.Color=selectedROI.SelectedColor;
                this.PointIconZ.SelectedColor=selectedROI.SelectedColor;
                this.PointIconZ.UserData=selectedROI.UserData;
                this.PointIconZ.InteractionsAllowed='all';


                this.LineIconX.Parent=this.AxesX;
                this.LineIconX.Color=selectedROI.SelectedColor;
                this.LineIconX.UserData=selectedROI.UserData;
                this.LineIconX.InteractionsAllowed='none';

                this.CircleIconX.Parent=this.AxesX;
                this.CircleIconX.Color=selectedROI.SelectedColor;
                this.CircleIconX.UserData=selectedROI.UserData;
                this.CircleIconX.InteractionsAllowed='none';


                this.PointIconX.Parent=this.AxesX;
                this.PointIconX.Color=selectedROI.SelectedColor;
                this.PointIconX.SelectedColor=selectedROI.SelectedColor;
                this.PointIconX.UserData=selectedROI.UserData;
                this.PointIconX.InteractionsAllowed='all';


                this.LineIconY.Parent=this.AxesY;
                this.LineIconY.Color=selectedROI.SelectedColor;
                this.LineIconY.UserData=selectedROI.UserData;
                this.LineIconY.InteractionsAllowed='none';

                this.CircleIconY.Parent=this.AxesY;
                this.CircleIconY.Color=selectedROI.SelectedColor;
                this.CircleIconY.UserData=selectedROI.UserData;
                this.CircleIconY.InteractionsAllowed='none';


                this.PointIconY.Parent=this.AxesY;
                this.PointIconY.Color=selectedROI.SelectedColor;
                this.PointIconY.SelectedColor=selectedROI.SelectedColor;
                this.PointIconY.UserData=selectedROI.UserData;
                this.PointIconY.InteractionsAllowed='all';



                settingRotateIcon(this,this.RectZ.RotationAngle,this.RectZ,'Z');
                settingRotateIcon(this,this.RectX.RotationAngle,this.RectX,'X');
                settingRotateIcon(this,this.RectY.RotationAngle,this.RectY,'Y');
            end
        end


        function activateProjectedViewLine(this,src,pointCloud,cVal,cMap,bgColor)




            this.updateROIVisibility("Line");

            if this.ProjectedView
                this.CVal=cVal;
                this.CMap=cMap;
                this.BgColor=bgColor;

                [activate,selectedROI,pos]=checkActivation(this,src);
                if~activate
                    return;
                end




                maxDistance=max(max(pos(:,3)),max(max(pos(:,2)),max(pos(:,1))));



                start(1)=max(min(pos(:,1))-maxDistance/2,pointCloud.XLimits(1));
                endx(1)=min(max(pos(:,1))+maxDistance/2,pointCloud.XLimits(2));
                start(2)=max(min(pos(:,2))-maxDistance/2,pointCloud.YLimits(1));
                endx(2)=min(max(pos(:,2))+maxDistance/2,pointCloud.YLimits(2));
                start(3)=pointCloud.ZLimits(1);
                endx(3)=pointCloud.ZLimits(2);

                roi=[start(1),endx(1),start(2),endx(2),start(3),endx(3)];


                limits=double(horzcat(pointCloud.XLimits',pointCloud.YLimits',...
                pointCloud.ZLimits'));


                indices=findPointsInROI(pointCloud,roi);
                newPointCloud=select(pointCloud,indices);
                updateLimits=true;




                matx=[0,0,1,0;...
                1,0,0,0;...
                0,1,0,0;...
                0,0,0,1];
                tformx=affine3d(matx);
                s=start*matx(1:3,1:3);
                e=endx*matx(1:3,1:3);
                t=vertcat(s,e);
                sx=[min(t(:,1)),min(t(:,2)),min(t(:,3))];
                ex=[max(t(:,1)),max(t(:,2)),max(t(:,3))];
                pointCloudX=pctransform(newPointCloud,tformx);
                xLims=limits*matx(1:3,1:3);

                if newPointCloud.Count

                    [X,Y,Z,cdata]=updateColormapProjectedView(this,pointCloudX.Location,...
                    updateLimits,this.AxesX,sx,ex);


                    set(this.Handlex,'XData',X,'YData',Y,'ZData',Z,'CData',cdata);
                else


                    if updateLimits
                        xLim=[sx(1),ex(1)];
                        yLim=[sx(2),ex(2)];
                        zLim=[sx(3),ex(3)];
                        cen_valz=-1*mean(zLim);
                        new_zLim=zLim+[cen_valz,cen_valz];
                        set(this.AxesX,'XLim',xLim,'YLim',yLim,'ZLim',new_zLim,'Colormap',this.CMap,'Color',this.BgColor);
                        set(this.AxesX.Parent,'BackgroundColor',this.BgColor);
                    end

                    xLim=[sx(3),ex(3)];
                    cenValX=-1*mean(xLim);
                    set(this.Handlex,'XData',[],'YData',[],'ZData',[]+cenValX,'CData',[]);
                end

                LinePosX=pos*matx(1:3,1:3);
                this.Line2Dx.Position=[LinePosX(:,1),LinePosX(:,2)];

                this.assignLineDimensions(this.Line3Dx,this.AxesX,selectedROI,...
                this.Line2Dx,xLims);







                maty=[1,0,0,0;...
                0,0,1,0;...
                0,1,0,0;...
                0,0,0,1];
                tformy=affine3d(maty);
                s=start*maty(1:3,1:3);
                e=endx*maty(1:3,1:3);
                t=vertcat(s,e);
                sy=[min(t(:,1)),min(t(:,2)),min(t(:,3))];
                ey=[max(t(:,1)),max(t(:,2)),max(t(:,3))];
                pointCloudY=pctransform(newPointCloud,tformy);
                yLims=limits*maty(1:3,1:3);


                if newPointCloud.Count
                    [X,Y,Z,cdata]=updateColormapProjectedView(this,pointCloudY.Location,...
                    updateLimits,this.AxesY,sy,ey);


                    set(this.Handley,'XData',X,'YData',Y,'ZData',Z,'CData',cdata);
                else


                    if updateLimits
                        xLim=[sy(1),ey(1)];
                        yLim=[sy(2),ey(2)];
                        zLim=[sy(3),ey(3)];
                        cen_valz=-1*mean(yLim);
                        new_zLim=zLim+[cen_valz,cen_valz];
                        set(this.AxesY,'XLim',xLim,'YLim',yLim,'ZLim',new_zLim,'Colormap',this.CMap,'Color',this.BgColor);
                        set(this.AxesY.Parent,'BackgroundColor',this.BgColor);
                    end

                    yLim=[sy(3),ey(3)];
                    cenValY=-1*mean(yLim);
                    set(this.Handley,'XData',[],'YData',[],'ZData',[]+cenValY,'CData',[]);
                end



                LinePosY=pos*maty(1:3,1:3);
                this.Line2Dy.Position=[LinePosY(:,1),LinePosY(:,2)];

                this.assignLineDimensions(this.Line3Dy,this.AxesY,selectedROI,...
                this.Line2Dy,yLims);





                pointCloudZ=newPointCloud;




                if newPointCloud.Count

                    [X,Y,Z,cdata]=updateColormapProjectedView(this,pointCloudZ.Location,...
                    updateLimits,this.AxesZ,start,endx);


                    set(this.Handlez,'XData',X,'YData',Y,'ZData',Z,'CData',cdata);
                else


                    if updateLimits
                        xLim=[start(1),endx(1)];
                        yLim=[start(2),endx(2)];
                        zLim=[start(3),endx(3)];
                        cen_valz=-1*mean(zLim);
                        new_zLim=zLim+[cen_valz,cen_valz];
                        set(this.AxesZ,'XLim',xLim,'YLim',yLim,'ZLim',new_zLim,'Colormap',this.CMap,'Color',this.BgColor);
                        set(this.AxesZ.Parent,'BackgroundColor',this.BgColor);
                    end

                    zLim=[start(3),endx(3)];
                    cen_valz=-1*mean(zLim);
                    set(this.Handlez,'XData',[],'YData',[],'ZData',[]+cen_valz,'CData',[]);
                end

                LinePosZ=pos;
                this.Line2Dz.Position=[LinePosZ(:,1),LinePosZ(:,2)];

                this.assignLineDimensions(this.Line3Dz,this.AxesZ,selectedROI,...
                this.Line2Dz,limits);




            end
        end

        function validateBoundingLocation(~,boundingLoc,displayAxes)

            if boundingLoc(1)<displayAxes.XLim(1)
                displayAxes.XLim(1)=boundingLoc(1);
            end

            if boundingLoc(1)+boundingLoc(3)>displayAxes.XLim(2)
                displayAxes.XLim(2)=boundingLoc(1)+boundingLoc(3);
            end

            if boundingLoc(2)<displayAxes.YLim(1)
                displayAxes.YLim(1)=boundingLoc(2);
            end

            if boundingLoc(2)+boundingLoc(4)>displayAxes.YLim(2)
                displayAxes.YLim(2)=boundingLoc(2)+boundingLoc(4);
            end
        end

        function assignLineDimensions(this,ROI3D,pcAxes,selectedROI,ROI2D,limits)

            ROI3D.Parent=pcAxes;
            ROI3D.Label=selectedROI.Label;
            ROI3D.Tag=selectedROI.Label;
            ROI3D.Color=selectedROI.Color;
            ROI3D.UserData=selectedROI.UserData;
            ROI3D.Selected=true;
            ROI3D.InteractionsAllowed='all';

            ROI2D.Parent=pcAxes;
            ROI2D.Label=selectedROI.Label;
            ROI2D.Color=selectedROI.Color;
            ROI2D.UserData=selectedROI.UserData;


            newLims=getDrawingAreaLimits(this,pcAxes,limits);
            ROI2D.DrawingArea=[newLims(1,1:2),abs(newLims(2,1:2)-newLims(1,1:2))];
            ROI2D.Selected=true;
            ROI2D.InteractionsAllowed='all';

            pcAxes.CameraUpVector=[0,1,0];
            pcAxes.CameraPosition=[mean(newLims(:,1)),mean(newLims(:,2)),mean(newLims(:,3))+20];
            pcAxes.CameraTarget=[mean(newLims(:,1)),mean(newLims(:,2)),mean(newLims(:,3))];
        end

        function assignCuboidDimensions(this,cuboid,pcAxes,selectedROI,cuboidPos,handle,rect,previewScatter,limits,rot)

            cuboid.Parent=pcAxes;
            cuboid.Label=selectedROI.Label;
            cuboid.Tag=selectedROI.Label;
            cuboid.Color=selectedROI.Color;
            cuboid.UserData=selectedROI.UserData;
            cuboid.Selected=true;
            cuboid.RotationAngle=[0,0,0];
            cuboid.InteractionsAllowed='all';
            set(cuboid,'CenteredPosition',cuboidPos,'RotationAngle',rot);

            rect.Parent=pcAxes;
            rect.Label=selectedROI.Label;
            rect.Color=selectedROI.Color;
            rect.UserData=selectedROI.UserData;
            rect.UserData{1}='rect';

            newLims=getDrawingAreaLimits(this,pcAxes,limits);
            rect.DrawingArea=[newLims(1,1:2),abs(newLims(2,1:2)-newLims(1,1:2))];
            rect.Selected=true;
            rect.InteractionsAllowed='all';

            if~isempty(handle.XData)
                x=handle.XData(isfinite(handle.XData));
                y=handle.YData(isfinite(handle.YData));
                z=handle.ZData(isfinite(handle.ZData));
                TF=inROI(cuboid,x,y,z);
                set(previewScatter,'XData',x(TF),'YData',y(TF),'ZData',z(TF),'Visible','on')
            else
                set(previewScatter,'XData',[],'YData',[],'ZData',[],'Visible','on')
            end


            pcAxes.CameraUpVector=[0,1,0];
            pcAxes.CameraPosition=[cuboidPos(1),cuboidPos(2),cuboidPos(3)+0.75*max(abs([cuboidPos(1),cuboidPos(2)]))];
            pcAxes.CameraTarget=cuboidPos(1:3);
        end


        function updateROIVisibility(this,value)

            if strcmp(value,"Line")
                TF=true;
            else
                TF=false;
            end

            this.Cuboidx.Visible=~TF;
            this.Cuboidy.Visible=~TF;
            this.Cuboidz.Visible=~TF;

            this.RectX.Visible=~TF;
            this.RectY.Visible=~TF;
            this.RectZ.Visible=~TF;

            this.CircleIconZ.Visible=~TF;
            this.LineIconZ.Visible=~TF;
            this.PointIconZ.Visible=~TF;

            this.CircleIconX.Visible=~TF;
            this.LineIconX.Visible=~TF;
            this.PointIconX.Visible=~TF;

            this.CircleIconY.Visible=~TF;
            this.LineIconY.Visible=~TF;
            this.PointIconY.Visible=~TF;

            this.PreviewScatterx.Visible=~TF;
            this.PreviewScattery.Visible=~TF;
            this.PreviewScatterz.Visible=~TF;

            this.Line2Dx.Visible=TF;
            this.Line2Dy.Visible=TF;
            this.Line2Dz.Visible=TF;

            this.Line3Dx.Visible=TF;
            this.Line3Dy.Visible=TF;
            this.Line3Dz.Visible=TF;
        end

        function newLims=getDrawingAreaLimits(~,pcAxes,limits)


            pcLimits=horzcat(pcAxes.XLim',pcAxes.YLim',pcAxes.ZLim');
            newLims=vertcat(max(limits(1,:),pcLimits(1,:)),...
            min(limits(2,:),pcLimits(2,:)));
            newLims=double(newLims);
        end

        function[X,Y,Z,cdata,xLim,yLim,zLim]=updateColormapProjectedView(this,I,updateLimits,axes,start,endx)


            if ismatrix(I)
                X=I(:,1);
                Y=I(:,2);
                Z=I(:,3);
            else
                X=reshape(I(:,:,1),[],1);
                Y=reshape(I(:,:,2),[],1);
                Z=reshape(I(:,:,3),[],1);
            end


            switch this.CVal
            case 'z'
                pts=Z;
            case 'radial'
                pts=sqrt((X.^2)+(Y.^2));
            otherwise
                assert(false,'Not a valid colormap value');
            end

            if updateLimits

                xLim=[min(start(1),min(X,[],'omitnan')),max(endx(1),max(X,[],'omitnan'))];
                yLim=[min(start(2),min(Y,[],'omitnan')),max(endx(2),max(Y,[],'omitnan'))];
                zLim=[min(start(3),min(Z,[],'omitnan')),max(endx(3),max(Z,[],'omitnan'))];

                if any(isnan([xLim,yLim,zLim]))
                    return;
                end

                cen_valz=-1*mean(zLim);
                new_zLim=zLim+[cen_valz,cen_valz];
                set(axes,'XLim',xLim,'YLim',yLim,'ZLim',new_zLim,'Colormap',this.CMap,'Color',this.BgColor);
                set(axes.Parent,'BackgroundColor',this.BgColor);

                sortedPts=sort(pts(~isnan(pts)));
                n=numel(sortedPts);
                if n>100
                    this.CLimProjectedView=[sortedPts(floor(0.02*n)),sortedPts(ceil(0.98*n))];
                else
                    this.CLimProjectedView=[min(sortedPts),max(sortedPts)];
                end

            end


            cdata=(pts-this.CLimProjectedView(1))/(this.CLimProjectedView(2)-this.CLimProjectedView(1));
            cdata(cdata>1)=1;
            cdata(cdata<0)=0;

        end

        function settingRotateIcon(this,angle,rect,RectType)

            switch RectType
            case 'X'

                extra_h=0.2*(rect.Position(3)/2+rect.Position(4));
            case 'Y'

                extra_h=0.2*(rect.Position(3)/2+rect.Position(4));
            case 'Z'

                extra_h=0.15*(rect.Position(3)+rect.Position(4));
            end


            circlepos=[rect.Position(1)+rect.Position(3)/2,rect.Position(2)+rect.Position(4);...
            rect.Position(1)+rect.Position(3)/2,rect.Position(2)+rect.Position(4)+extra_h];


            pointpos=[rect.Position(1)+rect.Position(3)/2,rect.Position(2)+rect.Position(4)+extra_h];


            theta=(angle*2*pi)/360;
            matrotate=[cos(theta),-1*sin(theta);...
            sin(theta),cos(theta)];

            if RectType=='Z'
                rect_center=this.RectZ.Position(1:2)+this.RectZ.Position(3:4)/2;
            elseif RectType=='X'
                rect_center=this.RectX.Position(1:2)+this.RectX.Position(3:4)/2;
            else
                rect_center=this.RectY.Position(1:2)+this.RectY.Position(3:4)/2;
            end



            diffpos=pointpos-rect_center;
            diff1=circlepos-vertcat(rect_center,rect_center);

            if RectType=='Z'


                this.LineIconZ.Position=diff1*matrotate+vertcat(rect_center,rect_center);
                this.PointIconZ.Position=diffpos*matrotate+rect_center;


                pointArea=(this.RectZ.Position(3)+this.RectZ.Position(4))*0.15;

                this.CircleIconZ.Center=this.PointIconZ.Position;
                this.CircleIconZ.Radius=pointArea/2;
            elseif RectType=='X'
                this.LineIconX.Position=diff1*matrotate+vertcat(rect_center,rect_center);
                this.PointIconX.Position=diffpos*matrotate+rect_center;
                pointArea=(this.RectX.Position(3)+this.RectX.Position(4))*0.15;

                this.CircleIconX.Center=this.PointIconX.Position;
                this.CircleIconX.Radius=pointArea*0.3;
            else
                this.LineIconY.Position=diff1*matrotate+vertcat(rect_center,rect_center);
                this.PointIconY.Position=diffpos*matrotate+rect_center;
                pointArea=(this.RectY.Position(3)+this.RectY.Position(4))*0.15;

                this.CircleIconY.Center=this.PointIconY.Position;
                this.CircleIconY.Radius=pointArea*0.3;
            end

        end


        function configure(this,keyPressCallback,deleteCallback)
            this.Figure.DeleteFcn=deleteCallback;
            this.Figure.KeyPressFcn=keyPressCallback;
        end


        function addFigureToApp(this,container)
            addFigureToApp(this.DockableFigure,container);
            this.Figure.WindowStyle='normal';
        end


        function show(this)
            this.Figure.Visible='on';
        end


        function flag=isPanelVisible(this)
            flag=strcmpi(this.Figure.Visible,'on');
        end


        function dockProjectedViewDisplay(this)
            doDock(this.DockableFigure);
        end


        function undockProjectedViewDisplay(this)
            doUndock(this.DockableFigure);
        end


        function name=get.Name(this)
            name=this.Figure.Name;
        end


        function close(this)

            if isvalid(this)
                drawnow();
                delete(this.DockableFigure);
            end
            delete(this);
        end
    end




    methods(Access=public,Hidden)

        function rectRotatingCallback(this,src,evt,RectType)
            newRectangle=src;
            angle=newRectangle.RotationAngle;

            if evt.PreviousRotationAngle~=evt.CurrentRotationAngle
                if RectType=='Z'
                    settingRotateIcon(this,angle,newRectangle,'Z');
                elseif RectType=='X'
                    settingRotateIcon(this,angle,newRectangle,'X');
                else
                    settingRotateIcon(this,angle,newRectangle,'Y');
                end
            end
        end

        function[angle,point]=getAngleMadeByPoint(this,change,rect)


            rect_center=[rect.Position(1)+rect.Position(3)/2,rect.Position(2)+rect.Position(4)/2];
            point=[rect_center;change.Position];
            angle=360*atan(diff(point(:,1))/diff(point(:,2)))/(2*pi);
        end

        function pointMovingCallback(this,change,evt,rect,RectType)


            [angle,point]=getAngleMadeByPoint(this,change,rect);


            if RectType=='Z'
                isInLimits=checkIfInLimits(this,rect.Vertices,...
                (angle*2*pi)/360,rect.DrawingArea,rect);
                if~isInLimits
                    this.PointIconZ.Position=evt.PreviousPosition;
                    return;
                end

                adjustingNewPointPosition(this,change,angle,point,rect,RectType);


                this.PointIconZ.SelectedColor=[1,1,1];
                this.CircleIconZ.Color=[1,1,1];
            elseif RectType=='X'
                isInLimits=checkIfInLimits(this,rect.Vertices,...
                (angle*2*pi)/360,rect.DrawingArea,rect);
                if~isInLimits
                    this.PointIconX.Position=evt.PreviousPosition;
                    return;
                end

                adjustingNewPointPosition(this,change,angle,point,rect,RectType);


                this.PointIconX.SelectedColor=[1,1,1];
                this.CircleIconX.Color=[1,1,1];
            else
                isInLimits=checkIfInLimits(this,rect.Vertices,...
                (angle*2*pi)/360,rect.DrawingArea,rect);
                if~isInLimits
                    this.PointIconY.Position=evt.PreviousPosition;
                    return;
                end

                adjustingNewPointPosition(this,change,angle,point,rect,RectType);


                this.PointIconY.SelectedColor=[1,1,1];
                this.CircleIconY.Color=[1,1,1];
            end
        end

        function isInLimits=checkIfInLimits(this,vertices,theta,constraints,rect)
            theta=-1*theta;
            rotateMat=[cos(theta),-1*sin(theta);sin(theta),cos(theta)];
            cen=rect.Position(1:2)+rect.Position(3:4)/2;
            centers=repmat(cen,[4,1]);




            newVertices=(vertices-centers)*rotateMat+centers;
            xCoords=all(newVertices(:,1)>=constraints(1)&newVertices(:,1)<=constraints(1)+constraints(3));
            yCoords=all(newVertices(:,2)>=constraints(2)&newVertices(:,2)<=constraints(2)+constraints(4));
            isInLimits=xCoords&yCoords;
        end

        function[data,changeIdx]=pointMovedCallback(this,change,currentrois,rect,recttype)




            [angle,point]=getAngleMadeByPoint(this,change,rect);

            angle=adjustingNewPointPosition(this,change,angle,point,rect,recttype);

            pointArea=(rect.Position(3)+rect.Position(4))*0.15;
            if recttype=='X'
                this.CircleIconX.Radius=pointArea*0.3;
            elseif recttype=='Y'
                this.CircleIconY.Radius=pointArea*0.3;
            else
                this.CircleIconZ.Radius=pointArea/2;
            end

            finalPos=[];
            changeIdx=0;
            for idx=1:numel(currentrois)
                if strcmp(rect.UserData{4},currentrois{idx}.UserData{4})


                    pos_1=currentrois{idx}.Position;

                    pos_1(1:2)=this.RectZ.Position(1:2);
                    pos_1(4:5)=this.RectZ.Position(3:4);
                    finalPos=horzcat(pos_1,currentrois{idx}.RotationAngle);
                    if recttype=='X'
                        finalPos(7)=360-angle;
                    elseif recttype=='Y'
                        finalPos(8)=360-angle;
                    else
                        finalPos(9)=360-angle;
                    end
                    changeIdx=idx;
                end
            end
            data=finalPos;
        end

        function angle=adjustingNewPointPosition(this,change,angle,point,rect,recttype)





            if point(2,2)<point(1,2)
                angle=angle-180;
            end
            rect.RotationAngle=angle;
            theta=(angle*2*pi)/360;

            switch recttype
            case 'X'

                extra_h=0.2*(rect.Position(3)/2+rect.Position(4));
            case 'Y'

                extra_h=0.2*(rect.Position(3)/2+rect.Position(4));
            case 'Z'

                extra_h=0.15*(rect.Position(3)+rect.Position(4));
            end


            circlepos=[rect.Position(1)+rect.Position(3)/2,rect.Position(2)+rect.Position(4);...
            rect.Position(1)+rect.Position(3)/2,rect.Position(2)+rect.Position(4)+extra_h];


            pointpos=[rect.Position(1)+rect.Position(3)/2,rect.Position(2)+rect.Position(4)+extra_h];


            pointRotate=[cos(theta),-1*sin(theta);...
            sin(theta),cos(theta)];
            rect_center=rect.Position(1:2)+rect.Position(3:4)/2;



            diffpos=pointpos-rect_center;
            diff1=circlepos-vertcat(rect_center,rect_center);

            if recttype=='X'
                this.LineIconX.Position=diff1*pointRotate+vertcat(rect_center,rect_center);
                this.PointIconX.Position=diffpos*pointRotate+rect_center;
                this.CircleIconX.Center=change.Position;
            elseif recttype=='Y'
                this.LineIconY.Position=diff1*pointRotate+vertcat(rect_center,rect_center);
                this.PointIconY.Position=diffpos*pointRotate+rect_center;
                this.CircleIconY.Center=change.Position;
            else
                this.LineIconZ.Position=diff1*pointRotate+vertcat(rect_center,rect_center);
                this.PointIconZ.Position=diffpos*pointRotate+rect_center;
                this.CircleIconZ.Center=change.Position;
            end
        end

        function[data,changeIdx]=rectMovedCallback(this,change,currentrois)


            finalPos=[];
            changeIdx=0;
            for idx=1:numel(currentrois)

                if strcmp(change.Source.UserData{4},currentrois{idx}.UserData{4})
                    pos_1=currentrois{idx}.Position;

                    if strcmp(change.Source.Tag,'rectx')||strcmp(change.Source.Tag,'recty')
                        isRectX=false;
                        if strcmp(change.Source.Tag,'rectx')
                            isRectX=true;
                        end
                        pos_1=this.calculatePosForXandY(pos_1,currentrois{idx}.RotationAngle(3),...
                        change.CurrentPosition,isRectX,change.PreviousPosition);
                    else


                        pos_1(1:2)=change.CurrentPosition(1:2);
                        pos_1(4:5)=change.CurrentPosition(3:4);
                    end


                    finalPos=horzcat(pos_1,currentrois{idx}.RotationAngle);
                    if strcmp(change.Source.Tag,'rectz')
                        finalPos(9)=360-change.CurrentRotationAngle;
                    end
                    changeIdx=idx;
                    break;
                end
            end
            data=finalPos;
        end




        function[data,changeIdx]=lineROIMovedCallback(~,change,currentrois)


            finalPos=[];
            changeIdx=0;
            for idx=1:numel(currentrois)

                if strcmp(change.Source.UserData{4},currentrois{idx}.UserData{4})
                    pos_1=currentrois{idx}.Position;
                    offset=change.CurrentPosition-change.PreviousPosition;
                    if strcmp(change.Source.Tag,'Line2Dx')||strcmp(change.Source.Tag,'Line2Dy')
                        if strcmp(change.Source.Tag,'Line2Dx')
                            offset=[zeros(size(offset,1),1),offset(:,1),offset(:,2)];
                        else
                            offset=[offset(:,1),zeros(size(offset,1),1),offset(:,2)];
                        end
                    else
                        offset=[offset(:,1),offset(:,2),zeros(size(offset,1),1)];
                    end
                    finalPos=pos_1+offset;
                    changeIdx=idx;
                end
            end
            data=finalPos;
        end




        function[data,changeIdx]=lineROIVertexDeletedCallback(~,change,currentrois)


            finalPos=[];
            changeIdx=0;
            for idx=1:numel(currentrois)

                if strcmp(change.Source.UserData{4},currentrois{idx}.UserData{4})
                    pos_1=currentrois{idx}.Position;
                    if strcmp(change.Source.Tag,'Line2Dx')||strcmp(change.Source.Tag,'Line2Dy')
                        if strcmp(change.Source.Tag,'Line2Dx')
                            newPosition=pos_1(:,[2,3]);
                            deletedRowIdx=find(~ismember(newPosition,change.Source.Position,'rows'),1);
                        else
                            newPosition=pos_1(:,[1,3]);
                            deletedRowIdx=find(~ismember(newPosition,change.Source.Position,'rows'),1);
                        end
                    else
                        newPosition=pos_1(:,[1,2]);
                        deletedRowIdx=find(~ismember(newPosition,change.Source.Position,'rows'),1);
                    end
                    pos_1(deletedRowIdx,:)=[];
                    finalPos=pos_1;
                    changeIdx=idx;
                end
            end
            data=finalPos;
        end

        function finalPos=calculatePosForXandY(this,pos,rot,currPos,isRectX,prevPos)


            if rot~=0


                offset=currPos-prevPos;
                if isRectX


                    cenpos=this.RectXPosition+offset;
                else


                    cenpos=this.RectYPosition+offset;
                end

                cenposFinal=cenpos;
                finalPos=assignVals(this,pos,cenposFinal,isRectX);
                finalPos=assignDimensions(this,finalPos,cenposFinal,isRectX);
            else
                finalPos=assignVals(this,pos,currPos,isRectX);
                finalPos=assignDimensions(this,finalPos,currPos,isRectX);
            end

        end

        function finalPos=assignVals(~,pos,currPos,isRectX)
            finalPos=pos;
            if isRectX

                finalPos(2)=currPos(1);
            else

                finalPos(1)=currPos(1);
            end

            finalPos(3)=currPos(2);
        end

        function finalPos=assignDimensions(~,pos,currPos,isRectX)
            finalPos=pos;
            if isRectX

                finalPos(5)=currPos(3);
            else

                finalPos(4)=currPos(3);
            end

            finalPos(6)=currPos(4);
        end
    end

    methods(Access=private)

        function layoutDockableFigure(this)

            this.DockableFigure=vision.internal.uitools.DockableAppFigure(...
            'NumberTitle','off',...
            'IntegerHandle','off',...
            'Name',vision.getMessage('vision:labeler:LidarProjectedView'),...
            'Units','normalized',...
            'MenuBar','none',...
            'HandleVisibility','off',...
            'Visible','off');

            addlistener(this.DockableFigure,'FigureDocked',@(~,~)notify(this,'FigureDocked'));
            addlistener(this.DockableFigure,'FigureUndocked',@(~,~)notify(this,'FigureUndocked'));
            addlistener(this.DockableFigure,'FigureClosed',@(~,~)notify(this,'FigureClosed'));
        end
    end
end
classdef SlicingInteractivity<handle
    properties(Hidden=true)
Figure
Axes
patch
        Contextmenu;
SliceButton
Multiplier
    end
    properties(Hidden=true)
        InteractivityFlag=0;
    end
    properties(Access=protected)

Panel
PanelAxes
Layout

XYBtn
YZBtn
XZBtn
undoBtn
redoBtn
restoreViewBtn
deleteBtn
FinishBtn
panel

SliceSurface
        PlaneFlag=[1,0,0];
        startpt=[];
        BoundingBox={};
        BoundingBoxFlag;
        ExcludeId;
        deleteMenu;
defLims

marker
SelectedEdges

        undostack;
        redostack;
        keypress={'';''};

FeedPoint
FeedPoints
FeedTriangle
FeedTriangulation
FeedWidth
FeedHeight
Triang
AntennaObj
FeedEdgeLine

    end
    methods

        function Slicer(obj,varargin)



            if~isempty(obj.Figure)
                obj.Figure.delete;
            end
            obj.SelectedEdges=[];
            if numel(varargin)>1
                obj.AntennaObj=varargin{2};
            else
                obj.AntennaObj=[];
            end
            obj.SliceSurface=[];obj.BoundingBox={};
            if isempty(varargin)

                f=figure;
                obj.Figure=f;
                ax=gca;
                obj.Axes=ax;ax.XLabel.String='X';ax.ZLabel.String='Z';ax.YLabel.String='Y';
                antennaColor=[223,185,58]/255;
                ant=discone;
                [~]=mesh(ant,'MaxEdgeLength',1);
                [p,t]=exportMesh(ant);
                obj.Triang=triangulation(t,p);
                ax.Position=[0.05,0.14,0.675,0.715];
                obj.view_mesh(ax,p,t(:,1:3),antennaColor);
            elseif(isa(varargin{1},'triangulation'))

                p=varargin{1}.Points;
                [p,obj.Multiplier,units]=engunits(p);
                t=varargin{1}.ConnectivityList;
                obj.Triang=varargin{1};
                antennaColor=[223,185,58]/255;

                f=gcf;


                if isa(obj.AntennaObj,'customAntennaStl')
                    f.Name='Create Feed';
                end
                obj.disableAxesToolbar(f,'off');
                clf(f);
                ax=gca;
                enableLegacyExplorationModes(f);
                axt=axtoolbar(ax,{'datacursor','pan','zoomin','zoomout','rotate'});
                obj.Figure=f;
                ax=gca;
                obj.Axes=ax;
                ax.XLabel.String='x';
                ax.ZLabel.String='z';
                ax.YLabel.String='y';
                if isprop(obj.AntennaObj,'Units')
                    ax.XLabel.String=['x(',obj.AntennaObj.Units,')'];
                    ax.ZLabel.String=['z(',obj.AntennaObj.Units,')'];
                    ax.YLabel.String=['y(',obj.AntennaObj.Units,')'];
                end

                obj.view_mesh(ax,p,t(:,1:3),antennaColor);
                em.MeshGeometry.decoratefigureandaxes(p(:,1),p(:,2),p(:,3),units);
                if numel(varargin)>1



                end
            elseif(isa(varargin{1},'matlab.ui.Figure'))

                obj.Figure=varargin{1};
                f=obj.Figure;
                f.Visible='off';

                ax=findall(obj.Figure,'Type','axes','-not','Type','Colorbar');
                obj.Axes=ax(1);
            end
            f.Visible='off';
            obj.disableAxesToolbar(f,'off');

            obj.createComponents();
            obj.layoutComponents();

            ax.XLim=1.25*ax.XLim;ax.YLim=1.25*ax.YLim;ax.ZLim=1.25*ax.ZLim;
            obj.defLims=[ax.XLim;ax.YLim;ax.ZLim];

            z=zoom(f);
            z.setAxes3DPanAndZoomStyle(ax,'camera');


            f.WindowButtonUpFcn=@(src,evt)obj.removeSelection(src,evt,ax);
            f.WindowButtonMotionFcn=@(src,evt)obj.movePlane(src,evt);
            f.WindowKeyPressFcn=@obj.Keypress;
            f.WindowKeyReleaseFcn=@obj.clearKeypress;
            f.DeleteFcn=@(src,evt)obj.delete(src,evt);
            ax.ButtonDownFcn=@(src,evt)obj.FigureClicked(src,evt,'on');
            ax.DeleteFcn=@(src,evt)obj.delete(src,evt);
            if f.Position(3)<740
                f.Position(3)=740;
            end
            ax.Parent=obj.PanelAxes;
            axt=axtoolbar(ax,{'datacursor','pan','zoomin','zoomout','rotate'});


            mi=findall(f,'type','UIControl','Tag','Tatoo');
            rst=findall(f,'type','UIControl','Tag','radiiScaleText');
            lgd=findobj(f,'Type','Legend');
            patch_geometry=findall(f,'Type','patch');
            set(patch_geometry,'HitTest','off');
            if~isempty(mi)
                for i=1:size(mi,1)
                    mi(i).Parent=obj.PanelAxes;
                end
            end
            if~isempty(lgd)

                lgd.Parent=obj.PanelAxes;
            end
            obj.PanelAxes.Position=[0,0,0.745,1];
            pause(0.2);
            f.Units='Pixels';
            f.Visible='on';
            if~isempty(rst)
                rst.Parent=obj.PanelAxes;
            end

        end






























        function FigureClicked(obj,~,evt,vis)








            if obj.SliceButton.Value==0&&isprop(evt,'Source')&&~isempty(obj.AntennaObj)

                cpt=obj.Axes.CurrentPoint;
                if isempty(obj.patch)||~isa(obj.patch,'matlab.graphics.primitive.Patch')||isempty(obj.Triang)
                    return;
                end


                tr1=triangulation(obj.patch.Faces,obj.patch.Vertices);
                rtobj=matlabshared.internal.StaticSceneRayTracer(tr1);
                [directionf,distancef]=matlabshared.internal.segmentToRay(cpt(1,:),cpt(2,:));
                [pt,tr,~]=allIntersections(rtobj,cpt(1,:),directionf,distancef);
                if isempty(pt{1})

                    return;
                end
                pt=pt{1};tr=tr{1};

                dist=pt-obj.Axes.CameraPosition;dist=dist.*dist;dist=sum(dist,2);[~,idx]=min(dist);pt=pt(idx,:);tr=tr(idx);
                obj.AntennaObj.FigureClicked(obj,evt,pt,tr);
            end

            if~isempty(obj.SliceSurface)&&~strcmpi(obj.SliceSurface.UserData,'Selected')&&strcmpi(obj.SliceSurface.Visible,'on')

                ax=obj.Axes;
                intersectionVert=evt.IntersectionPoint;
                PlaneVal=obj.XYBtn.Value*1+obj.YZBtn.Value*2+obj.XZBtn.Value*3;
                switch PlaneVal
                case 1
                    zval=obj.SliceSurface.ZData(1,1);
                    if intersectionVert(3)<zval
                        obj.BoundingBoxFlag=0;
                        id=6;
                    else
                        obj.BoundingBoxFlag=1;
                        id=5;
                    end
                case 2
                    xval=obj.SliceSurface.XData(1,1);
                    if intersectionVert(1)<xval
                        obj.BoundingBoxFlag=0;
                        id=2;
                    else
                        obj.BoundingBoxFlag=1;
                        id=1;
                    end
                case 3
                    yval=obj.SliceSurface.YData(1,1);
                    if intersectionVert(2)<yval
                        obj.BoundingBoxFlag=0;
                        id=4;
                    else
                        obj.BoundingBoxFlag=1;
                        id=3;
                    end
                end
                obj.ExcludeId=id;
                lims=obj.getLimsBoundingBox();
                obj.createBoundingBox(ax,lims,'k',id);
                cellfun(@(x)set(x,'Visible',vis),obj.BoundingBox,'UniformOutput',false);
                cellfun(@(x)set(x,'Visible','off'),obj.BoundingBox(id),'UniformOutput',false);
                if(strcmpi(vis,'off'))
                    obj.Contextmenu.Children.Enable='off';
                else
                    obj.Contextmenu.Children.Enable='on';
                end
            end
        end

        function DeleteFeedEdgeLine(obj,src,~)

            obj.SelectedEdges(str2num(src.Tag),:)=[0,0];
            src.delete;
        end

        function lims=getLimsBoundingBox(obj)




            PlaneVal=obj.XYBtn.Value*1+obj.YZBtn.Value*2+obj.XZBtn.Value*3;
            ax=obj.Axes;
            switch PlaneVal
            case 1
                zval=obj.SliceSurface.ZData(1,1);
                if obj.BoundingBoxFlag==0
                    lims=[ax.XLim;ax.YLim;ax.ZLim(1),zval];
                else
                    lims=[ax.XLim;ax.YLim;zval,ax.ZLim(2)];
                end
            case 2
                xval=obj.SliceSurface.XData(1,1);
                if obj.BoundingBoxFlag==0
                    lims=[ax.XLim(1),xval;ax.YLim;ax.ZLim];
                else
                    lims=[xval,ax.XLim(2);ax.YLim;ax.ZLim];
                end
            case 3
                yval=obj.SliceSurface.YData(1,1);
                if obj.BoundingBoxFlag==0
                    lims=[ax.XLim;ax.YLim(1),yval;ax.ZLim];
                else
                    lims=[ax.XLim;yval,ax.YLim(2);ax.ZLim];
                end
            end
        end
        function createComponents(obj)



            f=obj.Figure;

            obj.Panel=uipanel(...
            'Parent',obj.Figure,...
            'Title',getString(message('antenna:customantennastl:SlicerPanel')),...
            'BorderType','line',...
            'HighlightColor',[.5,.5,.5],...
            'Visible','on',...
            'FontWeight','bold',...
            'Tag','SlicingInteractivityPanel');
            title='';



            obj.PanelAxes=uipanel(...
            'Parent',obj.Figure,...
            'Title',title,...
            'BorderType','none',...
            'HighlightColor',[.5,.5,.5],...
            'Visible','on',...
            'FontWeight','bold',...
            'Tag','AxesPanel');

            p=uipanel(...
            'Parent',obj.Figure,...
            'Title',title,...
            'BorderType','line',...
            'HighlightColor',[.5,.5,.5],...
            'Visible','on',...
            'FontWeight','bold',...
            'Tag','divPanel');
            p.Position=[0.745,0,0.005,1];
            obj.restoreViewBtn=uicontrol(obj.Panel,'Style','pushbutton','HandleVisibility','off');
            obj.restoreViewBtn.String=getString(message('antenna:customantennastl:Restore'));
            obj.restoreViewBtn.Units='normalized';
            obj.restoreViewBtn.Tag='RestoreBtn';

            obj.restoreViewBtn.Callback=@obj.RestoreView;
            obj.restoreViewBtn.HandleVisibility='off';
            obj.restoreViewBtn.Tooltip=getString(message('antenna:customantennastl:RestoreDesc'));

            obj.undoBtn=uicontrol(obj.Panel,'Style','pushbutton','HandleVisibility','off');
            obj.undoBtn.String=getString(message('antenna:customantennastl:Undo'));
            obj.undoBtn.Units='normalized';
            obj.undoBtn.Tag='UndoBtn';

            obj.undoBtn.Callback=@obj.undo;
            obj.undoBtn.HandleVisibility='off';
            obj.undoBtn.Tooltip=getString(message('antenna:customantennastl:UndoDesc'));

            obj.redoBtn=uicontrol(obj.Panel,'Style','pushbutton','HandleVisibility','off');
            obj.redoBtn.String=getString(message('antenna:customantennastl:Redo'));
            obj.redoBtn.Tag='RedoBtn';
            obj.redoBtn.Units='normalized';

            obj.redoBtn.Callback=@obj.redo;
            obj.redoBtn.HandleVisibility='off';
            obj.redoBtn.Tooltip=getString(message('antenna:customantennastl:RedoDesc'));

            obj.XYBtn=uicontrol(obj.Panel,'Style','togglebutton');
            obj.XYBtn.String='XY';
            obj.XYBtn.Tag='XYBtn';
            obj.XYBtn.Units='normalized';

            obj.XYBtn.Callback=@(src,evt)obj.drawDynamicPlane(src,evt);
            obj.XYBtn.HandleVisibility='off';
            obj.XYBtn.Tooltip=getString(message('antenna:customantennastl:XYDesc'));


            obj.YZBtn=uicontrol(obj.Panel,'Style','togglebutton','HandleVisibility','off');
            obj.YZBtn.String='YZ';
            obj.YZBtn.Tag='YZBtn';
            obj.YZBtn.Units='normalized';

            obj.YZBtn.Callback=@(src,evt)obj.drawDynamicPlane(src,evt);
            obj.YZBtn.HandleVisibility='off';
            obj.YZBtn.Tooltip=getString(message('antenna:customantennastl:YZDesc'));


            obj.XZBtn=uicontrol(obj.Panel,'Style','togglebutton','HandleVisibility','off');
            obj.XZBtn.String='XZ';
            obj.XZBtn.Tag='XZBtn';
            obj.XZBtn.Units='normalized';

            obj.XZBtn.Callback=@(src,evt)obj.drawDynamicPlane(src,evt);
            obj.XZBtn.HandleVisibility='off';
            obj.XZBtn.Tooltip=getString(message('antenna:customantennastl:XZDesc'));

            obj.SliceButton=uicontrol(obj.Panel,'Style','checkbox','HandleVisibility','off');
            obj.SliceButton.String=getString(message('antenna:customantennastl:SlicerMode'));
            obj.SliceButton.Tag='SlicerBtn';
            obj.SliceButton.Units='normalized';

            obj.SliceButton.Callback=@obj.SliceSelected;
            obj.SliceButton.HandleVisibility='off';
            obj.SliceButton.Tooltip=getString(message('antenna:customantennastl:SlicerModeDesc'));

            obj.deleteBtn=uicontrol(obj.Panel,'Style','pushbutton','HandleVisibility','off');
            obj.deleteBtn.String=getString(message('antenna:customantennastl:Hide'));
            obj.deleteBtn.Tag='HideBtn';
            obj.deleteBtn.Units='normalized';

            obj.deleteBtn.Callback=@obj.Delete;
            obj.deleteBtn.HandleVisibility='off';
            obj.deleteBtn.Tooltip=getString(message('antenna:customantennastl:HideDesc'));
            obj.deleteBtn.Enable='off';
            obj.disableControl('off');
        end
        function layoutComponents(obj)
            hspacing=3;
            vspacing=8;
            obj.Layout=...
            matlabshared.application.layout.GridBagLayout(...
            obj.Panel,...
            'VerticalGap',vspacing,...
            'HorizontalGap',hspacing,...
            'VerticalWeights',[0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],...
            'HorizontalWeights',[1,1,1,1,1,1]);
            w1=100;

            w3=49;
            row=1;
            h=20;
            orientationText=uicontrol(obj.Panel,'Style','Text','String',getString(message('antenna:customantennastl:Orientation')),...
            'HorizontalAlignment','left');
            orientationText.Tooltip=getString(message('antenna:customantennastl:OrientationDesc'));
            ActionText=uicontrol(obj.Panel,'Style','Text','String',getString(message('antenna:customantennastl:Actions')),...
            'HorizontalAlignment','left');
            ActionText.Tooltip=getString(message('antenna:customantennastl:ActionsDesc'));
            row=row+1;
            cad.utilities.SlicingInteractivity.addButton(obj.Layout,obj.SliceButton,row,[1,2,3,4,5,6],w3,h);
            row=row+2;
            cad.utilities.SlicingInteractivity.addButton(obj.Layout,orientationText,row,[1,2,3,4,5,6],w1,h);
            row=row+1;
            cad.utilities.SlicingInteractivity.addButton(obj.Layout,obj.XYBtn,row,[1,2],w3,h);
            cad.utilities.SlicingInteractivity.addButton(obj.Layout,obj.YZBtn,row,[3,4],w3,h);
            cad.utilities.SlicingInteractivity.addButton(obj.Layout,obj.XZBtn,row,[5,6],w3,h);

            row=row+2;
            cad.utilities.SlicingInteractivity.addButton(obj.Layout,ActionText,row,[1,2,3,4,5,6],w1,h);
            row=row+1;
            cad.utilities.SlicingInteractivity.addButton(obj.Layout,obj.deleteBtn,row,[1,2,3,4,5,6],w3,h);
            row=row+1;
            cad.utilities.SlicingInteractivity.addButton(obj.Layout,obj.restoreViewBtn,row,[5,6],w3,h);
            cad.utilities.SlicingInteractivity.addButton(obj.Layout,obj.undoBtn,row,[1,2],w3,h);
            cad.utilities.SlicingInteractivity.addButton(obj.Layout,obj.redoBtn,row,[3,4],w3,h);
            [~,~,w,h]=getMinimumSize(obj.Layout);
            W=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
            H=max(h(2:end))*numel(h(2:end))+...
            obj.Layout.VerticalGap*(numel(h(2:end))+1)+(6);
            ps=obj.Figure.Position;
            obj.Panel.Position=[0.75,0.6,0.24,0.4];
        end
    end

    methods(Static=true)
        function addButton(layout,uic,row,col,w,h)
            popupInset=-2;
            add(layout,uic,row,col,...
            'MinimumWidth',w,...
            'MinimumHeight',h-popupInset,...
            'TopInset',popupInset,'Fill','Both')
        end
    end

    methods



















        function RestoreView(obj,~,~)




            if~isempty(obj.SliceSurface)
                obj.SliceSurface.Visible='off';
            end
            if~isempty(obj.BoundingBox)
                cellfun(@(x)set(x,'Visible','off'),obj.BoundingBox,'UniformOutput',false);
            end
            obj.SliceButton.Value=0;
            obj.XYBtn.Value=0;obj.YZBtn.Value=0;obj.XZBtn.Value=0;
            obj.Axes.XLim=obj.defLims(1,:);obj.Axes.YLim=obj.defLims(2,:);obj.Axes.ZLim=obj.defLims(3,:);
            obj.SliceButton.Value=1;
            obj.SliceSelected(obj.SliceButton);
        end

        function disableControl(obj,value)
            obj.XYBtn.Enable=value;
            obj.XZBtn.Enable=value;
            obj.YZBtn.Enable=value;
            obj.undoBtn.Enable=value;
            obj.redoBtn.Enable=value;
            obj.restoreViewBtn.Enable=value;
            obj.deleteBtn.Enable=value;
            obj.boundingBoxVisibilityToggled(0,0);
        end

        function SliceSelected(obj,src,~)




            if isempty(obj.SliceSurface)||(~obj.XYBtn.Value&&~obj.XZBtn.Value&&~obj.YZBtn.Value)
                obj.XYBtn.Value=1;
                obj.drawDynamicPlane(obj.XYBtn,1);
            end
            if obj.XYBtn.Value
                obj.drawDynamicPlane(obj.XYBtn,1);
            elseif obj.XZBtn.Value
                obj.drawDynamicPlane(obj.XZBtn,1);
            elseif obj.YZBtn.Value
                obj.drawDynamicPlane(obj.YZBtn,1);
            end
            a.IntersectionPoint=[-1,-1,-1];
            if(src.Value==1)
                if~isempty(obj.AntennaObj)&&isa(obj.AntennaObj,'customAntennaStl')
                    value='off';
                    disableControl(obj.AntennaObj,value,obj.Figure);
                end
                obj.disableControl('on');

                obj.SliceSurface.ButtonDownFcn=@obj.setSelection;
                obj.SliceSurface.Visible='on';
                obj.FigureClicked(-1,a,'off')

            else
                if~isempty(obj.AntennaObj)&&isa(obj.AntennaObj,'customAntennaStl')
                    value='on';
                    disableControl(obj.AntennaObj,value,obj.Figure);
                end
                obj.disableControl('off');

                obj.XYBtn.Value=0;obj.YZBtn.Value=0;obj.XZBtn.Value=0;
                obj.SliceSurface.ButtonDownFcn=@obj.setSelection;
                obj.SliceSurface.Visible='off';
                obj.FigureClicked(-1,a,'off')
                cellfun(@(x)set(x,'Visible','off'),obj.BoundingBox,'UniformOutput',false);
            end
        end
        function obj=Slicinginteractivity(obj)

            ant=discone;
            [~]=mesh(ant,'MaxEdgeLength',1);
            [p,t]=exportMesh(ant);
            obj.Figure=uifigure('Visible','off');
            obj.Axes=uiaxes(obj.Figure);
            antennaColor=[223,185,58]/255;
            obj.view_mesh(obj.Axes,p',transpose(t(:,1:3)),antennaColor);
            obj.Figure.Visible='on';
        end
        function drawDynamicPlane(obj,src,~)




            hold(obj.Axes,'on');
            ax=obj.Axes;
            lightBlue=([91,207,244]+11)/255;
            if src.Value==1
                switch src.String
                case 'XY'
                    obj.YZBtn.Value=0;
                    obj.XZBtn.Value=0;
                    obj.PlaneFlag=[1,0,0];
                    xval=linspace(ax.XLim(1),ax.XLim(2),15);
                    yval=linspace(ax.YLim(1),ax.YLim(2),15);
                    [x,y]=meshgrid(xval,yval);
                    z=ones(size(x))*((ax.ZLim(1)+ax.ZLim(2))/2);
                    ipt=[mean(ax.XLim),mean(ax.YLim),ax.ZLim(1)+diff(ax.ZLim)/3];
                    a.IntersectionPoint=ipt;
                    if isempty(obj.SliceSurface)
                        obj.SliceSurface=surf(obj.Axes,x,y,z,'FaceColor',lightBlue,'FaceAlpha',0.5,...
                        'EdgeColor','k','EdgeAlpha',0.5,'tag','MovingPlane',...
                        'ButtonDownFcn',@obj.setSelection,'Visible','off','HandleVisibility','off');
                    else
                        obj.SliceSurface.XData=x;obj.SliceSurface.YData=y;obj.SliceSurface.ZData=z;
                    end
                    obj.ExcludeId=6;
                case 'XZ'
                    obj.XYBtn.Value=0;
                    obj.YZBtn.Value=0;
                    obj.PlaneFlag=[0,1,0];
                    xval=linspace(ax.XLim(1),ax.XLim(2),15);
                    zval=linspace(ax.ZLim(1),ax.ZLim(2),15);
                    [x,z]=meshgrid(xval,zval);
                    y=ones(size(x))*((ax.YLim(1)+ax.YLim(2))/2);
                    if isempty(obj.SliceSurface)
                        obj.SliceSurface=surf(obj.Axes,x,y,z,'FaceColor',lightBlue,'FaceAlpha',0.5,...
                        'EdgeColor','k','EdgeAlpha',0.5,'tag','MovingPlane',...
                        'ButtonDownFcn',@obj.setSelection,'Visible','off','HandleVisibility','off');
                    else
                        obj.SliceSurface.XData=x;obj.SliceSurface.YData=y;obj.SliceSurface.ZData=z;
                    end
                    ipt=[mean(ax.XLim),ax.YLim(1)+diff(ax.YLim)/3,mean(ax.ZLim)];
                    a.IntersectionPoint=ipt;
                    obj.ExcludeId=4;
                case 'YZ'
                    obj.XYBtn.Value=0;
                    obj.XZBtn.Value=0;
                    obj.PlaneFlag=[0,0,1];
                    yval=linspace(ax.YLim(1),ax.YLim(2),15);
                    zval=linspace(ax.ZLim(1),ax.ZLim(2),15);
                    [y,z]=meshgrid(yval,zval);
                    x=ones(size(y))*((ax.XLim(1)+ax.XLim(2))/2);
                    if isempty(obj.SliceSurface)
                        obj.SliceSurface=surf(obj.Axes,x,y,z,'FaceColor',lightBlue,'FaceAlpha',0.5,...
                        'EdgeColor','k','EdgeAlpha',0.5,'tag','MovingPlane',...
                        'ButtonDownFcn',@obj.setSelection,'Visible','off','HandleVisibility','off');
                    else
                        obj.SliceSurface.XData=x;obj.SliceSurface.YData=y;obj.SliceSurface.ZData=z;
                    end
                    ipt=[ax.XLim(1)+diff(ax.XLim)/3,mean(ax.YLim),mean(ax.ZLim)];
                    a.IntersectionPoint=ipt;
                    obj.ExcludeId=2;
                end
                hold(obj.Axes,'off');
            elseif src.Value==0
                switch src.String
                case 'XY'
                    if obj.YZBtn.Value==0&&obj.XZBtn.Value==0


                        src.Value=1;
                        obj.drawDynamicPlane(src,-1);
                        ipt=[mean(ax.XLim),mean(ax.YLim),ax.ZLim(1)+diff(ax.ZLim)/3];
                        a.IntersectionPoint=ipt;
                    end
                case 'YZ'
                    if obj.XZBtn.Value==0&&obj.XYBtn.Value==0
                        src.Value=1;
                        obj.drawDynamicPlane(src,-1);
                        ipt=[ax.XLim(1)+diff(ax.XLim)/3,mean(ax.YLim),mean(ax.ZLim)];
                        a.IntersectionPoint=ipt;
                    end
                case 'XZ'
                    if obj.YZBtn.Value==0&&obj.XYBtn.Value==0
                        src.Value=1;
                        obj.drawDynamicPlane(src,-1);
                        ipt=[mean(ax.XLim),ax.YLim(1)+diff(ax.YLim)/3,mean(ax.ZLim)];
                        a.IntersectionPoint=ipt;
                    end
                end

            end
            if obj.SliceButton.Value==1&&src.Value==1

                obj.SliceSurface.Visible='on';
                obj.FigureClicked(-1,a,'off')

            else
                cellfun(@(x)set(x,'Visible','off'),obj.BoundingBox,'UniformOutput',false);
            end
            obj.Figure.NextPlot='replace';
        end

        function setSelection(obj,src,~)





            src.UserData='Selected';
            ax=obj.Axes;
            srf=obj.SliceSurface;
            pd.Value=1*obj.XYBtn.Value+2*obj.YZBtn.Value+3*obj.XZBtn.Value;
            cellfun(@(x)set(x,'Visible','off'),obj.BoundingBox,'UniformOutput',false);
            switch pd.Value
            case 1
                srfnormal=[0,0,1];
            case 2
                srfnormal=[1,0,0];
            case 3
                srfnormal=[0,1,0];
            end
            obj.startpt=calculateIntersectionpt(...
            srfnormal,ax.CurrentPoint,[mean(mean(srf.XData)),mean(mean(srf.YData)),mean(mean(srf.ZData))]);
        end


        function removeSelection(obj,src,~,ax)





            srf=obj.SliceSurface;
            if~isempty(srf)
                srf.UserData=[];
            end
            tmp=findall(obj.Axes,'type','Surface','tag','');
            if~isempty(tmp)&&strcmpi(srf.Visible,'on')

            end
            obj.startpt=[];
        end

        function movePlane(obj,src,~)



            srf=obj.SliceSurface;

            pd.Value=1*obj.XYBtn.Value+2*obj.YZBtn.Value+3*obj.XZBtn.Value;
            ax=obj.Axes;
            if~isempty(srf)&&strcmpi(srf.Visible,'on')
                switch pd.Value
                case 1
                    srfnormal=[0,0,1];
                case 2
                    srfnormal=[1,0,0];
                case 3
                    srfnormal=[0,1,0];
                end
                if(strcmpi(srf.UserData,'Selected'))
                    [norm,~]=getSurfacenormal(ax,0);




                    pt=calculateIntersectionpt(norm,ax.CurrentPoint,obj.startpt);
                    switch pd.Value
                    case 1
                        val=(srfnormal*pt');
                        if val<ax.ZLim(1)
                            val=ax.ZLim(1);
                        elseif val>ax.ZLim(2)
                            val=ax.ZLim(2);
                        end
                        srf.ZData=val*ones(size(srf.XData));
                    case 2
                        val=(srfnormal*pt');
                        if val<ax.XLim(1)
                            val=ax.XLim(1);
                        elseif val>ax.XLim(2)
                            val=ax.XLim(2);
                        end
                        srf.XData=val*ones(size(srf.XData));
                    case 3
                        val=(srfnormal*pt');
                        if val<ax.YLim(1)
                            val=ax.YLim(1);
                        elseif val>ax.YLim(2)
                            val=ax.YLim(2);
                        end
                        srf.YData=val*ones(size(srf.XData));
                    end
                    obj.updateBoundingBox(pd);
                end
            end
        end

        function updateBoundingBox(obj,pd)

            lims=obj.getLimsBoundingBox();
            obj.createBoundingBox(obj.Axes,lims,'k',0);
        end
        function createSelectionSurfaces(obj,src,~,ax,pd)
            pd.Enable='off';
            srf=findall(ax,'tag','MovingPlane');
            tmp=findall(obj.Axes,'type','Surface','tag','');
            if(~isempty(srf)&&strcmpi(srf.Visible,'on')&&isempty(tmp))
                srf.Visible='off';
                lims=[ax.XLim;ax.YLim;ax.ZLim];
                switch pd.Value
                case 1
                    val=srf.ZData(1);
                    lim1=[ax.XLim;ax.YLim;ax.ZLim(1),val];
                    lim2=[ax.XLim;ax.YLim;val,ax.ZLim(2)];
                    slice=3;
                    tmp=lims(3,:);
                    if(any(tmp==val))
                        return;
                    end
                case 2
                    val=srf.XData(1);
                    lim1=[ax.XLim(1),val;ax.YLim;ax.ZLim];
                    lim2=[val,ax.XLim(2);ax.YLim;ax.ZLim];
                    slice=1;
                    tmp=lims(1,:);
                    if(any(tmp==val))
                        return;
                    end
                case 3
                    val=srf.YData(1);
                    lim1=[ax.XLim;ax.YLim(1),val;ax.ZLim];
                    lim2=[ax.XLim;val,ax.YLim(2);ax.ZLim];
                    slice=2;
                    tmp=lims(2,:);
                    if(any(tmp==val))
                        return;
                    end
                end
                lightBlue=([91,207,244]+11)/255;
                obj.createBoundingBox(ax,lim1,'k',pd,[slice,1,val]);
                obj.createBoundingBox(ax,lim2,lightBlue,pd,[slice,2,val]);
            end
        end

        function createBoundingBox(obj,ax,lim,color,exList,slice)

            hold(obj.Axes,'on');
            for i=1:size(lim,1)
                switch i
                case 1
                    [y,z]=meshgrid(linspace(lim(2,1),lim(2,2),15),...
                    linspace(lim(3,1),lim(3,2),15));
                    x1=lim(1,1)*ones(15,15);
                    x2=lim(1,2)*ones(15,15);
                    if numel(obj.BoundingBox)<1||~isa(obj.BoundingBox{1},'matlab.graphics.chart.primitive.Surface')||~isvalid(obj.BoundingBox{1})
                        obj.BoundingBox{1}=surf(ax,x1,y,z,'FaceColor',...
                        color,'FaceAlpha',0.2,'LineStyle','none','Visible','off','UIContextMenu',obj.Contextmenu,'HandleVisibility','off');
                        addlistener(obj.BoundingBox{1},'Visible','PostSet',@obj.boundingBoxVisibilityToggled);
                    else
                        obj.BoundingBox{1}.XData=x1;obj.BoundingBox{1}.YData=y;obj.BoundingBox{1}.ZData=z;
                    end
                    if numel(obj.BoundingBox)<2||~isa(obj.BoundingBox{2},'matlab.graphics.chart.primitive.Surface')||~isvalid(obj.BoundingBox{2})
                        obj.BoundingBox{2}=surf(ax,x2,y,z,'FaceColor',...
                        color,'FaceAlpha',0.2,'LineStyle','none','Visible','off','UIContextMenu',obj.Contextmenu,'HandleVisibility','off');
                        addlistener(obj.BoundingBox{2},'Visible','PostSet',@obj.boundingBoxVisibilityToggled);
                    else
                        obj.BoundingBox{2}.XData=x2;obj.BoundingBox{2}.YData=y;obj.BoundingBox{2}.ZData=z;
                    end
                case 2
                    [x,z]=meshgrid(linspace(lim(1,1),lim(1,2),15),...
                    linspace(lim(3,1),lim(3,2),15));
                    y1=lim(2,1)*ones(15,15);
                    y2=lim(2,2)*ones(15,15);
                    if numel(obj.BoundingBox)<3||~isa(obj.BoundingBox{3},'matlab.graphics.chart.primitive.Surface')||~isvalid(obj.BoundingBox{3})
                        obj.BoundingBox{3}=surf(ax,x,y1,z,'FaceColor',...
                        color,'FaceAlpha',0.2,'LineStyle','none','Visible','off','UIContextMenu',obj.Contextmenu,'HandleVisibility','off');
                        addlistener(obj.BoundingBox{3},'Visible','PostSet',@obj.boundingBoxVisibilityToggled);
                    else
                        obj.BoundingBox{3}.XData=x;obj.BoundingBox{3}.YData=y1;obj.BoundingBox{3}.ZData=z;
                    end
                    if numel(obj.BoundingBox)<4||~isa(obj.BoundingBox{4},'matlab.graphics.chart.primitive.Surface')||~isvalid(obj.BoundingBox{4})
                        obj.BoundingBox{4}=surf(ax,x,y2,z,'FaceColor',...
                        color,'FaceAlpha',0.2,'LineStyle','none','Visible','off','UIContextMenu',obj.Contextmenu,'HandleVisibility','off');
                        addlistener(obj.BoundingBox{4},'Visible','PostSet',@obj.boundingBoxVisibilityToggled);
                    else
                        obj.BoundingBox{4}.XData=x;obj.BoundingBox{4}.YData=y2;obj.BoundingBox{4}.ZData=z;
                    end
                case 3
                    [x,y]=meshgrid(linspace(lim(1,1),lim(1,2),15),...
                    linspace(lim(2,1),lim(2,2),15));
                    z1=lim(3,1)*ones(15,15);
                    z2=lim(3,2)*ones(15,15);
                    if numel(obj.BoundingBox)<5||~isa(obj.BoundingBox{5},'matlab.graphics.chart.primitive.Surface')||~isvalid(obj.BoundingBox{5})
                        obj.BoundingBox{5}=surf(ax,x,y,z1,'FaceColor',...
                        color,'FaceAlpha',0.2,'LineStyle','none','Visible','off','UIContextMenu',obj.Contextmenu,'HandleVisibility','off');
                        addlistener(obj.BoundingBox{5},'Visible','PostSet',@obj.boundingBoxVisibilityToggled);
                    else
                        obj.BoundingBox{5}.XData=x;obj.BoundingBox{5}.YData=y;obj.BoundingBox{5}.ZData=z1;
                    end
                    if numel(obj.BoundingBox)<6||~isa(obj.BoundingBox{6},'matlab.graphics.chart.primitive.Surface')||~isvalid(obj.BoundingBox{6})
                        obj.BoundingBox{6}=surf(ax,x,y,z2,'FaceColor',...
                        color,'FaceAlpha',0.2,'LineStyle','none','Visible','off','UIContextMenu',obj.Contextmenu,'HandleVisibility','off');
                        addlistener(obj.BoundingBox{6},'Visible','PostSet',@obj.boundingBoxVisibilityToggled);
                    else
                        obj.BoundingBox{6}.XData=x;obj.BoundingBox{6}.YData=y;obj.BoundingBox{6}.ZData=z2;
                    end
                end
            end

            hold(obj.Axes,'off');
            obj.Figure.NextPlot='replace';
        end

        function toggleVisibility(obj,~,~)

            if strcmpi(obj.BoundingBox{1}.Visible,'on')||strcmpi(obj.BoundingBox{3}.Visible,'on')||...
                strcmpi(obj.BoundingBox{5}.Visible,'on')
                cellfun(@(x)set(x,'Visible','off'),obj.BoundingBox,'UniformOutput',false);
                obj.Contextmenu.Children.Enable='off';
            else
                cellfun(@(x)set(x,'Visible','on'),obj.BoundingBox,'UniformOutput',false);
                obj.Contextmenu.Children.Enable='on';
            end
        end

        function setSlice(obj,src,evt,slice,pd)
            ax=obj.Axes;
            val=slice(3);
            switch slice(1)
            case 1
                if slice(2)==1
                    ax.XLim=[ax.XLim(1),val];
                else
                    ax.XLim=[val,ax.XLim(2)];
                end
            case 2
                if slice(2)==1
                    ax.YLim=[ax.YLim(1),val];
                else
                    ax.YLim=[val,ax.YLim(2)];
                end
            case 3
                if slice(2)==1
                    ax.ZLim=[ax.ZLim(1),val];
                else
                    ax.ZLim=[val,ax.ZLim(2)];
                end
            end
            f=obj.Figure;
            f.UserData(:,:,end+1)=[ax.XLim;ax.YLim;ax.ZLim];
            pd.Enable='on';
            obj.drawDynamicPlane(pd,-1,ax);
        end

        function hfill=view_mesh(obj,ax,p,t,antennaColor)

            p=p';t=t';






            p=p';t=t';
            obj.patch=patch(ax,'Vertices',p,'Faces',t,'FaceColor',antennaColor,...
            'AmbientStrength',1,'ButtonDownFcn',@(src,evt)obj.FigureClicked(src,evt,'on'),...
            'HandleVisibility','off','PickableParts','all');
            hfill=obj.patch;
            diffx=diff(ax.XLim);ax.XLim=[-0.6*diffx,0.6*diffx]+mean(ax.XLim);
            diffy=diff(ax.YLim);ax.YLim=[-0.6*diffy,0.6*diffy]+mean(ax.YLim);
            diffz=diff(ax.ZLim);ax.ZLim=[-0.6*diffz,0.6*diffz]+mean(ax.ZLim);
            daspect(ax,[1,1,1]);

            grid(ax,'on');
            box(ax,'on');
            view(-40,35);
        end


        function Keypress(obj,src,evt)



            if strcmpi(evt.Key,'control')

                obj.keypress{1}=evt.Key;
            end

            obj.keypress{2}=evt.Key;


            if strcmpi(evt.Key,'delete')
                obj.Delete(src,evt);
            elseif strcmpi(obj.keypress{1},'control')&&strcmpi(obj.keypress{2},'y')
                obj.redo(1,1);
            elseif strcmpi(obj.keypress{1},'control')&&strcmpi(obj.keypress{2},'z')
                obj.undo(1,1);
            end

        end

        function clearKeypress(obj,~,evt)




            if strcmpi(evt.Key,'control')


                obj.keypress{1}='';
            end
            obj.keypress{2}='';
        end

        function undo(obj,src,evt)







            if~isempty(obj.SliceSurface)
                obj.SliceSurface.Visible='off';
            end
            if~isempty(obj.BoundingBox)
                cellfun(@(x)set(x,'Visible','off'),obj.BoundingBox,'UniformOutput',false);
            end


            if isempty(obj.undostack)

                obj.SliceButton.Value=1;
                obj.SliceSelected(obj.SliceButton);
                return;
            end
            ax=obj.Axes;

            if isempty(obj.redostack)
                obj.redostack(:,:,1)=[ax.XLim;ax.YLim;ax.ZLim];
            else
                obj.redostack(:,:,end+1)=[ax.XLim;ax.YLim;ax.ZLim];
            end

            ax.XLim=obj.undostack(1,:,end);ax.YLim=obj.undostack(2,:,end);ax.ZLim=obj.undostack(3,:,end);
            if size(obj.undostack,3)==1
                obj.undostack=[];
            else
                obj.undostack=obj.undostack(:,:,1:end-1);
            end
            obj.SliceButton.Value=1;
            obj.SliceSelected(obj.SliceButton);
        end

        function redo(obj,~,~)







            if~isempty(obj.SliceSurface)
                obj.SliceSurface.Visible='off';
            end
            if~isempty(obj.BoundingBox)
                cellfun(@(x)set(x,'Visible','off'),obj.BoundingBox,'UniformOutput',false);
            end


            if isempty(obj.redostack)

                obj.SliceButton.Value=1;
                obj.SliceSelected(obj.SliceButton);
                return;
            end
            ax=obj.Axes;

            if isempty(obj.undostack)
                obj.undostack(:,:,1)=[ax.XLim;ax.YLim;ax.ZLim];
            else
                obj.undostack(:,:,end+1)=[ax.XLim;ax.YLim;ax.ZLim];
            end

            ax.XLim=obj.redostack(1,:,end);ax.YLim=obj.redostack(2,:,end);ax.ZLim=obj.redostack(3,:,end);
            if size(obj.redostack,3)==1
                obj.redostack=[];
            else
                obj.redostack=obj.redostack(:,:,1:end-1);
            end
            obj.SliceButton.Value=1;
            obj.SliceSelected(obj.SliceButton);
        end

        function Delete(obj,~,~)




            flag=0;
            try
                lims=obj.getLimsBoundingBox();
            catch
                return
            end
            if isempty(obj.BoundingBox)
                return;
            end
            if~(strcmpi(obj.BoundingBox{1}.Visible,'on')||strcmpi(obj.BoundingBox{3}.Visible,'on')||...
                strcmpi(obj.BoundingBox{5}.Visible,'on'))
                return;
            end
            ax=obj.Axes;


            if~(all(obj.Axes.XLim==lims(1,:)))
                f=find(obj.Axes.XLim~=lims(1,:));
                if(f==2)
                    lims(1,:)=[lims(1,f),ax.XLim(2)];
                else
                    lims(1,:)=[ax.XLim(1),lims(1,f)];
                end
                flag=1;
            elseif~(all(obj.Axes.YLim==lims(2,:)))
                f=find(obj.Axes.YLim~=lims(2,:));
                if(f==2)
                    lims(2,:)=[lims(2,f),ax.YLim(2)];
                else
                    lims(2,:)=[ax.YLim(1),lims(2,f)];
                end
                flag=1;
            elseif~(all(obj.Axes.ZLim==lims(3,:)))
                f=find(obj.Axes.ZLim~=lims(3,:));
                if(f==2)
                    lims(3,:)=[lims(3,f),ax.ZLim(2)];
                else
                    lims(3,:)=[ax.ZLim(1),lims(3,f)];
                end
                flag=1;
            end




            if flag
                if isempty(obj.undostack)
                    obj.undostack=[ax.XLim;ax.YLim;ax.ZLim];
                else
                    obj.undostack(:,:,end+1)=[ax.XLim;ax.YLim;ax.ZLim];
                end
                obj.redostack=[];
            end
            ax.XLim=lims(1,:);ax.YLim=lims(2,:);ax.ZLim=lims(3,:);
        end

        function delete(obj,src,evt)

            f=obj.Figure;ax=obj.Axes;
            obj.disableAxesToolbar(f,'off');
            if isvalid(f)
                f.WindowButtonUpFcn=[];
                f.WindowButtonMotionFcn=[];
                f.WindowKeyPressFcn=[];
                f.WindowKeyReleaseFcn=[];
                f.Name='';
                if isa(src,'matlab.ui.Figure')
                    f.delete;
                end
            end
            if isvalid(ax)
                ax.ButtonDownFcn=[];
                ax.delete;
            end
            if isvalid(obj.Panel)
                obj.Panel.delete;
            end
            if~isempty(obj.AntennaObj)&&isvalid(obj.AntennaObj)

                obj.AntennaObj=[];
            end







        end
        function disableAxesToolbar(obj,f,val)
            rx=rotate3d(f);
            rx.Enable=val;
            z1x=zoom(f);
            z1x.Enable=val;
            px=pan(f);
            px.Enable=val;
            dx=datacursormode(f);
            dx.Enable=val;
        end

        function boundingBoxVisibilityToggled(obj,~,~)
            fl=0;
            for i=1:size(obj.BoundingBox,2)
                if strcmpi(obj.BoundingBox{i}.Visible,'on')
                    fl=1;
                    break;
                end
            end
            if fl
                obj.deleteBtn.Enable='on';
            else
                obj.deleteBtn.Enable='off';
            end
        end

        function r=loadobj(obj)
            if isobject(obj)&&isObjectFromCurrentVersion(obj)
                r=obj;
            else

                r=cad.utilities.SlicingInteractivity;
            end
        end
    end

end

function[normal,idx]=getSurfacenormal(ax,val)
    vector=ax.CameraPosition-ax.CameraTarget;
    normalVect=[1,0,0;0,1,0;0,0,1;-1,0,0;0,-1,0;0,0,-1];
    vector=vector./sqrt(sum(vector.^2));
    d=sum((normalVect-vector).^2,2);
    [~,idx]=min(d);normal=normalVect(idx,:);
    if val==0
        normal=vector;idx=-1;
    end
end

function calcPt=calculateIntersectionpt(surfvector,Currpt,pt)
    intercept=sum(pt.*surfvector);
    p=Currpt;
    linevect=p(2,:)-p(1,:);
    linevect=linevect./sqrt(sum(linevect.^2));
    p0=p(1,:);
    t=intercept-dot(surfvector,p0);
    t=t/dot(surfvector,linevect);
    calcPt=p0+t.*linevect;
end

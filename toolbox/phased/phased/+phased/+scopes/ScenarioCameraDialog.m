classdef ScenarioCameraDialog<dialogmgr.DCTableForm


    properties
hVisual
    end

    properties(Dependent,SetObservable)
CameraPerspective
CameraPosition
CameraViewAngle
CameraOrientation
    end
    properties(Access=private)
        pCameraPerspective=1
        pActiveTag=[];
    end
    methods
        function this=ScenarioCameraDialog(hVisual)
            this.Name='Camera';
            this.hVisual=hVisual;
        end

        function set.CameraPerspective(this,value)
            this.pCameraPerspective=value;
            if isempty(this.hVisual.lastTime)
                return;
            end
            cbtns=this.hVisual.CameraButtons;
            activeBtn=strcmp(get(cbtns,'State'),'on');
            hfig=this.hVisual.Fig;

            isEnabled=strcmp(cbtns(1).Enable,'on');

            if isEnabled
                if any(activeBtn)
                    this.pActiveTag=cbtns(activeBtn).Tag;
                else
                    this.pActiveTag=[];
                end
            end
            if value==1
                set(this.hVisual.hCrossHair,'Visible','off');
                cameratoolbar(hfig,'stopmoving');
                cameratoolbar(hfig,'SetMode','nomode');
                set(cbtns,'Enable','off')
                view(this.hVisual.Axes,45,10);
                set(this.hVisual.Axes,...
                'CameraPositionMode','auto',...
                'CameraTargetMode','auto',...
                'CameraUpVectorMode','auto',...
                'CameraViewAngleMode','auto');

                this.hVisual.ShowBeam=this.hVisual.ShowBeam;
            elseif value==2
                set(this.hVisual.hCrossHair,'Visible','off');
                if~isEnabled&&~isempty(this.pActiveTag)
                    cameratoolbar(hfig,'SetMode',this.pActiveTag);
                end
                set(cbtns,'Enable','on');

                this.hVisual.ShowBeam=this.hVisual.ShowBeam;
                set(this.hVisual.Axes,...
                'CameraPositionMode','manual',...
                'CameraTargetMode','manual',...
                'CameraUpVectorMode','manual',...
                'CameraViewAngleMode','manual');

                this.CameraPosition=[];
                this.CameraOrientation=[];
                this.CameraViewAngle=[];
            else
                cameratoolbar(hfig,'stopmoving');
                cameratoolbar(hfig,'SetMode','nomode');
                set(cbtns,'Enable','off')

                this.hVisual.Beam(this.hVisual.ReferenceRadar).Visible='off';
                set(this.hVisual.Axes,...
                'CameraPositionMode','manual',...
                'CameraTargetMode','manual',...
                'CameraUpVectorMode','manual',...
                'CameraViewAngleMode','manual');
                set(this.hVisual.hCrossHair,'Visible','on');
            end
            update(this.hVisual);
        end
        function value=get.CameraPerspective(this)
            value=this.pCameraPerspective;
        end

        function set.CameraPosition(this,value)

            if isempty(value)
                return;
            end
            this.hVisual.Axes.CameraPosition=value;
        end
        function value=get.CameraPosition(this)
            value=round(this.hVisual.Axes.CameraPosition,2);
        end
        function set.CameraOrientation(this,value)

            if isempty(value)
                return;
            end

            ax=this.hVisual.Axes;

            ax.CameraUpVector=[0,0,1];
            tPos=ax.CameraPosition;




            dist=norm(ax.CameraTarget-tPos);
            tPos(1)=tPos(1)+dist;

            ax.CameraTarget=tPos;
            dvalue=value;
            campan(ax,dvalue(1),dvalue(2));
            camroll(ax,dvalue(3));
        end
        function value=get.CameraOrientation(this)
            value=round(getCamOrientation(this.hVisual.Axes),2);
        end
        function set.CameraViewAngle(this,value)

            if isempty(value)
                return;
            end
            this.hVisual.Axes.CameraViewAngle=value;
        end
        function value=get.CameraViewAngle(this)
            value=round(this.hVisual.Axes.CameraViewAngle,2);
        end
    end

    methods(Access=protected)
        function initTable(this)
            this.InterColumnSpacing=2;
            this.InterRowSpacing=2;
            this.InnerBorderSpacing=4;
            this.ColumnWidths={'min','max','min'};
            this.HorizontalAlignment={'right','left','left'};


            perspectives={'Auto','Custom','Radar'};
            c=uipopup(this,perspectives,'label',getString(message('phased:scopes:SVPerspective')));
            c.Tag='PerspectiveCDTag';
            c.TooltipString=getString(message('phased:scopes:SVPerspectiveTT'));
            connectPropertyAndControl(this,'CameraPerspective',c,'value');
            connectRowVisToControl(this,{'CameraPositionCDTag','OrientationCDTag','ViewAngleCDTag'},c,'Custom',true);

            this.newrow


            c=uieditv(this,'label',getString(message('phased:scopes:SVCameraPosition')));
            c.Tag='CameraPositionCDTag';
            c.TooltipString=getString(message('phased:scopes:SVCameraPositionTT'));
            c.ValidAttributes={'finite','nonnan','nonempty','real','vector','numel',3};
            connectPropertyAndControl(this,'CameraPosition',c);
            uitext(this,'m');
            this.newrow;


            c=uieditv(this,'label',getString(message('phased:scopes:SVOrientation')));
            c.Tag='OrientationCDTag';
            c.TooltipString=getString(message('phased:scopes:SVOrientationTT'));
            c.ValidAttributes={};
            c.ValidationFunction=@validateOrientation;
            connectPropertyAndControl(this,'CameraOrientation',c);
            uitext(this,'deg');
            this.newrow;


            c=uieditv(this,'label',getString(message('phased:scopes:SVViewAngle')));
            c.Tag='ViewAngleCDTag';
            c.TooltipString=getString(message('phased:scopes:SVViewAngleTT'));
            c.ValidAttributes={'positive','scalar','<',360};
            c.ValidationFunction=@sigdatatypes.validateAngle;
            connectPropertyAndControl(this,'CameraViewAngle',c);
            uitext(this,'deg');
            this.newrow;


        end
    end
end

function orient=getCamOrientation(ax)





    x=ax.CameraTarget-ax.CameraPosition;
    x=x/norm(x);
    z=ax.CameraUpVector;
    y=crossSimple(z,x);
    z=crossSimple(x,y);
    m=[x;y;z].';

    roll=atan2d(m(3,2),m(3,3));
    tilt=atan2d(m(3,1),sqrt(m(3,3)^2+m(3,2)^2));
    m(4,4)=1;
    rt=makehgtform('axisrotate',x,deg2rad(-roll));
    m=rt*m;
    pan=atan2d(m(1,2),m(2,2));
    orient=[pan,tilt,roll];
end


function c=crossSimple(a,b)
    c(1)=b(3)*a(2)-b(2)*a(3);
    c(2)=b(1)*a(3)-b(3)*a(1);
    c(3)=b(2)*a(1)-b(1)*a(2);
end


function validateOrientation(value,varargin)
    sigdatatypes.validateAngle(value,varargin{1},varargin{2},{'vector','numel',3});
    validateattributes(value(1),{'double'},{'scalar','<=',180,'>=',-180},'',...
    'pan angle');

    validateattributes(value(2),{'double'},{'scalar','<=',90,'>=',-90},'',...
    'tilt angle');

    validateattributes(value(3),{'double'},{'scalar','<=',180,'>=',-180},'',...
    'roll angle');
end

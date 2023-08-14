classdef OrientationIndicator
    properties(SetAccess=protected)
Parent
Axes
AxesArrow
AxesLabel
    end

    properties(Hidden,Constant)
        PanelHeight=80
        AxesColorX=[1,0,0]
        AxesColorY=[0,.5,0]
        AxesColorZ=[0,0,1]
        FontSize=10
        HeadLength=5
        HeadWidth=5
    end

    properties(SetAccess=protected,Transient,Hidden)
AxesViewListener
AxesCameraPositionListener
AxesCameraUpVectorListener
AxesCameraTargetListener
    end

    methods
        function this=OrientationIndicator(hParent,hAxes)
            this.Parent=hParent;
            this.Axes=hAxes;
            this.Parent.Position=[0,0,hParent.Position(3),this.PanelHeight];
            this.AxesArrow=[annotation(this.Parent,'arrow','Color',this.AxesColorX,'Units','pixels','HeadLength',this.HeadLength,'HeadWidth',this.HeadWidth,'Tag','IndicatorArrowX')
            annotation(this.Parent,'arrow','Color',this.AxesColorY,'Units','pixels','HeadLength',this.HeadLength,'HeadWidth',this.HeadWidth,'Tag','IndicatorArrowY')
            annotation(this.Parent,'arrow','Color',this.AxesColorZ,'Units','pixels','HeadLength',this.HeadLength,'HeadWidth',this.HeadWidth,'Tag','IndicatorArrowZ')];
            this.AxesLabel=[annotation(this.Parent,'textbox','String','x','Color',this.AxesColorX,'LineStyle','none','HorizontalAlignment','center','VerticalAlignment','middle','Units','pixels','Tag','IndicatorLabelX')
            annotation(this.Parent,'textbox','String','y','Color',this.AxesColorY,'LineStyle','none','HorizontalAlignment','center','VerticalAlignment','middle','Units','pixels','Tag','IndicatorLabelY')
            annotation(this.Parent,'textbox','String','z','Color',this.AxesColorZ,'LineStyle','none','HorizontalAlignment','center','VerticalAlignment','middle','Units','pixels','Tag','IndicatorLabelZ')];

            this.AxesViewListener=listener(this.Axes,'View','PostSet',@(src,evt)indicate(this));
            this.AxesCameraPositionListener=listener(this.Axes,'CameraPosition','PostSet',@(src,evt)indicate(this));
            this.AxesCameraUpVectorListener=listener(this.Axes,'CameraUpVector','PostSet',@(src,evt)indicate(this));
            this.AxesCameraTargetListener=listener(this.Axes,'CameraTarget','PostSet',@(src,evt)indicate(this));
        end

        function indicate(this)
            hAxes=this.Axes;
            posPanel=this.Parent.Position;
            h=posPanel(4);
            fontSiz=this.FontSize;
            originX=h/2;
            unitLenX=(h-2.5*fontSiz)/2;
            originY=h/2;
            unitLenY=(h-2.5*fontSiz)/2;

            v=view(hAxes);
            v(:,2:3)=-v(:,2:3);
            for i=1:3
                deltaX=unitLenX*v(1,i);
                deltaY=unitLenY*v(2,i);
                set(this.AxesArrow(i),...
                'X',originX+[0,deltaX],...
                'Y',originY+[0,deltaY])

                if norm(v(1:2,i))>0.2
                    style='vback2';
                else
                    style='none';
                end
                this.AxesArrow(i).HeadStyle=style;

                set(this.AxesLabel(i),...
                'Position',[originX+deltaX,originY+deltaY,0,0]...
                +fontSiz/2*[v(1,i),0,0,0]...
                +fontSiz/2*[0,v(2,i),0,0]);
            end
        end
    end

end
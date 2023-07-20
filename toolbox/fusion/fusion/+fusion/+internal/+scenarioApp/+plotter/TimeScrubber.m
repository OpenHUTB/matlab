classdef TimeScrubber<handle

    properties
        CallbackFcn=''
    end

    properties(SetAccess=private,Hidden)
Parent
Figure
SliderKnob
PastRange
FutureRange
TotalRange
TimeStatus
ButtonUpListener
        TotalTime=10
        CurrentTime=0
        RecordTime=0
        TimeStatusWidth=0
        DragEnabled=false
        Dragging=false
    end

    properties(Constant,Hidden)
        KnobHeight=11
        KnobWidth=16
        KnobHighlightColor=[0.8000,0.8000,0.8000]
        KnobBackgroundColor=[0.1686,0.5686,0.9686]

        TimeLineHeight=5
        TimeLineGutter=12
        TimeHighlightColor=[0.5000,0.5000,0.5000]
        PastBackgroundColor=[0.1686,0.5686,0.9686]
        FutureBackgroundColor=[0.6353,0.8431,1.0000]
        TotalBackgroundColor=[0.9412,0.9412,0.9412]
    end


    methods
        function this=TimeScrubber(hParent)
            this.Parent=hParent;
            this.Figure=ancestor(this.Parent,'Figure');
            createGraphics(this);
        end

        function setTotalTime(this,total)
            this.TotalTime=total;
            this.RecordTime=min(this.RecordTime,total);
            this.CurrentTime=min(this.CurrentTime,total);
        end

        function setRecordTime(this,record)
            this.RecordTime=record;
            this.TotalTime=max(this.TotalTime,record);
            this.CurrentTime=min(this.CurrentTime,record);
        end

        function setCurrentTime(this,current)
            this.CurrentTime=current;
            this.TotalTime=max(this.TotalTime,current);
            this.RecordTime=max(this.RecordTime,current);
        end

        function setTimeStatus(this,timeString)
            this.TimeStatus.String=timeString;
            update(this);
        end

        function hide(this)
            this.Parent.Visible='off';
        end

        function show(this)
            pos=getpixelposition(this.Parent.Parent);
            this.Parent.Position=[0,0,pos(3),25];
            this.Parent.Visible='on';
        end

        function update(this)
            w=this.KnobWidth;
            h=this.KnobHeight;
            this.SliderKnob.Position=[0,0,w,h];

            h=this.TimeLineHeight;

            ParentW=this.Parent.Position(3);
            ParentH=this.Parent.Position(4);
            StatusW=this.TimeStatusWidth;
            RangeH=this.TimeLineHeight;


            this.TimeStatus.Position=[ParentW-StatusW,0,StatusW,ParentH];


            GutterX=this.TimeLineGutter;
            GutterY=(ParentH-RangeH)/2;
            TotalW=ParentW-StatusW-2*GutterX;
            this.TotalRange.Position=[GutterX,GutterY,TotalW,RangeH];


            PastW=round(this.CurrentTime*TotalW/this.TotalTime);
            this.PastRange.Position=[GutterX,GutterY,PastW,h];


            FutureX=GutterX+PastW;
            FutureW=max(0,min(max(0,round(this.RecordTime*TotalW/this.TotalTime)),TotalW)-PastW);
            this.FutureRange.Position=[FutureX,GutterY,FutureW,h];


            KnobH=this.KnobHeight;
            KnobW=this.KnobWidth;
            KnobX=FutureX-round(KnobW/2);
            KnobY=round((ParentH-KnobH)/2);
            this.SliderKnob.Position=[KnobX,KnobY,KnobW,KnobH];
        end
    end

    methods(Access=private)

        function createGraphics(this)
            this.TotalRange=uipanel(...
            'Parent',this.Parent,...
            'BackgroundColor',this.TotalBackgroundColor,...
            'BorderWidth',1,...
            'HighlightColor',this.TimeHighlightColor,...
            'Units','pixels',...
            'Tag','TotalRange',...
            'BorderType','line',...
            'Visible','on',...
            'ButtonDownFcn',@this.onButtonDown);

            this.PastRange=uipanel(...
            'Parent',this.Parent,...
            'BackgroundColor',this.PastBackgroundColor,...
            'BorderWidth',1,...
            'HighlightColor',this.TimeHighlightColor,...
            'Units','pixels',...
            'Tag','PastRange',...
            'BorderType','line',...
            'Visible','on',...
            'ButtonDownFcn',@this.onButtonDown);

            this.FutureRange=uipanel(...
            'Parent',this.Parent,...
            'BackgroundColor',this.FutureBackgroundColor,...
            'BorderWidth',1,...
            'HighlightColor',this.TimeHighlightColor,...
            'Units','pixels',...
            'Tag','FutureRange',...
            'BorderType','line',...
            'Visible','on',...
            'ButtonDownFcn',@this.onButtonDown);

            this.SliderKnob=uipanel(...
            'Parent',this.Parent,...
            'BackgroundColor',this.KnobBackgroundColor,...
            'BorderWidth',1,...
            'HighlightColor',this.KnobHighlightColor,...
            'Units','pixels',...
            'Tag','SliderKnob',...
            'BorderType','line',...
            'Visible','on',...
            'ButtonDownFcn',@this.onButtonDown);

            this.TimeStatus=uicontrol(...
            'Parent',this.Parent,...
            'String','T = 0000.000 / 0000.000',...
            'Style','text',...
            'Units','pixels',...
            'Tag','TimeStatus',...
            'Visible','on');
            this.TimeStatusWidth=this.TimeStatus.Extent(3);
            this.ButtonUpListener=addlistener(this.Figure,'WindowMouseRelease',@this.onButtonUp);
        end
    end


    methods

        function onButtonDown(this,~,~)
            this.DragEnabled=true;
            this.Figure.WindowButtonMotionFcn=@this.onButtonMove;
        end

        function onButtonUp(this,~,~)
            this.Figure.WindowButtonMotionFcn=[];
            if this.DragEnabled
                this.DragEnabled=false;
                postNewTime(this);
            end
        end

        function onButtonMove(this,~,~)
            if this.DragEnabled&&~this.Dragging
                this.Dragging=true;
                stopDrag=onCleanup(@(~)stopDragging(this));
                postNewTime(this);
            end
        end

        function stopDragging(this)
            if isvalid(this)
                this.Dragging=false;
            end
        end

        function postNewTime(this)
            hFig=ancestor(this.Parent,'Figure');


            mousePos=hFig.CurrentPoint;
            rangePos=getpixelposition(this.TotalRange,true);
            relativePos=(mousePos(1)-rangePos(1))./rangePos(3);
            relativePos=min(max(0,relativePos),1);


            newTime=min(relativePos*this.TotalTime,this.RecordTime);

            if~isempty(this.CallbackFcn)
                this.CallbackFcn(newTime);
            end
        end
    end

end


classdef(Sealed)TimeScope<matlab.mixin.SetGet




    properties(Dependent,Transient)
        Parent;
    end

    properties(Dependent,Hidden,Transient)


        MaximumDimensions=[1,1];
        SampleTimes=0;
        InputNames={};

        OriginTime;
    end

    properties(Hidden,Transient)

        BufferLengthPerInput=500;
    end

    properties(Dependent)

        TimeSpan;

        FrameBasedProcessing;
        TimeSpanOverrunMethod;
        TimeUnits;
        PlotType;
        YLimits;
        YLabelString;
        TimeGrid;
        YGrid;
        Legend;

        TimeTicks;
        TimeTicksMode;
        TimeTickLabels;
        TimeTickLabelsMode;
        YTicks;
        YTicksMode;
        YTickLabels;
        YTickLabelsMode;

        ChannelNames;
        ContinuousAutoscale;
    end

    properties

        Visible='on';
        Units='pixels';
        Tag='';
    end

    properties(SetObservable)
        Position=[1,1,300,200];
    end

    properties(Hidden,SetAccess=private,Transient)



        Plotter;



        Panel;



        DataBuffer;

        Autoscaler;

        ContextMenu;
    end

    properties(Hidden,SetAccess=private,Dependent,Transient)
        AxesSize;
        TimeLimits;
    end

    properties(Access=private,Transient)


PropertyCache

        pAutoscale=false;
        pYLabelString='Amplitude';
        AlwaysScaleMenu;
        ScaleMenu;
        LegendMenu;
        TextTimer;
        LegendPositionListener;
        FigureDestroyListener;
    end

    methods

        function this=TimeScope(varargin)



            this.DataBuffer=scopesutil.TimeBuffer(1,'SingleRate',5000,[1,1]);
            this.TextTimer=scopesutil.OneShotTimer(.5);




            try
                for indx=1:2:numel(varargin)
                    this.(varargin{indx})=varargin{indx+1};
                end
            catch ME


                delete(this);


                rethrow(ME);
            end
        end


        function delete(this)

            if~isempty(this.Plotter)&&isvalid(this.Plotter)
                delete(this.Plotter);
            end
            if~isempty(this.Panel)&&ishghandle(this.Panel)
                delete(this.Panel);
            end
        end





        function set.ContinuousAutoscale(this,value)
            value=checkEnum(value,{'on','off'},'ContinuousAutoscale');

            set(this.AlwaysScaleMenu,'Checked',value);

            value=strcmpi(value,'on');
            this.pAutoscale=value;
            if value&&~isempty(this.Plotter)
                autoscale(this,true);
            end
        end

        function value=get.ContinuousAutoscale(this)
            if this.pAutoscale
                value='on';
            else
                value='off';
            end
        end





        function originTime=get.OriginTime(this)
            originTime=this.Plotter.OriginTime;
        end

        function set.OriginTime(this,time)
            if isempty(this.Plotter)
                this.PropertyCache.OriginTime=time;
            else
                this.Plotter.OriginTime=time;
            end
        end

        function axesSize=get.AxesSize(this)
            axesPosition=getpixelposition(this.Plotter.Axes(1));
            axesSize=axesPosition(3:4);
        end

        function inputNames=get.InputNames(this)
            inputNames=this.Plotter.InputNames;
        end

        function set.InputNames(this,inputNames)

            if isempty(this.Plotter)
                this.PropertyCache.InputNames=inputNames;
            else
                this.Plotter.InputNames=inputNames;
            end
        end

        function channelNames=get.ChannelNames(this)
            channelNames=this.Plotter.ChannelNames;
        end

        function set.ChannelNames(this,channelNames)

            if~iscellstr(channelNames)&&~isstring(channelNames)
                error(message('Spcuilib:scopes:InvalidChannelNames'));
            elseif isempty(this.Plotter)
                this.PropertyCache.ChannelNames=channelNames;
            else
                this.Plotter.UserDefinedChannelNames=channelNames;
            end
        end

        function set.MaximumDimensions(this,maxDims)
            if isempty(this.Plotter)
                this.PropertyCache.MaximumDimensions=maxDims;
            else
                this.Plotter.MaxDimensions=maxDims;
                this.DataBuffer=scopesutil.TimeBuffer(size(maxDims,1),...
                'MultipleRate',ceil(this.BufferLengthPerInput./prod(maxDims,2)),...
                maxDims);
                applyLineColors(this.Plotter);
                createLegendPositionListener(this);
            end
        end
        function maxDims=get.MaximumDimensions(this)
            maxDims=this.Plotter.MaxDimensions;
        end

        function set.SampleTimes(this,sampleTimes)
            if isempty(this.Plotter)
                this.PropertyCache.SampleTimes=sampleTimes;
            else

                this.Plotter.SampleTimes=sampleTimes;
                applyLineColors(this.Plotter);
            end
        end
        function sampleTimes=get.SampleTimes(this)
            sampleTimes=this.Plotter.SampleTimes;
        end

        function timeLimits=get.TimeLimits(this)
            timeLimits=get(this.Plotter.Axes(1),'XLim');
        end

        function set.TimeSpan(this,timeSpan)

            if~isscalar(timeSpan)||~isnumeric(timeSpan)||...
                isnan(timeSpan)||isinf(timeSpan)||...
                timeSpan<=0
                error(message('Spcuilib:scopes:InvalidTimeSpan'));
            end

            if isempty(this.Plotter)
                this.PropertyCache.TimeSpan=timeSpan;
            else
                this.Plotter.TimeSpan=timeSpan;


                if any(this.Plotter.MaxDimensions>0)
                    updateDisplay(this);
                end
            end
        end
        function timeSpan=get.TimeSpan(this)
            timeSpan=this.Plotter.TimeSpan;
        end

        function set.TimeUnits(this,timeUnits)
            timeUnits=checkEnum(timeUnits,{'none','metric','seconds'},'TimeUnits');
            if isempty(this.Plotter)
                this.PropertyCache.TimeUnits=timeUnits;
            else
                this.Plotter.TimeUnits=timeUnits;
            end
        end
        function timeUnits=get.TimeUnits(this)
            timeUnits=this.Plotter.TimeUnits;
        end

        function set.YLabelString(this,yLabel)

            if~ischar(yLabel)&&~(isstring(yLabel)&&isscalar(yLabel))
                error(message('Spcuilib:scopes:InvalidYLabelString'));
            end

            this.pYLabelString=yLabel;
            if isempty(this.Plotter)
                this.PropertyCache.YLabelString=yLabel;
            else
                this.Plotter.YLabelReal=yLabel;
                resizePanel(this);
            end
        end
        function yLabel=get.YLabelString(this)
            yLabel=this.pYLabelString;
        end

        function set.FrameBasedProcessing(this,frameProcessing)
            frameProcessing=checkEnum(frameProcessing,{'on','off'},'FrameBasedProcessing');
            if isempty(this.Plotter)
                this.PropertyCache.FrameBasedProcessing=frameProcessing;
            else
                this.Plotter.FrameProcessing=strcmp(frameProcessing,'on');

                applyLineColors(this.Plotter);
            end
        end
        function frameProcessing=get.FrameBasedProcessing(this)
            if this.Plotter.FrameProcessing
                frameProcessing='on';
            else
                frameProcessing='off';
            end
        end

        function set.PlotType(this,plotType)
            plotType=checkEnum(plotType,{'auto','line','stairs'},'PlotType');
            if isempty(this.Plotter)
                this.PropertyCache.PlotType=plotType;
            else
                this.Plotter.PlotType=plotType;
            end
        end
        function plotType=get.PlotType(this)
            plotType=lower(this.Plotter.PlotType);
        end

        function set.YLimits(this,yLim)

            if~isnumeric(yLim)||numel(yLim)~=2
                error(message('Spcuilib:scopes:InvalidYLimitsSize'));
            elseif diff(yLim)<=0||any(isnan(yLim))||any(isinf(yLim))
                error(message('Spcuilib:scopes:InvalidYLimitsValue'));
            elseif isempty(this.Plotter)
                this.PropertyCache.YLimits=yLim;
            else
                this.Plotter.YLimReal=yLim;
            end
        end
        function yLim=get.YLimits(this)
            yLim=this.Plotter.YLimReal;
        end

        function set.TimeSpanOverrunMethod(this,newDisplayType)
            newDisplayType=checkEnum(newDisplayType,{'wrap','scroll'},'TimeSpanOverrunMethod');
            if isempty(this.Plotter)
                this.PropertyCache.TimeSpanOverrunMethod=newDisplayType;
            else
                this.Plotter.TimeOverrunMode=newDisplayType;
            end
        end
        function displayType=get.TimeSpanOverrunMethod(this)
            displayType=lower(this.Plotter.TimeOverrunMode);
        end

        function set.TimeGrid(this,grid)
            grid=checkEnum(grid,{'on','off'},'TimeGrid');
            if isempty(this.Plotter)
                this.PropertyCache.TimeGrid=grid;
            else
                this.Plotter.XGrid=strcmpi(grid,'on');
            end
        end
        function grid=get.TimeGrid(this)
            grid=this.Plotter.XGrid;
            if grid
                grid='on';
            else
                grid='off';
            end
        end

        function set.YGrid(this,grid)

            grid=checkEnum(grid,{'on','off'},'YGrid');
            if isempty(this.Plotter)
                this.PropertyCache.YGrid=grid;
            else
                this.Plotter.YGrid=strcmpi(grid,'on');
            end
        end
        function grid=get.YGrid(this)
            grid=this.Plotter.YGrid;
            if grid
                grid='on';
            else
                grid='off';
            end
        end

        function set.Legend(this,newLegend)
            newLegend=checkEnum(newLegend,{'on','off'},'Legend');
            if isempty(this.Plotter)
                this.PropertyCache.Legend=newLegend;
            else
                this.Plotter.LegendVisibility=newLegend;
                createLegendPositionListener(this);
            end

            set(this.LegendMenu,'Checked',newLegend);

        end

        function legendVisibility=get.Legend(this)
            legendVisibility=this.Plotter.LegendVisibility;
        end




        function parent=get.Parent(this)
            parent=get(this.Panel,'Parent');
        end
        function set.Parent(this,newParent)

            hPanel=this.Panel;
            if isempty(newParent)
                if~isempty(this.Parent)


                    this.PropertyCache=saveobj(this);


                    if isvalid(this.Plotter)
                        delete(this.Plotter);
                    end
                    if ishghandle(hPanel)
                        delete(hPanel);
                    end
                    if ishghandle(this.ContextMenu)
                        delete(this.ContextMenu);
                    end
                    this.ContextMenu=[];
                    this.Plotter=[];
                    this.Panel=[];
                end
            elseif isempty(hPanel)



                hPanel=uipanel(...
                'Parent',newParent,...
                'Visible','off',...
                'DeleteFcn',makePanelDeleteFcn(this),...
                'Units',this.Units,...
                'Position',this.Position,...
                'Tag','TimeScopePanel',...
                'HandleVisibility','off',...
                'Serializable','off',...
                'BorderType','none');


                hPlotter=matlabshared.scopes.visual.TimeDomainPlotter(hPanel);
                hPlotter.SettingTimeProperties=false;
                hPlotter.Initializing=false;
                this.Panel=hPanel;

                hFig=ancestor(newParent,'figure');
                this.ContextMenu=uicontextmenu('Parent',hFig,...
                'Tag','TimeScopeAxesContextMenu',...
                'Serializable','off');
                this.AlwaysScaleMenu=uimenu(this.ContextMenu,...
                'Tag','AlwaysScale',...
                'Serializable','off',...
                'Label',uiscopes.message('AutoScaleAxesLimits'),...
                'Checked',this.ContinuousAutoscale,...
                'Callback',makeAutoscaleCallback(this));
                uimenu(this.ContextMenu,...
                'Tag','ScaleLimits',...
                'Serializable','off',...
                'Label',uiscopes.message('ScaleAxesLimits'),...
                'Callback',makeScaleCallback(this));
                uimenu(this.ContextMenu,...
                'Tag','EnableZoom',...
                'Serializable','off',...
                'Label',uiscopes.message('EnableZoom'),...
                'Callback',@(~,~)enableZoomCallback(hFig));
                set(hPlotter.Axes,'HandleVisibility','callback',...
                'Serializable','off',...
                'UIContextMenu',this.ContextMenu);

                this.FigureDestroyListener=uiservices.addlistener(hFig,...
                'ObjectBeingDestroyed',uiservices.makeCallback(@onFigureBeingDestroyed,this));

                this.Plotter=hPlotter;

                this.LegendMenu=uimenu(this.ContextMenu,...
                'Tag','ToggleLegend',...
                'Serializable','off',...
                'Label',uiscopes.message('MenuShowLegend'),...
                'Checked',this.Legend,...
                'Callback',@(~,~)toggleLegend(this));




                restorePropertyCache(this);
                installZoomControls(this);



                set(hPanel,'ResizeFcn',@(~,~)resizePanel(this));
                resizePanel(this);

                set(hPanel,'Visible',this.Visible);
            else
                set(hPanel,'Parent',newParent);
            end
        end

        function set.Visible(this,visible)
            visible=checkEnum(visible,{'on','off'},'Visible');

            this.Visible=visible;
            set(this.Panel,'Visible',visible);%#ok<MCSUP>
        end
        function set.Position(this,position)
            if any(~isnumeric(position))||any(isnan(position))||...
                any(isinf(position))||~isequal(size(position),[1,4])
                error(message('Spcuilib:scopes:InvalidPosition'));
            end
            this.Position=position;
            set(this.Panel,'Position',position);%#ok<MCSUP>
        end
        function set.Units(this,units)
            units=checkEnum(units,{'pixels','normalized'},'Units');

            this.Units=units;
            set(this.Panel,'Units',units);%#ok<MCSUP>
        end




        function set.TimeTicksMode(this,value)
            value=checkEnum(value,{'auto','manual'},'TimeTicksMode');
            if isempty(this.Plotter)
                this.PropertyCache.TimeTicksMode=value;
            else
                this.Plotter.XTickMode=value;
            end
        end
        function value=get.TimeTicksMode(this)
            value=this.Plotter.XTickMode;
        end

        function set.TimeTicks(this,value)
            if~isnumeric(value)||any(diff(value)<=0)
                error(message('Spcuilib:scopes:InvalidTimeTicks'));
            elseif isempty(this.Plotter)
                this.PropertyCache.TimeTicks=value;
            else
                this.Plotter.XTick=value;
            end
        end
        function value=get.TimeTicks(this)
            value=this.Plotter.XTick;
        end

        function set.TimeTickLabelsMode(this,value)
            value=checkEnum(value,{'auto','manual'},'TimeTickLabelsMode');

            if isempty(this.Plotter)
                this.PropertyCache.TimeTickLabelsMode=value;
            else
                this.Plotter.XTickLabelMode=value;
            end
        end
        function value=get.TimeTickLabelsMode(this)
            value=this.Plotter.XTickLabelMode;
        end

        function set.TimeTickLabels(this,value)
            if~iscellstr(value)&&~isstring(value)
                error(message('Spcuilib:scopes:InvalidTimeTickLabels'));
            elseif isempty(this.Plotter)
                this.PropertyCache.TimeTickLabels=value;
            else
                this.Plotter.XTickLabel=value;
            end
        end
        function value=get.TimeTickLabels(this)
            value=this.Plotter.XTickLabel;
            if ischar(value)||(isstring(value)&&isscalar(value))
                value=convertToCell(value);
            else
                value=value(:)';
            end
        end

        function set.YTicksMode(this,value)
            value=checkEnum(value,{'auto','manual'},'YTicksMode');
            if isempty(this.Plotter)
                this.PropertyCache.YTicksMode=value;
            else
                this.Plotter.YTickMode=value;
            end
        end
        function value=get.YTicksMode(this)
            value=this.Plotter.YTickMode;
        end

        function set.YTicks(this,value)
            if~isnumeric(value)||any(diff(value)<=0)
                error(message('Spcuilib:scopes:InvalidYTicks'));
            elseif isempty(this.Plotter)
                this.PropertyCache.YTicks=value;
            else
                this.Plotter.YTick=value;
            end
        end
        function value=get.YTicks(this)
            value=this.Plotter.YTick;
        end

        function set.YTickLabelsMode(this,value)
            value=checkEnum(value,{'auto','manual'},'YTickLabelsMode');

            if isempty(this.Plotter)
                this.PropertyCache.YTickLabelsMode=value;
            else
                this.Plotter.YTickLabelMode=value;
            end
        end
        function value=get.YTickLabelsMode(this)
            value=this.Plotter.YTickLabelMode;
        end

        function set.YTickLabels(this,value)
            if~iscellstr(value)&&~isstring(value)
                error(message('Spcuilib:scopes:InvalidYTickLabels'));
            elseif isempty(this.Plotter)
                this.PropertyCache.YTickLabels=value;
            else
                this.Plotter.YTickLabel=value;
            end
        end
        function value=get.YTickLabels(this)
            value=this.Plotter.YTickLabel;
            if ischar(value)||(isstring(value)&&isscalar(value))
                value=convertToCell(value);
            else
                value=value(:)';
            end
        end




        function set.BufferLengthPerInput(this,newBufferLength)
            this.BufferLengthPerInput=newBufferLength;
            this.DataBuffer.MaxNumTimeSteps=...
            ceil(newBufferLength/prod(this.MaximumDimensions,2));%#ok<MCSUP>
        end
    end
    methods(Hidden)

        function autoscale(this,varargin)
            if isempty(this.Autoscaler)
                this.Autoscaler=matlabshared.scopes.tool.Autoscaler;
            end
            autoscale(this.Autoscaler,this.Plotter,varargin{:});
        end

        function dataBuffer=getDataBuffer(this)
            dataBuffer=this.DataBuffer;
        end

        function updateText(this)
            updateTimeOffsetReadout(this.Plotter);
        end

        function updateDisplay(this)

            hPlotter=this.Plotter;
            hDBuffer=this.DataBuffer;


            if~hDBuffer.IsReady
                return;
            end

            endTime=hDBuffer.getLastTime;

            if endTime==-inf


                endTime=0;
            end




            hPlotter.EndTime=calculateAsynchronousEndTime(hPlotter,endTime);

            nPorts=hDBuffer.NPorts;
            drawInputs=repmat(struct('values',[],'time',[]),1,nPorts);

            for indx=1:nPorts
                [drawInputs(indx).time,drawInputs(indx).values]=getTimeAndValue(...
                hDBuffer,indx,...
                hPlotter.StartTime,endTime,true);
            end

            draw(this.Plotter,drawInputs);



            if this.pAutoscale
                autoscale(this)
            end

            if this.TextTimer.isTimeUp
                updateText(this);
                start(this.TextTimer);
            end

            drawnow limitrate nocallbacks
        end

        function onPauseStop(this)

            endTime=this.DataBuffer.getLastTime;
            if endTime==-inf,endTime=0;end
            this.Plotter.EndTime=endTime;
            if this.pAutoscale



                autoscale(this,true);
            end


            updateText(this);
        end

        function s=saveobj(this)


            s.Visible=this.Visible;
            s.Position=this.Position;
            s.Units=this.Units;
            s.Tag=this.Tag;

            if~isempty(this.Plotter)&&isvalid(this.Plotter)

                s.TimeSpan=this.TimeSpan;
                s.FrameBasedProcessing=this.FrameBasedProcessing;
                s.TimeSpanOverrunMethod=this.TimeSpanOverrunMethod;
                s.TimeUnits=this.TimeUnits;
                s.PlotType=this.PlotType;
                s.YLimits=this.YLimits;
                s.YLabelString=this.YLabelString;
                s.TimeGrid=this.TimeGrid;
                s.YGrid=this.YGrid;
                s.Legend=this.Legend;
                s.TimeTicks=this.TimeTicks;
                s.TimeTicksMode=this.TimeTicksMode;
                s.TimeTickLabels=this.TimeTickLabels;
                s.TimeTickLabelsMode=this.TimeTickLabelsMode;
                s.YTicks=this.YTicks;
                s.YTicksMode=this.YTicksMode;
                s.YTickLabels=this.YTickLabels;
                s.YTickLabelsMode=this.YTickLabelsMode;
                s.ChannelNames=this.ChannelNames;
                s.ContinuousAutoscale=this.ContinuousAutoscale;
            else
                s.PropertyCache=this.PropertyCache;
            end
        end
    end

    methods(Static,Hidden)
        function this=loadobj(s)
            this=simulink.ui.scope.TimeScope;



            this.Position=s.Position;
            this.Units=s.Units;
            this.Visible=s.Visible;
            this.Tag=s.Tag;

            if isfield(s,'PropertyCache')
                this.PropertyCache=s.PropertyCache;
            else


                this.PropertyCache=rmfield(s,{'Position','Units','Visible','Tag'});
            end
        end
    end
end


function resizePanel(this)

    hPlotter=this.Plotter;

    hAxes=hPlotter.Axes(1);


    positionReadout=get(hPlotter.TimeOffsetReadout,'Position');
    endReadout=positionReadout(1)+positionReadout(3);

    if isprop(hPlotter,'ShowTimeAxisLabel')
        hPlotter.ShowTimeAxisLabel=true;
    else
        hPlotter.XLabel='';
    end



    xlabel=get(hAxes,'XLabel');
    oldPosition=get(xlabel,'position');
    origUnits=get(xlabel,'Units');
    set(xlabel,'Units','pixels');
    positionXLabel=get(xlabel,'Position');
    set(xlabel,'Units',origUnits,'Position',oldPosition);



    if isprop(hPlotter,'ShowTimeAxisLabel')
        if endReadout>positionXLabel(1)
            hPlotter.ShowTimeAxisLabel=false;
        end
    else
        pf=get(0,'ScreenPixelsPerInch')/96;
        if endReadout+10*pf>positionXLabel(1)
            hPlotter.XLabel=' ';
        end
    end
end


function restorePropertyCache(this)

    propertyCache=this.PropertyCache;
    if~isempty(propertyCache)


        propertyCache=cleanModeProp(propertyCache,'TimeTicks');
        propertyCache=cleanModeProp(propertyCache,'YTicks');
        propertyCache=cleanModeProp(propertyCache,'YTickLabels');



        fields=fieldnames(propertyCache);
        for indx=1:numel(fields)
            this.(fields{indx})=propertyCache.(fields{indx});
        end
        this.PropertyCache=[];
    end

end


function props=cleanModeProp(props,propName)

    modeProp=[propName,'Mode'];
    if isfield(props,modeProp)&&...
        strcmp(props.(modeProp),'auto')&&...
        isfield(props,propName)
        props=rmfield(props,propName);
    end
end


function cb=makePanelDeleteFcn(this)

    cb=@(~,~)onPanelBeingDestroyed(this);
end


function onPanelBeingDestroyed(this)

    this.Parent=[];

end

function onFigureBeingDestroyed(this)
    this.Parent=[];
end


function enableZoomCallback(hFig)

    zoom(hFig,'on');

end


function cb=makeAutoscaleCallback(this)
    cb=@(~,~)autoscaleCallback(this);
end


function cb=makeScaleCallback(this)
    cb=@(~,~)autoscale(this,true);
end


function autoscaleCallback(this)

    this.pAutoscale=~this.pAutoscale;

    set(this.AlwaysScaleMenu,'Checked',this.ContinuousAutoscale);

end


function installZoomControls(this)


    hFig=ancestor(this.Panel,'figure');


    z=zoom(hFig);

    hC=uicontextmenu('Parent',hFig,...
    'Serializable','off');

    uimenu(hC,...
    'Serializable','off',...
    'Tag','DisableZoom',...
    'Label',uiscopes.message('DisableZoom'),...
    'Callback',@(~,~)disableZoomCallback(hFig));

    set(z,'UIContextMenu',hC);

end


function toggleLegend(this)

    if strcmp(this.Legend,'off')
        this.Legend='on';
    else
        this.Legend='off';
    end

end


function disableZoomCallback(hFig)

    zoom(hFig,'off');

end


function applyLineColors(hPlotter)

    hAxes=hPlotter.Axes;
    hLines=hPlotter.Lines;

    colorOrder=get(hAxes(1),'ColorOrder');

    for indx=1:numel(hLines)
        set(hLines(indx),'Color',colorOrder(rem(indx-1,size(colorOrder,1))+1,:));
    end

end


function output=convertToCell(input)

    nRows=size(input,1);
    output=cell(1,nRows);

    for indx=1:nRows
        output{indx}=strtrim(input(indx,:));
    end

end


function fixLegendPosition(this)

    hPlotter=this.Plotter;
    if~isempty(hPlotter)
        leg=hPlotter.LegendHandle;
        if~isempty(leg)&&ishghandle(leg)
            legPos=getpixelposition(leg);
            panPos=getpixelposition(this.Panel);


            if legPos(1)<1
                legPos(1)=1;
            end
            if legPos(1)+legPos(3)>panPos(3)
                legPos(1)=panPos(3)-legPos(3);
            end
            if legPos(2)<1
                legPos(2)=1;
            end
            if legPos(2)+legPos(4)>panPos(4)
                legPos(2)=panPos(4)-legPos(4);
            end

            setpixelposition(leg,legPos);
        end
    end

end


function createLegendPositionListener(this)

    leg=this.Plotter.LegendHandle;
    if ishghandle(leg)
        listen=uiservices.addlistener(...
        leg,'Position','PostSet',@(h,ev)fixLegendPosition(this));
    else
        listen=[];
    end
    this.LegendPositionListener=listen;

end


function value=checkEnum(value,validValues,propName)

    indx=strncmpi(value,validValues,numel(value));
    if~any(indx)
        if numel(validValues)==2
            error(message('Spcuilib:scopes:InvalidEnumeration2',propName,validValues{:}));
        else
            error(message('Spcuilib:scopes:InvalidEnumeration3',propName,validValues{:}));
        end
    else
        value=validValues{indx};
    end

end



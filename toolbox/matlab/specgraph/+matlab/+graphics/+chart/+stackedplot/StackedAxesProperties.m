classdef(Sealed)StackedAxesProperties<matlab.mixin.SetGet&matlab.mixin.Copyable&...
    matlab.graphics.mixin.internal.GraphicsDataTypeContainer




    properties(Dependent)

        YLimits(1,2)=[0,1]%#ok<MDEPIN> 
        YScale matlab.internal.datatype.matlab.graphics.datatype.AxisScale='linear' %#ok<MDEPIN> 
LegendLabels
        LegendLocation matlab.internal.datatype.matlab.graphics.datatype.LegendInsideLocationType='northeast' %#ok<MDEPIN> 
        LegendVisible matlab.internal.datatype.matlab.graphics.datatype.on_off='off' %#ok<MDEPIN> 
        CollapseLegend matlab.internal.datatype.matlab.graphics.datatype.on_off='off' %#ok<MDEPIN>
    end

    properties(Hidden,AbortSet)
        YLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        LegendVisibleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        LegendLabelsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        CollapseLegendMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Access=?matlab.graphics.chart.StackedLineChart)
        YLimits_I(1,2)=[0,1]
        YScale_I matlab.internal.datatype.matlab.graphics.datatype.AxisScale='linear'
        LegendLocation_I matlab.internal.datatype.matlab.graphics.datatype.LegendInsideLocationType='northeast'
        LegendVisible_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off'
LegendLabels_I
        CollapseLegend_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off'
AxesIndex




CollapseLegendMapping
    end

    properties(Hidden,Access=?matlab.graphics.chart.StackedLineChart,...
        Transient,NonCopyable)
Axes
        Presenter matlab.graphics.chart.internal.stackedplot.Presenter
    end

    events
PropertiesChanged
    end

    methods(Access=protected)
        function cp=copyElement(obj)

            cp=copyElement@matlab.mixin.Copyable(obj);


            cp.YLimits_I=obj.YLimits;
            cp.YScale_I=obj.YScale;
            cp.LegendLocation_I=obj.LegendLocation;
            cp.LegendVisible_I=obj.LegendVisible;
            cp.LegendLabels_I=obj.LegendLabels;
        end
    end

    methods(Access=?matlab.graphics.chart.StackedLineChart)
        function cp=shallowCopyNoUpdate(obj)



            cp=matlab.graphics.chart.stackedplot.StackedAxesProperties.empty(0,1);
            for i=1:numel(obj)
                cp(i)=obj(i).shallowCopyElementNoUpdate();
            end
            if~isempty(cp)
                cp=reshape(cp,size(obj));
            end
        end

        function cp=shallowCopyElementNoUpdate(obj)



            cp=matlab.graphics.chart.stackedplot.StackedAxesProperties();
            cp.YLimits_I=obj.YLimits_I;
            cp.YScale_I=obj.YScale_I;
            cp.LegendLocation_I=obj.LegendLocation_I;
            cp.LegendVisible_I=obj.LegendVisible_I;
            cp.LegendLabels_I=obj.LegendLabels_I;
            cp.YLimitsMode=obj.YLimitsMode;
            cp.LegendVisibleMode=obj.LegendVisibleMode;
            cp.LegendLabelsMode=obj.LegendLabelsMode;
            cp.CollapseLegendMapping=obj.CollapseLegendMapping;
            cp.CollapseLegend_I=obj.CollapseLegend_I;
            cp.CollapseLegendMode=obj.CollapseLegendMode;
        end
    end

    methods
        function hAxesProps=StackedAxesProperties(varargin)
            if~isempty(varargin)
                set(hAxesProps,varargin{:});
            end
        end

        function yl=get.YLimits(hAxesProps)

            if hAxesProps.YLimitsMode=="auto"&&~isempty(hAxesProps.Presenter)
                hAxesProps.YLimits_I=hAxesProps.Presenter.getYLimits(hAxesProps.AxesIndex);
            end
            yl=hAxesProps.YLimits_I;
        end

        function set.YLimits(hAxesProps,yl)
            try
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hAxesProps.AxesIndex,'YLimits',hAxesProps.YLimits,yl);


                set(hAxesProps.Axes,'XLimMode','manual','YLim',yl);

                hAxesProps.YLimitsMode='manual';
                hAxesProps.YLimits_I=yl;
                notify(hAxesProps,'PropertiesChanged',eventdata);
            catch ME
                throwAsCaller(ME);
            end
        end

        function ys=get.YScale(hAxesProps)

            if~isempty(hAxesProps.Axes)&&isvalid(hAxesProps.Axes)&&...
                strcmp(hAxesProps.Axes.Visible,'on')
                hAxesProps.YScale_I=hAxesProps.Axes.YScale;
            end
            ys=hAxesProps.YScale_I;
        end

        function set.YScale(hAxesProps,ys)
            try
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hAxesProps.AxesIndex,'YScale',hAxesProps.YScale,ys);
                set(hAxesProps.Axes,'YScale',ys);
                hAxesProps.YScale_I=ys;
                notify(hAxesProps,'PropertiesChanged',eventdata);
            catch ME
                throwAsCaller(ME);
            end
        end

        function set.YLimitsMode(hAxesProps,ylm)
            hAxesProps.YLimitsMode=ylm;
            if~isempty(hAxesProps.Presenter)%#ok<MCSUP> 
                hAxesProps.YLimits_I=hAxesProps.Presenter.getYLimits(hAxesProps.AxesIndex);%#ok<MCSUP> 
            end
            if ylm=="auto"
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hAxesProps.AxesIndex,'YLimitsMode','manual','auto');%#ok<MCSUP>
                notify(hAxesProps,'PropertiesChanged',eventdata);
            end
        end

        function leglabels=get.LegendLabels(hAxesProps)
            leglabels=hAxesProps.LegendLabels_I;
        end

        function set.LegendLabels(hAxesProps,leglabels)
            try
                if~iscellstr(leglabels)&&~isstring(leglabels)
                    error(message('MATLAB:stackedplot:LegendLabelsInvalidType'));
                end
                if~isempty(hAxesProps.Presenter)&&...
                    (~isvector(leglabels)||(length(leglabels)~=hAxesProps.getNumPlotsInAxes()&&...
                    length(leglabels)~=length(hAxesProps.LegendLabels_I)))
                    error(message('MATLAB:stackedplot:LegendLabelsInvalidSize'));
                end
                leglabels=cellstr(reshape(leglabels,1,[]));
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hAxesProps.AxesIndex,'LegendLabels',hAxesProps.LegendLabels,leglabels);
                hAxesProps.LegendLabels_I=leglabels;
                hAxesProps.LegendLabelsMode='manual';
                notify(hAxesProps,'PropertiesChanged',eventdata);
            catch ME
                throwAsCaller(ME);
            end
        end

        function set.LegendLabelsMode(hAxesProps,leglabelsmode)
            hAxesProps.LegendLabelsMode=leglabelsmode;
            if strcmp(leglabelsmode,'auto')
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hAxesProps.AxesIndex,'LegendLabelsMode','manual','auto');%#ok<MCSUP>
                notify(hAxesProps,'PropertiesChanged',eventdata);
            end
        end

        function legloc=get.LegendLocation(hAxesProps)
            legloc=hAxesProps.LegendLocation_I;
        end

        function set.LegendLocation(hAxesProps,legloc)
            try
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hAxesProps.AxesIndex,'LegendLocation',hAxesProps.LegendLocation,legloc);
                hAxesProps.LegendLocation_I=legloc;
                notify(hAxesProps,'PropertiesChanged',eventdata);
            catch ME
                throwAsCaller(ME);
            end
        end

        function legvis=get.LegendVisible(hAxesProps)
            legvis=hAxesProps.LegendVisible_I;
        end

        function set.LegendVisible(hAxesProps,legvis)
            try
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hAxesProps.AxesIndex,'LegendVisible',hAxesProps.LegendVisible,legvis);
                hAxesProps.LegendVisible_I=legvis;
                hAxesProps.LegendVisibleMode='manual';
                notify(hAxesProps,'PropertiesChanged',eventdata);
            catch ME
                throwAsCaller(ME);
            end
        end

        function set.LegendVisibleMode(hAxesProps,legvismode)
            hAxesProps.LegendVisibleMode=legvismode;
            if strcmp(legvismode,'auto')
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hAxesProps.AxesIndex,'LegendVisibleMode','manual','auto');%#ok<MCSUP>
                notify(hAxesProps,'PropertiesChanged',eventdata);
            end
        end

        function cl=get.CollapseLegend(hAxesProps)
            cl=hAxesProps.CollapseLegend_I;
        end

        function set.CollapseLegend(hAxesProps,cl)
            try
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hAxesProps.AxesIndex,'CollapseLegend',hAxesProps.CollapseLegend_I,cl);
                hAxesProps.CollapseLegend_I=cl;
                hAxesProps.CollapseLegendMode='manual';
                notify(hAxesProps,'PropertiesChanged',eventdata);
            catch ME
                throwAsCaller(ME);
            end
        end

        function set.CollapseLegendMode(hAxesProps,mode)
            hAxesProps.CollapseLegendMode=mode;
            if mode=="auto"
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hAxesProps.AxesIndex,'CollapseLegendMode','manual','auto');%#ok<MCSUP>
                notify(hAxesProps,'PropertiesChanged',eventdata);
            end
        end

        function set.Axes(hAxesProps,ax)
            hAxesProps.Axes=ax;

            if strcmp(hAxesProps.YLimitsMode,'manual')
                autoylim=ax.YAxis.Limits_I;
                manualylim=hAxesProps.YLimits_I;
                if(isnumeric(autoylim)&&isnumeric(manualylim))||...
                    isequal(class(autoylim),class(manualylim))
                    ax.YAxis.Limits=manualylim;
                else


                    hAxesProps.YLimitsMode='auto';
                end
            end

            suppliedyscale=ax.YScale;
            existingyscale=hAxesProps.YScale_I;
            if isequal(class(suppliedyscale),class(existingyscale))
                ax.YScale=existingyscale;
            end





            createPostSetListenersForAxesTitleAndLabels(hAxesProps,ax);
        end

        function createPostSetListenersForAxesTitleAndLabels(hAxesProps,ax)
            addlistener(ax.YLabel,'String','PostSet',...
            @(~,~)notifyAxesYLabelChanged(hAxesProps,ax));

            addlistener(ax.XLabel,'String','PostSet',...
            @(~,~)notifyAxesXLabelChanged(hAxesProps,ax));

            addlistener(ax.Title,'String','PostSet',...
            @(~,~)notifyAxesTitleChanged(hAxesProps,ax));
        end

        function notifyAxesYLabelChanged(hAxesProps,ax)
            eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
            hAxesProps.AxesIndex,'YLabel','',ax.YLabel.String_I);
            notify(hAxesProps,'PropertiesChanged',eventdata);
        end

        function notifyAxesXLabelChanged(hAxesProps,ax)
            eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
            hAxesProps.AxesIndex,'XLabel','',ax.XLabel.String_I);
            notify(hAxesProps,'PropertiesChanged',eventdata);
        end

        function notifyAxesTitleChanged(hAxesProps,ax)
            eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
            hAxesProps.AxesIndex,'Title','',ax.Title.String_I);
            notify(hAxesProps,'PropertiesChanged',eventdata);
        end

    end

    methods(Access=?matlab.graphics.chart.StackedLineChart)
        function validate(hAxesProps)

            if~isempty(hAxesProps.Presenter)&&strcmp(hAxesProps.LegendLabelsMode,'manual')&&...
                length(hAxesProps.LegendLabels)~=hAxesProps.getNumPlotsInAxes()
                error(message('MATLAB:stackedplot:LegendLabelsInvalidSize'));
            end
        end
    end

    methods(Access=private)
        function numPlots=getNumPlotsInAxes(hAxesProps)


            yData=hAxesProps.Presenter.getAxesYData(hAxesProps.AxesIndex);
            numPlots=0;
            for i=1:length(yData)
                numPlots=numPlots+size(yData{i}(:,:),2);
            end
        end
    end

    methods(Hidden)
        function hAxesProps=saveobj(hAxesProps)

            hAxesProps.YLimits_I=hAxesProps.YLimits;
            hAxesProps.YScale_I=hAxesProps.YScale;
        end
    end
end

classdef(Sealed)StackedLineProperties<matlab.mixin.SetGet&matlab.mixin.Copyable&...
    matlab.graphics.mixin.internal.GraphicsDataTypeContainer




    properties(Dependent)
        Color matlab.internal.datatype.matlab.graphics.datatype.RGBMatrixNoneColor=[0,0.447,0.741]
        MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBMatrixNoneColor='none'
        MarkerEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBMatrixNoneColor=[0,0.447,0.741]
        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyleArray='-'
        LineWidth matlab.internal.datatype.matlab.graphics.datatype.PositiveVectorData=0.5
        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyleArray='none'
        MarkerSize matlab.internal.datatype.matlab.graphics.datatype.PositiveVectorData=6
        PlotType matlab.internal.datatype.matlab.graphics.datatype.StackedPlotType='plot'
    end

    properties(Hidden,AbortSet)
        ColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        MarkerEdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'


        MarkerFaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='manual'
        LineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Hidden,Access=?matlab.graphics.chart.StackedLineChart)
AxesIndex

        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBMatrixNoneColor=[0,0.447,0.741]
        MarkerFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBMatrixNoneColor='none'
        MarkerEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBMatrixNoneColor=[0,0.447,0.741]
        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyleArray='-'
        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.PositiveVectorData=0.5
        Marker_I matlab.internal.datatype.matlab.graphics.datatype.MarkerStyleArray='none'
        MarkerSize_I matlab.internal.datatype.matlab.graphics.datatype.PositiveVectorData=6
        PlotType_I matlab.internal.datatype.matlab.graphics.datatype.StackedPlotType='plot'
        NumPlots(1,1)double=1
    end

    events
PropertiesChanged
    end

    methods
        function hLineProps=StackedLineProperties(varargin)
            if~isempty(varargin)
                set(hLineProps,varargin{:});
            end
        end

        function c=get.Color(hLineProps)
            c=hLineProps.Color_I;
        end

        function set.Color(hLineProps,c)
            try
                if isnumeric(c)
                    if size(c,1)~=1&&size(c,1)~=hLineProps.NumPlots
                        error(message('MATLAB:stackedplot:InvalidColorMatrix'));
                    end
                end

                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hLineProps.AxesIndex,'Color',hLineProps.Color_I,c);
                hLineProps.Color_I=c;
                hLineProps.ColorMode='manual';
                notify(hLineProps,'PropertiesChanged',eventdata);
            catch ME
                throwAsCaller(ME);
            end
        end

        function set.ColorMode(hLineProps,cm)
            hLineProps.ColorMode=cm;

            if strcmp(cm,'auto')
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hLineProps.AxesIndex,'ColorMode','manual','auto');%#ok<MCSUP>
                notify(hLineProps,'PropertiesChanged',eventdata);
            end
        end

        function c=get.MarkerFaceColor(hLineProps)
            c=hLineProps.MarkerFaceColor_I;
        end

        function set.MarkerFaceColor(hLineProps,c)
            try
                if isnumeric(c)
                    if size(c,1)~=1&&size(c,1)~=hLineProps.NumPlots
                        error(message('MATLAB:stackedplot:InvalidMarkerFaceColorMatrix'));
                    end
                end
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hLineProps.AxesIndex,'MarkerFaceColor',hLineProps.MarkerFaceColor_I,c);
                hLineProps.MarkerFaceColor_I=c;
                hLineProps.MarkerFaceColorMode='manual';
                notify(hLineProps,'PropertiesChanged',eventdata);
            catch ME
                throwAsCaller(ME);
            end
        end

        function set.MarkerFaceColorMode(hLineProps,cm)
            hLineProps.MarkerFaceColorMode=cm;

            if strcmp(cm,'auto')
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hLineProps.AxesIndex,'MarkerFaceColorMode','manual','auto');%#ok<MCSUP>
                notify(hLineProps,'PropertiesChanged',eventdata);
            end
        end

        function c=get.MarkerEdgeColor(hLineProps)
            c=hLineProps.MarkerEdgeColor_I;
        end

        function set.MarkerEdgeColor(hLineProps,c)
            try
                if isnumeric(c)
                    if size(c,1)~=1&&size(c,1)~=hLineProps.NumPlots
                        error(message('MATLAB:stackedplot:InvalidMarkerEdgeColorMatrix'));
                    end
                end
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hLineProps.AxesIndex,'MarkerEdgeColor',hLineProps.MarkerEdgeColor_I,c);
                hLineProps.MarkerEdgeColor_I=c;
                hLineProps.MarkerEdgeColorMode='manual';
                notify(hLineProps,'PropertiesChanged',eventdata);
            catch ME
                throwAsCaller(ME);
            end
        end

        function set.MarkerEdgeColorMode(hLineProps,mecm)
            hLineProps.MarkerEdgeColorMode=mecm;

            if strcmp(mecm,'auto')
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hLineProps.AxesIndex,'MarkerEdgeColorMode','manual','auto');%#ok<MCSUP>
                notify(hLineProps,'PropertiesChanged',eventdata);
            end
        end

        function ls=get.LineStyle(hLineProps)
            ls=hLineProps.LineStyle_I;
        end

        function set.LineStyle(hLineProps,ls)
            try
                if iscell(ls)
                    if length(ls)~=hLineProps.NumPlots
                        error(message('MATLAB:stackedplot:InvalidLineStyleArray'));
                    end
                    ls=reshape(ls,1,[]);
                end
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hLineProps.AxesIndex,'LineStyle',hLineProps.LineStyle_I,ls);
                hLineProps.LineStyle_I=ls;
                hLineProps.LineStyleMode='manual';
                notify(hLineProps,'PropertiesChanged',eventdata);
            catch ME
                throwAsCaller(ME);
            end
        end

        function set.LineStyleMode(hLineProps,lm)
            hLineProps.LineStyleMode=lm;

            if lm=="auto"
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hLineProps.AxesIndex,'LineStyleMode','manual','auto');%#ok<MCSUP>
                notify(hLineProps,'PropertiesChanged',eventdata);
            end
        end

        function lw=get.LineWidth(hLineProps)
            lw=hLineProps.LineWidth_I;
        end

        function set.LineWidth(hLineProps,lw)
            try
                if~isscalar(lw)
                    if length(lw)~=hLineProps.NumPlots
                        error(message('MATLAB:stackedplot:InvalidLineWidthArray'));
                    end
                end
                lw=reshape(lw,1,[]);
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hLineProps.AxesIndex,'LineWidth',hLineProps.LineWidth_I,lw);
                hLineProps.LineWidth_I=lw;
                notify(hLineProps,'PropertiesChanged',eventdata);
            catch ME
                throwAsCaller(ME);
            end
        end

        function ms=get.Marker(hLineProps)
            ms=hLineProps.Marker_I;
        end

        function set.Marker(hLineProps,ms)
            try
                if iscell(ms)
                    if length(ms)~=hLineProps.NumPlots
                        error(message('MATLAB:stackedplot:InvalidMarkerStyleArray'));
                    end
                    ms=reshape(ms,1,[]);
                end
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hLineProps.AxesIndex,'Marker',hLineProps.Marker_I,ms);
                hLineProps.Marker_I=ms;
                notify(hLineProps,'PropertiesChanged',eventdata);
            catch ME
                throwAsCaller(ME);
            end
        end

        function ms=get.MarkerSize(hLineProps)
            ms=hLineProps.MarkerSize_I;
        end

        function set.MarkerSize(hLineProps,ms)
            try
                if~isscalar(ms)
                    if length(ms)~=hLineProps.NumPlots
                        error(message('MATLAB:stackedplot:InvalidMarkerSizeArray'));
                    end
                end
                ms=reshape(ms,1,[]);
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hLineProps.AxesIndex,'MarkerSize',hLineProps.MarkerSize_I,ms);
                hLineProps.MarkerSize_I=ms;
                notify(hLineProps,'PropertiesChanged',eventdata);
            catch ME
                throwAsCaller(ME);
            end
        end

        function pt=get.PlotType(hLineProps)
            pt=hLineProps.PlotType_I;
        end

        function set.PlotType(hLineProps,pt)
            try
                if iscell(pt)
                    if length(pt)~=hLineProps.NumPlots
                        error(message('MATLAB:stackedplot:InvalidPlotTypeArray'));
                    end
                    pt=reshape(pt,1,[]);
                end
                eventdata=matlab.graphics.chart.stackedplot.PropertiesEventData(...
                hLineProps.AxesIndex,'PlotType',hLineProps.PlotType_I,pt);
                hLineProps.PlotType_I=pt;
                notify(hLineProps,'PropertiesChanged',eventdata);
            catch ME
                throwAsCaller(ME);
            end
        end
    end

    methods(Access=?matlab.graphics.chart.StackedLineChart)
        function validate(hLineProps)

            numplots=hLineProps.NumPlots;
            c=hLineProps.Color_I;
            if isnumeric(c)&&size(c,1)~=1&&size(c,1)~=numplots
                error(message('MATLAB:stackedplot:InvalidColorMatrix'));
            end
            mfc=hLineProps.MarkerFaceColor_I;
            if isnumeric(mfc)&&size(mfc,1)~=1&&size(mfc,1)~=numplots
                error(message('MATLAB:stackedplot:InvalidMarkerFaceColorMatrix'));
            end
            mec=hLineProps.MarkerEdgeColor_I;
            if isnumeric(mec)&&size(mec,1)~=1&&size(mec,1)~=numplots
                error(message('MATLAB:stackedplot:InvalidMarkerEdgeColorMatrix'));
            end
            ls=hLineProps.LineStyle_I;
            if iscell(ls)&&length(ls)~=numplots
                error(message('MATLAB:stackedplot:InvalidLineStyleArray'));
            end
            lw=hLineProps.LineWidth_I;
            if~isscalar(lw)&&length(lw)~=numplots
                error(message('MATLAB:stackedplot:InvalidLineWidthArray'));
            end
            m=hLineProps.Marker_I;
            if iscell(m)&&length(m)~=numplots
                error(message('MATLAB:stackedplot:InvalidMarkerStyleArray'));
            end
            ms=hLineProps.MarkerSize_I;
            if~isscalar(ms)&&length(ms)~=hLineProps.NumPlots
                error(message('MATLAB:stackedplot:InvalidMarkerSizeArray'));
            end
            pt=hLineProps.PlotType_I;
            if iscell(pt)&&length(pt)~=hLineProps.NumPlots
                error(message('MATLAB:stackedplot:InvalidPlotTypeArray'));
            end
        end
    end
end

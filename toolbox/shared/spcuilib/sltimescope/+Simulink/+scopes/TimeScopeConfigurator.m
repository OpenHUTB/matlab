classdef TimeScopeConfigurator<handle&matlab.mixin.CustomDisplay







    properties

        NumInputPorts;
    end

    properties(Dependent)

        Name;

        Position;

        OpenAtSimulationStart;

        Visible;

        MaximizeAxes;

        MinimizeControls;

        AxesScaling;

        AxesScalingNumUpdates;

        TimeSpan;

        TimeSpanOverrunAction;

        TimeUnits;

        TimeDisplayOffset;

        TimeAxisLabels;

        ShowTimeAxisLabel;

        LayoutDimensions;

        DataLogging;

        DataLoggingVariableName;

        DataLoggingSaveFormat;

        DataLoggingLimitDataPoints;

        DataLoggingMaxPoints;

        DataLoggingDecimateData;

        DataLoggingDecimation;

        ActiveDisplay;

        Title;

        ShowLegend;

        ShowGrid;

        PlotAsMagnitudePhase;

        YLimits;

        YLabel;

        SampleTime;

        FrameBasedProcessing;

        ReduceUpdates;

        DisplayFullPath;

        PreserveColorsForCopyToClipboard;
    end


    properties(Hidden,Dependent)
        Location;
        Open;
        TickLabels;
        TimeRange;
        LimitDataPoints;
        MaxDataPoints;
        SaveToWorkspace;
        SaveName;
        DataFormat;
        Decimation;
        ScopeGraphics;
        ShowLegends;
        LimitMaxRows;
        MaxRows;
        ResolvedAxesTitles;
        BlockParamSampleInput;
        BlockParamSampleTime;
        ScrollMode;

        IsSourceVectorScope;
        HorizSpan;
        AxisGrid;
        AxisLegend;
        AxisZoom;
        OpenScopeAtSimStart;
        FigPos;
        InheritXIncr;
        XIncr;
        LineMarkers;
        LineStyles;
    end

    properties(Hidden,Dependent)


        FrameBasedProcessingString;




        ActiveDisplayYMinimum;
        ActiveDisplayYMaximum;


        LayoutDimensionsString;
        ActiveDisplayString;

        ZoomMode;
        Grid;
        YMin;
        YMax;
        AxesTitles;

        SampleInput;
        ShowDataMarkers;
    end


    properties(Hidden)

        BufferLength='5000';
    end

    properties(Hidden)




        DataFormatSet=false;
        LimitDataPointsSet=false;
        DecimationSet=false;

        UsePreviousFormat=false;
        isDST=false;
        VectorScopeLegacyMode=false;
    end

    properties(Hidden)
        BlockHandle;
    end

    properties(Constant,Hidden)
        DefaultScopeGraphics=struct('FigureColor','[0.5 0.5 0.5]',...
        'AxesColor','[0 0 0]','AxesTickColor','[1 1 1]',...
        'LineColors','[1 1 0;1 0 1;0 1 1;1 0 0;0 1 0;0 0 1]',...
        'LineStyles','-|-|-|-|-|-','LineWidths','[0.5 0.5 0.5 0.5 0.5 0.5]',...
        'MarkerStyles','none|none|none|none|none|none');
        ScopeDisplayProperties={'Name','Position','Visible','ReduceUpdates',...
        'OpenAtSimulationStart','DisplayFullPath','PreserveColorsForCopyToClipboard','NumInputPorts','LayoutDimensions','SampleTime','FrameBasedProcessing',...
        'MaximizeAxes','MinimizeControls','AxesScaling','AxesScalingNumUpdates','TimeSpan','TimeSpanOverrunAction',...
        'TimeUnits','TimeDisplayOffset','TimeAxisLabels','ShowTimeAxisLabel','ActiveDisplay',...
        'Title','ShowLegend','ShowGrid','PlotAsMagnitudePhase','YLimits','YLabel','DataLogging',...
        'DataLoggingVariableName','DataLoggingLimitDataPoints','DataLoggingMaxPoints',...
        'DataLoggingDecimateData','DataLoggingDecimation','DataLoggingSaveFormat'};




        FloatingScopeExclusions={'NumInputPorts','SampleTime','DataLogging','DataLoggingVariableName',...
        'DataLoggingSaveFormat'};




        ScopeViewerExclusions={'NumInputPorts','SampleTime','DataLogging','DataLoggingVariableName',...
        'DataLoggingSaveFormat','DisplayFullPath'};





        LockedLibraryExclusions={'LayoutDimensions','ActiveDisplay','Title','ShowLegend','ShowGrid',...
        'PlotAsMagnitudePhase','YLimits','YLabel'};

        SimulinkScopeExclusions={'ReduceUpdates'};

        SimulinkFloatingScopeExclusions={'NumInputPorts','SampleTime','DataLogging','DataLoggingVariableName',...
        'DataLoggingSaveFormat','ReduceUpdates'};

        SimulinkViewerExclusions={'NumInputPorts','SampleTime','DataLogging','DataLoggingVariableName',...
        'DataLoggingSaveFormat','DisplayFullPath','ReduceUpdates'};



        ScopeLockedLibraryDisplayProperties=setdiff(...
        Simulink.scopes.TimeScopeConfigurator.ScopeDisplayProperties,...
        Simulink.scopes.TimeScopeConfigurator.LockedLibraryExclusions,'stable');

        FloatingScopeDisplayProperties=setdiff(...
        Simulink.scopes.TimeScopeConfigurator.ScopeDisplayProperties,...
        Simulink.scopes.TimeScopeConfigurator.FloatingScopeExclusions,'stable');

        FloatingScopeLockedLibraryDisplayProperties=setdiff(...
        Simulink.scopes.TimeScopeConfigurator.ScopeDisplayProperties,...
        union(Simulink.scopes.TimeScopeConfigurator.FloatingScopeExclusions,...
        Simulink.scopes.TimeScopeConfigurator.LockedLibraryExclusions),'stable');

        ScopeViewerDisplayProperties=setdiff(...
        Simulink.scopes.TimeScopeConfigurator.ScopeDisplayProperties,...
        Simulink.scopes.TimeScopeConfigurator.ScopeViewerExclusions,'stable');

        ScopeViewerLockedLibraryDisplayProperties=setdiff(...
        Simulink.scopes.TimeScopeConfigurator.ScopeDisplayProperties,...
        union(Simulink.scopes.TimeScopeConfigurator.ScopeViewerExclusions,...
        Simulink.scopes.TimeScopeConfigurator.LockedLibraryExclusions),'stable');

        SimulinkScopeDisplayProperties=setdiff(...
        Simulink.scopes.TimeScopeConfigurator.ScopeDisplayProperties,...
        Simulink.scopes.TimeScopeConfigurator.SimulinkScopeExclusions,'stable');

        SimulinkScopeLockedLibraryDisplayProperties=setdiff(...
        Simulink.scopes.TimeScopeConfigurator.SimulinkScopeDisplayProperties,...
        Simulink.scopes.TimeScopeConfigurator.LockedLibraryExclusions,'stable');


        SimulinkFloatingScopeDisplayProperties=setdiff(...
        Simulink.scopes.TimeScopeConfigurator.SimulinkScopeDisplayProperties,...
        Simulink.scopes.TimeScopeConfigurator.SimulinkFloatingScopeExclusions,'stable');

        SimulinkFloatingScopeLockedLibraryDisplayProperties=setdiff(...
        Simulink.scopes.TimeScopeConfigurator.SimulinkScopeDisplayProperties,...
        union(Simulink.scopes.TimeScopeConfigurator.SimulinkFloatingScopeExclusions,...
        Simulink.scopes.TimeScopeConfigurator.LockedLibraryExclusions),'stable');

        SimulinkScopeViewerDisplayProperties=setdiff(...
        Simulink.scopes.TimeScopeConfigurator.SimulinkScopeDisplayProperties,...
        Simulink.scopes.TimeScopeConfigurator.SimulinkViewerExclusions,'stable');

        SimulinkScopeViewerLockedLibraryDisplayProperties=setdiff(...
        Simulink.scopes.TimeScopeConfigurator.SimulinkScopeDisplayProperties,...
        union(Simulink.scopes.TimeScopeConfigurator.SimulinkViewerExclusions,...
        Simulink.scopes.TimeScopeConfigurator.LockedLibraryExclusions),'stable');

        LogicalProperties=getLogicalProperties;
    end

    methods(Hidden)

        function value=convertLogicalToString(~,value)
            if islogical(value)
                if value
                    value='on';
                else
                    value='off';
                end
            end
        end


        function value=convertStringToLogical(~,value)
            if isequal(lower(value),'on')
                value=true;
            else
                value=false;
            end
        end
    end

    methods
        function this=TimeScopeConfigurator(blkHandle)


            this.BlockHandle=blkHandle;
            defautlConfigName=get_param(blkHandle,'DefaultConfigurationName');
            this.isDST=strcmp(defautlConfigName,'spbscopes.TimeScopeBlockCfg');
        end


        function set.Name(this,value)
            set_param(this.BlockHandle,'Name',value);
        end

        function value=get.Name(this)
            value=get_param(this.BlockHandle,'Name');
        end


        function set.Position(this,value)
            set_param(this.BlockHandle,'WindowPosition',num2str(value));
        end

        function value=get.Position(this)
            value=str2num(get_param(this.BlockHandle,'WindowPosition'));
        end


        function set.OpenAtSimulationStart(this,value)
            set_param(this.BlockHandle,'OpenAtSimulationStart',this.convertLogicalToString(value));
        end

        function value=get.OpenAtSimulationStart(this)
            value=this.convertStringToLogical(get_param(this.BlockHandle,'OpenAtSimulationStart'));
        end


        function set.Visible(this,value)
            set_param(this.BlockHandle,'Visible',this.convertLogicalToString(value));
        end

        function value=get.Visible(this)
            value=this.convertStringToLogical(get_param(this.BlockHandle,'Visible'));
        end

        function set.DisplayFullPath(this,value)
            value=this.convertLogicalToString(value);
            set_param(this.BlockHandle,"DisplayFullPath",value);
        end

        function value=get.DisplayFullPath(this)
            value=get_param(this.BlockHandle,"DisplayFullPath");
            value=this.convertStringToLogical(value);
        end


        function set.PreserveColorsForCopyToClipboard(this,value)



















        end

        function value=get.PreserveColorsForCopyToClipboard(this)


            value='off';
        end


        function set.NumInputPorts(this,value)















            set_param(this.BlockHandle,'NumInputPorts',value);
        end

        function value=get.NumInputPorts(this)
            value=get_param(this.BlockHandle,'NumInputPorts');
        end


        function set.TimeSpan(this,value)
            set_param(this.BlockHandle,'TimeSpan',value);
        end

        function value=get.TimeSpan(this)
            value=get_param(this.BlockHandle,'TimeSpan');
        end


        function set.TimeDisplayOffset(this,value)
            set_param(this.BlockHandle,'TimeDisplayOffset',value);
        end

        function value=get.TimeDisplayOffset(this)
            value=get_param(this.BlockHandle,'TimeDisplayOffset');
        end


        function set.TimeUnits(this,value)
            set_param(this.BlockHandle,'TimeUnits',value);
        end

        function value=get.TimeUnits(this)
            value=get_param(this.BlockHandle,'TimeUnits');
            if isequal(value,'Metric (based on Time Span)')
                value='Metric';
            end
        end


        function set.TimeSpanOverrunAction(this,value)
            set_param(this.BlockHandle,'TimeSpanOverrunAction',value);
        end

        function value=get.TimeSpanOverrunAction(this)
            value=get_param(this.BlockHandle,'TimeSpanOverrunAction');
        end


        function set.TimeAxisLabels(this,value)
            set_param(this.BlockHandle,'TimeAxisLabels',value);
        end

        function value=get.TimeAxisLabels(this)
            value=get_param(this.BlockHandle,'TimeAxisLabels');
            if isequal(value,'Bottom displays only')
                value='Bottom';
            end
        end


        function set.ShowTimeAxisLabel(this,value)
            value=this.convertLogicalToString(value);
            set_param(this.BlockHandle,'ShowTimeAxisLabel',value);
        end

        function value=get.ShowTimeAxisLabel(this)
            value=get_param(this.BlockHandle,'ShowTimeAxisLabel');
            value=this.convertStringToLogical(value);
        end


        function set.MaximizeAxes(this,value)
            if islogical(value)
                value=this.convertLogicalToString(value);
            end
            set_param(this.BlockHandle,'MaximizeAxes',value);
        end

        function value=get.MaximizeAxes(this)
            value=get_param(this.BlockHandle,'MaximizeAxes');
        end


        function set.AxesScaling(this,value)
            set_param(this.BlockHandle,'AxesScaling',value);
        end

        function value=get.AxesScaling(this)
            value=get_param(this.BlockHandle,'AxesScaling');
        end


        function set.AxesScalingNumUpdates(this,value)
            set_param(this.BlockHandle,'AxesScalingNumUpdates',value);
        end

        function value=get.AxesScalingNumUpdates(this)
            value=get_param(this.BlockHandle,'AxesScalingNumUpdates');
        end


        function set.BufferLength(this,value)

            this.BufferLength=value;
        end

        function value=get.BufferLength(this)
            value=this.BufferLength;
        end


        function set.LayoutDimensions(this,value)

            pVal=['[',num2str(value(1)),',',num2str(value(2)),']'];
            set_param(this.BlockHandle,'LayoutDimensionsString',pVal);
        end

        function value=get.LayoutDimensions(this)
            value=str2num(get_param(this.BlockHandle,'LayoutDimensionsString'));
        end

        function set.LayoutDimensionsString(this,value)
            set_param(this.BlockHandle,'LayoutDimensionsString',value);
        end

        function value=get.LayoutDimensionsString(this)
            value=get_param(this.BlockHandle,'LayoutDimensionsString');
        end



        function set.MinimizeControls(~,~)

        end

        function value=get.MinimizeControls(~)

            value=false;
        end


        function set.ActiveDisplay(this,value)
            this.ActiveDisplayString=num2str(value);
        end

        function set.ActiveDisplayString(this,value)
            set_param(this.BlockHandle,'ActiveDisplayString',value);
        end

        function value=get.ActiveDisplay(this)
            value=str2num(this.ActiveDisplayString);
        end

        function value=get.ActiveDisplayString(this)
            value=get_param(this.BlockHandle,'ActiveDisplayString');
        end


        function set.PlotAsMagnitudePhase(this,value)
            value=this.convertLogicalToString(value);
            set_param(this.BlockHandle,'PlotAsMagnitudePhase',value);
        end

        function value=get.PlotAsMagnitudePhase(this)
            value=get_param(this.BlockHandle,'PlotAsMagnitudePhase');
            value=this.convertStringToLogical(value);
        end


        function set.YLimits(this,yLimits)

            this.ActiveDisplayYMinimum=yLimits(1);
            this.ActiveDisplayYMaximum=yLimits(2);
        end

        function value=get.YLimits(this)
            value=[str2num(this.ActiveDisplayYMinimum),str2num(this.ActiveDisplayYMaximum)];
        end


        function set.ActiveDisplayYMinimum(this,yMinIn)
            set_param(this.BlockHandle,'ActiveDisplayYMinimum',num2str(yMinIn));
        end

        function yMin=get.ActiveDisplayYMinimum(this)
            yMin=get_param(this.BlockHandle,'ActiveDisplayYMinimum');
        end


        function set.ActiveDisplayYMaximum(this,yMaxIn)
            set_param(this.BlockHandle,'ActiveDisplayYMaximum',num2str(yMaxIn));
        end

        function yMax=get.ActiveDisplayYMaximum(this)
            yMax=get_param(this.BlockHandle,'ActiveDisplayYMaximum');
        end


        function set.YLabel(this,value)
            set_param(this.BlockHandle,'YLabel',value);
        end

        function value=get.YLabel(this)
            value=get_param(this.BlockHandle,'YLabel');
        end


        function set.Title(this,value)

            set_param(this.BlockHandle,'Title',value);
        end

        function value=get.Title(this)
            value=get_param(this.BlockHandle,'Title');
        end


        function set.ShowGrid(this,value)
            value=this.convertLogicalToString(value);
            set_param(this.BlockHandle,'ShowGrid',value);
        end

        function value=get.ShowGrid(this)
            value=get_param(this.BlockHandle,'ShowGrid');
            value=this.convertStringToLogical(value);
        end


        function set.ShowLegend(this,value)
            value=this.convertLogicalToString(value);
            set_param(this.BlockHandle,'ShowLegend',value);
        end

        function value=get.ShowLegend(this)
            value=get_param(this.BlockHandle,'ShowLegend');
            value=this.convertStringToLogical(value);
        end


        function set.DataLogging(this,value)
            value=this.convertLogicalToString(value);
            set_param(this.BlockHandle,'DataLogging',value);
        end

        function value=get.DataLogging(this)
            value=get_param(this.BlockHandle,'DataLogging');
            value=this.convertStringToLogical(value);
        end


        function set.DataLoggingVariableName(this,value)
            set_param(this.BlockHandle,'DataLoggingVariableName',value);
        end

        function value=get.DataLoggingVariableName(this)
            value=get_param(this.BlockHandle,'DataLoggingVariableName');
        end


        function set.DataLoggingSaveFormat(this,value)
            if(isequal(lower(value),'structurewithtime'))
                value='Structure With Time';
            end
            set_param(this.BlockHandle,'DataLoggingSaveFormat',value);
        end

        function value=get.DataLoggingSaveFormat(this)
            value=get_param(this.BlockHandle,'DataLoggingSaveFormat');
            if isequal(value,'Structure With Time')
                value='StructureWithTime';
            end
        end


        function set.DataLoggingLimitDataPoints(this,value)
            value=this.convertLogicalToString(value);
            set_param(this.BlockHandle,'DataLoggingLimitDataPoints',value);
        end

        function value=get.DataLoggingLimitDataPoints(this)
            value=get_param(this.BlockHandle,'DataLoggingLimitDataPoints');
            value=this.convertStringToLogical(value);
        end


        function set.DataLoggingMaxPoints(this,value)
            set_param(this.BlockHandle,'DataLoggingMaxPoints',value);
        end

        function value=get.DataLoggingMaxPoints(this)
            value=get_param(this.BlockHandle,'DataLoggingMaxPoints');
        end


        function set.DataLoggingDecimateData(this,value)
            value=this.convertLogicalToString(value);
            set_param(this.BlockHandle,'DataLoggingDecimateData',value);
        end

        function value=get.DataLoggingDecimateData(this)
            value=get_param(this.BlockHandle,'DataLoggingDecimateData');
            value=this.convertStringToLogical(value);
        end


        function set.DataLoggingDecimation(this,value)
            set_param(this.BlockHandle,'DataLoggingDecimation',value);
        end

        function value=get.DataLoggingDecimation(this)
            value=get_param(this.BlockHandle,'DataLoggingDecimation');
        end


        function set.FrameBasedProcessing(this,value)
            value=this.convertLogicalToString(value);
            set_param(this.BlockHandle,'FrameBasedProcessing',value);
        end

        function value=get.FrameBasedProcessing(this)
            value=get_param(this.BlockHandle,'FrameBasedProcessing');
            value=this.convertStringToLogical(value);
        end



        function set.FrameBasedProcessingString(this,value)
            set_param(this.BlockHandle,'FrameBasedProcessingString',value);
        end

        function value=get.FrameBasedProcessingString(this)
            value=get_param(this.BlockHandle,'FrameBasedProcessingString');
        end


        function set.SampleTime(this,value)
            set_param(this.BlockHandle,'SampleTime',value);
        end

        function value=get.SampleTime(this)
            value=get_param(this.BlockHandle,'SampleTime');
        end
    end


    methods

        function set.Location(this,value)
            set_param(this.BlockHandle,'Location',value);
        end

        function value=get.Location(this)
            value=get_param(this.BlockHandle,'Location');
        end


        function set.Open(this,value)
            value=this.convertLogicalToString(value);
            set_param(this.BlockHandle,'Open',value);
        end

        function value=get.Open(this)
            value=get_param(this.BlockHandle,'Open');
            value=this.convertStringToLogical(value);
        end



        function set.TickLabels(this,value)
            set_param(this.BlockHandle,'TickLabels',value);
        end

        function value=get.TickLabels(this)
            value=get_param(this.BlockHandle,'TickLabels');
        end


        function set.ZoomMode(this,value)
            set_param(this.BlockHandle,'ZoomMode',value);
        end

        function value=get.ZoomMode(this)
            value=get_param(this.BlockHandle,'ZoomMode');
        end


        function set.Grid(this,value)
            set_param(this.BlockHandle,'Grid',value);
        end

        function value=get.Grid(this)
            value=get_param(this.BlockHandle,'Grid');
        end


        function set.TimeRange(this,value)
            set_param(this.BlockHandle,'TimeRange',value);
        end

        function value=get.TimeRange(this)
            value=get_param(this.BlockHandle,'TimeRange');
        end


        function set.YMin(this,value)
            set_param(this.BlockHandle,'YMin',value);
        end

        function value=get.YMin(this)
            value=get_param(this.BlockHandle,'YMin');
        end


        function set.YMax(this,value)
            set_param(this.BlockHandle,'YMax',value);
        end

        function value=get.YMax(this)
            value=get_param(this.BlockHandle,'YMax');
        end


        function set.LimitDataPoints(this,value)
            value=this.convertLogicalToString(value);
            set_param(this.BlockHandle,'LimitDataPoints',value);
        end


        function value=get.LimitDataPoints(this)
            value=get_param(this.BlockHandle,'LimitDataPoints');
            value=this.convertStringToLogical(value);
        end


        function set.MaxDataPoints(this,value)
            set_param(this.BlockHandle,'MaxDataPoints',value);
        end

        function value=get.MaxDataPoints(this)
            value=get_param(this.BlockHandle,'MaxDataPoints');
        end


        function set.SaveToWorkspace(this,value)
            set_param(this.BlockHandle,'SaveToWorkspace',this.convertLogicalToString(value));
        end

        function value=get.SaveToWorkspace(this)
            value=this.convertStringToLogical(get_param(this.BlockHandle,'SaveToWorkspace'));
        end


        function set.SaveName(this,value)
            set_param(this.BlockHandle,'SaveName',value);
        end

        function value=get.SaveName(this)
            value=get_param(this.BlockHandle,'SaveName');
        end


        function set.DataFormat(this,value)
            set_param(this.BlockHandle,'DataFormat',value);
        end

        function value=get.DataFormat(this)
            value=get_param(this.BlockHandle,'DataFormat');
        end


        function set.Decimation(this,value)
            set_param(this.BlockHandle,'Decimation',value);
        end

        function value=get.Decimation(this)
            value=get_param(this.BlockHandle,'Decimation');
        end


        function set.AxesTitles(this,value)
            set_param(this.BlockHandle,'AxesTitles',value);
        end

        function value=get.AxesTitles(this)
            value=get_param(this.BlockHandle,'AxesTitles');
        end



        function value=get.ResolvedAxesTitles(this)




            value=this.AxesTitles;
            fields=fieldnames(value);
            numFields=numel(fields);
            inputsignames=get_param(this.BlockHandle,'InputSignalNames');
            if~isempty(inputsignames)
                for indx=1:numFields
                    value.(fields{indx})=strrep(strrep(value.(fields{indx}),...
                    '%<SignalLabel>',inputsignames{indx}),newline,' ');
                end
            end
        end


        function set.ScopeGraphics(this,scpgraphics)







































































        end

        function value=get.ScopeGraphics(this)






            value=get_param(this.BlockHandle,'ScopeGraphics');
        end


        function set.ShowLegends(this,value)
            set_param(this.BlockHandle,'ShowLegends',this.convertLogicalToString(value));
        end

        function value=get.ShowLegends(this)
            value=this.convertStringToLogical(get_param(this.BlockHandle,'ShowLegends'));
        end


        function set.LimitMaxRows(this,value)
            set_param(this.BlockHandle,'ShowLegends',this.convertLogicalToString(value));
        end

        function value=get.LimitMaxRows(this)
            value=this.convertStringToLogical(get_param(this.BlockHandle,'ShowLegends'));
        end


        function set.MaxRows(this,value)
            set_param(this.BlockHandle,'MaxRows',value);
        end

        function value=get.MaxRows(this)
            value=get_param(this.BlockHandle,'MaxRows');
        end


        function set.BlockParamSampleInput(this,value)
            if isSimulationRunning(this)
                return;
            end
            this.SampleInput=uiservices.onOffToLogical(value);
            if~this.SampleInput
                this.SampleTime='-1';
            end
        end

        function value=get.BlockParamSampleInput(this)
            value=transformScopeParam(this.Specification,'SampleInput');
        end


        function set.BlockParamSampleTime(this,value)


            if this.SampleInput
                set_param(this.BlockHandle,'SampleTime',value);
            end

        end

        function value=get.BlockParamSampleTime(this)
            value=get_param(this.BlockHandle,'SampleTime');
        end


        function set.ScrollMode(this,value)
            set_param(this.BlockHandle,'ScrollMode',value)
        end

        function value=get.ScrollMode(this)
            value=get_param(this.BlockHandle,'ScrollMode');
        end


        function set.ShowDataMarkers(this,value)
            set_param(this.BlockHandle,'ShowDataMarkers',this.convertLogicalToString(value));
        end

        function value=get.ShowDataMarkers(this)
            value=this.convertStringToLogical(get_param(this.BlockHandle,'ShowDataMarkers'));
        end

        function set.IsSourceVectorScope(obj,val)







        end
        function val=get.IsSourceVectorScope(obj)






        end

        function set.HorizSpan(this,strValue)
            set_param(this.BlockHandle,'HorizSpan',strValue);
        end

        function value=get.HorizSpan(this)
            value=get_param(this.BlockHandle,'HorizSpan');
        end

        function set.AxisGrid(this,strValue)
            set_param(this.BlockHandle,'AxisGrid',strValue);
        end

        function value=get.AxisGrid(this)
            value=get_param(this.BlockHandle,'AxisGrid');
        end

        function set.AxisLegend(this,strValue)
            set_param(this.BlockHandle,'AxisLegend',strValue);
        end

        function value=get.AxisLegend(this)
            value=get_param(this.BlockHandle,'AxisLegend');
        end

        function set.AxisZoom(this,strValue)
            set_param(this.BlockHandle,'AxisZoom',strValue);
        end

        function value=get.AxisZoom(this)
            value=get_param(this.BlockHandle,'AxisZoom');
        end


        function set.OpenScopeAtSimStart(this,strValue)
            set_param(this.BlockHandle,'OpenScopeAtSimStart',strValue);
        end

        function value=get.OpenScopeAtSimStart(this)
            value=get_param(this.BlockHandle,'OpenScopeAtSimStart');
        end


        function set.FigPos(this,strValue)

            ind=strfind(strValue,'%');
            if~isempty(ind)
                strValue=strValue(1:ind-1);
            end
            set_param(this.BlockHandle,'WindowPosition',strValue);
        end

        function value=get.FigPos(this)
            value=sprintf('[%s]',num2str(get_param(this.BlockHandle,'WindowPosition')));
            value=strrep(value,'  ',' ');
        end

        function set.InheritXIncr(~,~)

        end

        function value=get.InheritXIncr(~)
            value='on';
        end

        function set.XIncr(this,~)

            set_param(this.BlockHandle,'SampleTime','-1');
        end

        function value=get.XIncr(this)
            value=get_param(this.BlockHandle,'SampleTime');
        end

        function set.LineMarkers(this,val)
            set_param(this.BlockHandle,'LineMarkers',val);
        end
        function value=get.LineMarkers(this)

            value=get_param(this.BlockHandle,'LineMarkers');
        end

        function set.LineStyles(this,val)
            set_param(this.BlockHandle,'LineStyles',val);
        end
        function value=get.LineStyles(this)
            value=get_param(this.BlockHandle,'LineStyles');
        end

        function set.VectorScopeLegacyMode(obj,value)

        end
        function value=get.VectorScopeLegacyMode(obj)

            value=false;
        end
    end

    methods(Hidden,Access=protected)
        function header=getHeader(this)



            allBlockHandles=[this.BlockHandle];
            classString=getString(message('Spcuilib:scopes:Configuration',get_param(allBlockHandles(1),'BlockType')));
            mapFileLocationSimulink=fullfile(docroot,'mapfiles','simulink.map');
            topicID='ControlScopesProgrammatically';
            className=['<a href="matlab: helpview ',mapFileLocationSimulink,' '...
            ,topicID,'"',' style="font-weight:bold">',classString,'</a>'];
            if isscalar(this)
                header=getString(message('MATLAB:ObjectText:DISPLAY_AND_DETAILS_SCALAR_WITH_PROPS',className));
            else
                tSize=size(this);

                sizeStr='';
                lenSize=length(tSize);
                for indx=1:lenSize
                    if(indx==lenSize)
                        sizeStr=sprintf('%s%d',sizeStr,tSize(indx));
                    else
                        sizeStr=sprintf('%s%dx',sizeStr,tSize(indx));
                    end
                end
                header=getString(message('MATLAB:ObjectText:DISPLAY_AND_DETAILS_ARRAY_WITH_PROPS',sizeStr,className));
            end
            header=sprintf('%s\n',header);
        end
    end

    methods(Access=protected)
        function groups=getPropertyGroups(this)

            groups=matlab.mixin.util.PropertyGroup(getDisplayProperties(this));
        end
    end

    methods(Hidden)

        function props=getDisplayProperties(this)






            allBlockHandles=[this.BlockHandle];
            isLockedLibrary=any(strcmp(get_param(bdroot(allBlockHandles),'Lock'),'on'))||...
            any(strcmp(get_param(allBlockHandles,'LinkStatus'),'implicit'));
            isFloating=any(uiservices.onOffToLogical(get_param(allBlockHandles,'Floating')));
            isViewer=any(strcmp(get_param(allBlockHandles,'IOType'),'viewer'));
            isAnyDST=any([this.isDST]);
            if isFloating
                if isLockedLibrary
                    if isAnyDST
                        props=this.FloatingScopeLockedLibraryDisplayProperties;
                    else
                        props=this.SimulinkFloatingScopeLockedLibraryDisplayProperties;
                    end
                else
                    if isAnyDST
                        props=this.FloatingScopeDisplayProperties;
                    else
                        props=this.SimulinkFloatingScopeDisplayProperties;
                    end
                end
            elseif isViewer
                if isLockedLibrary
                    if isAnyDST
                        props=this.ScopeViewerLockedLibraryDisplayProperties;
                    else
                        props=this.SimulinkScopeViewerLockedLibraryDisplayProperties;
                    end
                else
                    if isAnyDST
                        props=this.ScopeViewerDisplayProperties;
                    else
                        props=this.SimulinkScopeViewerDisplayProperties;
                    end
                end
            else
                if isLockedLibrary
                    if isAnyDST
                        props=this.ScopeLockedLibraryDisplayProperties;
                    else
                        props=this.SimulinkScopeLockedLibraryDisplayProperties;
                    end
                else
                    if isAnyDST
                        props=this.ScopeDisplayProperties;
                    else
                        props=this.SimulinkScopeDisplayProperties;
                    end
                end
            end
        end

    end
end

function b=isDefaultGraphics(this,scpGraphics)

    if isempty(scpGraphics)
        b=true;
        return;
    end

    defGraphics=this.DefaultScopeGraphics;

    scpFigColor=str2num(scpGraphics.FigureColor);%#ok<*ST2NM>
    defFigColor1=str2num(defGraphics.FigureColor);
    defFigColor2=[128,128,128]/255;

    scpGraphics=rmfield(scpGraphics,'FigureColor');
    defGraphics=rmfield(defGraphics,'FigureColor');

    b=isequal(scpGraphics,defGraphics)&&...
    (all(abs(scpFigColor-defFigColor1)<1e-6)||all(abs(scpFigColor-defFigColor2)<1e-6));

end

function props=getLogicalProperties

    props={'OpenAtSimulationStart','Visible','MinimizeControls',...
    'ShowTimeAxisLabel','DataLogging','DataLoggingLimitDataPoints',...
    'DataLoggingDecimateData','ShowLegend','ShowGrid',...
    'PlotAsMagnitudePhase','FrameBasedProcessing','ReduceUpdates',...
    'DisplayFullPath','SampleInput','DataFormatSet','LimitDataPointsSet',...
    'DecimationSet','UsePreviousFormat','isDST','PreserveColorsForCopyToClipboard','VectorScopeLegacyMode'};
    if feature('OnoffSwitchState')
        props=[props,{'Open'}];
    end

end



classdef PercentileDefinitionPropsDataOptions<matlab.mixin.SetGet




    properties(Constant,Hidden)
        TIMECOURSE_HANDLING_INTERPOLATION='interpolation';
        TIMECOURSE_HANDLING_BINNING='binning';

        BINNING_AUTO='auto';
        BINNING_NUM_BINS='specifyNumBins';
        BINNING_BIN_EDGES='specifyBinEdges';

        NUM_TIMEPOINTS_PER_GROUP_CUTOFF=25;
    end

    properties(Access=public)
        DataSource=SimBiology.internal.plotting.data.DataSource.empty;
        TimecourseHandling=SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionPropsDataOptions.TIMECOURSE_HANDLING_INTERPOLATION;
        InterpolationSettings=SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionPropsDataOptions.getInterpolationSettings();
        BinningSettings=SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionPropsDataOptions.getBinningSettings();
        RawDataPercentage=0;
    end




    methods(Access=public)
        function obj=PercentileDefinitionPropsDataOptions(input)

            if nargin>0
                if isempty(input)
                    obj=SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionPropsDataOptions.empty;
                elseif isa(input,'SimBiology.internal.plotting.sbioplot.PlotArgument')
                    obj(numel(input),1)=SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionPropsDataOptions;
                    arrayfun(@configureSingleObjectForPlotArgument,obj,input);
                else
                    obj(numel(input),1)=SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionPropsDataOptions;
                    arrayfun(@configureSingleObjectFromStruct,obj,input);
                end
            end
        end

        function info=getStruct(obj)
            if isempty(obj)
                info=struct([]);
            else
                for i=numel(obj):-1:1
                    info(i,1)=struct('DataSource',obj(i).DataSource.getStruct(),...
                    'TimecourseHandling',obj(i).TimecourseHandling,...
                    'InterpolationSettings',obj(i).InterpolationSettings,...
                    'BinningSettings',obj(i).BinningSettings,...
                    'RawDataPercentage',obj(i).RawDataPercentage);
                end
            end
        end
    end

    methods(Access=protected)
        function configureSingleObjectFromStruct(obj,input)
            if~isempty(input.DataSource)
                set(obj,'DataSource',SimBiology.internal.plotting.data.DataSource(input.DataSource));
            end
            set(obj,'TimecourseHandling',input.TimecourseHandling,...
            'InterpolationSettings',input.InterpolationSettings,...
            'BinningSettings',input.BinningSettings,...
            'RawDataPercentage',input.RawDataPercentage);
        end

        function configureSingleObjectForPlotArgument(obj,plotArgument)
            set(obj,'DataSource',plotArgument.dataSource);


            if~matlab.internal.feature("SimBioPercentilePlotTimepointBinning")||...
                plotArgument.data.anyNumTimepointsPerGroupIsGreaterThan(obj.NUM_TIMEPOINTS_PER_GROUP_CUTOFF)
                obj.TimecourseHandling=obj.TIMECOURSE_HANDLING_INTERPOLATION;
            else
                obj.TimecourseHandling=obj.TIMECOURSE_HANDLING_BINNING;
            end
        end
    end

    methods(Access=public)
        function dataSources=getDataSources(obj)

            if isempty(obj)
                dataSources=SimBiology.internal.plotting.data.DataSource.empty;
            else
                dataSources=[obj.DataSource];
            end
        end
    end

    methods(Static,Access=private)
        function options=getInterpolationSettings()
            options=struct;
            options.InterpolationMethod=SimBiology.internal.plotting.data.SBioDataInterfaceForTimecourseData.LINEAR;
            options.Timepoints=SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionProps.AUTO_TIMEPOINTS;
        end

        function options=getBinningSettings()
            options=struct;
            options.BinningMethod=SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionPropsDataOptions.BINNING_AUTO;
            options.NumTimepointBins=[];
            options.TimepointBinEdges=[];
            options.ShowBinEdges=false;
        end
    end
end
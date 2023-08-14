classdef Engine<handle










    properties(SetAccess=private)
RGBGenerator
ClientType
    end

    properties(Hidden)


        RunName;
        TableData=table();


        DataIndicesWithoutHistogramData;

        InScopeData;
        CanvasData;
        RGBData;

        YLimits;
        GlobalYLimits;
        VisualYLimits;

        DataThreshold=20;

        LastIndex=0;
        NumRecordsToPublish=20;


        StartIndex;
        EndIndex;


        SelectedResultId;

    end
    methods

        function this=Engine(clientType)

            this.ClientType=clientType;
            this.RGBGenerator=DataTypeWorkflow.Visualizer.RGBGeneratorFactory.getGenerator(clientType);
        end

    end
    methods
        init(this);


        canvasData=generateCanvasData(this);


        generateRGBUsingDB(this);

    end
    methods(Hidden)

        computeYLimitsForVisualization(this);


        filterRecordsWithHistogramData(this);

        computeDataIndexRange(this);

        rowIndex=getRowIndexForScopingId(this,scopingId);
    end
end

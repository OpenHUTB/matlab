classdef SimOutputExplorerOutput<handle



    properties(Access='public')
        RootSource;
        TimeSource;
        DataSource;
        TimeValues;
        DataValues;
        BlockSource;
        ModelSource;
        SignalLabel;
        TimeDim;
        SampleDims;
        PortIndex;
        SID;
        rootDataSrc;
        interpolation;
        metaData;
        Unit;


        HierarchyReference;





        AlwaysUseSignalLabel;


        SLDVData;





        busesPrefixForLabel;
        SampleTimeString;
    end

    methods(Access='public')

        function this=SimOutputExplorerOutput()
            this.RootSource=[];
            this.TimeSource=[];
            this.DataSource=[];
            this.DataValues=[];
            this.BlockSource=[];
            this.ModelSource=[];
            this.SignalLabel=[];
            this.TimeDim=[];
            this.SampleDims=[];
            this.PortIndex=[];
            this.SID=[];
            this.rootDataSrc='';
            this.metaData=[];
            this.interpolation='zoh';
            this.Unit='';
            this.HierarchyReference=[];
            this.AlwaysUseSignalLabel=false;
            this.SLDVData=[];
            this.busesPrefixForLabel='';
            this.SampleTimeString='';
        end

    end

end

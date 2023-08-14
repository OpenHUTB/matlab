classdef Collector<handle





    properties(Hidden,Access=private)

        SelectedSystem='';


        TopModel='';


        AllSystemsToScale={};

    end


    properties(SetAccess=private)

compiledDoubleResultsCache

    end


    properties(Constant,Hidden,Access=private)

        SingleConverterRunName='D2S_Run_Collector_Internal_Run_Name';
    end

    methods
        function collector=Collector(selectedSystem,topModel,allSystemsToScale)

            collector.SelectedSystem=selectedSystem;
            collector.TopModel=topModel;
            collector.AllSystemsToScale=allSystemsToScale;
        end

        collectInfoToDataset(this)
        err=collectDoubleResults(this)
    end

    methods(Access=public,Hidden)
        reportedResults=performProposal(this,groups)
    end

end

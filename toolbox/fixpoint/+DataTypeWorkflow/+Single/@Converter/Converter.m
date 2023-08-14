classdef Converter<handle







    properties(Hidden,Access=private)

        SelectedSystem='';

        TopModel='';

        AllSystemsToScale={}

        MLFBConverter=[]
    end


    properties(Constant,Access=private)
        Settings=struct('SglStr','single');
    end


    methods
        function converter=Converter(analyzerScope,mlfbConverter)
            converter.SelectedSystem=analyzerScope.SelectedSystem;
            converter.TopModel=analyzerScope.TopModel;
            converter.AllSystemsToScale=analyzerScope.AllSystemsToScale;
            converter.MLFBConverter=mlfbConverter;
        end
    end


    methods
        function reportInfo=convert(converter)
            reportInfo=struct('err',[],'results',[],'ready',false);
            collector=DataTypeWorkflow.Single.Collector(converter.SelectedSystem,converter.TopModel,converter.AllSystemsToScale);





            try

                collector.collectDoubleResults();


                compiledResults=converter.convertDoublesToSingles(collector.compiledDoubleResultsCache);

                converter.MLFBConverter.convert;



                converter.updateConfigurations();


                reportInfo.results=compiledResults;
                reportInfo.ready=true;

            catch ME
                reportInfo.err=ME;
                reportInfo.ready=false;
            end

        end
    end


    methods(Access=public)
        function results=convertDoublesToSingles(converter,results)

            topAppData=SimulinkFixedPoint.getApplicationData(converter.TopModel);

            proposalSettings=topAppData.AutoscalerProposalSettings;
            proposalSettings.scaleUsingRunName=topAppData.ScaleUsing;

            engineContext=SimulinkFixedPoint.DataTypingServices.EngineContext(...
            converter.SelectedSystem,...
            converter.SelectedSystem,...
            proposalSettings,...
            SimulinkFixedPoint.DataTypingServices.EngineActions.Apply);

            engineInterface=SimulinkFixedPoint.DataTypingServices.EngineInterface.getInterface();
            engineInterface.run(engineContext);

        end
    end

    methods(Access=private)
        function updateConfigurations(converter)


            for idx=1:numel(converter.AllSystemsToScale)

                model=converter.AllSystemsToScale{idx};
                if~DataTypeWorkflow.Single.Utils.checkConfigSetRef(model)
                    cs=getActiveConfigSet(model);
                    originalUnderspecifiedDTField=get_param(cs,'DefaultUnderspecifiedDataType');
                    if strcmp(originalUnderspecifiedDTField,'double')
                        set_param(cs,'DefaultUnderspecifiedDataType','single');
                    end
                end
            end
        end
    end
end


classdef MatlabCodeAnalyzerWarnings<slmetric.metric.Metric




    properties

    end

    methods
        function this=MatlabCodeAnalyzerWarnings()
            this.ID='mathworks.metrics.MatlabCodeAnalyzerWarnings';
            this.CompileContext='None';
            this.Version=2;
            this.ComponentScope=[...
            Advisor.component.Types.MATLABFunction];
            this.AggregationMode=slmetric.AggregationMode.Sum;
            this.Name=DAStudio.message('slcheck:metric:MatlabCodeAnalyzerStatus_Name');
            this.Description=DAStudio.message('slcheck:metric:MatlabCodeAnalyzerStatus_Desc');
            this.ValueName=DAStudio.message('slcheck:metric:MatlabCodeAnalyzerStatus_ValueLabel');
            this.AggregatedValueName=DAStudio.message('slcheck:metric:MatlabCodeAnalyzerStatus_AggregateValueLabel');

            this.setCSH('ma.metricchecks','MatlabCodeAnalyzerWarnings');
        end

        function res=algorithm(this,component)

            res=slmetric.metric.Result();
            res.MetricID=this.ID;
            res.ComponentID=component.ID;


            res.Value=0;



            chartObj=Advisor.component.getComponentSource(component);


            if~isempty(chartObj)


                analyzerResults=...
                checkcode(chartObj.Script,'-severity','dummy.m','-text','-id','-codegen');





                analyzerResults=analyzerResults(...
                arrayfun(@(x)(x.severity<=1),...
                analyzerResults));




                analyzerResults=analyzerResults(...
                arrayfun(@(x)~strcmp(x.id,'FNDEF'),...
                analyzerResults));

                if isa(chartObj,'Stateflow.EMFunction')&&~isempty(analyzerResults)

                    msgs2Filter=sfprivate('getEMLFcnFilteredOutMLintMsgs');


                    analyzerResults=analyzerResults(...
                    arrayfun(@(x)~any(strcmp(x.id,msgs2Filter)),...
                    analyzerResults));
                end

                res.Value=numel(analyzerResults);
            end
        end
    end
end


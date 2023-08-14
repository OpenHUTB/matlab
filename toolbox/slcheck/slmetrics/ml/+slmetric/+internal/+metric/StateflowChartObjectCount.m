classdef StateflowChartObjectCount<slmetric.metric.Metric




    properties

    end

    methods
        function this=StateflowChartObjectCount()
            this.ID='mathworks.metrics.StateflowChartObjectCount';
            this.Version=1;
            this.ComponentScope=Advisor.component.Types.Chart;
            this.AggregationMode=slmetric.AggregationMode.Sum;
            this.Name=DAStudio.message('slcheck:metric:StateflowChartObjectCount_Name');
            this.Description=DAStudio.message('slcheck:metric:StateflowChartObjectCount_Desc');
            this.ValueName=DAStudio.message('slcheck:metric:StateflowChartObjectCount_ValueLabel');
            this.AggregatedValueName=DAStudio.message('slcheck:metric:StateflowChartObjectCount_AggregateValueLabel');
            this.setCSH('ma.metricchecks','StateflowObjectCount');
        end

        function res=algorithm(this,component)


            chartObj=Advisor.component.getComponentSource(component);

            res=slmetric.metric.Result();
            res.ComponentID=component.ID;
            res.MetricID=this.ID;

            if ishandle(chartObj)&&isa(chartObj,'Stateflow.Chart')

                [~,total]=this.getChartContentCount(chartObj);
                res.Value=total;

            else



                res.Value=0;
            end
        end

    end

    methods(Access=private,Static)
        function[counts,total]=getChartContentCount(chartObj)
            objectTypes={'Chart','State','Box',...
            'EMFunction','EMChart','Function','LinkChart',...
            'TruthTable','Transition','Junction',...
            'Event','Data','Target','Machine','SLFunction',...
            'AtomicSubchart'};
            counts=[];
            total=0;


            for k=1:length(objectTypes)

                Hobjs=chartObj.find(...
                '-isa',['Stateflow.',objectTypes{k}],...
                '-and','Chart',chartObj);

                Hobjs=Hobjs(arrayfun(@(o)(~isCommented(o)),Hobjs));

                counts.(objectTypes{k})=length(Hobjs);
                total=total+length(Hobjs);
            end

        end
    end
end


classdef SubSystemDepth<slmetric.metric.Metric




    properties

    end

    methods
        function this=SubSystemDepth()
            this.ID='mathworks.metrics.SubSystemDepth';
            this.Version=2;
            this.ComponentScope=[Advisor.component.Types.Model,...
            Advisor.component.Types.SubSystem];
            this.AggregationMode=slmetric.AggregationMode.Sum;
            this.Name=DAStudio.message('slcheck:metric:SubSysDepth_Name');
            this.Description=DAStudio.message('slcheck:metric:SubSysDepth_Desc');
            this.ValueName=DAStudio.message('slcheck:metric:SubSysDepth_ValueLabel');
            this.AggregatedValueName=DAStudio.message('slcheck:metric:SubSysDepth_MeasuresLabel1');
            this.setCSH('ma.metricchecks','SubSystemDepth');
        end

        function res=algorithm(this,component)
            res=slmetric.metric.Result();
            res.ComponentID=component.ID;
            res.MetricID=this.ID;

            ssPath=component.getPath();




            level=0;
            blk=ssPath;
            while~isempty(get_param(blk,'Parent'))
                level=level+1;
                blk=get_param(blk,'Parent');
            end
            res.Value=level;
        end

    end
end


classdef SimulinkBlockCount<slmetric.metric.Metric




    properties

    end

    methods
        function this=SimulinkBlockCount()
            this.ID='mathworks.metrics.SimulinkBlockCount';
            this.Version=2;
            this.ComponentScope=[Advisor.component.Types.Model,...
            Advisor.component.Types.SubSystem];
            this.AggregationMode=slmetric.AggregationMode.Sum;
            this.Name=DAStudio.message('slcheck:metric:SimulinkBlockCount_Name');
            this.Description=DAStudio.message('slcheck:metric:SimulinkBlockCount_Desc');
            this.ValueName=DAStudio.message('slcheck:metric:SimulinkBlockCount_ValueLabel');
            this.AggregatedValueName=DAStudio.message('slcheck:metric:SimulinkBlockCount_AggregateValueLabel');

            this.setCSH('ma.metricchecks','SimulinkBlockCount');
        end

        function res=algorithm(this,component)
            res=slmetric.metric.Result();
            res.ComponentID=component.ID;
            res.MetricID=this.ID;

            ssPath=component.getPath();



            blocks=find_system(ssPath,...
            'LookUnderMasks','all',...
            'FollowLinks','on',...
            'MatchFilter',@Simulink.match.allVariants,...
            'SearchDepth',1,...
            'Type','Block');


            blocks=setdiff(blocks,{ssPath});


            maskTypes=get_param(blocks,'MaskType');
            blocks=blocks(~strcmp(maskTypes,'System Requirement Item'));

            numBlocks=length(blocks);

            res.Value=numBlocks;
        end
    end
end


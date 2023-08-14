classdef ExplicitIOCount<slmetric.metric.Metric




    methods
        function h=ExplicitIOCount()
            h.ID='mathworks.metrics.ExplicitIOCount';
            h.Version=1;
            h.CompileContext='None';
            h.AggregationMode=slmetric.AggregationMode.Max;
            h.ComponentScope=[...
            Advisor.component.Types.MATLABFunction,...
            Advisor.component.Types.Model,...
            Advisor.component.Types.SubSystem,...
            Advisor.component.Types.Chart];

            h.Name=DAStudio.message('slcheck:metric:IOCount_Name');
            h.Description=DAStudio.message('slcheck:metric:IOCount_Desc');
            h.ValueName=DAStudio.message('slcheck:metric:IOCount_ValueLabel');
            h.AggregatedValueName=DAStudio.message('slcheck:metric:IOCount_AggregateValueLabel');
            h.MeasuresNames={...
            DAStudio.message('slcheck:metric:IOCount_MeasuresLabel1'),...
            DAStudio.message('slcheck:metric:IOCount_MeasuresLabel2')};
            h.AggregatedMeasuresNames={...
            DAStudio.message('slcheck:metric:IOCount_AggregateMeasuresLabel1'),...
            DAStudio.message('slcheck:metric:IOCount_AggregateMeasuresLabel2')};

            h.setCSH('ma.metricchecks','ExplicitIOCount');
        end

        function res=algorithm(this,component)

            res=slmetric.metric.Result();


            res.ComponentID=component.ID;
            res.MetricID=this.ID;


            nIn=0;
            nOut=0;




            if component.Type==Advisor.component.Types.Model||...
                component.Type==Advisor.component.Types.SubSystem





                inportBlocks=find_system(component.getPath(),...
                'SearchDepth',1,...
                'FollowLinks','on',...
                'MatchFilter',@Simulink.match.allVariants,...
                'LookUnderMasks','on',...
                'BlockType','Inport');


                outportBlocks=find_system(component.getPath(),...
                'SearchDepth',1,...
                'FollowLinks','on',...
                'LookUnderMasks','on',...
                'MatchFilter',@Simulink.match.allVariants,...
                'BlockType','Outport');

                triggerBlocks=find_system(component.getPath(),...
                'SearchDepth',1,...
                'FollowLinks','on',...
                'LookUnderMasks','on',...
                'MatchFilter',@Simulink.match.allVariants,...
                'IncludeCommented','off',...
                'BlockType','TriggerPort');

                enableBlocks=find_system(component.getPath(),...
                'SearchDepth',1,...
                'FollowLinks','on',...
                'LookUnderMasks','on',...
                'MatchFilter',@Simulink.match.allVariants,...
                'IncludeCommented','off',...
                'BlockType','EnablePort');

                nIn=nIn+numel(inportBlocks)...
                +numel(triggerBlocks)...
                +numel(enableBlocks);

                nOut=nOut+numel(outportBlocks);



            elseif component.Type==Advisor.component.Types.Chart||component.Type==Advisor.component.Types.MATLABFunction


                chartObj=Advisor.component.getComponentSource(component);

                if~isempty(chartObj)

                    ios=chartObj.find('-isa','Stateflow.Data','-or','-isa','Stateflow.Event','-depth',1);
                    scopes=arrayfun(@(x)x.Scope,ios,'UniformOutput',false);
                    nIn=nnz(strcmp(scopes,'Input'));
                    nOut=nnz(strcmp(scopes,'Output'));
                end

            end




            res.Measures=[nIn,nOut];
            res.Value=sum(res.Measures);

        end

    end

end


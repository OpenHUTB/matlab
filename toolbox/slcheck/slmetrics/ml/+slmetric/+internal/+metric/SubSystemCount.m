classdef SubSystemCount<slmetric.metric.Metric



    properties

    end

    methods
        function this=SubSystemCount()
            this.ID='mathworks.metrics.SubSystemCount';
            this.Version=2;
            this.ComponentScope=[Advisor.component.Types.Model,...
            Advisor.component.Types.SubSystem];
            this.AggregationMode=slmetric.AggregationMode.Sum;
            this.Name=DAStudio.message('slcheck:metric:SubSystemCount_Name');
            this.Description=DAStudio.message('slcheck:metric:SubSystemCount_Desc');
            this.ValueName=DAStudio.message('slcheck:metric:SubSystemCount_ValueLabel');
            this.AggregatedValueName=DAStudio.message('slcheck:metric:SubSystemCount_AggregateValueLabel');
            this.setCSH('ma.metricchecks','SubSystemCount');
        end

        function res=algorithm(this,component)
            res=slmetric.metric.Result();
            res.ComponentID=component.ID;
            res.MetricID=this.ID;

            ssPath=component.getPath();
            subSystems=find_system(ssPath,...
            'LookUnderMasks','all',...
            'FollowLinks','on',...
            'MatchFilter',@Simulink.match.allVariants,...
            'SearchDepth',1,...
            'BlockType','SubSystem');
            modelPath=strtok(ssPath,'/');
            [libfile,resolved]=sls_resolvename(modelPath);
            testroot=fullfile(matlabroot,'test');

            if resolved
                if~(strncmp(testroot,libfile,length(testroot)))
                    subSystems=slmetric.internal.filterMathWorksBuiltInLibraryBlocks(subSystems);
                end

            end


            numSS=0;

            if~isempty(subSystems)


                subSystems=setdiff(subSystems,{ssPath});


                isSfBlkList=~slprivate('is_stateflow_based_block',subSystems);
                subSystems=subSystems(isSfBlkList);

                if~isempty(subSystems)

                    maskTypes=get_param(subSystems,'MaskType');

                    keep=~strcmp(maskTypes,'System Requirement Item');
                    keep=keep&~strcmp(maskTypes,'System Requirements');

                    numSS=sum(keep);
                end
            end

            res.Value=numSS;
        end
    end
end


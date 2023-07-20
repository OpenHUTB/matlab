classdef LibraryLinkCount<slmetric.metric.Metric




    properties

    end

    methods
        function this=LibraryLinkCount()
            this.ID='mathworks.metrics.LibraryLinkCount';
            this.Version=3;
            this.ComponentScope=[Advisor.component.Types.Model,...
            Advisor.component.Types.SubSystem];
            this.AggregationMode=slmetric.AggregationMode.Sum;

            this.Name=DAStudio.message('slcheck:metric:LibraryLinkCount_Name');
            this.Description=DAStudio.message('slcheck:metric:LibraryLinkCount_Desc');
            this.ValueName=DAStudio.message('slcheck:metric:LibraryLinkCount_ValueLabel');
            this.AggregatedValueName=DAStudio.message('slcheck:metric:LibraryLinkCount_AggregateValueLabel');

            this.setCSH('ma.metricchecks','LibraryLinkCount');
        end

        function res=algorithm(this,component)
            res=slmetric.metric.Result();
            res.ComponentID=component.ID;
            res.MetricID=this.ID;

            ssPath=component.getPath();


            LinkedBlocks=find_system(ssPath,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'SearchDepth',1,...
            'Type','Block','LinkStatus','resolved');

            modelPath=strtok(ssPath,'/');
            [libfile,resolved]=sls_resolvename(modelPath);
            testroot=fullfile(matlabroot,'test');

            if resolved
                if~(strncmp(testroot,libfile,length(testroot)))
                    LinkedBlocks=slmetric.internal.filterMathWorksBuiltInLibraryBlocks(LinkedBlocks);
                end

            end

            numLinks=length(LinkedBlocks);
            if component.Type==Advisor.component.Types.SubSystem&&numLinks>0
                if strcmp(get_param(ssPath,'LinkStatus'),'resolved')


                    numLinks=numLinks-1;
                end
            end
            res.Value=numLinks;
        end
    end
end


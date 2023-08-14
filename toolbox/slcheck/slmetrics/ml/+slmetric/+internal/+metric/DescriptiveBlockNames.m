classdef DescriptiveBlockNames<slmetric.metric.Metric




    properties

    end

    methods
        function this=DescriptiveBlockNames()
            this.ID='mathworks.metrics.DescriptiveBlockNames';
            this.Version=1;
            this.ComponentScope=[Advisor.component.Types.Model,...
            Advisor.component.Types.SubSystem];
            this.AggregationMode=slmetric.AggregationMode.Sum;
            this.Name=DAStudio.message('slcheck:metric:DescriptiveBlockNames_Name');
            this.Description=DAStudio.message('slcheck:metric:DescriptiveBlockNames_Desc');
            this.ValueName=DAStudio.message('slcheck:metric:DescriptiveBlockNames_ValueLabel');
            this.AggregatedValueName=DAStudio.message('slcheck:metric:DescriptiveBlockNames_AggregateValueLabel');
            this.setCSH('ma.metricchecks','DescriptiveBlockNames');
        end

        function res=algorithm(this,component)
            slPath={component.getPath()};




            inportsNormal=find_system(slPath,'LookUnderMasks','all',...
            'SearchDepth',1,...
            'FollowLinks','on',...
            'BlockType','Inport');

            inportsShadow=find_system(slPath,'LookUnderMasks','all',...
            'SearchDepth',1,...
            'FollowLinks','on',...
            'BlockType','InportShadow');

            inports=[inportsNormal;inportsShadow];
            numIps=length(inports);
            ipDefaultNames=this.getPortNaming(inports,'In');


            outports=find_system(slPath,'LookUnderMasks','all',...
            'SearchDepth',1,...
            'FollowLinks','on',...
            'BlockType','Outport');
            numOps=length(outports);
            opDefaultNames=this.getPortNaming(outports,'Out');




            ss=find_system(slPath,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'SearchDepth',1,...
            'FollowLinks','on',...
            'BlockType','SubSystem');


            if component.Type==Advisor.component.Types.SubSystem
                if length(ss)>1
                    ss=ss(2:end);
                else
                    ss={};
                end
            end

            numSS=length(ss);
            ssDefaultNames=this.getSubSystemNaming(ss);

            res=slmetric.metric.Result();
            res.ComponentID=component.ID;
            res.MetricID=this.ID;
            res.Measures=[numIps,ipDefaultNames,numOps,opDefaultNames,...
            numSS,ssDefaultNames];
            res.Value=sum([ipDefaultNames,opDefaultNames,ssDefaultNames]);
        end
    end

    methods(Access=private,Static)
        function defaultNames=getPortNaming(ports,defaultName)
            defaultNames=0;
            blkNames=get_param(ports,'Name');

            for n=1:length(ports)

                if strcmp(get_param(ports{n},'ShowName'),'off')



                elseif slmetric.internal.metric.DescriptiveBlockNames.isNonDescriptive(...
                    blkNames{n},defaultName)

                    defaultNames=defaultNames+1;

                end
            end
        end

        function defaultNames=getSubSystemNaming(ss)
            defaultNames=0;
            blkNames=get_param(ss,'Name');

            for n=1:length(ss)

                if strcmp(get_param(ss{n},'ShowName'),'off')


                elseif strcmp(get_param(ss{n},'LinkStatus'),'resolved')&&...
                    ~isempty(get_param(ss{n},'ReferenceBlock'))&&...
                    slmetric.internal.metric.DescriptiveBlockNames.isBuiltInLibraryBlock(ss{n})


                elseif slmetric.internal.metric.DescriptiveBlockNames.isNonDescriptive(...
                    blkNames{n},'SubSystem')

                    defaultNames=defaultNames+1;

                end
            end

        end

        function out=isBuiltInLibraryBlock(ss)
            out=false;
            refBlock=get_param(ss,'ReferenceBlock');

            try
                libraryAccessible=true;

                libraryName=bdroot(refBlock);
            catch E
                if strcmp(E.identifier,'Simulink:Commands:InvSimulinkObjectName')

                    try
                        firstSlashIdx=regexp(refBlock,'/','once');

                        libraryName=refBlock(1:firstSlashIdx-1);
                        load_system(libraryName);
                    catch E %#ok<NASGU>
                        libraryAccessible=false;
                    end
                else
                    libraryAccessible=false;
                end
            end

            if libraryAccessible
                filePath=which(libraryName);

                if strncmpi(filePath,'built-in',8)||...
                    strncmp(matlabroot,filePath,length(matlabroot))
                    out=true;
                end
            end
        end

        function result=isNonDescriptive(blockName,defaultName)
            persistent defaultSubSystemNames;

            tempName=strtrim(blockName);
            tempName=regexprep(tempName,'\d*$','');
            if strcmp(defaultName,'SubSystem')
                if isempty(defaultSubSystemNames)
                    defaultSubSystemNames={...
                    'Atomic Subsystem';...
                    'CodeReuseSubsystem';...
                    sprintf('Configurable\nSubsystem');...
                    sprintf('Enabled\nSubsystem');...
                    sprintf('Enabled and\nTriggered Subsystem');...
                    sprintf('For Each\nSubsystem');...
                    sprintf('For Iterator\nSubsystem');...
                    sprintf('Function-Call\nSubsystem');...
                    sprintf('If Action\nSubsystem');...
                    sprintf('Resettable\nSubsystem');...
                    'Subsystem';...
                    sprintf('Switch Case Action\nSubsystem');...
                    sprintf('Triggered\nSubsystem');...
                    'Variant Subsystem';...
                    sprintf('While Iterator\nSubsystem')};
                end
                if any(strcmp(tempName,defaultSubSystemNames))
                    result=true;
                else
                    result=false;
                end
            else
                if strcmp(tempName,defaultName)
                    result=true;
                else
                    result=false;
                end
            end
        end

    end
end


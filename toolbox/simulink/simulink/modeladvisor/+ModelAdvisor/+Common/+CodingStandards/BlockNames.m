
classdef BlockNames<ModelAdvisor.Common.CodingStandards.Base

    methods(Access=public)

        function this=BlockNames(system,messagePrefix)
            this@ModelAdvisor.Common.CodingStandards.Base(...
            system,messagePrefix);
            this.flaggedObjects=struct(...
            'uuid',{});
        end

        function algorithm(this)



            blockList=find_system(this.system,...
            'FollowLinks','on',...
            'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'Type','Block');


            blockList=this.filterResultWithExclusion(blockList);

            for index=1:numel(blockList)
                thisBlock=blockList{index};
                blockName=get_param(thisBlock,'Name');
                if any(blockName=='/')
                    this.addFlaggedObject(thisBlock);
                end
            end

        end

        function report(this)
            resultTable=ModelAdvisor.FormatTemplate('ListTemplate');
            resultTable.setSubBar(false);
            resultTable.setCheckText(this.getMessage('CheckText'));

            flaggedBlocks=cell(this.getNumFlaggedObjects(),1);
            for i=1:this.getNumFlaggedObjects()
                flaggedBlocks{i}=this.getFlaggedObjects(i).uuid;
            end

            if this.getNumFlaggedObjects()==0
                this.localResultStatus=true;
                resultTable.setSubResultStatus('pass');
                resultTable.setSubResultStatusText(...
                this.getMessage('SubResultStatusText_Pass'));
            else
                this.localResultStatus=false;
                resultTable.setSubResultStatus('warn');
                resultTable.setSubResultStatusText(...
                this.getMessage('SubResultStatusText_Fail'));
                resultTable.setRecAction(...
                this.getMessage('RecAction'));
                resultTable.setListObj(flaggedBlocks);
            end
            this.addReportObject(resultTable);
        end

    end

    methods(Access=protected)

        function addFlaggedObject(this,uuid)
            this.flaggedObjects(end+1)=struct(...
            'uuid',uuid);
        end

    end
end


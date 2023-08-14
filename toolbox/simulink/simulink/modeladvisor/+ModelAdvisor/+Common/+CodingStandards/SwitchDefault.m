
classdef SwitchDefault<ModelAdvisor.Common.CodingStandards.Base

    methods(Access=public)

        function this=SwitchDefault(system,messagePrefix)
            this@ModelAdvisor.Common.CodingStandards.Base(...
            system,messagePrefix);
        end

        function algorithm(this)



            switchBlocks=find_system(this.system,...
            'FollowLinks','on',...
            'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType','SwitchCase');
            [remaningObjects,~]=...
            this.filterResultWithExclusion(switchBlocks);

            for i=1:numel(remaningObjects)
                showDefaultCase=get_param(remaningObjects{i},...
                'ShowDefaultCase');
                if strcmp(showDefaultCase,'off')
                    if strcmp(this.messageFile,'misra')
                        justification=this.getPolyspaceJustification(...
                        switchBlocks{i});
                        justifiedCorrectly=this.isJustifiedCorrectly(...
                        justification,'16.4');
                        if justifiedCorrectly
                            this.addJustifiedObject(remaningObjects{i},...
                            justification);
                        else
                            this.addFlaggedObject(remaningObjects{i});
                        end
                    else
                        this.addFlaggedObject(remaningObjects{i});
                    end
                end
            end

            if this.getNumFlaggedObjects()==0
                this.localResultStatus=true;
            else
                this.localResultStatus=false;
            end

        end

        function report(this)

            resultTable=ModelAdvisor.FormatTemplate('TableTemplate');
            resultTable.setCheckText(this.getMessage('CheckText'));
            resultTable.setSubBar(false);
            resultTable.setColTitles({...
            this.getMessage('ResultTableHeader_Location')});
            for i=1:this.getNumFlaggedObjects()
                flaggedObject=this.getFlaggedObjects(i);
                resultTable.addRow({flaggedObject.uuid});
            end

            if this.getNumFlaggedObjects()==0
                resultTable.setSubResultStatus('pass');
                if this.getNumJustifiedObjects()==0
                    resultTable.setSubResultStatusText(this.getMessage(...
                    'SubResultStatusText_Pass'));
                else
                    resultTable.setSubResultStatusText(this.getMessage(...
                    'SubResultStatusText_PassWithAnnotation'));
                end
            else
                resultTable.setSubResultStatus('warn');
                resultTable.setSubResultStatusText(this.getMessage(...
                'SubResultStatusText_Fail'));
                resultTable.setRecAction(this.getMessage(...
                'Action'));
            end

            this.addReportObject(resultTable);
            if this.getNumJustifiedObjects()>0
                justifiedTable=this.createJustifiedTable();
                header=ModelAdvisor.Text(this.getCommonMessage(...
                'JustifiedBlocks'));
                header.IsBold=1;
                this.addReportObject(header);
                this.addReportObject(justifiedTable);
            end

        end

    end

end


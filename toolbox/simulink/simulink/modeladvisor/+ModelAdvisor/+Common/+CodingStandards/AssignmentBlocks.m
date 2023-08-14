
classdef AssignmentBlocks<ModelAdvisor.Common.CodingStandards.Base

    methods(Access=public)

        function this=AssignmentBlocks(system,messagePrefix,enabled)

            this@ModelAdvisor.Common.CodingStandards.Base(...
            system,messagePrefix);
            this.flaggedObjects=struct(...
            'uuid',{},...
            'actualValue',{},...
            'recommendedValue',{});
            if nargin==2
                this.enabled=true;
            else
                this.enabled=enabled;
            end
        end

        function algorithm(this)



            assignmentBlocks=find_system(this.system,...
            'LookUnderMasks','all',...
            'FollowLinks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType','Assignment');

            assignmentBlocks=this.filterResultWithExclusion(assignmentBlocks);
            for blockIndex=1:length(assignmentBlocks)
                thisBlock=assignmentBlocks{blockIndex};
                [hasIssue,actualValue,recommendedValue]=...
                this.checkBlock(thisBlock);
                if hasIssue
                    this.addFlaggedObject(...
                    thisBlock,...
                    actualValue,...
                    recommendedValue);
                end
            end

        end

        function report(this)
            resultTable=ModelAdvisor.FormatTemplate('TableTemplate');
            switch this.messageFile
            case 'misra'
                resultTable.setSubBar(false);
            case 'security'
                resultTable.setSubBar(false);
            otherwise
                resultTable.setSubTitle(this.getMessage('SubTitle'));
                resultTable.setSubBar(true);
            end

            resultTable.setColTitles({...
            this.getMessage('ResultColumn1'),...
            this.getMessage('ResultColumn2'),...
            this.getMessage('ResultColumn3')});


            if this.enabled==false
                resultTable.setSubResultStatusText(...
                this.getMessage('SubcheckDisabled'));
                this.addReportObject(resultTable);
                this.localResultStatus=true;
                return;
            end

            listText=ModelAdvisor.List;
            listText.addItem(this.getMessage('DescriptionListItem1'));
            listText.addItem(this.getMessage('DescriptionListItem2'));
            description=this.getMessage('Description',this.getParameterString());
            resultTable.setInformation({description,listText});

            for i=1:this.getNumFlaggedObjects()
                flaggedObject=this.getFlaggedObjects(i);
                resultTable.addRow({...
                flaggedObject.uuid,...
                flaggedObject.actualValue,...
                flaggedObject.recommendedValue});
            end

            if this.getNumFlaggedObjects()==0
                this.localResultStatus=true;
                resultTable.setSubResultStatus('Pass');
                resultTable.setSubResultStatusText(this.getMessage(...
                'Pass',this.getParameterString()));
            else
                this.localResultStatus=false;
                resultTable.setSubResultStatus('Warn');
                resultTable.setSubResultStatusText(this.getMessage(...
                'Warn',this.getParameterString()));
                resultTable.setRecAction(this.getMessage(...
                'RecAct',this.getParameterString()));
            end
            this.addReportObject(resultTable);
        end

        function result=action(this,mdladvObj)
            result=ModelAdvisor.FormatTemplate('TableTemplate');
            result.setCheckText(this.getMessage(...
            'ActionResultText',this.getParameterString()));
            result.setColTitles({...
            this.getMessage('ActionColumn1'),...
            this.getMessage('ActionColumn2'),...
            this.getMessage('ActionColumn3')});
            checkResult=mdladvObj.getCheckResult(mdladvObj.ActiveCheck.ID);
            tableInfo=checkResult{1}.TableInfo;
            for blockIndex=1:size(tableInfo,1)
                thisBlock=tableInfo{blockIndex,1};
                recommendedValue=tableInfo{blockIndex,3};
                set_param(thisBlock,'DiagnosticForDimensions',recommendedValue);
            end
            result.setTableInfo(tableInfo);
        end
    end

    properties(Access=protected)
        enabled;
    end

    methods(Access=protected)

        function addFlaggedObject(this,uuid,actualValue,recommendedValue)
            this.flaggedObjects(end+1)=struct(...
            'uuid',uuid,...
            'actualValue',actualValue,...
            'recommendedValue',recommendedValue);
        end

        function[hasIssue,actualValue,suggestedValue]=checkBlock(this,block)
            hasIssue=false;
            actualValue='';
            suggestedValue='';
            indexOptions=get_param(block,'IndexOptionArray');
            for dimensionIndex=1:length(indexOptions)
                if strcmp(indexOptions{dimensionIndex},'Index vector (port)')||...
                    strcmp(indexOptions{dimensionIndex},'Starting index (port)')
                    outputInitialize=get_param(block,'OutputInitialize');
                    if strcmp(outputInitialize,'Specify size for each dimension in table')
                        diagnosticProperty=get_param(block,'DiagnosticForDimensions');
                        if this.isWithinForWhileIterator(block)
                            if strcmp(diagnosticProperty,'None')
                                hasIssue=true;
                                actualValue=diagnosticProperty;
                                suggestedValue='Warning';
                                break;
                            end
                        else
                            if~strcmp(diagnosticProperty,'Error')
                                hasIssue=true;
                                actualValue=diagnosticProperty;
                                suggestedValue='Error';
                                break;
                            end
                        end
                    end
                end
            end
        end

        function result=isWithinForWhileIterator(~,thisBlock)
            root=bdroot(thisBlock);
            parent=get_param(thisBlock,'Parent');
            result=false;
            while~strcmp(parent,root)
                whileIterators=find_system(parent,...
                'SearchDepth',1,...
                'Type','Block',...
                'BlockType','WhileIterator');
                forIterators=find_system(parent,...
                'SearchDepth',1,...
                'Type','Block',...
                'BlockType','ForIterator');
                if~isempty(whileIterators)||~isempty(forIterators)
                    result=true;
                    break;
                end
                parent=get_param(parent,'Parent');
            end
        end

        function string=getParameterString(~)
            string=DAStudio.message('Simulink:blkprm_prompts:DiagOptionNoAll');
            if string(end)==':'
                string=string(1:end-1);
            end
        end


    end

end


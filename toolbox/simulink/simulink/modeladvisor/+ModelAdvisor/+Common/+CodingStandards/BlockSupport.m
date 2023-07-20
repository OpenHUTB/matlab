
classdef BlockSupport<ModelAdvisor.Common.CodingStandards.Base

    methods(Access=public)

        function this=BlockSupport(system,messagePrefix)
            this@ModelAdvisor.Common.CodingStandards.Base(...
            system,messagePrefix);
            this.flaggedObjects=struct(...
            'uuid',{},...
            'type',{});
        end

        function algorithm(this)

            followLinks='on';
            lookUnderMasks='all';







            blockList=find_system(this.system,...
            'FollowLinks',followLinks,...
            'LookUnderMasks',lookUnderMasks,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType','Lookup_n-D');

            blockList=Advisor.Utils.Simulink.standardFilter(...
            this.system,...
            blockList,...
            {'Verification'});
            blockList=this.filterResultWithExclusion(blockList);
            interpolationMethod=get_param(blockList,'InterpMethod');
            extrapolationMethod=get_param(blockList,'ExtrapMethod');
            filter=strcmp(interpolationMethod,'Cubic spline')|...
            strcmp(extrapolationMethod,'Cubic spline');
            filter=~filter;
            blockList(filter)=[];
            for i=1:numel(blockList)
                this.addFlaggedObject(blockList{i},'CubicSpline');
            end







            blockList=find_system(this.system,...
            'FollowLinks',followLinks,...
            'LookUnderMasks',lookUnderMasks,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'RegExp','on',...
            'BlockType','\<Lookup\>|\<Lookup2D\>');

            blockList=Advisor.Utils.Simulink.standardFilter(...
            this.system,...
            blockList,...
            {'Verification'});
            blockList=this.filterResultWithExclusion(blockList);
            for i=1:numel(blockList)
                this.addFlaggedObject(blockList{i},'DeprecatedLUT');
            end







            blockList=find_system(this.system,...
            'FollowLinks',followLinks,...
            'LookUnderMasks',lookUnderMasks,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType','S-Function',...
            'MaskType','S-Function Builder');

            blockList=Advisor.Utils.Simulink.standardFilter(...
            this.system,...
            blockList,...
            {'Verification'});
            blockList=this.filterResultWithExclusion(blockList);
            for i=1:numel(blockList)
                this.addFlaggedObject(blockList{i},'SFcnBuilder');
            end







            blockList=find_system(this.system,...
            'FollowLinks',followLinks,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks',lookUnderMasks,...
            'BlockType','FromWorkspace');
            blockList=Advisor.Utils.Simulink.standardFilter(...
            this.system,...
            blockList,...
            {'Verification','Shipping'});
            blockList=this.filterResultWithExclusion(blockList);
            for i=1:numel(blockList)
                this.addFlaggedObject(blockList{i},'FromWorkspace');
            end





            blockTypeList={...
            'ComposeString';...
            'ScanString';...
            'ToString'};
            blockList={};
            for i=1:numel(blockTypeList)


                subList=find_system(this.system,...
                'FollowLinks',followLinks,...
                'LookUnderMasks',lookUnderMasks,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'BlockType',blockTypeList{i});

                blockList=[blockList;subList];%#ok<AGROW>
            end
            blockList=Advisor.Utils.Simulink.standardFilter(...
            this.system,...
            blockList,...
            {'Verification'});
            blockList=this.filterResultWithExclusion(blockList);
            for i=1:numel(blockList)
                this.addFlaggedObject(blockList{i},'String');
            end

            if this.getNumFlaggedObjects()==0
                this.localResultStatus=true;
            else
                this.localResultStatus=false;
            end

        end

        function report(this)

            resultTable=ModelAdvisor.FormatTemplate('TableTemplate');
            resultTable.setCheckText(...
            this.getMessage('CheckText'));
            resultTable.setSubBar(false);
            resultTable.setColTitles({...
            this.getMessage('ResultTableHeader_Block'),...
            this.getMessage('ResultTableHeader_Advice')});
            for i=1:this.getNumFlaggedObjects()
                flaggedObject=this.getFlaggedObjects(i);
                switch flaggedObject.type
                case 'CubicSpline'
                    advice=this.getMessage('Advice_CubicSpline');
                case 'DeprecatedLUT'
                    advice=this.getMessage('Advice_DeprecatedLUT');
                case 'SFcnBuilder'
                    advice=this.getMessage('Advice_SFcnBuilder');
                case 'FromWorkspace'
                    advice=this.getMessage('Advice_FromWorkspace');
                case 'String'
                    advice=this.getMessage('Advice_String');
                otherwise
                    advice='';
                end
                resultTable.addRow({flaggedObject.uuid,advice});
            end

            if this.getNumFlaggedObjects()==0
                resultTable.setSubResultStatus('pass');
                resultTable.setSubResultStatusText(this.getMessage(...
                'SubResultStatusText_Pass'));
            else
                resultTable.setSubResultStatus('warn');
                resultTable.setSubResultStatusText(this.getMessage(...
                'SubResultStatusText_Fail'));
                resultTable.setRecAction(this.getMessage(...
                'RecAction'));
            end

            this.addReportObject(resultTable);

        end

    end

    methods(Access=protected)

        function addFlaggedObject(this,uuid,type)
            this.flaggedObjects(end+1)=struct(...
            'uuid',uuid,...
            'type',type);
        end

    end

end


classdef CheckInternalRuleInGroup<SimulinkFixedPoint.WarningConditions.AbstractCondition








    methods
        function this=CheckInternalRuleInGroup()
            this.messageID={'FixedPointTool:fixedPointTool:alertInternalRuleInSharedGroup'};
        end

        function flag=check(~,result,~)
            flag=~result.hasProposedDT&&...
            ~isempty(regexp(result.getSpecifiedDT,'via internal rule','once'));

        end

    end

end
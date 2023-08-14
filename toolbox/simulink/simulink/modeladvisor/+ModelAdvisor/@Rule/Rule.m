classdef Rule<handle
    properties(Hidden)
    end

    properties(SetAccess=public)
        SID='off';
        RegExp='off';
        Type='Library';
        Name='';
        Value='';
    end

    methods

        function Rule=Rule()
        end

        function set.Type(ruleObj,value)
            [~,ruleTypes]=enumeration('ModelAdvisor.ModelAdvisorExclusionTypeEnum');
            if ismember(value,ruleTypes)
                ruleObj.Type=value;
            else
                cell2table(ruleTypes)
                DAStudio.error('ModelAdvisor:engine:MAInvalidRuleType');
            end
        end

        function set.Value(ruleObj,val)



            ruleObj.Value=strrep(val,sprintf('\n'),' ');
        end

    end
end
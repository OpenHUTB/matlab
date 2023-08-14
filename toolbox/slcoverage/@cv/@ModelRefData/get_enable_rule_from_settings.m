



function rules=get_enable_rule_from_settings(topModelName,refs,excludeTopModel,modelRefEnable,excludedList)

    rules=cell(1,length(refs));
    for idx=1:length(refs)
        cs=refs{idx};
        enable=getRule(cs,modelRefEnable,excludedList);
        rules{idx}={cs,enable};
    end
    rules{end+1}={get_param(topModelName,'name'),~excludeTopModel};

    function recordCoverage=getRule(modelName,modelRefEnable,excludedList)

        if strcmpi(modelRefEnable,'all')||strcmpi(modelRefEnable,'on')
            recordCoverage=true;
        elseif strcmpi(modelRefEnable,'filtered')
            if any(strcmp(modelName,excludedList))
                recordCoverage=false;
            else
                recordCoverage=true;
            end
        else
            recordCoverage=false;
        end

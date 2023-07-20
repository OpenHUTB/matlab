
function conditionsArr=parseSwitchCaseConditions(sid)

    try
        conditionsStr=get_param(sid,'CaseConditions');

        if isempty(conditionsStr)
            conditionsArr=[];
            return;
        end

        conditionsArr=slResolve(conditionsStr,sid);


        for i=1:numel(conditionsArr)
            conditionsArr{i}=double(conditionsArr{i});
        end

    catch Exception %#ok
        conditionsArr=[];
    end
end


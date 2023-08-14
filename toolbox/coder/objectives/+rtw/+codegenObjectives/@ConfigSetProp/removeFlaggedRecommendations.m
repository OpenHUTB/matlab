function removeFlaggedRecommendations(obj,cs)



    removed=[];
    for i=1:length(obj.scriptList)
        script=obj.scriptList{i};
        if~isempty(script.flag)
            for f=1:length(script.flag)
                equal=isequal(cs.get_param(script.flag{f}{1}),script.flag{f}{2});
                if script.flag{f}{3}
                    equal=~equal;
                end
                if equal
                    removed(end+1)=i;%#ok<AGROW>
                    break;
                end
            end
        end
        if strcmp(obj.Parameters(script.id).name,'ParenthesesLevel')



            if slfeature('ParenthesesLevelStandards')...
                &&strcmpi(cs.get_param('ParenthesesLevel'),'maximum')
                removed(end+1)=i;%#ok<AGROW>
            end
        end
    end

    obj.scriptList(removed)=[];
    obj.lenOfList=length(obj.scriptList);

end

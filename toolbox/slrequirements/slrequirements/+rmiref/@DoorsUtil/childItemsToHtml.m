function html=childItemsToHtml(moduleId,itemId,headerLevel)
    html='';
    childIds=rmidoors.getObjAttribute(moduleId,itemId,'childIds');
    if~isempty(childIds)
        for i=1:length(childIds)
            childId=childIds{i};
            if length(childId)>1


                data=rmiref.DoorsUtil.doorsTableIdsToStrings(moduleId,childId);
                html=[html,rmiut.arrayToHtmlTable(data,struct('header',false))];%#ok<AGROW>
            else
                childHeader=rmidoors.getObjAttribute(moduleId,childId,'Object Heading');
                html=[html,newline,htHeader(headerLevel,sprintf('#%d: %s',childId,childHeader))];%#ok<AGROW>
                childText=rmidoors.getObjAttribute(moduleId,childId,'textAsHtml');
                if~isempty(childText)
                    html=[html,childText];%#ok<AGROW>
                end
                moreHtml=rmiref.DoorsUtil.childItemsToHtml(moduleId,childId,headerLevel+1);
                if~isempty(moreHtml)
                    html=[html,newline,moreHtml];%#ok<AGROW>
                end
            end
        end
    end
end

function html=htHeader(level,label)
    html=sprintf('<h%d>%s</h%d>',level,label,level);
end

function parsedResults=removeDuplicateEntries(parsedResults)



    dupIdx=[];
    for i=1:length(parsedResults.tag)
        for j=i+1:length(parsedResults.tag)
            if compareTag(parsedResults.tag{i},parsedResults.tag{j})
                dupIdx=[dupIdx,i];
                break;
            end
        end
    end
    parsedResults.tag(dupIdx)=[];



    for i=1:length(parsedResults.tag)
        lines=Advisor.BaseRegisterCGIRInspectorResults.splitUp(parsedResults.tag{i}.sid);
        dupIdx=[];
        for j=1:length(lines)
            if isempty(find(dupIdx==j,1))
                idx=find(strcmp(lines,lines{j}));
                dupIdx=[dupIdx,setdiff(idx,j)];%#ok<*AGROW>
            end
        end
        lines(unique(dupIdx))=[];
        parsedResults.tag{i}.sid=strjoin(lines,'\n');
    end






    function res=compareTag(tag1,tag2)
        res=true;

        if~strcmp(tag1.sid,tag2.sid)
            res=false;
            return
        end

        if isfield(tag1,'info')&&isfield(tag2,'info')
            res=compareInfo(tag1.info,tag2.info);
        end






        function res=compareInfo(info1,info2)

            if isequal(values(info1),values(info2))
                res=true;
            else
                res=false;
            end




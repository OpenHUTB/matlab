function parsedResults=removeEmptyEntries(parsedResults)



    dupIdx=[];
    for i=1:length(parsedResults.tag)
        if isempty(parsedResults.tag{i}.sid)
            dupIdx=[dupIdx,i];%#ok<AGROW>
        end
    end
    parsedResults.tag(dupIdx)=[];
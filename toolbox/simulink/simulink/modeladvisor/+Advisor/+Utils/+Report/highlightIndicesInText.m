function highlightedText=highlightIndicesInText(text,startIndices,endIndices,emphasis)






















    highlightedText=text;


    if isempty(startIndices)||isempty(endIndices)||isempty(text)
        return;
    end

    if~isequal(numel(startIndices),numel(endIndices))
        disp(DAStudio.message('ModelAdvisor:engine:ArraySizeMismatch'));
        return;
    end


    if nargin<4
        emphasis='n';
    else
        emphasis=lower(emphasis);
    end

    if startIndices(1)>0&&endIndices(end)<=numel(text)
        for idx=numel(endIndices):-1:2
            start=startIndices(idx);
            finish=endIndices(idx);
            if start<=finish&&start>endIndices(idx-1)
                highlightedText=highlightPortion(highlightedText,start,finish,emphasis);
            end
        end
        highlightedText=highlightPortion(highlightedText,startIndices(1),endIndices(1),emphasis);
    end
end



function highlightedText=highlightPortion(highlightedText,start,finish,emphasis)
    textBeforeIssue=highlightedText(1:start-1);
    textIssue=highlightedText(start:finish);
    textAfterIssue=highlightedText(finish+1:end);

    if emphasis=='b'||emphasis=='i'
        highlightedText=[textBeforeIssue,...
        '<',emphasis,'>','<mark>',textIssue,'</mark>','</',emphasis,'>',...
        textAfterIssue];
    else
        highlightedText=[textBeforeIssue,...
        '<mark>',textIssue,'</mark>',...
        textAfterIssue];
    end
end


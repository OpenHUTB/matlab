function yn=isEmpty(html)


















    if containsImageTag(html)||containsObject(html)
        yn=false;
    else
        noTags=regexprep(html,'<[^>]+>','');
        yn=isempty(strtrim(noTags));
    end
end

function tf=containsImageTag(html)
    matched=regexp(html,'<img [^>]*src=','once');
    tf=~isempty(matched);
end

function tf=containsObject(html)
    matched=regexp(html,'<object [^>]*data=','once');
    tf=~isempty(matched);
end

function value=parseValue(rdf,attribute,format)
    if nargin<3
        format=false;
    end
    value='';
    if attribute(end)=='='
        matched=regexp(rdf,['<',attribute,'"([^"]+)"/?>'],'tokens');
    else
        matched=regexp(rdf,['<',attribute,'[^>]*>([\s\S]*?)</',attribute,'>'],'tokens');
    end
    if length(matched)==1
        value=matched{1}{1};
    else
        for i=1:length(matched)
            value{i}=matched{i}{1};
        end
    end
    if format
        value=strrep(value,char(10),['<br/>',char(10)]);
    end
end

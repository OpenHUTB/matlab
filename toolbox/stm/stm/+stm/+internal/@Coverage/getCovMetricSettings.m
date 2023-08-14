

function new=getCovMetricSettings(old,new)

    nonCoverageMetricCharacters='sw';
    len=length(nonCoverageMetricCharacters);
    for i=1:len
        char=nonCoverageMetricCharacters(i);
        if contains(old,char)
            new=[new,char];%#ok<AGROW>
        end
    end
end

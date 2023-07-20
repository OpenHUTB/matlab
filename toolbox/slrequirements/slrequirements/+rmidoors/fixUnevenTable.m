function out=fixUnevenTable(in)























    out=regexprep(in,'(\[\s*\d+)[^\]]+\]',' $1 ]');

    tableStarts=find(in=='[');
    tableEnds=find(in==']');
    if length(tableStarts)~=length(tableEnds)
        return;
    end
    if any(tableStarts>tableEnds)
        return;
    end

    out=in(1:tableStarts(1)-1);
    for i=1:length(tableStarts)
        thisTable=in(tableStarts(i):tableEnds(i));

        [okTable,rows]=isGoodTable(thisTable);
        if okTable
            out=[out,thisTable];%#ok<AGROW>
        else
            flatTable=makeFlatTable(rows);
            out=[out,flatTable];%#ok<AGROW>
        end
        if i<length(tableStarts)

            out=[out,in(tableEnds(i)+1:tableStarts(i+1)-1)];%#ok<AGROW>
        end
    end

    out=[out,in(tableEnds(end)+1:end)];
end

function[tf,rows]=isGoodTable(in)

    rows=regexp(in,'([\s\d]+);','tokens');
    if isempty(rows)

        tf=true;
        return;
    end
    wantedCount=sum(rows{1}{1}==' ');
    for i=2:length(rows)
        if sum(rows{i}{1}==' ')==wantedCount
            continue;
        else
            tf=false;
            return;
        end
    end
    tf=true;
end

function out=makeFlatTable(rows)










    out='[';
    for i=1:length(rows)
        oneRow=rows{i}{1};
        out=[out,oneRow,' '];%#ok<AGROW>
    end
    out=[regexprep(out,'  +',' '),']'];
end

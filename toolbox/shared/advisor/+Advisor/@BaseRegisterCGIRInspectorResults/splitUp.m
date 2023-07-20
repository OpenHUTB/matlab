function lines=splitUp(inCell)



    lines=regexp(inCell,'\n+','split');

    while length(lines)>1&&isempty(lines{end})
        lines(end)=[];
    end
    while length(lines)>1&&isempty(lines{1})
        lines(1)=[];
    end

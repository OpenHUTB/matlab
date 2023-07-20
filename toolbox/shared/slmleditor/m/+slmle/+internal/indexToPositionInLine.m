function[line,column]=indexToPositionInLine(text,index)



    line=1;
    column=1;

    n=length(text);
    m=min(n,index);

    for i=1:m
        if text(i)==newline
            line=line+1;
            column=1;
        else
            column=column+1;
        end
    end

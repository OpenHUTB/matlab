function index=positionInLineToIndex(text,line,column)



    l=1;
    c=1;
    index=0;
    if l>line||(l==line&&c>=column)
        return;
    end

    for i=1:length(text)
        if text(i)==newline
            l=l+1;
            c=1;
        else
            c=c+1;
        end
        if l>line
            return;
        elseif l==line&&c>=column
            index=i;
            return;
        end
        index=i;
    end


function[lineNo,colNo]=messageLineno(text,unicodemap,start)




    srcLen=numel(text);
    if srcLen<1
        lineNo=1;
        colNo=1;
    else
        lineNo=1;
        eolPos=0;
        if start<0
            start=0;
        else
            start=uniposition(unicodemap,start,start);
        end
        stop=min(start+1,srcLen);
        for i=1:stop
            c=text(i);
            if c==newline
                eolPos=i;
                lineNo=lineNo+1;
            end
        end
        colNo=max(1,i-eolPos);
    end


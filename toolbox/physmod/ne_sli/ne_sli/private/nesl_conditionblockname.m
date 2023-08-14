function fixedStr=nesl_conditionblockname(origStr)










    fixedStr=strtrim(origStr);
    remain=fixedStr;


    maxSize=20;

    if(length(remain)<maxSize)
        return;
    end

    newNameStr='';
    lineStr='';
    nToksInLine=0;
    startNewLine=false;

    while(~isempty(remain))
        [tok,remain]=strtok(remain,' ');%#ok<STTOK>
        newLen=length(lineStr)+length(tok);

        if(newLen<maxSize)
            if(nToksInLine)
                lineStr=sprintf('%s %s',lineStr,tok);
            else
                lineStr=tok;
            end
            nToksInLine=nToksInLine+1;
        elseif(nToksInLine==0)
            lineStr=tok;
            startNewLine=true;
            nToksInLine=nToksInLine+1;
        else

            remain=[tok,remain];%#ok<AGROW>
            startNewLine=true;
        end

        if(startNewLine||isempty(remain))
            lineStr=strtrim(lineStr);

            if(isempty(newNameStr))
                newNameStr=lineStr;
            else
                newNameStr=sprintf('%s\n%s',newNameStr,lineStr);
            end

            startNewLine=false;
            lineStr='';
            nToksInLine=0;
        end
    end

    fixedStr=strtrim(newNameStr);
end

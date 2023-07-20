function parsedLine=symbol_parse(lineStr)























    parsedLine.freeFormText=[];
    parsedLine.symbol=[];
    symStart=0;
    symEnd=0;

    symbolDelimiterIndex1=findstr(lineStr,'%<');
    symbolDelimiterIndex2=findstr(lineStr,'>');


    if~isempty(symbolDelimiterIndex1)
        for i=1:length(symbolDelimiterIndex1)
            symbolDelimiterIndex{i}=[symbolDelimiterIndex1(i)+1,symbolDelimiterIndex2(i)];
        end
    else
        symbolDelimiterIndex=[];
    end









    if isempty(symbolDelimiterIndex)==0
        len=length(symbolDelimiterIndex);
        for i=1:len
            freeFormStart=symEnd+1;
            symStart=symbolDelimiterIndex{i}(1);
            symEnd=symbolDelimiterIndex{i}(2);
            parsedLine.symbol{end+1}=lineStr(symStart+1:symEnd-1);

            parsedLine.freeFormText{end+1}=lineStr(freeFormStart:symStart-2);
        end

        if symEnd<length(lineStr)
            parsedLine.freeFormText{end+1}=lineStr(symEnd+1:end);
            parsedLine.symbol{end+1}='';
        end
    else

        parsedLine.symbol{1}='';
        parsedLine.freeFormText{1}=lineStr;
    end

function encodedString=encodeHTMLEntityString(htmlString)








    htmlChars=char(htmlString);

    count=0;
    n=numel(htmlChars);
    buffer=char.empty(0,fix(n*1.1));
    for i=1:numel(htmlChars)
        htmlChar=htmlChars(i);
        code=fix(htmlChar);
        if(code>=160)
            str=sprintf('&#%d;',code);
        else
            str=htmlChar;
        end

        for j=1:numel(str)
            count=count+1;
            buffer(count)=str(j);
        end
    end

    encodedString=string(buffer);
end
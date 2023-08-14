function outStr=printFormatString(inStr)

    len=length(inStr);
    linebreak=false;
    foundEscape=false;
    if len>100
        linebreak=true;
    end
    if linebreak
        ssStr=['[',''''];
    else
        ssStr='''';
    end
    curlidx=0;
    for ii=1:len
        ch=inStr(ii);
        ascii=double(ch);
        if ascii<32
            foundEscape=true;
            switch ascii

            case 0
                esc='\\\\0';
            case 7
                esc='\\\\a';
            case 8
                esc='\\\\b';
            case 9
                esc='\\\\t';
            case 10
                esc='\\\\n';
                if linebreak&&curlidx>50
                    esc=[esc,'''',' ...\\n\\t',''''];
                    curlidx=0;
                end
            case 11
                esc='\\\\v';
            case 12
                esc='\\\\f';
            case 13
                esc='\\\\r';
            otherwise
                esc='';
            end
            ssStr=[ssStr,esc];%#ok<*AGROW>
        else
            ssStr=[ssStr,ch];
        end
        curlidx=curlidx+1;
    end
    if linebreak
        ssStr=[ssStr,'''',']'];
    else
        ssStr=[ssStr,''''];
    end
    if foundEscape
        outStr=['sprintf(',ssStr,')'];
    else
        outStr=ssStr;
    end
end

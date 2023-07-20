function[nextC,restOfC]=parsec(str,size)
















    nextC=[];
    restOfC=[];
    len=length(str);
    if len>size
        cnt=size;
        index=0;
        while(cnt>0)
            if str(cnt)==' '
                index=cnt;
                break;
            end
            cnt=cnt-1;
        end
        if index>0
            nextC=str(1:index);
            restOfC=str(index+1:end);
        end
    else
        nextC=str;
        restOfC=[];
    end

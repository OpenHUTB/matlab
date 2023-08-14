



function[startIdx,endIdx,lineToIndex]=findComments(s)



    LF=char(10);
    CR=char(13);
    s=[s,' '];
    len=length(s);


    startIdx=zeros(1,int64(len/2));
    endIdx=zeros(1,int64(len/2));
    lineToIndex=zeros(1,len);

    target='/';
    firstIdx=0;
    i=1;
    count=0;
    line=1;
    startLine=1;
    while(i<len)




        if(s(i)==LF||s(i)==CR)
            line=line+1;
            if(target==LF)
                count=count+1;
                startIdx(count)=firstIdx;
                endIdx(count)=i-1;
                lineToIndex(startLine)=count;
                target='/';
            end
            if(s(i)==CR&&s(i+1)==LF)
                i=i+1;
            end
        elseif(s(i)==target)
            if(target=='/')
                if(s(i+1)=='*'||s(i+1)=='/')
                    if(s(i+1)=='*')
                        target='*';
                    elseif(s(i+1)=='/')
                        target=LF;
                    end
                    firstIdx=i;
                    startLine=line;
                    i=i+1;
                end
            elseif(target=='*'&&s(i+1)=='/')
                count=count+1;
                startIdx(count)=firstIdx;
                endIdx(count)=i+1;
                lineToIndex(startLine:line)=count;
                i=i+1;
                target='/';
            end
        end
        i=i+1;
    end

    startIdx(count+1:end)=[];
    endIdx(count+1:end)=[];
    lineToIndex(line+1:end)=[];
end



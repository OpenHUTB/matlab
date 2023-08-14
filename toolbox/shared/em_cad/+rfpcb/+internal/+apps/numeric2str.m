function rtn=numeric2str(numInput)





    rtn='[';
    if ischar(numInput)
        numString=strjoin(strsplit(numInput),', ');
        rtn=[rtn,numString,']'];
    else
        if(size(numInput,1)>1&&size(numInput,2)>1)
            rtn=mat2str(numInput);
            return;
        end
        if length(numInput)>1
            for i=1:(length(numInput)-1)
                rtn=[rtn,num2str(numInput(i)),' '];%#ok<AGROW> 
            end
            rtn=[rtn,num2str(numInput(i+1)),']'];
            return;
        end
        rtn=num2str(numInput);
    end
end


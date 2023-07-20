function dispStr=dispObjCounts(dispStr,propName,pty,className)












    if isstruct(pty)

        if~isempty(pty)
            numObjects=nnz(~structfun(@isempty,pty));
        else
            numObjects=0;
        end

        if numObjects~=1

            if endsWith(className,'y')

                numLetters=strlength(className);
                className=replaceBetween(className,numLetters,numLetters,'ies');
            else
                className=className+"s";
            end
        end

        [~,endIdx]=regexp(dispStr,propName+': \[.*?\]');
        newStr=" containing "+numObjects+" "+className;
        dispStr=insertAfter(dispStr,endIdx,newStr);
    else

        dispStr=erase(dispStr,"optim.problemdef.");
    end
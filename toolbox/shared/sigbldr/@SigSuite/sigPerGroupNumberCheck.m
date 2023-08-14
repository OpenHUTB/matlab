





function[doesmatch]=sigPerGroupNumberCheck(grpCnt,sigList)
    doesmatch=true;
    if~iscell(sigList)
        return;
    else
        sigCnt=length(sigList{1});
        for i=2:grpCnt
            if sigCnt~=length(sigList{i})
                doesmatch=false;
                return;
            end
        end
    end
end
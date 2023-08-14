function out=getNextQuestionIdFinish(status)

    if strcmp(status,'success')
        out='Additional';
    elseif strcmp(status,'applyfail')
        out='ApplyFail';
    else
        out='CodeGenFail';
    end

end
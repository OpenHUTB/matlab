function[line,col]=scriptPositionToLine(script,offset)



    if offset<0
        line=-1;
        col=-1;
    elseif isfield(script,'linemap')
        [line,col]=script.linemap(offset);
    else
        assert(false,'scriptPositionToLine: should not reach here.');
    end

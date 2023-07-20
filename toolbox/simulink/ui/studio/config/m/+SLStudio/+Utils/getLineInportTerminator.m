function terminator=getLineInportTerminator(line)




    assert(SLStudio.Utils.objectIsValidLine(line));
    terminator={};
    for iter=1:line.segment.size
        seg=line.segment.at(iter);

        terminator=SLStudio.Utils.getSegmentInportTerminator(seg);
    end
end

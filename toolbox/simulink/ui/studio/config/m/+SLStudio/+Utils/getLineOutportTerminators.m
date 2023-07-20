function terminators=getLineOutportTerminators(line)




    assert(SLStudio.Utils.objectIsValidLine(line));
    terminators={};
    for iter=1:line.segment.size
        seg=line.segment.at(iter);

        terms=SLStudio.Utils.getSegmentOutportTerminators(seg);
        terminators=[terminators,terms];%#ok<AGROW>
    end
end

function terminators=getSegmentOutportTerminators(segment)




    assert(SLStudio.Utils.objectIsValidSegment(segment));
    terminators={};
    for iter=1:segment.terminator.size
        term=segment.terminator.at(iter);

        if strcmpi(term.type,'Out Port')
            terminators=[terminators,term];%#ok<AGROW>
        end
    end
end

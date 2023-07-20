function terminator=getSegmentInportTerminator(segment)




    assert(SLStudio.Utils.objectIsValidSegment(segment));
    terminator={};
    for iter=1:segment.terminator.size
        term=segment.terminator.at(iter);
        if strcmpi(term.type,'In Port')

            terminator=term;
            return
        end
    end
end

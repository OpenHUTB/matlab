function port=getLineSourcePort(line)




    assert(SLStudio.Utils.objectIsValidLine(line));
    port={};
    for iter=1:line.segment.size
        segment=line.segment.at(iter);
        if SLStudio.Utils.objectIsValidPort(segment.srcElement)

            port=segment.srcElement;
            return
        end
    end
end

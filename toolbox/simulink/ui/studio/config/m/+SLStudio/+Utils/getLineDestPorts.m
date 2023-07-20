function ports=getLineDestPorts(line)




    assert(SLStudio.Utils.objectIsValidLine(line));
    ports={};
    for iter=1:line.segment.size
        segment=line.segment.at(iter);
        if SLStudio.Utils.objectIsValidPort(segment.dstElement)

            ports=[ports,segment.dstElement];%#ok<AGROW>
        end
    end
end

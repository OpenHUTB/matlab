function outStr=getLinkTargetString(inStr)
    if length(inStr)>40
        outStr=mlreportgen.utils.hash(inStr);
    else
        outStr=inStr;
    end
end


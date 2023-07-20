function parts=pathSplit(diagramPath)













    [parent,name]=slreportgen.utils.pathParts(diagramPath);
    parts=name;

    while(strlength(parent)>0)
        [parent,name]=slreportgen.utils.pathParts(parent);
        parts=[name,parts];%#ok
    end
end


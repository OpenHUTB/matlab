function diagramPath=getDiagramPath(obj)




















    diagramPath=string.empty();

    if~isempty(obj)
        hs=slreportgen.utils.HierarchyService;
        dhid=hs.getDiagramHID(obj);

        if~isempty(dhid)
            diagramPath=hs.getPath(dhid);
        end
        diagramPath=string(regexprep(diagramPath,"\s"," "));
    end
end

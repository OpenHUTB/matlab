function tf=hasDiagram(obj)



















    unsupportedSFClasses=[
"Stateflow.StateTransitionTableChart"
"Stateflow.TruthTableChart"
"Stateflow.TruthTable"
    ];

    try
        objH=slreportgen.utils.getSlSfHandle(obj);
        hs=slreportgen.utils.HierarchyService;
        hid=hs.getDiagramHID(objH);

        if hs.isValid(hid)

            diagH=slreportgen.utils.getSlSfHandle(hid);
            if isa(diagH,'Stateflow.Object')
                tf=~ismember(class(diagH),unsupportedSFClasses);
            else
                tf=true;
            end
        else
            tf=false;
        end

    catch
        tf=false;
    end
end
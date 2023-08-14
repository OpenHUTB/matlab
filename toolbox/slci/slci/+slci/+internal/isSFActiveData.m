



function out=isSFActiveData(aObj)
    out=true;
    parentObj=aObj.getParent;
    if isa(parentObj,'Stateflow.State')...
        ||isa(parentObj,'Stateflow.SLFunction')...
        ||isa(parentObj,'Stateflow.Function')...
        ||isa(parentObj,'Stateflow.TruthTable')...
        ||isa(parentObj,'Stateflow.Junction')...
        ||isa(parentObj,'Stateflow.Transition')
        if parentObj.IsExplicitlyCommented...
            ||parentObj.IsImplicitlyCommented
            out=false;
        end
    end
end
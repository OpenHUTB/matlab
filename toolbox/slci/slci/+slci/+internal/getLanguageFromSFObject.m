



function out=getLanguageFromSFObject(aObj)
    if isa(aObj,'slci.stateflow.Chart')
        out=aObj.getActionLanguage;
    else
        assert(isa(aObj,'slci.stateflow.TruthTable'));
        out=aObj.getLanguage;
    end
end
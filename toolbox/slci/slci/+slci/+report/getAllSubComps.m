


function allComps=getAllSubComps(obj,reader)
    allComps={};
    subComps=obj.getComponents();
    for k=1:numel(subComps)
        compKey=subComps{k};
        compObj=reader.getObject(compKey);
        if isa(compObj,'slci.results.StateObject')...
            ||isa(compObj,'slci.results.TruthTableObject')...
            ||isa(compObj,'slci.results.GraphicalFunctionObject')
            allSubComps=slci.report.getAllSubComps(compObj,reader);
        else
            allSubComps={};
        end
        allComps=[allComps;subComps(k);allSubComps];%#ok
    end
end

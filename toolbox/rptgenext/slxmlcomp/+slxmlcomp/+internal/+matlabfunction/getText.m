function text=getText(location)




    [~,obj]=slxmlcomp.internal.matlabfunction.locate(location);
    if isa(obj,'Stateflow.TruthTable')
        text=sf('get',obj.Id,'state.eml.script');
    else
        text=obj.Script;
    end

end


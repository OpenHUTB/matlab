function setText(location,text)




    [~,obj]=slxmlcomp.internal.matlabfunction.locate(location);
    if isa(obj,'Stateflow.TruthTable')
        sf('set',obj.Id,'state.eml.script',text);
    else
        obj.Script=text;
    end

end


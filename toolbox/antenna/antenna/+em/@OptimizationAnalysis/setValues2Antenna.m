function setValues2Antenna(obj,propValues)
    propIdx=getPropIndex(obj);













    if isfield(obj.OptimStruct,'SetValuesFcn')&&~isempty(obj.OptimStruct.SetValuesFcn)&&isa(obj,'pcbStack')
        obj.OptimStruct.SetValuesFcn(obj,obj.OptimStruct.PropertyNames,propValues,propIdx);
    else
        for i=1:numel(obj.OptimStruct.PropertyNames)


            setProperty(obj,obj.OptimStruct.PropertyNames{i},propValues(str2num(propIdx{i})))%#ok<ST2NM>
        end
    end

end
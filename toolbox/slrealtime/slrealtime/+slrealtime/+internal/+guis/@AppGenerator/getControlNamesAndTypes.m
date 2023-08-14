function[controlNames,controlTypes]=getControlNamesAndTypes(bindingData)







    controlNames={};
    controlTypes={};

    if isempty(bindingData),return;end

    controlNames=cellfun(@(x)x.ControlName,bindingData,'UniformOutput',false);
    controlTypes=cellfun(@(x)x.ControlType,bindingData,'UniformOutput',false);
    [controlNames,idxs,~]=unique(controlNames);
    controlTypes=controlTypes(idxs);
end


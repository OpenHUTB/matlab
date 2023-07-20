function[allControlNames,allControlTypes]=getAllControlNamesAndTypes(this,excludeRow)
















    allControlNames={};
    allControlTypes={};
    if~isempty(this.BindingData)
        allControlNames=cellfun(@(x)x.ControlName,this.BindingData(setdiff(1:end,excludeRow)),'UniformOutput',false);
        allControlTypes=cellfun(@(x)x.ControlType,this.BindingData(setdiff(1:end,excludeRow)),'UniformOutput',false);
    end
end

function checkControlNames(this,controlNames,components)





    invalidControlNames=intersect(controlNames,this.getNamesForAllExistingComponents(components));
    if~isempty(invalidControlNames)
        slrealtime.internal.throw.Error('slrealtime:appdesigner:ExistingControlNames',...
        char(join(cellfun(@(x)[char(9),x],invalidControlNames,'UniformOutput',false),newline)));
    end
end

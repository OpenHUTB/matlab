function val=getter(this,val)
    if isempty(this.CoderGroups)
        val='Default';
    else
        groupNames=this.getGroupNames;
        if~ismember(val,groupNames)
            val='Default';
        end
    end
end


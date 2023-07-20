function result=saveData(this,nodeIDs)
    result=[];

    if ismember(this.TreeData(1).id,nodeIDs)

        this.propValues.checkIDs='.*';
    else
        checkIds={this.TreeData(ismember({this.TreeData(:).id},nodeIDs)).checkid};
        this.propValues.checkIDs=checkIds(~cellfun(@isempty,checkIds));
    end
    if~isempty(this.Parent)
        if isfield(this.propValues,'updateTable')
            this.Parent.updateTable(this.propValues);
        else
            this.Parent.addExclusion(this.propValues);
        end
    end
    this.close();
end
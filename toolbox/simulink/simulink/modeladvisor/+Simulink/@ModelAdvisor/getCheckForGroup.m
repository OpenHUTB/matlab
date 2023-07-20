function[CheckIDArray,CheckSerialNumArray]=getCheckForGroup(this,groupNameArray)




    CheckIDArray={};
    CheckSerialNumArray={};
    if ischar(groupNameArray)

        groupNameArray={groupNameArray};
    end

    for i=1:length(this.CheckCellarray)
        if ismember(this.CheckCellarray{i}.Group,groupNameArray)
            CheckIDArray{end+1}=this.CheckCellarray{i}.ID;%#ok<AGROW>
            CheckSerialNumArray{end+1}=i;%#ok<AGROW>
        end
    end

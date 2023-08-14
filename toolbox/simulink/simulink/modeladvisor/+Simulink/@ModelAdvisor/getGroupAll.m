function GroupNameArray=getGroupAll(this)




    GroupNameArray={};

    for i=1:length(this.CheckCellarray)
        if iscell(this.CheckCellarray{i}.Group)
            for j=1:length(this.CheckCellarray{i}.Group)
                GroupNameArray=AddToGroup(GroupNameArray,this.CheckCellarray{i}.Group{j});
            end
        else
            GroupNameArray=AddToGroup(GroupNameArray,this.CheckCellarray{i}.Group);
        end
    end

end

function groupArray=AddToGroup(groupArray,Group)
    if~ismember(Group,groupArray)&&~isempty(Group)
        groupArray{end+1}=Group;
    end
end
function success=selectCheckForGroup(this,groupNameArray)




    if ischar(groupNameArray)

        groupNameArray={groupNameArray};
    end

    try
        success=true;

        allGroupNameArray=this.getGroupAll;
        if~isempty(setdiff(groupNameArray,allGroupNameArray))
            success=false;
        end

        for j=1:length(this.CheckCellarray)
            if ismember(this.CheckCellarray{j}.Group,groupNameArray)

                if~this.updateCheck(j,true)
                    success=false;
                end
            end
        end
    catch E
        success=false;
        rethrow(E);
    end

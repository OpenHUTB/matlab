function success=selectCheck(this,checkTitleID)








    success=false;

    selectCount=0;
    if ischar(checkTitleID)
        if isempty(checkTitleID)
            checkTitleID={};
        else

            checkTitleID={checkTitleID};
        end
    end
    for i=1:length(checkTitleID)
        if this.CheckIDMap.isKey(checkTitleID{i})
            if this.updateCheck(this.CheckIDMap(checkTitleID{i}),true)
                selectCount=selectCount+1;
            end
        else
            newID=ModelAdvisor.convertCheckID(checkTitleID{i});
            if this.CheckIDMap.isKey(newID)
                modeladvisorprivate('modeladvisorutil2','WarnOldCheckID',checkTitleID{i},newID);
                if this.updateCheck(this.CheckIDMap(newID),true)
                    selectCount=selectCount+1;
                end
            end
        end
    end

    if selectCount==length(checkTitleID)
        success=true;
    end

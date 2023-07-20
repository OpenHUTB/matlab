function checkStatusArray=getCheckResultStatus(this,checkArray)




    checkStatusArray={};
    if ischar(checkArray)

        checkArray={checkArray};
        isCellOperation=false;
    else
        isCellOperation=true;
    end

    for i=1:length(checkArray)
        noMatchFound=true;
        if this.CheckIDMap.isKey(checkArray{i})
            noMatchFound=false;
            if isCellOperation
                checkStatusArray{end+1}=(this.CheckCellarray{this.CheckIDMap(checkArray{i})}.status==ModelAdvisor.CheckStatus.Passed);%#ok<AGROW>
            else
                checkStatusArray=this.CheckCellArray{this.CheckIDMap(checkArray{i})}.status==ModelAdvisor.CheckStatus.Passed;
            end
        end


        if noMatchFound
            newID=ModelAdvisor.convertCheckID(checkArray{i});
            if~isempty(newID)
                modeladvisorprivate('modeladvisorutil2','WarnOldCheckID',checkArray{i},newID);
                if this.CheckIDMap.isKey(newID)
                    if isCellOperation
                        checkStatusArray{end+1}=(this.CheckCellarray{this.CheckIDMap(newID)}.status==ModelAdvisor.CheckStatus.Passed);%#ok<AGROW>
                    else
                        checkStatusArray=(this.CheckCellArray{this.CheckIDMap(newID)}.status==ModelAdvisor.CheckStatus.Passed);
                    end
                end
            end
        end
    end

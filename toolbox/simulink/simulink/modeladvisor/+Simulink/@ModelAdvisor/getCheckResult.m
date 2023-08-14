function ResultCellArray=getCheckResult(this,checkIDArray)




    ResultCellArray={};
    if ischar(checkIDArray)
        checkIDArray={checkIDArray};
        isCellOperation=false;
    else
        isCellOperation=true;
    end
    for i=1:length(checkIDArray)
        noMatchFound=true;
        if this.CheckIDMap.isKey(checkIDArray{i})
            noMatchFound=false;
            if isCellOperation
                ResultCellArray{end+1}=this.CheckCellarray{this.CheckIDMap(checkIDArray{i})}.Result;%#ok<AGROW>
            else
                ResultCellArray=this.CheckCellArray{this.CheckIDMap(checkIDArray{i})}.Result;
            end
        end


        if noMatchFound
            newID=ModelAdvisor.convertCheckID(checkIDArray{i});
            if~isempty(newID)
                modeladvisorprivate('modeladvisorutil2','WarnOldCheckID',checkIDArray{i},newID);
                if this.CheckIDMap.isKey(newID)
                    if isCellOperation
                        ResultCellArray{end+1}=this.CheckCellarray{this.CheckIDMap(newID)}.Result;%#ok<AGROW>
                    else
                        ResultCellArray=this.CheckCellArray{this.CheckIDMap(newID)}.Result;
                    end
                end
            end
        end
    end


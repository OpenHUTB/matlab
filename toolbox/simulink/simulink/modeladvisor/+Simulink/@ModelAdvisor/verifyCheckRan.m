function[success,missingCheckArray,additionCheckArray]=verifyCheckRan(this,checkIDArray)





    runnedArray={};
    notrunnedArray={};
    if ischar(checkIDArray)
        checkIDArray={checkIDArray};
    end

    for i=1:length(checkIDArray)
        newID=ModelAdvisor.convertCheckID(checkIDArray{i});
        if~isempty(newID)
            checkIDArray{i}=newID;
        end
    end
    quickLocalReference=this.CheckCellarray;
    for j=1:length(quickLocalReference)
        if isempty(quickLocalReference{j}.Result)
            notrunnedArray{end+1}=quickLocalReference{j}.ID;%#ok<AGROW>
        else
            runnedArray{end+1}=quickLocalReference{j}.ID;%#ok<AGROW>
        end
    end

    missingCheckArray=setdiff(checkIDArray,runnedArray);
    additionCheckArray=setdiff(runnedArray,checkIDArray);
    success=isempty(missingCheckArray)&&isempty(additionCheckArray);

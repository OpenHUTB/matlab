function[CheckIDArray,CheckSerialNumArray]=getSelectedCheck(this)




    CheckIDArray={};
    CheckSerialNumArray={};
    quickLocalReference=this.CheckCellarray;
    for i=1:length(quickLocalReference)
        if quickLocalReference{i}.Selected
            CheckIDArray{end+1}=quickLocalReference{i}.ID;%#ok<*AGROW>
            CheckSerialNumArray{end+1}=i;
        end
    end

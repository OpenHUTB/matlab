function[CheckIDArray,CheckSerialNumArray]=getSelectedCheckForTask(this)




    CheckIDArray={};
    CheckSerialNumArray={};

    for i=1:length(this.CheckCellarray)
        if this.CheckCellarray{i}.SelectedByTask
            CheckIDArray{end+1}=this.CheckCellarray{i}.ID;%#ok<AGROW>
            CheckSerialNumArray{end+1}=i;%#ok<AGROW>
        end
    end

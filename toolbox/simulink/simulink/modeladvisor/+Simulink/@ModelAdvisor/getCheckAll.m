function CheckIDArray=getCheckAll(this)




    CheckIDArray={};

    for i=1:length(this.CheckCellarray)
        CheckIDArray{end+1}=this.CheckCellarray{i}.ID;%#ok<AGROW>
    end

function result=deleteExclusion(this,rowsData)



    numRows=length(rowsData);
    rowNums=zeros(1,numRows);
    for ind=1:numRows
        rowNums(ind)=rowsData(ind).rows.start+1;
    end

    rowNums=rowNums(rowNums~=0);
    rowNums=sort(rowNums);

    this.TableData(rowNums)=[];
    result=this.TableData;
    this.updateDialogForAction(this.UpdateDialogAction.Dirty);
end

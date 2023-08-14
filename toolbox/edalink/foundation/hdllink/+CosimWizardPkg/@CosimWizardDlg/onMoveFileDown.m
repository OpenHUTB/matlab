function onMoveFileDown(this,dialog)


    row=dialog.getSelectedTableRow('edaFileList');
    [TotalRowNumber,~]=size(this.FileTable);
    if(row>=0&&row<TotalRowNumber-1)

        tmp=this.FileTable(row+1,:);
        this.FileTable(row+1,:)=this.FileTable(row+2,:);
        this.FileTable(row+2,:)=tmp;

        dialog.refresh;
        dialog.selectTableRow('edaFileList',row+1);
    end
end



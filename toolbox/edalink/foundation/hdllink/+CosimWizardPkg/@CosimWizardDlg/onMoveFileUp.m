function onMoveFileUp(this,dialog)


    row=dialog.getSelectedTableRow('edaFileList');
    if(row>0)


        tmp=this.FileTable(row+1,:);
        this.FileTable(row+1,:)=this.FileTable(row,:);
        this.FileTable(row,:)=tmp;

        dialog.refresh;
        dialog.selectTableRow('edaFileList',row-1);

    end
end


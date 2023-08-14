function onRemoveHdlFile(this,dlg)


    row=dlg.getSelectedTableRows('edaFileList');
    if~isempty(row)
        this.FileTable(row+1,:)=[];
        dlg.refresh;
        [newRow,~]=size(this.FileTable);
        if(newRow)
            rowselect=min(row);
            if(rowselect>newRow-1)
                rowselect=newRow-1;
            end
            dlg.selectTableRow('edaFileList',rowselect);
        end

    end
end



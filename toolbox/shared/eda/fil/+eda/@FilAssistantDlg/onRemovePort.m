function onRemovePort(this,dlg)



    row=dlg.getSelectedTableRows('edaPortTable');
    if(~isempty(row))
        this.PortTableData(row+1,:)=[];
        dlg.refresh;
        [newRow,~]=size(this.PortTableData);
        if(newRow)
            rowselect=min(row);
            if(rowselect>newRow-1)
                rowselect=newRow-1;
            end
            dlg.selectTableRow('edaPortTable',rowselect);
        end
    end
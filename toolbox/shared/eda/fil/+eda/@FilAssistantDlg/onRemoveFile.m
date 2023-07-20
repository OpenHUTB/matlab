function onRemoveFile(this,dlg)




    row=dlg.getSelectedTableRows('edaSourceFiles');
    if(~isempty(row))

        for m=length(row):-1:1
            this.BuildInfo.removeSourceFile(row(m)+1);
        end

        this.FileTableData(row+1,:)=[];
        dlg.refresh;

        [newRow,~]=size(this.FileTableData);
        if(newRow)
            rowselect=min(row);
            if(rowselect>newRow-1)
                rowselect=newRow-1;
            end
            dlg.selectTableRow('edaSourceFiles',rowselect);
        end



        if this.IsInHDLWA
            taskObj=Advisor.Utils.convertMCOS(dlg.getSource);
            hdlwa.setOptionsCallBack(taskObj);
            dlg.enableApplyButton(true);
        end

    end
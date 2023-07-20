function onMoveUpFile(this,dlg)



    row=dlg.getSelectedTableRows('edaSourceFiles');
    if(size(row)==1)
        if row>0

            tmp=this.FileTableData(row+1,:);
            this.FileTableData(row+1,:)=this.FileTableData(row,:);
            this.FileTableData(row,:)=tmp;


            this.BuildInfo.swapSourceFile(row,row+1);

            dlg.refresh;

            dlg.selectTableRow('edaSourceFiles',row-1);



            if this.IsInHDLWA
                taskObj=Advisor.Utils.convertMCOS(dlg.getSource);
                hdlwa.setOptionsCallBack(taskObj);
                dlg.enableApplyButton(true);
            end
        end
    end
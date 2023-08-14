function onMoveDownFile(this,dlg)




    row=dlg.getSelectedTableRows('edaSourceFiles');
    if(size(row)==1)
        [TotalRowNumber,~]=size(this.FileTableData);
        if row>=0&&row<TotalRowNumber-1

            tmp=this.FileTableData(row+1,:);
            this.FileTableData(row+1,:)=this.FileTableData(row+2,:);
            this.FileTableData(row+2,:)=tmp;


            this.BuildInfo.swapSourceFile(row+1,row+2);

            dlg.refresh;

            dlg.selectTableRow('edaSourceFiles',row+1);



            if this.IsInHDLWA
                taskObj=Advisor.Utils.convertMCOS(dlg.getSource);
                hdlwa.setOptionsCallBack(taskObj);
                dlg.enableApplyButton(true);
            end
        end
    end

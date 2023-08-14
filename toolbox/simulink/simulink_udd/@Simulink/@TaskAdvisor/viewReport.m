function viewReport(this)




    if~isempty(this.MAObj)&&~isempty(this.MAObj.AtticData)&&~isempty(this.MAObj.AtticData.DiagnoseRightFrame)
        if exist(this.MAObj.AtticData.DiagnoseRightFrame,'file')
            this.MAObj.displayReport(this.MAObj.AtticData.DiagnoseRightFrame);
        else
            warndlg(DAStudio.message('Simulink:tools:MAReportNotExist'));
        end
    end

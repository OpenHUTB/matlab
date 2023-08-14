function exportReport(this)




    if strcmp(this.MAObj.CustomTARootID,'_modeladvisor_');
        dlgObj=ModelAdvisor.ExportPDFDialog.getInstance();
        dlgs=DAStudio.ToolRoot.getOpenDialogs(dlgObj);
        if isa(dlgs,'DAStudio.Dialog')
            dlgs.show;
        else
            dlgObj.TaskNode=this;
            DAStudio.Dialog(dlgObj);
        end
    else
        srcFilename=['report_',num2str(this.index),'.html'];
        MdlAdvHandle=this.MAObj;
        report=[MdlAdvHandle.getWorkDir('CheckOnly'),filesep,srcFilename];
        if~(exist(report,'file'))
            this.viewReport('saveas');
        end
        [filename,filepath]=uiputfile('.html',DAStudio.message('Simulink:tools:MASaveAs'),srcFilename);
        dstFileName=[filepath,filename];
        if(dstFileName(1)~=0)
            [success,message]=MdlAdvHandle.exportReport(dstFileName,srcFilename);
            if~success
                errordlg(message);
            end
        end
    end
function out=captureDialog(this,d,objH)






    out=[];

    if isempty(objH)
        this.status(getString(message('rptgen:RptDialogSnapshot:NoCurrentObject')));
        return;
    end

    if isa(objH,'Simulink.Block')






        openParameterDlg=true;
        if strcmp(objH.Mask,'on')
            try
                open_system(objH.Handle,'mask');
                openParameterDlg=false;
            catch ex %#ok<NASGU>

            end
        end

        if openParameterDlg
            try
                open_system(objH.Handle,'parameter');
            catch ex
                this.status(getString(message('rptgen:RptDialogSnapshot:UnableToCreate')),2);
                this.status(ex.message,5);
                return;
            end
        end


        allDialogs=DAStudio.ToolRoot.getOpenDialogs;

        dlgH=[];
        for i=1:length(allDialogs)
            if isa(allDialogs(i).getDialogSource,'Simulink.SLDialogSource')&&...
                allDialogs(i).getDialogSource.getBlock==objH
                dlgH=allDialogs(i);
                break;
            end
        end

        if isempty(dlgH)
            this.status(getString(message('rptgen:RptDialogSnapshot:UnableToCreate')),2);
            return;
        end

    else
        try
            dlgH=DAStudio.Dialog(objH);
        catch ex
            this.status(getString(message('rptgen:RptDialogSnapshot:UnableToCreate')),2);
            this.status(ex.message,5);
            return;
        end
    end

    if this.CaptureTabs
        dlgIm=DAStudio.imDialog.getIMWidgets(dlgH);
        out=this.traverseTabs(d,dlgH,dlgIm);
    end

    if isempty(out)


        try
            out=this.gr_makeGraphic(d,dlgH);
        catch ex
            this.status(getString(message('rptgen:RptDialogSnapshot:UnableToSnapshot')),2);
            this.status(ex.message,5);
        end
    end

    try
        delete(dlgH);
    catch ex %#ok<NASGU>
    end

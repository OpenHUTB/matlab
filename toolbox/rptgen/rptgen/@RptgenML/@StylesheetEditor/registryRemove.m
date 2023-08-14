function registryRemove(this,showWarning)





    if nargin>1&&showWarning
        cancelStr=getString(message('rptgen:RptgenML_StylesheetEditor:cancelLabel'));
        qAnswer=questdlg(...
        sprintf(getString(message('rptgen:RptgenML_StylesheetEditor:removeStylesheetConfirmationMsg')),...
        this.ID,this.Registry),...
        getString(message('rptgen:RptgenML_StylesheetEditor:deleteStylesheetLabel')),...
        getString(message('rptgen:RptgenML_StylesheetEditor:okLabel')),cancelStr,cancelStr);
        if strcmp(qAnswer,cancelStr)
            return;
        end
    end




    openedSS=find(RptgenML.Root,'ID',this.ID,'Registry',this.Registry);
    if~isempty(openedSS)
        closeReport(RptgenML.Root,openedSS);
    end


    removeStylesheetFromLibrary(RptgenML.StylesheetRoot,this);


    if~isempty(this.JavaHandle)
        removeFromRegistry(this.JavaHandle);
    else
        if rptgen.use_java
            com.mathworks.toolbox.rptgen.xml.StylesheetEditor.removeFromRegistry(...
            java.io.File(this.Registry),this.ID);
        else
            mlreportgen.re.internal.ui.StylesheetEditor.removeFromRegistry(...
            this.Registry,this.ID);
        end
    end

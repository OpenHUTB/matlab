function fileName=cbkSave(this,saveDoc,saveAs)









    if((nargin<2)||isempty(saveDoc))
        saveDoc=this.getCurrentDoc;
    end

    if((nargin<3)||isempty(saveAs))
        saveAs=false;
    end

    try
        dlgH=this.getCurrentDialog();
        if~isempty(dlgH)
            dlgH.apply;
        end
        fileName=doSave(saveDoc,saveAs);
    catch ME

        if(strcmp(ME.identifier,'MATLAB:UndefinedFunction')&&isempty(saveDoc))
            warndlg(getString(message('rptgen:RptgenML_Root:cannotSaveUntilLoaded')));
        else
            warndlg(ME.message);
        end

        fileName='';
    end

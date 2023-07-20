function[status,errStr]=closeCallback(this,dlg)




    status=true;
    errStr='';

    if this.needSave
        saveStr=getString(message('Sldv:Filter:Save'));
        ignoreStr=getString(message('Sldv:Filter:Ignore'));
        buttonRes=questdlg(getString(message('Sldv:Filter:UnsavedChanges')),...
        getString(message('Sldv:Filter:SaveUnappliedChanges')),...
        saveStr,...
        ignoreStr,...
        ignoreStr);
        if strcmpi(buttonRes,saveStr)
            this.saveFilterCallback;
        end
    end
    this.hasUnappliedChanges=false;
    this.reset;
    this.updateResults;
    this.delete;
end

function[status,errStr]=closeCallback(this,dlg)




    status=true;
    errStr='';

    if this.needSave
        saveStr=getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveFilter'));
        ignoreStr=getString(message('Slvnv:simcoverage:cvresultsexplorer:UnappliedChangesIgnore'));
        buttonRes=questdlg(getString(message('Slvnv:simcoverage:cvresultsexplorer:UnappliedChangesMsg')),...
        getString(message('Slvnv:simcoverage:cvresultsexplorer:UnappliedChangesAplpyChanges')),...
        saveStr,...
        ignoreStr,...
        ignoreStr);
        if strcmpi(buttonRes,saveStr)
            this.saveFilterCallback(dlg);
        end
    end
    this.hasUnappliedChanges=false;
    this.reset();
    this.delete();



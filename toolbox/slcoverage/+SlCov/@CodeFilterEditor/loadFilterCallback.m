function loadFilterCallback(this,dlg)




    fileFilter={'*.cvf',getString(message('Slvnv:simcoverage:cvresultsexplorer:CoverageFilterFiles'));...
    '*.*',getString(message('Slvnv:simcoverage:cvresultsexplorer:AllFiles'))};
    title=getString(message('Slvnv:simcoverage:cvresultsexplorer:LoadFilter'));
    [fileName,path,~]=uigetfile(fileFilter,title);

    if fileName~=0
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

        this.reset();
        this.fileName=fullfile(path,fileName);
        this.load(this.fileName);
        this.hasUnappliedChanges=false;
        this.lastFilterElement={};
        if~isempty(this.nameTag)
            dlg.clearWidgetDirtyFlag(this.nameTag);
        end
        if~isempty(this.descriptionTag)
            dlg.clearWidgetDirtyFlag(this.descriptionTag);
        end
    end



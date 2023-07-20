function loadFilterCallback(this)




    fileFilter={'*.cvf',getString(message('Sldv:Filter:FilterFiles'));...
    '*.*',getString(message('Sldv:Filter:AllFiles'))};
    title=getString(message('Sldv:Filter:dvFilterLoad'));
    [fileName,path,~]=uigetfile(fileFilter,title);
    if fileName~=0
        if this.needSave
            saveStr=getString(message('Sldv:Filter:Save'));
            ignoreStr=getString(message('Sldv:Filter:Ignore'));
            buttonRes=questdlg(getString(message('Sldv:Filter:UnsavedChangesBeforeLoad')),...
            getString(message('Sldv:Filter:SaveUnappliedChanges')),...
            saveStr,...
            ignoreStr,...
            ignoreStr);
            if strcmpi(buttonRes,saveStr)
                this.saveFilterCallback;
            end
        end
        this.reset;
        this.fileName=fullfile(path,fileName);
        this.load(this.fileName);
        this.hasUnappliedChanges=false;
        this.lastFilterElement={};


        this.updateResults;
    end
end

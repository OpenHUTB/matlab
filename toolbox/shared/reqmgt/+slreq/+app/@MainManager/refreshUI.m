function refreshUI(this,dasObj)



    editor=this.requirementsEditor;

    if~isempty(editor)
        if nargin<2||isempty(dasObj)
            editor.refreshUI();
        else
            editor.refreshUI(dasObj);
        end
    end

    spmgr=this.spreadsheetManager;

    if~isempty(spmgr)
        if nargin<2||isempty(dasObj)
            spmgr.refreshUI();
        else
            spmgr.refreshUI(dasObj);
        end
    end
end

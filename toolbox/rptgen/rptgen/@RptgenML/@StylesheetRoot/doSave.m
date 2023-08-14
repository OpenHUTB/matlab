function fileName=doSave(this,isSaveAs)





    if(nargin<2)
        isSaveAs=false;
    end

    thisChild=this.down;
    fileName='empty';
    while~isempty(thisChild)&&~isempty(fileName)
        try
            canSaveChild=canSave(thisChild);
        catch ME %#ok
            canSaveChild=false;
        end

        if canSaveChild
            try
                fileName=doSave(thisChild,isSaveAs);
            catch ME
                errordlg(ME.message,getString(message('rptgen:RptgenML_StylesheetRoot:saveErrorLabel')));
                fileName='';
            end
        end
        thisChild=thisChild.right;
    end





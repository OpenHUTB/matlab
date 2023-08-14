function continueAction=warnDirtyStylesheet(this,id)








    continueAction=true;
    ssDirty=findDirtyStylesheet(this,id);
    if~isempty(ssDirty)
        optConvert=getString(message('rptgen:RptgenML_StylesheetRoot:convertAnywayLabel'));
        optConvertSave=getString(message('rptgen:RptgenML_StylesheetRoot:saveAndConvertLabel'));
        optCancel=getString(message('rptgen:RptgenML_StylesheetRoot:cancelLabel'));
        btnSelection=questdlg(sprintf(getString(message('rptgen:RptgenML_StylesheetRoot:saveStylesheetMsg')),ssDirty.DisplayName),...
        getString(message('rptgen:RptgenML_StylesheetRoot:editingStylesheetLabel')),...
        optConvert,optConvertSave,optCancel,optCancel);

        switch btnSelection
        case optConvert

        case optConvertSave
            ssDirty.doSave;
        otherwise
            continueAction=false;
        end
    end


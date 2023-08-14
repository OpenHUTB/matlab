function dLabel=getDisplayLabel(this)




    dLabel=this.DisplayName;
    if isempty(this.JavaHandle)
        if isempty(dLabel)
            dLabel=getString(message('rptgen:RptgenML_StylesheetEditor:stylesheetEditorLabel'));
        end
        return;
    elseif isempty(dLabel)
        dLabel=getString(message('rptgen:RptgenML_StylesheetEditor:unnamedSheetLabel'));
    end

    if this.getDirty
        dirtyFlag='*';
    else
        dirtyFlag='';
    end

    dType=getString(message('rptgen:RptgenML_StylesheetEditor:stylesheetLabel'));

    dLabel=[dType,' - ',dLabel,dirtyFlag];
function filterRemoveCallback(this,dlg,widgetTag,forCode)




    try
        if nargin<1
            forCode=false;
        end
        c='';
        if forCode
            c='c';
        end
        rowIdx=dlg.getSelectedTableRow(widgetTag)+1;
        propName=[c,'tableIdxMap'];
        prop=[];
        if this.(propName).isKey(rowIdx)
            prop=this.(propName)(rowIdx);
            this.removeFilterByProp(prop);
            this.([c,'lastKeyAdded'])=[];
        end

        if~isempty(dlg)
            dlg.refresh();
            this.hasUnappliedChanges=true;
            dlg.enableApplyButton(true);
        end
    catch MEx
        rethrow(MEx);
    end
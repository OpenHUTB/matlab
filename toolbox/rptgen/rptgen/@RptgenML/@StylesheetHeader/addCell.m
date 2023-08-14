function newCell=addCell(this)





    chooseEl=this.getChooseElement;
    if isempty(chooseEl)

        newCell=[];
    else
        newCell=RptgenML.StylesheetHeaderCell(this,...
        [],...
        chooseEl.getFirstChild);

        r=RptgenML.Root;
        if~isempty(r.Editor)&&~isempty(newCell)
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('HierarchyChangedEvent',this);

            r.Editor.view(newCell);
        end
    end


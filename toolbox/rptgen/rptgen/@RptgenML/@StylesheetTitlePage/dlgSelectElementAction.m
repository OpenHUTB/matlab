function dlgSelectElementAction(this,dlg,elemIdx)





    elem=this.Format.getIncludeElement(this.IncludedElementNames(elemIdx+1));
    this.CurrElemRow=elem.RowNum-1;
    dlg.setWidgetValue('TitlePageRecto_ElementLORow',elem.RowNum-1);
    this.CurrElemRowSpan=elem.RowSpan;
    dlg.setWidgetValue('TitlePageRecto_ElementLORowSpan',elem.RowSpan);
    this.CurrElemCol=elem.ColNum-1;
    dlg.setWidgetValue('TitlePageRecto_ElementLOCol',elem.ColNum-1);
    this.CurrElemColSpan=elem.ColSpan;
    dlg.setWidgetValue('TitlePageRecto_ElementLOColSpan',elem.ColSpan);
    this.CurrElemHAlign=elem.HAlign;
    dlg.setWidgetValue('TitlePageRecto_ElementLOHAlign',elem.HAlign);




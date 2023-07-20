function out=simrfV2create_panel(this,panelname,items,layout)




    out.Type='panel';
    out.Name='';
    out.Tag=panelname;
    out.Items=items;
    out.LayoutGrid=layout.LayoutGrid;
    out.RowSpan=layout.RowSpan;
    out.ColSpan=layout.ColSpan;
    out.RowStretch=layout.RowStretch;



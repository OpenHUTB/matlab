function out=rfblkscreate_panel(this,panelname,items,layout)




    out=rfblksGetContainerWidgetBase('panel','',panelname);
    out.Items=items;
    out.LayoutGrid=layout.LayoutGrid;
    out.RowSpan=layout.RowSpan;
    out.ColSpan=layout.ColSpan;
    out.RowStretch=layout.RowStretch;


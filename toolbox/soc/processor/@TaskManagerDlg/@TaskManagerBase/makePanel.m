function pnlWidget=makePanel(h,name,tag,items,rowSpan,colSpan,layout,rowStretch,colStretch,enb,vis)%#ok<INUSL>




    pnlWidget.Name=name;
    pnlWidget.Type='panel';
    pnlWidget.Tag=tag;
    pnlWidget.RowSpan=rowSpan;
    pnlWidget.ColSpan=colSpan;
    pnlWidget.LayoutGrid=layout;
    pnlWidget.RowStretch=rowStretch;
    pnlWidget.ColStretch=colStretch;
    pnlWidget.Enabled=enb;
    pnlWidget.Visible=vis;
    pnlWidget.Items=items;
end

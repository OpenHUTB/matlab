function grpWidget=makeGroup(h,name,tag,items,rowSpan,colSpan,layout,rowStretch,colStretch,enb,vis)%#ok<INUSL>




    if isempty(rowStretch),rowStretch=[zeros(1,layout(1)-1),1];end
    if isempty(colStretch),colStretch=[zeros(1,layout(2)-1),1];end
    grpWidget.Name=name;
    grpWidget.Tag=tag;
    grpWidget.Type='group';
    grpWidget.RowSpan=rowSpan;
    grpWidget.ColSpan=colSpan;
    grpWidget.LayoutGrid=layout;
    grpWidget.RowStretch=rowStretch;
    grpWidget.ColStretch=colStretch;
    grpWidget.Visible=vis;
    grpWidget.Enabled=enb;
    grpWidget.Items=items;
end

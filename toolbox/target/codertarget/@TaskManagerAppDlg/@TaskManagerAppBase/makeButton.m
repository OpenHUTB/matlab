function btnWidget=makeButton(h,name,tag,method,rows,cols,enb,vis,tip,align)




    btnWidget.Name=name;
    btnWidget.Tag=tag;
    btnWidget.Type='pushbutton';
    btnWidget.RowSpan=rows;
    btnWidget.ColSpan=cols;
    btnWidget.ToolTip=tip;
    btnWidget.MatlabMethod=method;
    btnWidget.MatlabArgs={h,'%dialog'};
    btnWidget.Visible=vis;
    btnWidget.Enabled=enb;
    btnWidget.DialogRefresh=true;
    btnWidget.Alignment=align;
end

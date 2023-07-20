function txtWidget=makeText(h,textStr,tag,rows,cols,enb,vis)%#ok<INUSL>




    txtWidget.Name=textStr;
    txtWidget.Tag=tag;
    txtWidget.Type='text';
    txtWidget.WordWrap=1;
    txtWidget.RowSpan=rows;
    txtWidget.ColSpan=cols;
    txtWidget.Visible=enb;
    txtWidget.Enabled=vis;
end

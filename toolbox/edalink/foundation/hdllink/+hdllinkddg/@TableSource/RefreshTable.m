function RefreshTable(this,dlg)
    arrayfun(@(x)this.RefreshRow(this,dlg,x),1:length(this.RowSources));
end

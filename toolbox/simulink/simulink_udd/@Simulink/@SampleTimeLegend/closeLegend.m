function closeLegend(this)




    this.expandedVarTs={};
    for n=1:length(this.hasExpandedVarTs)
        this.hasExpandedVarTs{n}=-1;
    end
    this.legendDlg={};


function DngOptions_queryHistory_callback(this,dlg)



    selectedIdx=dlg.getWidgetValue('DngOptions_queryHistory');

    if selectedIdx==0
        this.queryString='';
    else
        this.queryString=this.queryHistory{selectedIdx};
    end

    dlg.setWidgetValue('DngOptions_rawQuery',this.queryString)
    this.refreshDlg(dlg);
end


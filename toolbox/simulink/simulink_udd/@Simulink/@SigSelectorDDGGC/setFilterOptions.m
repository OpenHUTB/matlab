function setFilterOptions(this,tag,dlg)










    switch tag
    case 'sigselector_filterOptsExpand'

        dlg.setVisible('sigselector_filterOptsCollapse',true);
        dlg.setVisible('sigselector_filterOptsExpand',false);
        dlg.setVisible('sigselector_filterOptsGroup',true);

        LocalSyncFilteringOptions(dlg,this.TCPeer);
        this.ShowFilteringOptions=true;
        dlg.resetSize
    case 'sigselector_filterOptsCollapse'

        dlg.setVisible('sigselector_filterOptsCollapse',false);
        dlg.setVisible('sigselector_filterOptsExpand',true);
        dlg.setVisible('sigselector_filterOptsGroup',false);

        LocalSyncFilteringOptions(dlg,this.TCPeer);
        this.ShowFilteringOptions=false;
        dlg.resetSize
    case 'sigselector_filterOptsRegExp'
        ischecked=dlg.getWidgetValue('sigselector_filterOptsRegExp');
        this.TCPeer.setRegularExpression(ischecked);
        this.TCPeer.update();
    case 'sigselector_filterOptsFlatList'
        ischecked=dlg.getWidgetValue('sigselector_filterOptsFlatList');
        this.TCPeer.setFlatList(ischecked);
        this.TCPeer.update();
    otherwise

    end
    function LocalSyncFilteringOptions(dlg,tc)
        setWidgetValue(dlg,'sigselector_filterOptsRegExp',tc.getRegularExpression);
        setWidgetValue(dlg,'sigselector_filterOptsFlatList',tc.getFlatList);



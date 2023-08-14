function applyFilter(this,dialog)









    filterStr=getWidgetValue(dialog,'sigselector_filterEdit');
    this.TCPeer.setFilterText(filterStr);
    this.TCPeer.update;







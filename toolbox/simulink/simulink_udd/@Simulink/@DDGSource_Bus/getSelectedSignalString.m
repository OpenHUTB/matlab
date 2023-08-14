function name=getSelectedSignalString(this)





    tc=this.signalSelector.TCPeer;
    name=tc.FullItemNames(tc.SelectedIDs);

end

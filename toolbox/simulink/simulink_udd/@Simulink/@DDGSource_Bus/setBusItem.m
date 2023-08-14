function setBusItem(this,hierarchy)





    tc=this.signalSelector.TCPeer;
    if~isempty(hierarchy)
        item=Simulink.sigselector.BusItem;
        item.Hierarchy=oldFormat2NewFormat(this,hierarchy);
        tc.setItems({item});
    else
        tc.setItems([]);
    end

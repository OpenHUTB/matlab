function updateSelection(this,dlg,sigselectorddg)





    this.unhilite(dlg,false);
    if~(sigselectorddg.TCPeer.isAnyTreeSelection)
        dlg.setEnabled('findButton',0);
        dlg.setEnabled('selectButton',0);
    else
        dlg.setEnabled('findButton',1);
        dlg.setEnabled('selectButton',1);
    end

end


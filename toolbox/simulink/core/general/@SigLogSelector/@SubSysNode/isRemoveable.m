function val=isRemoveable(~)




    me=SigLogSelector.getExplorer;
    val=strcmpi('stopped',me.getRoot.daobject.SimulationStatus);

end

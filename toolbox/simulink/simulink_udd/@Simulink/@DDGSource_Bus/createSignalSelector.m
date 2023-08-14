function createSignalSelector(this,hierarchy)





    opts=Simulink.sigselector.Options;
    opts.ViewType='DDG';
    opts.RootName=DAStudio.message('Simulink:dialog:DDGSource_Bus_SignalsInBus');
    opts.HideBusRoot=true;
    tc=Simulink.sigselector.SigSelectorTC(opts);

    if~isempty(hierarchy)
        item=Simulink.sigselector.BusItem;
        item.Hierarchy=hierarchy;
        tc.setItems({item});
    else
        tc.setItems([]);
    end

    tc.setRegularExpression(true);
    tc.setFlatList(false);
    tc.update;
    selsigviewer=tc.createView;
    selsigviewer.Parent=this;
    this.signalSelector=selsigviewer;

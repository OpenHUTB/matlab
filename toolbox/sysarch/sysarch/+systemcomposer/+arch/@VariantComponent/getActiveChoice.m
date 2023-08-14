function comp=getActiveChoice(this)




    comp=systemcomposer.arch.Component.empty(1,0);

    sourceComp=systemcomposer.internal.getSourceElementForRedefinedElement(this);
    if~isequal(sourceComp.SimulinkHandle,-1)
        activeChoice=get_param(sourceComp.SimulinkHandle,'CompiledActiveChoiceBlock');
        activeChoiceHandle=get_param(activeChoice,'Handle');
        cImpl=systemcomposer.utils.getArchitecturePeer(activeChoiceHandle);
        comp=this.getComponentWrapper(cImpl);
    end

end
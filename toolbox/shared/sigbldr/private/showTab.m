function UD=showTab(UD,dsIdx)





    UD=dataSet_activate(UD,dsIdx);
    sigbuilder_tabselector('activate',UD.hgCtrls.tabselect.axesH,UD.current.dataSetIdx,1);

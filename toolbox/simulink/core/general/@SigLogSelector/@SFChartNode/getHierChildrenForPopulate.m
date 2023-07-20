function children=getHierChildrenForPopulate(h)





    chart=SigLogSelector.SFChartNode.getSFChartObject(h.daobject);
    children=chart.getHierarchicalChildren;
    children=SigLogSelector.filter(children);

end

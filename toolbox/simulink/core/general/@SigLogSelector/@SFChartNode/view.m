function view(h)




    if(~isempty(h.daobject))
        sfobj=SigLogSelector.SFChartNode.getSFChartObject(h.daobject);
        sfobj.view;
    end

end

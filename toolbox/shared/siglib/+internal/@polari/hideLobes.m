function hideLobes(p)









    a=p.hAntenna;
    if~isempty(a)
        removeLobeMarkers(a);
        hideLobes(a);
    end

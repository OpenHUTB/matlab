function updateLegend(p)







    if p.LegendVisible||~isempty(p.hLegend)
        legend(p,true);
    end

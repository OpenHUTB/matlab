function simscapeLegendCB(~,~)
    persistent d;
    if isempty(d)
        try
            d=simscape.internal.DomainStyleLegend;
        catch
        end
    end

    if~isempty(d)
        d.show();
    end
end

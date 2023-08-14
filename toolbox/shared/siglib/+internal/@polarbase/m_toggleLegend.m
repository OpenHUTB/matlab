function m_toggleLegend(p)

    if isLegendVisible(p)
        legend(p,false);
    else
        legend(p,true);
    end

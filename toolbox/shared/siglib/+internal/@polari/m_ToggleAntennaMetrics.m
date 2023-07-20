function m_ToggleAntennaMetrics(p,datasetIndex)


    if nargin>1&&~isempty(datasetIndex)







        a=p.hAntenna;
        if~isempty(a)&&areLobesVisible(a,datasetIndex)
            hideLobes(p);
        else

            showLobes(p,datasetIndex);
        end
    else


        if p.AntennaMetrics;
            hideLobes(p);
        else

            showLobes(p);
        end
    end

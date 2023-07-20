function charts=FilterSFCharts(charts,lookUnderMask,followLinks)

    switch lookUnderMask
    case 'none'
        charts=charts(hasmask(charts)==0);
    case 'graphical'
        charts=charts(hasmask(charts)~=2);
    case 'functional'
        charts=charts(hasmask(charts)~=1);
    end

    if strcmp(followLinks,'off')


        tempCharts=[];
        for k=1:length(charts)
            obj=get_param(charts(k),'object');
            if~obj.isLinked
                tempCharts=[tempCharts,charts(k)];
            end
        end
        charts=tempCharts;

    end
end
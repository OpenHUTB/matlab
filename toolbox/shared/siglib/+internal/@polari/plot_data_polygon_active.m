function plot_data_polygon_active(p)



    ht=p.hDataPatch;
    N=numel(ht);
    for datasetIndex=1:N

        if datasetIndex==p.pCurrentDataSetIndex
            if iscell(p.LineStyle)
                lineStyle=p.LineStyle{...
                1+rem(datasetIndex-1,numel(p.LineStyle))};
            else
                lineStyle=p.LineStyle;
            end
        else
            lineStyle='none';
        end

        ht(datasetIndex).LineStyle=lineStyle;
    end

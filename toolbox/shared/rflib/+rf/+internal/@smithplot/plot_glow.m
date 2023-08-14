function plot_glow(p,state,datasetIdx)





    if nargin<3
        datasetIdx=p.pHoverDataSetIndex;
    end
    if isempty(datasetIdx)

        state=false;
    end

    if state

        switch lower(p.Style)
        case 'line'


            ht=p.hDataLine;
            ht_i=ht(datasetIdx);
            hg=p.hDataLineGlow;
            if~isempty(hg)
                x=ht_i.XData;
                y=ht_i.YData;
                z=ht_i.ZData-0.01;





                if p.ConnectEndpoints&&strcmpi(ht_i.LineStyle,'none')
                    x=x(1:end-1);
                    y=y(1:end-1);
                    z=z(1:end-1);
                end

                hg.XData=x;
                hg.YData=y;
                hg.ZData=z;
                hg.Color=internal.ColorConversion.glowColor(ht_i.Color);
                hg.Visible='on';
                setappdata(hg,'smithiDatasetIndex',datasetIdx);
            end
        end
    else

        switch p.Style
        case 'line'
            if~isempty(p.hDataLineGlow)
                p.hDataLineGlow.Visible='off';
            end
        end
    end

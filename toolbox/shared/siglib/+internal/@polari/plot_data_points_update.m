function plot_data_points_update(p)








    hline=p.hDataLine;
    pdata=getAllDatasets(p);
    Nd=numel(pdata);
    for datasetIndex=1:Nd
        pdata_i=pdata(datasetIndex);

        r=getNormalizedMag(p,pdata_i.mag);
        th=getNormalizedAngle(p,pdata_i.ang);
        if p.ConnectEndpoints
            th=[th;th(1)];%#ok<AGROW>
            r=[r;r(1)];%#ok<AGROW>
        end



        r(r<=0)=eps;
        set(hline(datasetIndex),...
        'XData',r.*cos(th),...
        'YData',r.*sin(th));
    end

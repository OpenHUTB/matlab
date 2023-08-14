function lonlim=pointwiseLongitudeLimits(lon)








    lon=lon(:);


    lon(isnan(lon)|isinf(lon))=[];


    lon=mod(lon+180,360)-180;


    lon=unique(lon);

    if isempty(lon)
        lonlim=[];
    elseif isscalar(lon)

        lonlim=lon([1,1]);
    else



















        lon(end+1)=lon(1)+360;
        delta=mod(diff(lon),360);
        lon(end)=lon(1);
        k=find(delta==max(delta),1);
        lonlim=[lon(k+1),lon(k)];
        if lonlim(2)==-180
            lonlim(2)=180;
        end
    end
end

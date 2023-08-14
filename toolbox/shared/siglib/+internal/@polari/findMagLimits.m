function lim=findMagLimits(p)












    mx=-inf;
    mn=+inf;
    d=getAllDatasets(p);
    for i=1:numel(d)
        mag=d(i).mag;
        if~isempty(mag)

            magf=max(mag(mag~=inf));
            if isempty(magf)
                mx=inf;
            else
                mx=max(mx,magf);
            end


            magf=min(mag(mag~=-inf));
            if isempty(magf)
                mx=-inf;
            else
                mn=min(mn,magf);
            end
        end
    end
    lim=[mn,mx];

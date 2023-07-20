function extents=getColorAlphaDataExtents(hObj)




    colorExtent=[NaN,NaN];
    if strcmp(hObj.CLimInclude,'on')
        colorExtent=getColorDataExtent(hObj);
    end


    alphaExtent=[NaN,NaN,NaN,NaN];


    extents=[colorExtent;alphaExtent];
end

function colorExtent=getColorDataExtent(hObj)



    Z=hObj.ZData;
    levelList=getLevelListImpl(hObj);
    if strcmp(hObj.FaceColor,'none')
        cLevels=lineColorLevels(Z,levelList);
    else
        cLevels=fillColorLevels(Z,levelList);
    end


    k=find(isfinite(cLevels));
    colorExtent=matlab.graphics.chart.primitive.utilities.arraytolimits(cLevels(k));
end

function cLevels=fillColorLevels(Z,zLevels)





    cLevels=NaN(1,1+size(zLevels,2));

    Z=Z(:);
    Z(isnan(Z))=[];
    Z=unique(Z);
    zmin=min(Z);
    zmax=max(Z);

    if~isempty(zmin)&&zLevels(1)<=zmin
        cLevels(1)=zmin;
    end

    n=length(zLevels);
    if~isempty(Z)
        for k=1:(n-1)


            if any((zLevels(k)<=Z)&(Z<zLevels(k+1)))
                cLevels(k+1)=max(zmin,zLevels(k));
            end
        end
    end

    if~isempty(zmax)&&zLevels(end)<=zmax
        cLevels(end)=zLevels(end);
    end


    if~isempty(zmin)&&all(zLevels<zmin)
        cLevels(:)=zmin;
    end
end

function cLevels=lineColorLevels(Z,zLevels)





    cLevels=NaN(size(zLevels));
    [lo,hi]=intervals(Z);
    if~isempty(lo)&&~isempty(hi)
        for k=1:length(cLevels)
            if any(lo<=zLevels(k)&zLevels(k)<=hi)
                cLevels(k)=zLevels(k);
            end
        end
    end
end

function[lo,hi]=intervals(Z)







    T1=Z;
    T1(end+1,:)=NaN;


    T1=T1(:);


    T2=Z';
    T2(end+1,:)=NaN;



    T2=T2(:);



    lo=[T1(1:end-1);T2(1:end-1)];
    hi=[T1(2:end);T2(2:end)];





    q=isnan(lo)|isnan(hi);
    lo(q)=[];
    hi(q)=[];


    q=(lo>hi);
    t=lo(q);
    lo(q)=hi(q);
    hi(q)=t;
end

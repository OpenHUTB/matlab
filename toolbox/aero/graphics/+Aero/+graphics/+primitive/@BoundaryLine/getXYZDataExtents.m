function extents=getXYZDataExtents(hObj,T,constraints)









    if constraints.AllowZeroCrossing(1)
        xscale="linear";
    else
        xscale="log";
    end
    if constraints.AllowZeroCrossing(2)
        yscale="linear";
    else
        yscale="log";
    end


    if~hObj.isDataValid(false)
        extents=nan([3,4]);
        return
    end



    [x,y]=hObj.preProcessData(xscale,yscale,[],[]);


    data=T*([x,y,zeros(size(x,1),2,class(x))]');

    x=data(1,:).';
    y=data(2,:).';







    [normx,linearboundsx]=Aero.internal.math.normalize(x,xscale);
    [normy,linearboundsy]=Aero.internal.math.normalize(y,yscale);



    fudgefactorx=getFudgeFactor(linearboundsx,hObj.HatchLength_I,xscale);
    fudgefactory=getFudgeFactor(linearboundsy,hObj.HatchLength_I,yscale);

    minx=min(normx)-fudgefactorx;
    maxx=max(normx)+fudgefactorx;
    miny=min(normy)-fudgefactory;
    maxy=max(normy)+fudgefactory;


    denormx=Aero.internal.math.denormalize([minx,maxx],linearboundsx,xscale);
    denormy=Aero.internal.math.denormalize([miny,maxy],linearboundsy,yscale);


    xlim=matlab.graphics.chart.primitive.utilities.arraytolimits(denormx);
    ylim=matlab.graphics.chart.primitive.utilities.arraytolimits(denormy);
    zlim=matlab.graphics.chart.primitive.utilities.arraytolimits(0);

    extents=[xlim;ylim;zlim];

end

function fudgefactor=getFudgeFactor(linearbounds,hatchlength,scale)
    if isempty(linearbounds)








        if scale=="linear"
            fudgefactor=max(hatchlength,1);
        else

            fudgefactor=max(hatchlength,log(10));
        end
    else



        fudgefactor=hatchlength;
    end
end
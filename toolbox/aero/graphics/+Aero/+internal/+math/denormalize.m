function denormdata=denormalize(normdata,linearbounds,scale)








    if isempty(linearbounds)


        denormdata=normdata;
    else
        denormdata=Aero.internal.math.map(normdata,[0,1],linearbounds);
    end

    if scale=="log"

        denormdata=exp(denormdata);
    end
end
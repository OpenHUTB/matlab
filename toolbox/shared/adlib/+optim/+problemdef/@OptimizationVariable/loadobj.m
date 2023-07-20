function vout=loadobj(vin)








    if vin.OptimizationExpressionVersion==1
        vout=optim.problemdef.OptimizationVariable;

        vout=reloadv1tov2(vout,vin);
    else
        vout=vin;
    end
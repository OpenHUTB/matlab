function flag=useBlockWrapper(lutModelData,options)







    flag=false;





    dataType=lutModelData.OutputType;
    if~isfloat(dataType)&&~isempty(options)
        minTol=FunctionApproximation.internal.Utils.getMinimumAbsoluteTolerance(dataType);
        nD=lutModelData.NumberOfDimensions;
        if(minTol*2*(nD^2-nD+1)>=options.AbsTol)
            flag=true;
        end
    end





    if~flag&&~isempty(options)
        flag=(options.Interpolation=="Flat")&&(lutModelData.NumberOfDimensions>1);
    end
end

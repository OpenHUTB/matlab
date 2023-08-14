function flag=isSpacingPerfectlyEven(vectorOfValues,dataType)








    nValues=numel(vectorOfValues);

    if~(isvector(vectorOfValues)&&nValues>1)
        error(message('SimulinkFixedPoint:autoscaling:isSpacingPerfectlyEvenInputValidation'));
    end

    if nargin<2
        values=vectorOfValues;
    else

        values=fi(vectorOfValues,dataType);
    end

    if isfi(values)&&values.isscalingslopebias

        flag=true;
        for ii=3:nValues
            diff1=SimulinkFixedPoint.AutoscalerUtils.subtractSlopeBiasFiValues(values(ii),values(ii-1));
            diff2=SimulinkFixedPoint.AutoscalerUtils.subtractSlopeBiasFiValues(values(ii-1),values(ii-2));
            if diff1~=diff2
                flag=false;
                break;
            end
        end
    else
        flag=true;
        for ii=3:nValues
            diff1=values(ii)-values(ii-1);
            diff2=values(ii-1)-values(ii-2);
            if diff1~=diff2
                flag=false;
                break;
            end
        end
    end
end



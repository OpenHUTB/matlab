function isInRange=checkDesignRangeWithEps(curVal,designMin,designMax,evaluatedDt)




    isInRange=true;




    if~isempty(curVal)&&~isempty(evaluatedDt)&&~isinf(curVal)

        if~isempty(designMin)




            isInRange=curVal>=designMin||fi(curVal,evaluatedDt)>=fi(designMin,evaluatedDt);
        end


        if isInRange&&~isempty(designMax)




            isInRange=curVal<=designMax||fi(curVal,evaluatedDt)<=fi(designMax,evaluatedDt);
        end

    end
end

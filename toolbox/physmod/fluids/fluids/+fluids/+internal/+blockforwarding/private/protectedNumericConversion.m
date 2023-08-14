function PrOtEcTeD_EvAlUaTeD_VaLuE=protectedNumericConversion(PrOtEcTeD_ExPrEsSiOn_To_EvAlUaTe)







    try
        PrOtEcTeD_EvAlUaTeD_VaLuE=eval(PrOtEcTeD_ExPrEsSiOn_To_EvAlUaTe);
    catch
        PrOtEcTeD_EvAlUaTeD_VaLuE=[];
    end


    if~isnumeric(PrOtEcTeD_EvAlUaTeD_VaLuE)
        PrOtEcTeD_EvAlUaTeD_VaLuE=[];
    end

end
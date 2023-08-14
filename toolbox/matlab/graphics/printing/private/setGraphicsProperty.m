function setGraphicsProperty(obj,propName,val,useOriginalHGPrinting)










    if useOriginalHGPrinting
        try
            set(obj,[propName,'_I'],val);
        catch
            set(obj,propName,val);
        end
    else
        set(obj,propName,val);
    end
end


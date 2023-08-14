function out=getSLVerForSLCI(aObj)





    if aObj.fSlVerForSLCI<0
        try
            aObj.fSlVerForSLCI=slprivate('slVerForSLCI');
        catch
            aObj.fSlVerForSLCI=int32(0);
        end
    end
    out=aObj.fSlVerForSLCI;
end

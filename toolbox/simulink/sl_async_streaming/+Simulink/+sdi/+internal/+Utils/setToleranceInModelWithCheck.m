function setToleranceInModelWithCheck(blk,portIndex,tolType,tolValueStr)








    tolValue=str2double(tolValueStr);
    if~isnan(tolValue)&&isreal(tolValue)&&tolValue>=0
        Simulink.sdi.internal.Utils.setToleranceInModel(blk,portIndex,tolType,tolValue);
    end
end

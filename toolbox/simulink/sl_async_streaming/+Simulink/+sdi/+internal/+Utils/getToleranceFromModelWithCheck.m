function tolValue=getToleranceFromModelWithCheck(blk,portIndex,tolType)








    tolValue=Simulink.sdi.internal.Utils.getToleranceFromModel(blk,portIndex,tolType);
    if isempty(tolValue)
        tolValue=-1;
    end
end
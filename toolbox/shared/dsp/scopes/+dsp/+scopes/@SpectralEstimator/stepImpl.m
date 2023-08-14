function[PSD,PSDMaxHold,PSDMinHold,F]=stepImpl(obj,x)




    PSD=[];
    PSDMaxHold=[];
    PSDMinHold=[];
    F=[];








    [s1,isDataReady]=obj.pInputProcessingFunction(obj,double(x));

    if isDataReady

        [PSD,PSDMaxHold,PSDMinHold,F]=computePSD(obj,s1);
    end
end

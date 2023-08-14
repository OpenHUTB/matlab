function retStatus=Apply(hThis)







    retStatus=true;

    try

        hBlk=pmsl_getdoublehandle(hThis.BlockHandle);
        hThis.setParamCache(hBlk,hThis.ValueBlkParam,hThis.Value);
        retStatus=hThis.applyChildren();
    catch
        retStatus=false;
    end
end


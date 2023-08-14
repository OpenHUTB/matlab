function retStatus=Realize(hThis)







    retStatus=true;

    try

        strVal=get_param(pmsl_getdoublehandle(hThis.BlockHandle),hThis.ValueBlkParam);
        hThis.Value=strcmpi('on',strVal);

    catch
        retStatus=false;
    end

end
function retStatus=Realize(hThis)







    retStatus=true;

    try


        numVal=get_param(pmsl_getdoublehandle(hThis.BlockHandle),hThis.ValueBlkParam);


        hThis.Value=str2num(numVal);

    catch
        retStatus=false;
    end
end


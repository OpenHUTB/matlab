function retStatus=Realize(hThis)







    retStatus=true;

    try

        hThis.Value=get_param(pmsl_getdoublehandle(hThis.BlockHandle),hThis.ValueBlkParam);


        retStatus=realizeChildren(hThis);
    catch
        retStatus=false;
    end
end


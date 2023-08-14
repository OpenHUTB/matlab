function retStatus=Realize(hThis)







    retStatus=true;

    try
        origVal=get_param(pmsl_getdoublehandle(hThis.BlockHandle),hThis.ValueBlkParam);


        hThis.Value=origVal;
    catch %#ok<CTCH>
        retStatus=false;
    end
end


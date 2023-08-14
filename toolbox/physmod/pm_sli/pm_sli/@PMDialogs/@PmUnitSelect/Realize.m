function retStatus=Realize(hThis)







    retStatus=true;

    try


        defaultUnit=hThis.UnitDefault;
        blockUnit=get_param(pmsl_getdoublehandle(hThis.BlockHandle),...
        hThis.ValueBlkParam);


        [choices,valueStr,valueInt]=...
        pmsl_resolvedialogunit(defaultUnit,blockUnit,hThis.ValueBlkParam);


        hThis.Choices=choices;
        hThis.Value=valueStr;

    catch

        retStatus=false;

    end

end


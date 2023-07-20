function retStatus=Realize(hThis)







    retStatus=true;

    try


        defaultUnit=hThis.UnitDefault;
        blockUnit=get_param(pmsl_getdoublehandle(hThis.BlockHandle),...
        hThis.ValueBlkParam);


        if strcmp(hThis.Label(end),':')
            label=hThis.Label(1:end-1);
        else
            label=hThis.Label;
        end
        [choices,valueStr]=pmsl_resolvedialogunit(defaultUnit,blockUnit,label);





        if pm_isunit(blockUnit)
            if~pm_commensurate(defaultUnit,blockUnit)
                valueStr=blockUnit;
            end
        else
            valueStr=blockUnit;
        end


        hThis.Choices=choices;
        hThis.Value=valueStr;

    catch %#ok<CTCH>

        retStatus=false;

    end

end


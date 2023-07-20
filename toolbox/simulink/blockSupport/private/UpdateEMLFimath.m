function UpdateEMLFimath(block,h)








    if get_param(bdroot(block),'VersionLoaded')<=6.2
        return;
    end


    r=slroot;
    hb=r.find('-isa','Stateflow.EMChart','path',block);

    if isempty(hb)



        hb=r.find('-isa','Stateflow.TruthTableChart','path',block);
        if~isempty(hb)
            UpdateSFTruthTableFimath(block,h);
        end
    else

        UpdateFimath(block,hb,h,...
        'SimulinkBlocks:upgrade:emlFimathCastBeforeSumFalse');


        UpdateFimathForFiConstructors(block,hb,h,...
        'SimulinkBlocks:upgrade:emlFimathForFiConstructorsObsolete');
    end

end

function UpdateSFTruthTableFimath(block,h)







    if~license('test','Stateflow')
        return;
    end


    r=slroot;
    hb=r.find('-isa','Stateflow.TruthTableChart','path',block);


    UpdateFimath(block,hb,h,...
    'SimulinkBlocks:upgrade:SFTruthTableFimathCastBeforeSumFalse');


    UpdateFimathForFiConstructors(block,hb,h,...
    'SimulinkBlocks:upgrade:SFTruthTableFimathForFiConstructorsObsolete');
end

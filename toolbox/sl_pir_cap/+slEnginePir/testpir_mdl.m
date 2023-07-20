

function pirctx=testpir_mdl(mdl)


    load_simulink;
    load_system(mdl);



    oldf=slfeature('EnableAutomaticPIRCreator',0);


    cleanup=onCleanup(@()slfeature('EnableAutomaticPIRCreator',oldf));

    if~exist('h','var')||isempty(h)
        h=slEnginePir.PIRCreator(Simulink.SLPIR.Event.PostBlockSortingModel);
        h.add;
    end

    set_param(mdl,'SLPIR','on');

    sess=Simulink.CMI.CompiledSession(Simulink.EngineInterfaceVal.byFiat);
    bd=Simulink.CMI.CompiledBlockDiagram(sess,mdl);
    bd.init;
    bd.term;
    pirctx=h.getNamedCtx(mdl);

end

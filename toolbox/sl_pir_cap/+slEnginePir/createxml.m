

function createxml(mdl,filename)

    load_simulink;
    load_system(mdl);



    oldf=slfeature('EnableAutomaticPIRCreator',0);


    cleanup=onCleanup(@()slfeature('EnableAutomaticPIRCreator',oldf));

    h=slEnginePir.PIRXMLCreator(...
    Simulink.SLPIR.Event.PostBlockSortingModel,...
    filename);
    h.add;

    set_param(mdl,'SLPIR','on');

    sess=Simulink.CMI.CompiledSession;
    bd=Simulink.CMI.CompiledBlockDiagram(sess,mdl);
    bd.init;




    p=pir(mdl);
    gp=pir;
    gp.setTopPirCtx(p);
    dumpXMLForBA(p,filename);

    bd.term;

end



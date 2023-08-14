


function testGraphicalContextPir(mdl)
    g=pir;
    g.destroy;

    load_simulink;
    load_system(mdl);


    mdlfullname=getfullname(mdl);
    C=textscan(mdlfullname,'%s','Delimiter','/');
    mdlname=C{1}{1};

    [~,refmdls,~]=slEnginePir.all_referlinked_blk(mdlname,[],{},'on');

    o=slEnginePir.CloneDetectionCreator(Simulink.SLPIR.Event.PostCompBlock);
    o.createGraphicalPir([{mdlfullname},refmdls]);

end

function sps=DCMachineBlock(BLOCKLIST,sps)










    MaskType='DC machine';
    idx=BLOCKLIST.filter_type(MaskType);
    blocks=sort(spsGetFullBlockPath(BLOCKLIST.elements(idx)));

    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');
        sps.DCMachines{end+1}=getfullname(block);


        SPSVerifyLinkStatus(block);
        [RLa,RLf,Laf,Ke,Kt,J,Bm,Tf,w0]=getSPSmaskvalues(block,{'RLa','RLf','Laf','Ke','Kt','J','Bm','Tf','w0'});

        [MechanicalLoad]=getSPSmaskvalues(block,{'MechanicalLoad'});

        blocinit(block,{MechanicalLoad,RLa,RLf,Laf,Ke,Kt,J,Bm,Tf,w0});
    end



    idx=BLOCKLIST.filter_type('Discrete DC machine');
    blocks=sort(spsGetFullBlockPath(BLOCKLIST.elements(idx)));

    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');

        SPSVerifyLinkStatus(block);
        [RLa,RLf,Laf,Ke,Kt,J,Bm,Tf,w0]=getSPSmaskvalues(block,{'RLa','RLf','Laf','Ke','Kt','J','Bm','Tf','w0'});
        MechanicalLoad=get_param(block,'MechanicalLoad');
        blocinit(block,{MechanicalLoad,RLa,RLf,Laf,Ke,Kt,J,Bm,Tf,w0});
    end
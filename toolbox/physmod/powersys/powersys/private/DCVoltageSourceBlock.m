function[sps,Multimeter]=DCVoltageSourceBlock(nl,sps,Multimeter)






    idx=nl.filter_type('DC Voltage Source');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));


    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');
        measure=get_param(block,'Measurements');

        Amplitude=getSPSmaskvalues(block,{'Amplitude'});
        blocinit(block,{Amplitude});



        nodes=nl.block_nodes(block);

        sps.source(end+1,1:7)=[nodes(2),nodes(1),0,Amplitude,0,0,21];
        sps.srcstr{end+1}=['U_',BlockNom];


        if~sps.PowerguiInfo.Phasor
            ysrc=size(sps.source,1);

            sps.InputsNonZero(end+1)=ysrc;
        end

        sps.GotoSources{end+1}=get_param([BlockName,'/Goto'],'GotoTag');


        switch measure
        case 'Voltage'
            Multimeter.Yu(end+1,1:2)=sps.source(end,1:2);
            Multimeter.V{end+1}=['Usrc: ',BlockNom];
        end

        sps.modelnames{sps.basicnonlinearmodels+1}{end+1}=block;
        sps.nbmodels(sps.basicnonlinearmodels+1)=sps.nbmodels(sps.basicnonlinearmodels+1)+1;
        sps.sourcenames(end+1,1)=block;
        sps.blksrcnames{end+1}=BlockNom;
        sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.U.Mux(end+1)=1;
    end
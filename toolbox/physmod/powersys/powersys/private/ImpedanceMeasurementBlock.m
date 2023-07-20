function[sps,YuImpedance]=ImpedanceMeasurementBlock(nl,sps)






    idx=nl.filter_type('Impedance Measurement');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    YuImpedance=[];
    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');
        Factor=getSPSmaskvalues(block,{'Factor'});
        blocinit(block,{Factor});


        nodes=nl.block_nodes(block);

        sps.source(end+1,1:7)=[nodes(2),nodes(1),1,0,0,60,20];

        YuImpedance(end+1,1:2)=[nodes(1),nodes(2)];

        sps.srcstr{end+1}=['I_',BlockNom];
        sps.outstr{end+1}=['U_',BlockNom];

        sps.Zblocks{end+1,1}=getfullname(block);
        sps.Zblocks{end,2}=length(sps.srcstr);
        sps.Zblocks{end,3}=length(sps.outstr);
        sps.Zblocks{end,4}=Factor;

        xc=size(sps.modelnames{20},2);
        sps.modelnames{20}(xc+1)=block;
        sps.sourcenames(end+1,1)=block;

        sps.NonlinearDevices.Tags{end+1}='';
        sps.NonlinearDevices.Demux(end+1)=1;
        sps.U.Tags{end+1}='';
        sps.U.Mux(end+1)=1;
    end
    sps.nbmodels(20)=size(sps.modelnames{20},2);
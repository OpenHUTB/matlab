function Multimeter=GroundingTransformerblock(BLOCKLIST,sps,Multimeter)










    idx=BLOCKLIST.filter_type('Grounding Transformer');
    blocks=sort(spsGetFullBlockPath(BLOCKLIST.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');


        SPSVerifyLinkStatus(block);

        Measurements=get_param(block,'Measurements');
        switch Measurements

        case{'Voltages','All voltages and currents'}


            nodes=BLOCKLIST.block_nodes(block);

            Multimeter.Yu(end+1,1:2)=[nodes(1),nodes(4)];
            Multimeter.V{end+1}=['Uan: ',BlockNom];
            Multimeter.Yu(end+1,1:2)=[nodes(2),nodes(4)];
            Multimeter.V{end+1}=['Ubn: ',BlockNom];
            Multimeter.Yu(end+1,1:2)=[nodes(3),nodes(4)];
            Multimeter.V{end+1}=['Ucn: ',BlockNom];
        end

        switch Measurements

        case{'Currents','All voltages and currents'}

            BlockHandleT1=get_param([BlockName,'/T1'],'Handle');
            T1=find(sps.LinearTransformers(:,1)==BlockHandleT1,1);
            Multimeter.Yi{end+1,1}=sps.LinearTransformers(T1,2);
            Multimeter.I{end+1}=['Ian: ',BlockNom];

            BlockHandleT2=get_param([BlockName,'/T2'],'Handle');
            T2=find(sps.LinearTransformers(:,1)==BlockHandleT2,1);
            Multimeter.Yi{end+1,1}=sps.LinearTransformers(T2,2);
            Multimeter.I{end+1}=['Ibn: ',BlockNom];

            BlockHandleT3=get_param([BlockName,'/T3'],'Handle');
            T3=find(sps.LinearTransformers(:,1)==BlockHandleT3,1);
            Multimeter.Yi{end+1,1}=sps.LinearTransformers(T3,2);
            Multimeter.I{end+1}=['Icn: ',BlockNom];

        end
    end
function[sps,Multimeter]=ControlledCurrentSourceBlock(nl,sps,Multimeter)





    idx=nl.filter_type('Controlled Current Source');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));


    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');
        measure=get_param(block,'Measurements');

        [Amplitude,Phase,Frequency]=getSPSmaskvalues(block,{'Amplitude','Phase','Frequency'});
        blocinit(block,{Amplitude,Phase,Frequency});

        InitializeBlock=strcmp(get_param(block,'Initialize'),'on');

        if InitializeBlock
            if strcmp(get_param(block,'Source_Type'),'DC');
                Phase=0;
                Frequency=0;
            end
        else
            Amplitude=0;
            Phase=0;
            if sps.PowerguiInfo.Phasor
                Frequency=sps.PowerguiInfo.PhasorFrequency;
            else
                Frequency=0;
            end
        end



        nodes=nl.block_nodes(block);

        sps.source=[sps.source;
        nodes(1),nodes(2),1,Amplitude,Phase,Frequency,25];

        sps.srcstr{end+1}=['I_',BlockNom];


        ysrc=size(sps.source,1);
        if~sps.PowerguiInfo.Phasor||(sps.PowerguiInfo.Phasor&&Frequency==sps.PowerguiInfo.PhasorFrequency)
            sps.InputsNonZero(end+1)=ysrc;
        end

        sps.GotoSources{end+1}=get_param([BlockName,'/Goto'],'GotoTag');


        switch measure
        case 'Current'
            x=size(sps.source,1);
            Multimeter.I{end+1}=['Isrc: ',BlockNom];
            Multimeter.Yi{end+1,2}=x;
        end
        sps.modelnames{sps.basicnonlinearmodels+1}{end+1}=block;
        sps.nbmodels(sps.basicnonlinearmodels+1)=sps.nbmodels(sps.basicnonlinearmodels+1)+1;
        sps.sourcenames(end+1,1)=block;
        sps.blksrcnames{end+1}=BlockNom;
        sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.U.Mux(end+1)=1;
    end
function sps=ThreePhaseProgSourceBlock(nl,sps)





    idx=nl.filter_type('Three-Phase Programmable Voltage Source');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));



    if isfield(sps,'LoadFlow')

        NV=length(sps.LoadFlow.vsrc.handle);
    end

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');
        PositiveSequence=getSPSmaskvalues(block,{'PositiveSequence'});
        Mag_Vps=PositiveSequence(1)*sqrt(2/3);
        Phase_Vps=PositiveSequence(2);
        Freq_Vps=PositiveSequence(3);

        sps.GotoSources{end+1}=get_param([BlockName,'/Goto'],'GotoTag');



        nodes=nl.block_nodes(block);



        if isfield(sps,'LoadFlow')||isfield(sps,'UnbalancedLoadFlow')


        else

            sps.source(end+1:end+3,1:7)=[...
            nodes(2),nodes(1),0,Mag_Vps,Phase_Vps,Freq_Vps,22;
            nodes(3),nodes(1),0,Mag_Vps,Phase_Vps-120,Freq_Vps,22;
            nodes(4),nodes(1),0,Mag_Vps,Phase_Vps+120,Freq_Vps,22];
            sps.srcstr{end+1}=['U_A: ',BlockNom];
            sps.srcstr{end+1}=['U_B: ',BlockNom];
            sps.srcstr{end+1}=['U_C: ',BlockNom];


            if~sps.PowerguiInfo.Phasor||(sps.PowerguiInfo.Phasor&&Freq_Vps==sps.PowerguiInfo.PhasorFrequency)
                ysrc=size(sps.source,1);
                sps.InputsNonZero(end+1:end+3)=[ysrc-2,ysrc-1,ysrc];
            end

            sps.modelnames{sps.basicnonlinearmodels+4}{end+1}=block;

            sps.nbmodels(sps.basicnonlinearmodels+4)=sps.nbmodels(sps.basicnonlinearmodels+4)+1;
            sps.sourcenames(end+1:end+3,1)=[block;block;block];
            sps.blksrcnames{end+1}=['phase_A: ',BlockNom];
            sps.blksrcnames{end+1}=['phase_B: ',BlockNom];
            sps.blksrcnames{end+1}=['phase_C: ',BlockNom];

            sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
            sps.U.Mux(end+1)=3;
        end


        if isfield(sps,'LoadFlow')


            Fields=fieldnames(sps.LoadFlow.vsrc);

            BusType=getSPSmaskvalues(block,{'BusType'});

            Values={'Vprog',BusType,getSPSmaskvalues(block,{'Pref'}),...
            getSPSmaskvalues(block,{'Qref'}),getSPSmaskvalues(block,{'Qmin'}),...
            getSPSmaskvalues(block,{'Qmax'}),nodes(2:4),block};

            for k=1:length(Values)
                sps.LoadFlow.vsrc.(Fields{k}){i+NV}=Values{k};
            end


            sps.LoadFlow.vsrc.r{i+NV}=0;
            sps.LoadFlow.vsrc.x{i+NV}=0;
            sps.LoadFlow.vsrc.S{i+NV}=0;
            sps.LoadFlow.vsrc.Vi{i+NV}=0;
            sps.LoadFlow.vsrc.I{i+NV}=0;
            sps.LoadFlow.vsrc.Vint{i+NV}=0;
            sps.LoadFlow.vsrc.vnom{i+NV}=PositiveSequence(1);

            sps.LoadFlow.vsrc.busNumber{i+NV}=NaN;

        end


    end

function[sps,Multimeter]=ACVoltageSourceBlock(nl,sps,Multimeter)





    idx=nl.filter_type('AC Voltage Source');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);

        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');
        measure=get_param(block,'Measurements');

        [Amplitude,Phase,Frequency]=getSPSmaskvalues(block,{'Amplitude','Phase','Frequency'});
        blocinit(block,{Amplitude,Phase,Frequency});



        nodes=nl.block_nodes(block);

        if isfield(sps,'UnbalancedLoadFlow')

        else

            sps.source(end+1,1:7)=[nodes(2),nodes(1),0,Amplitude,Phase,Frequency,22];
            sps.srcstr{end+1}=['U_',BlockNom];


            if~sps.PowerguiInfo.Phasor||(sps.PowerguiInfo.Phasor&&Frequency==sps.PowerguiInfo.PhasorFrequency)
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

        if isfield(sps,'UnbalancedLoadFlow')

            sps.UnbalancedLoadFlow.vsrc.blockType{i}='Vsrc 1ph';
            sps.UnbalancedLoadFlow.vsrc.busType{i}=getSPSmaskvalues(block,{'BusType'});
            sps.UnbalancedLoadFlow.vsrc.P{i}=getSPSmaskvalues(block,{'Pref'});
            sps.UnbalancedLoadFlow.vsrc.Q{i}=getSPSmaskvalues(block,{'Qref'});
            sps.UnbalancedLoadFlow.vsrc.Qmin{i}=getSPSmaskvalues(block,{'Qmin'});
            sps.UnbalancedLoadFlow.vsrc.Qmax{i}=getSPSmaskvalues(block,{'Qmax'});
            sps.UnbalancedLoadFlow.vsrc.nodes{i}=[nodes(2),nodes(1)];
            sps.UnbalancedLoadFlow.vsrc.handle{i}=block;
            sps.UnbalancedLoadFlow.vsrc.connection{i}='';
            sps.UnbalancedLoadFlow.vsrc.r{i}=0;
            sps.UnbalancedLoadFlow.vsrc.x{i}=0;
            sps.UnbalancedLoadFlow.vsrc.S{i}=0;
            sps.UnbalancedLoadFlow.vsrc.Vi{i}=0;
            sps.UnbalancedLoadFlow.vsrc.I{i}=0;
            sps.UnbalancedLoadFlow.vsrc.Vint{i}=0;
            sps.UnbalancedLoadFlow.vsrc.vnom{i}=Amplitude;
            sps.UnbalancedLoadFlow.vsrc.busNumber{i}=0;

        end

    end
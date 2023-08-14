function[sps,YuNonlinear]=PMSynchronousMachineBlock(nl,sps,YuNonlinear)






    WantRshunt=1;

    MaskType='Permanent Magnet Synchronous Machine';
    idx=nl.filter_type(MaskType);
    sps.NbMachines=sps.NbMachines+length(idx);
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');
        IM=getSPSmaskvalues(block,{'IterativeDiscreteModel'});
        if(sps.PowerguiInfo.Discrete&&strcmp(IM,'Backward Euler robust'))||(sps.PowerguiInfo.Discrete&&strcmp(IM,'Trapezoidal robust'))
            LocallyWantDSS=1;
        else
            LocallyWantDSS=0;
        end

        NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,'PM Synchronous Machine');


        if sps.PowerguiInfo.WantDSS||LocallyWantDSS
            sps.DSS.block(end+1).type='PM Synchronous Machine';
            sps.DSS.block(end).Blockname=BlockName;
        end

        nodes=nl.block_nodes(block);

        switch get_param(block,'NbPhases')
        case '3'

            nStates=2;






            sps.source(end+1:end+2,1:7)=[...
            nodes(1),nodes(3),1,0,0,0,16;
            nodes(2),nodes(3),1,0,0,0,16];


            ysrc=size(sps.source,1)-1;
            sps.InputsNonZero(end+1:end+2)=[ysrc,ysrc+1];

            sps.srcstr{end+1}=['I_A: ',BlockNom];
            sps.srcstr{end+1}=['I_B: ',BlockNom];
            sps.outstr{end+1}=['U_AB: ',BlockNom];
            sps.outstr{end+1}=['U_BC: ',BlockNom];
            sps.sourcenames(end+1:end+2,1)=[block;block];

            xc=size(sps.modelnames{16},2);
            sps.modelnames{16}(xc+1)=block;

            YuNonlinear(end+1:end+2,1:2)=[nodes(1),nodes(2);nodes(2),nodes(3)];
            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=2;
            sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
            sps.U.Mux(end+1)=2;

        case '5'

            nStates=4;








            sps.source(end+1:end+4,1:7)=[...
            nodes(1),nodes(5),1,0,0,0,16;
            nodes(2),nodes(5),1,0,0,0,16;
            nodes(3),nodes(5),1,0,0,0,16;
            nodes(4),nodes(5),1,0,0,0,16];


            ysrc=size(sps.source,1)-3;
            sps.InputsNonZero(end+1:end+4)=[ysrc,ysrc+1,ysrc+2,ysrc+3];

            sps.srcstr{end+1}=['I_A: ',BlockNom];
            sps.srcstr{end+1}=['I_B: ',BlockNom];
            sps.srcstr{end+1}=['I_C: ',BlockNom];
            sps.srcstr{end+1}=['I_D: ',BlockNom];
            sps.outstr{end+1}=['U_AB: ',BlockNom];
            sps.outstr{end+1}=['U_BC: ',BlockNom];
            sps.outstr{end+1}=['U_CD: ',BlockNom];
            sps.outstr{end+1}=['U_DE: ',BlockNom];
            sps.sourcenames(end+1:end+4,1)=[block;block;block;block];

            xc=size(sps.modelnames{16},2);
            sps.modelnames{16}(xc+1)=block;

            YuNonlinear(end+1:end+4,1:2)=[nodes(1),nodes(2);nodes(2),nodes(3);nodes(3),nodes(4);nodes(4),nodes(5)];
            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=4;
            sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
            sps.U.Mux(end+1)=4;
        end

        Nsrc=size(sps.source,1);
        NbOut=length(sps.outstr);

        if sps.PowerguiInfo.WantDSS||LocallyWantDSS

            switch get_param(block,'NbPhases')
            case '3'
                sps.DSS.block(end).size=[nStates,2,2];
            case '5'
                sps.DSS.block(end).size=[nStates,4,4];
            end

            sps.DSS.block(end).xInit=[];
            sps.DSS.block(end).yinit=[0,0,0];
            sps.DSS.block(end).iterate=0;
            sps.DSS.block(end).VI=[];

            if sps.PowerguiInfo.WantDSS||LocallyWantDSS&&strcmp(IM,'Trapezoidal robust')

                sps.DSS.block(end).method=2;
            elseif LocallyWantDSS&&strcmp(IM,'Backward Euler robust')
                sps.DSS.block(end).method=1;
            end

            switch get_param(block,'NbPhases')
            case '3'
                sps.DSS.block(end).inputs=[Nsrc-1,Nsrc];
                sps.DSS.block(end).outputs=[NbOut-1,NbOut];
            case '5'
                sps.DSS.block(end).inputs=[Nsrc-3,Nsrc-2,Nsrc-1,Nsrc];
                sps.DSS.block(end).outputs=[NbOut-3,NbOut-2,NbOut-1,NbOut];
            end


            sps.DSS.model.inTags{end+1}=get_param([BlockName,'/GotoDSS'],'GotoTag');
            sps.DSS.model.inMux(end+1)=sps.DSS.block(end).size(2)*sps.DSS.block(end).size(3);

            if WantRshunt

                Rparasitic=1e6;

                switch get_param(block,'NbPhases')
                case '3'
                    sps.rlc(end+1,1:6)=[nodes(1),nodes(2),0,Rparasitic,0,0];
                    sps.rlc(end+1,1:6)=[nodes(2),nodes(3),0,Rparasitic,0,0];
                    sps.rlc(end+1,1:6)=[nodes(3),nodes(1),0,Rparasitic,0,0];
                    sps.rlcnames{end+1}=[BlockNom,'/Rparasitic'];
                    sps.rlcnames{end+1}=[BlockNom,'/Rparasitic'];
                    sps.rlcnames{end+1}=[BlockNom,'/Rparasitic'];

                case '5'
                    sps.rlc(end+1,1:6)=[nodes(1),nodes(2),0,Rparasitic,0,0];
                    sps.rlc(end+1,1:6)=[nodes(2),nodes(3),0,Rparasitic,0,0];
                    sps.rlc(end+1,1:6)=[nodes(3),nodes(4),0,Rparasitic,0,0];
                    sps.rlc(end+1,1:6)=[nodes(4),nodes(5),0,Rparasitic,0,0];
                    sps.rlc(end+1,1:6)=[nodes(5),nodes(1),0,Rparasitic,0,0];

                    sps.rlcnames{end+1}=[BlockNom,'/Rparasitic'];
                    sps.rlcnames{end+1}=[BlockNom,'/Rparasitic'];
                    sps.rlcnames{end+1}=[BlockNom,'/Rparasitic'];
                    sps.rlcnames{end+1}=[BlockNom,'/Rparasitic'];
                    sps.rlcnames{end+1}=[BlockNom,'/Rparasitic'];
                end

            end

        end

    end
    sps.nbmodels(16)=size(sps.modelnames{16},2);
function[BlockCount,sps,YuSwitches,Multimeter,NewNode]=BreakerBlock(BLOCKLIST,sps,YuSwitches,Multimeter,NewNode,LoadFlowAnalysis)





    idx=BLOCKLIST.filter_type('Breaker');

    sps.SwitchDevices.qty=sps.SwitchDevices.qty+length(idx);
    BlockCount=length(idx);
    blocks=sort(spsGetFullBlockPath(BLOCKLIST.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);

        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');

        sps.SwitchNames{end+1}=BlockNom;

        measure=get_param(block,'Measurements');

        [Ron,IC,Rs,Cs,comext,NoBreakLoop]=getSPSmaskvalues(block,{'BreakerResistance','InitialState','SnubberResistance','SnubberCapacitance','External','NoBreakLoop'});%#ok

        if sps.PowerguiInfo.SPID&&sps.PowerguiInfo.DisableRon

            Ron=0;
        end
        if sps.PowerguiInfo.SPID==0


            if Ron==-999
                Ron=0;
            end
        end

        blocinit(block,{Ron,IC,Rs,Cs,comext,0,'on'});

        if Ron==0&&sps.PowerguiInfo.SPID==0
            error(message('physmod:powersys:library:InvalidRonForNonIdealSwitches','Breaker resistance Ron(Ohm)',BlockName));
        end


        nodes=BLOCKLIST.block_nodes(block);


        if sps.PowerguiInfo.SPID&&sps.PowerguiInfo.DisableSnubbers

        else
            if(Rs==inf||Cs==0)

            else
                if Cs==inf
                    Cs=0;
                end
                if nodes(1)~=nodes(2)
                    sps.rlc(end+1,1:6)=[nodes(1),nodes(2),0,Rs,0,Cs*1e6];
                    sps.rlcnames{end+1}=['snubber: ',BlockNom];
                end
            end
        end

        sps.Rswitch(end+1)=Ron;
        sps.SwitchVf(1:2,end+1)=[0,0];

        if sps.PowerguiInfo.SPID


            if Ron==0&&nodes(1)==nodes(2)


                Ron=1;
            end

            if Ron>0
                if LoadFlowAnalysis
                    if IC==1


                        sps.rlc(end+1,1:6)=[nodes(1),nodes(2),0,Ron,0,0];
                        sps.rlcnames{end+1}=['Ron switch: ',BlockNom];
                    end
                else
                    RonNode=NewNode;
                    NewNode=NewNode+1;
                    sps.rlc(end+1,1:6)=[nodes(1),RonNode,0,Ron,0,0];
                    sps.rlcnames{end+1}=['Ron switch: ',BlockNom];
                end
            else
                RonNode=nodes(1);
            end


            if~LoadFlowAnalysis
                sps.rlc(end+1,1:6)=[RonNode,nodes(2),0,1,0,0];
                sps.rlcnames{end+1}=['SPID ',BlockNom];
                sps.SPIDresistors(end+1)=size(sps.rlc,1);
            end

        else


            sps.sourcenames(end+1,1)=block;
            sps.source(end+1,1:7)=[nodes(1),nodes(2),1,0,0,0,2];
            sps.srcstr{end+1}=['I_',BlockNom];
            sps.outstr{end+1}=['U_',BlockNom];
            YuSwitches(end+1,1:2)=[nodes(1),nodes(2)];%#ok

        end

        sps.switches(end+1,1:5)=[nodes(1),nodes(2),IC&1,Ron,0];


        if sps.PowerguiInfo.SPID
            x=size(sps.rlc,1);
            N1N2=sps.rlc(end,1:2);
            T=1;
        else
            x=size(sps.source,1);
            N1N2=sps.source(end,1:2);
            T=2;
        end

        if strcmp('Branch voltage',measure)||strcmp('Branch voltage and current',measure)
            Multimeter.Yu(end+1,1:2)=N1N2;
            Multimeter.V{end+1}=['Ub: ',BlockNom];
        end

        if strcmp('Branch current',measure)||strcmp('Branch voltage and current',measure)
            Multimeter.I{end+1}=['Ib: ',BlockNom];
            Multimeter.Yi{end+1,T}=x;
        end

        sps.modelnames{2}(end+1)=block;
        sps.SwitchType(end+1)=2;

        if sps.PowerguiInfo.Phasor==0&&sps.PowerguiInfo.DiscretePhasor==0
            sps.Status.Tags{end+1}=get_param([BlockName,'/Status'],'GotoTag');
            sps.Status.Demux(end+1)=1;
        end

        if sps.PowerguiInfo.SPID

            sps.Status.Demux(end)=2;
        end

        sps.Gates.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.Gates.Mux(end+1)=1;

        if sps.PowerguiInfo.SPID==0
            sps.SwitchDevices.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');
        end

        sps.SwitchDevices.Demux(end+1)=1;
        sps.SwitchGateInitialValue(end+1)=IC;

    end
function[BlockCount,sps,YuSwitches,VfVoltageSource,NewNode]=SwitchesBlock(flag,Device,SwitchID,BLOCKLIST,sps,YuSwitches,VfVoltageSource,NewNode,LoadFlowAnalysis)













    BlockCount=0;
    idx=BLOCKLIST.filter_type(Device);
    blocks=sort(spsGetFullBlockPath(BLOCKLIST.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');


        switch Device

        case 'Ideal Switch'
            L=0;
            Vf=0;
            IC=getSPSmaskvalues(block,{'IC'});

            SwitchType='Sfunction';

        case 'IGBT/Diode'
            L=0;
            Vf=0;
            IC=0;

            SwitchType='Sfunction';

        otherwise

            L=getSPSmaskvalues(block,{'Lon'});
            Vf=getSPSmaskvalues(block,{'Vf'});
            IC=getSPSmaskvalues(block,{'IC'});


            if sps.PowerguiInfo.SPID||sps.PowerguiInfo.Discrete
                if L~=0
                    sps.ForceLonToZero.status=1;
                    sps.ForceLonToZero.blocks{end+1}=BlockNom;
                    L=0;
                end
            end
            if L==0
                SwitchType='Sfunction';
            else
                SwitchType='CurrentSource';
            end
        end

        if flag==1&&L~=0||flag==2&&L==0



            continue
        end

        BlockCount=BlockCount+1;

        sps.SwitchNames{end+1}=BlockNom;


        SPSVerifyLinkStatus(block);
        NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,Device);


        [Ron,Rs,Cs]=getSPSmaskvalues(block,{'Ron','Rs','Cs'});

        if sps.PowerguiInfo.SPID&&sps.PowerguiInfo.DisableRon

            Ron=0;
        end
        if sps.PowerguiInfo.SPID==0


            if Ron==-999
                Ron=0;
            end
        end

        if sps.PowerguiInfo.SPID&&sps.PowerguiInfo.DisableVf

            Vf=0;
        end

        switch SwitchType
        case 'Sfunction'

            if Ron==0&&sps.PowerguiInfo.SPID==0
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                Erreur.message=['The Ron parameter of ''',BlockNom,''' block cannot be set to zero when you use this block in a discrete system, or when Lon is set to zero.',newline,'Ron and Lon can be set to zero at the same time only when the ''Continuous'' Simulation type in the Solver tab of the Powergui is selected and the ''Disable ideal switching'' option in the Preferences tab of powergui is not selected.'];
                psberror(Erreur);
            end


            switch Device
            case 'Ideal Switch'
                if sps.PowerguiInfo.Phasor==0
                    sps.Status.Tags{end+1}=get_param([BlockName,'/Status'],'GotoTag');
                    sps.Status.Demux(end+1)=1;
                end
            otherwise
                sps.Status.Tags{end+1}=get_param([BlockName,'/Status'],'GotoTag');
                sps.Status.Demux(end+1)=1;
            end

            switch Device
            case{'Gto','IGBT'}
                sps.SwitchDevices.total=sps.SwitchDevices.total+1;
                if sps.PowerguiInfo.SPID==0
                    sps.ITAIL.Tags{end+1}=get_param([BlockName,'/ITAIL'],'GotoTag');
                    sps.ITAIL.Mux(end+1)=1;
                end
            otherwise
                sps.SwitchDevices.qty=sps.SwitchDevices.qty+1;
            end
        end


        switch Device
        case 'IGBT/Diode'
            ParameterValidation={Ron,Rs,Cs};
        case{'Gto','IGBT'}

            Tf=0;
            Tt=0;
            ParameterValidation={Ron,L,Vf,Tf,Tt,IC,Rs,Cs};

        case 'Detailed Thyristor'
            [Il,Tq]=getSPSmaskvalues(block,{'Il','Tq'});
            ParameterValidation={Ron,L,Vf,Il,Tq,IC,Rs,Cs};
        otherwise
            ParameterValidation={Ron,L,Vf,IC,Rs,Cs};
        end
        if sps.PowerguiInfo.SPID==0
            blocinit(block,ParameterValidation);
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

        StartNode=nodes(1);

        switch SwitchType
        case 'Sfunction'
            if Vf~=0

                StartNode=NewNode;
                NewNode=NewNode+1;
            end
        end

        if sps.PowerguiInfo.SPID


            if Ron==0&&nodes(1)==nodes(2)


                Ron=1;
            end


            if Ron>0
                if LoadFlowAnalysis
                    if IC==1


                        sps.rlc(end+1,1:6)=[StartNode,nodes(2),0,Ron,0,0];
                        sps.rlcnames{end+1}=['Ron switch: ',BlockNom];
                    end
                    RonNode=StartNode;
                else
                    RonNode=NewNode;
                    NewNode=NewNode+1;
                    sps.rlc(end+1,1:6)=[StartNode,RonNode,0,Ron,0,0];
                    sps.rlcnames{end+1}=['Ron switch: ',BlockNom];
                end
            else
                RonNode=StartNode;
            end



            if~LoadFlowAnalysis
                sps.rlc(end+1,1:6)=[RonNode,nodes(2),0,1,0,0];
                sps.rlcnames{end+1}=['SPID ',BlockNom];
                sps.SPIDresistors(end+1)=size(sps.rlc,1);
            end


            sps.Status.Demux(end)=2;
            sps.switches(end+1,1:5)=[RonNode,nodes(2),0,Ron,0];

        else


            sps.sourcenames(end+1,1)=block;
            sps.srcstr{end+1}=['I_',BlockNom];
            sps.outstr{end+1}=['U_',BlockNom];
            sps.source(end+1,1:7)=[StartNode,nodes(2),1,0,0,0,SwitchID];


            INM=IC&1;
            if L==0&&~strcmp(Device,'Ideal Switch')
                INM=0;
            end
            sps.switches(end+1,1:5)=[StartNode,nodes(2),INM,Ron,L];

        end

        switch SwitchType

        case 'Sfunction'

            sps.Rswitch(end+1)=Ron;
            sps.SwitchVf(1:2,end+1)=[Vf,Vf];

            if L==0&&~strcmp(Device,'Ideal Switch')
                IC=0;
            end
            sps.SwitchGateInitialValue(end+1)=IC;
            sps.Gates.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
            sps.Gates.Mux(end+1)=1;
            if sps.PowerguiInfo.SPID==0
                sps.SwitchDevices.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');
                YuSwitches(end+1,1:2)=[StartNode,nodes(2)];%#ok
            end
            sps.SwitchDevices.Demux(end+1)=1;
            sps.SwitchType(end+1)=SwitchID;


            if Vf>0
                VfVoltageSource.source(end+1,1:7)=[nodes(1),StartNode,0,Vf,0,0,21];
                VfVoltageSource.srcstr{end+1}=['U_Vf: ',BlockNom];
                VfVoltageSource.sourcenames(end+1,1)=block;
                sps.VF.Tags{end+1}=get_param([BlockName,'/VF'],'GotoTag');
                sps.VF.Mux(end+1)=1;
            end

        case 'CurrentSource'

            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=1;
            sps.U.Tags{end+1}=get_param([BlockName,'/ISWITCH'],'GotoTag');
            sps.U.Mux(end+1)=1;


            YuSwitches(end+1,1:2)=[nodes(1),nodes(2)];%#ok

        end

    end
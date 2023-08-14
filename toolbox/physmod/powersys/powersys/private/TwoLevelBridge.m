function[BlockCount,sps,Multimeter,Yu,dcvf,NewNode]=TwoLevelBridge(nl,block,DeviceModel,sps,Multimeter,Yu,dcvf,NewNode)






    SPSVerifyLinkStatus(block);


    BlockName=getfullname(block);
    BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');


    NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,'Universal Bridge');



    [Rs,Cs,DeviceType,Ron,Lon,VFs,Vf,gtoparam,igbtparam]=getSPSmaskvalues(block,{'SnubberResistance','SnubberCapacitance','Device','Ron','Lon','ForwardVoltages','ForwardVoltage','GTOparameters','IGBTparameters'});%#ok

    if sps.PowerguiInfo.SPID&&sps.PowerguiInfo.DisableRon

        Ron=0;
    end

    if sps.PowerguiInfo.SPID==0

        if Ron==-999
            Ron=0;
        end
    end

    switch DeviceModel
    case{'Ideal Switch','Diode-Logic','Thyristor-Logic','GTO','IGBT','MOSFET'}
        Lon=0;
    end

    if Ron==0&&sps.PowerguiInfo.SPID==0
        if sps.PowerguiInfo.Discrete
            Erreur.message=['The Ron parameter of ''',BlockNom,''' block cannot be set to zero when the ''Simulation Type'' parameter of Powergui is set to Discrete.',newline,'Set Ron to a value greater than zero.'];
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end
        if Lon==0
            Erreur.message=['The Ron parameter of ''',BlockNom,''' block cannot be set to zero when Lon = 0.',newline,'To set Ron and Lon to zero at the same time, you need to deselect the ''Disable ideal switching'' option on the preferences tab of Powergui.'];
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end
    end

    if sps.PowerguiInfo.SPID&&sps.PowerguiInfo.DisableVf

        Vf=0;
        VFs=[0,0];
    end

    if sps.PowerguiInfo.SPID&&sps.PowerguiInfo.DisableSnubbers

        SNUBBER=0;
        Cs=0;
    else
        if(Rs==0&&Cs==Inf)
            Erreur.message=['In the mask of ''',BlockNom,''' block:',newline,'Snubber parameters are not set correctly (short-circuit). Specify  Rs=Inf or Cs=0 to disconnect the snubber. You can avoid the use of snubber by selecting the ''Continuous'' simulation type in the Solver tab of the Powergui and deselecting the ''Disable ideal switching'' option in the Preferences tab of powergui block.'];
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end
        if(Rs==inf||Cs==0)
            SNUBBER=0;
        else
            SNUBBER=1;
            if Cs==inf
                Cs=0;
            end
        end
    end



    arm1=strcmp(get_param(block,'arms'),'1');
    arm2=strcmp(get_param(block,'arms'),'2');
    arm3=strcmp(get_param(block,'arms'),'3');
    bras=(arm1*1+arm2*2+arm3*3);

    NumberOfSwitches=2*bras;
    BlockCount=NumberOfSwitches;

    switch DeviceModel

    case 'Ideal Switch'

        DeviceIndice=1;
        sps.SwitchType(end+1:end+NumberOfSwitches)=1*ones(1,NumberOfSwitches);
        sps.Status.Tags{end+1}=get_param([BlockName,'/Status'],'GotoTag');
        sps.Status.Demux(end+1)=NumberOfSwitches;
        sps.Gates.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.Gates.Mux(end+1)=NumberOfSwitches;
        if sps.PowerguiInfo.SPID==0
            sps.SwitchDevices.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');
        end
        sps.SwitchDevices.Demux(end+1)=NumberOfSwitches;
        sps.SwitchGateInitialValue(end+1:end+NumberOfSwitches)=zeros(1,NumberOfSwitches);
        sps.SwitchDevices.qty=sps.SwitchDevices.qty+NumberOfSwitches;
        VfDevice=0;
        VfDiode=0;

    case 'Diode-Logic'

        if(~sps.PowerguiInfo.SPID)&&sps.PowerguiInfo.DisplayEquations
            SnubberWarning(sps.PowerguiInfo.Ts,Rs,Cs,BlockName);
        end

        DeviceIndice=3;
        sps.SwitchType(end+1:end+NumberOfSwitches)=3*ones(1,NumberOfSwitches);
        sps.Status.Tags{end+1}=get_param([BlockName,'/Status'],'GotoTag');
        sps.Status.Demux(end+1)=NumberOfSwitches;
        sps.Gates.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.Gates.Mux(end+1)=NumberOfSwitches;
        if sps.PowerguiInfo.SPID==0
            sps.SwitchDevices.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');
        end
        sps.SwitchDevices.Demux(end+1)=NumberOfSwitches;
        sps.SwitchGateInitialValue(end+1:end+NumberOfSwitches)=zeros(1,NumberOfSwitches);
        sps.SwitchDevices.qty=sps.SwitchDevices.qty+NumberOfSwitches;
        VfDevice=Vf;
        VfDiode=0;

    case 'Thyristor-Logic'

        if(~sps.PowerguiInfo.SPID)&&sps.PowerguiInfo.DisplayEquations
            SnubberWarning(sps.PowerguiInfo.Ts,Rs,Cs,BlockName);
        end

        DeviceIndice=4;
        sps.SwitchType(end+1:end+NumberOfSwitches)=4*ones(1,NumberOfSwitches);
        sps.Status.Tags{end+1}=get_param([BlockName,'/Status'],'GotoTag');
        sps.Status.Demux(end+1)=NumberOfSwitches;
        sps.Gates.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.Gates.Mux(end+1)=NumberOfSwitches;
        if sps.PowerguiInfo.SPID==0
            sps.SwitchDevices.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');
        end
        sps.SwitchDevices.Demux(end+1)=NumberOfSwitches;
        sps.SwitchGateInitialValue(end+1:end+NumberOfSwitches)=zeros(1,NumberOfSwitches);
        sps.SwitchDevices.qty=sps.SwitchDevices.qty+NumberOfSwitches;
        VfDevice=Vf;
        VfDiode=0;

    case 'GTO'

        DeviceIndice=6;
        sps.SwitchDevices.total=sps.SwitchDevices.total+NumberOfSwitches;
        sps.SwitchType(end+1:end+NumberOfSwitches)=7*ones(1,NumberOfSwitches);
        sps.Status.Tags{end+1}=get_param([BlockName,'/Status'],'GotoTag');
        sps.Status.Demux(end+1)=NumberOfSwitches;
        sps.Gates.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.Gates.Mux(end+1)=NumberOfSwitches;
        if sps.PowerguiInfo.SPID==0
            sps.ITAIL.Tags{end+1}=get_param([BlockName,'/ITAIL'],'GotoTag');
            sps.ITAIL.Mux(end+1)=NumberOfSwitches;
            sps.SwitchDevices.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');
        end
        sps.SwitchDevices.Demux(end+1)=NumberOfSwitches;
        sps.SwitchGateInitialValue(end+1:end+NumberOfSwitches)=zeros(1,NumberOfSwitches);
        VfDevice=VFs(1);
        VfDiode=VFs(2);

    case 'IGBT'

        DeviceIndice=6;
        sps.SwitchDevices.total=sps.SwitchDevices.total+NumberOfSwitches;
        sps.SwitchType(end+1:end+NumberOfSwitches)=7*ones(1,NumberOfSwitches);
        sps.Status.Tags{end+1}=get_param([BlockName,'/Status'],'GotoTag');
        sps.Status.Demux(end+1)=NumberOfSwitches;
        sps.Gates.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.Gates.Mux(end+1)=NumberOfSwitches;
        if sps.PowerguiInfo.SPID==0
            sps.ITAIL.Tags{end+1}=get_param([BlockName,'/ITAIL'],'GotoTag');
            sps.ITAIL.Mux(end+1)=NumberOfSwitches;
            sps.SwitchDevices.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');
        end
        sps.SwitchDevices.Demux(end+1)=NumberOfSwitches;
        sps.SwitchGateInitialValue(end+1:end+NumberOfSwitches)=zeros(1,NumberOfSwitches);
        VfDevice=VFs(1);
        VfDiode=VFs(2);

    case 'MOSFET'

        DeviceIndice=6;
        sps.SwitchDevices.total=sps.SwitchDevices.total+NumberOfSwitches;
        sps.SwitchType(end+1:end+NumberOfSwitches)=7*ones(1,NumberOfSwitches);
        sps.Status.Tags{end+1}=get_param([BlockName,'/Status'],'GotoTag');
        sps.Status.Demux(end+1)=NumberOfSwitches;
        sps.Gates.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.Gates.Mux(end+1)=NumberOfSwitches;
        if sps.PowerguiInfo.SPID==0
            sps.ITAIL.Tags{end+1}=get_param([BlockName,'/ITAIL'],'GotoTag');
            sps.ITAIL.Mux(end+1)=NumberOfSwitches;
            sps.SwitchDevices.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');
        end
        sps.SwitchDevices.Demux(end+1)=NumberOfSwitches;
        sps.SwitchGateInitialValue(end+1:end+NumberOfSwitches)=zeros(1,NumberOfSwitches);
        VfDevice=0;
        VfDiode=0;

    case 'Diode-RL'

        if(~sps.PowerguiInfo.SPID)&&sps.PowerguiInfo.DisplayEquations
            SnubberWarning(sps.PowerguiInfo.Ts,Rs,Cs,BlockName);
        end

        DeviceIndice=7;
        VfDevice=0;
        VfDiode=0;
        sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');
        sps.NonlinearDevices.Demux(end+1)=NumberOfSwitches;
        sps.U.Tags{end+1}=get_param([BlockName,'/ISWITCH'],'GotoTag');
        sps.U.Mux(end+1)=NumberOfSwitches;

    case 'Thyristor-RL'

        if(~sps.PowerguiInfo.SPID)&&sps.PowerguiInfo.DisplayEquations
            SnubberWarning(sps.PowerguiInfo.Ts,Rs,Cs,BlockName);
        end

        DeviceIndice=8;
        VfDevice=0;
        VfDiode=0;
        sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');
        sps.NonlinearDevices.Demux(end+1)=NumberOfSwitches;
        sps.U.Tags{end+1}=get_param([BlockName,'/ISWITCH'],'GotoTag');
        sps.U.Mux(end+1)=NumberOfSwitches;
    end

    if sps.PowerguiInfo.SPID

        sps.Status.Demux(end)=2*NumberOfSwitches;
    end



















    nodes=nl.block_nodes(block);

    if arm1
        AA=nodes(1);
        BB=0;
        CC=0;
        POSI=nodes(4);
        NEGA=nodes(5);
    elseif arm2
        AA=nodes(1);
        BB=nodes(2);
        CC=0;
        POSI=nodes(4);
        NEGA=nodes(5);
    elseif arm3
        AA=nodes(1);
        BB=nodes(2);
        CC=nodes(3);
        POSI=nodes(4);
        NEGA=nodes(5);
    end

    if DeviceIndice==6||DeviceIndice==1







        NL(1)=POSI;NR(1)=AA;
        NL(2)=AA;NR(2)=NEGA;
        NL(3)=POSI;NR(3)=BB;
        NL(4)=BB;NR(4)=NEGA;
        NL(5)=POSI;NR(5)=CC;
        NL(6)=CC;NR(6)=NEGA;

    else

        if arm3






            NL(1)=AA;NR(1)=POSI;
            NL(2)=NEGA;NR(2)=CC;
            NL(3)=BB;NR(3)=POSI;
            NL(4)=NEGA;NR(4)=AA;
            NL(5)=CC;NR(5)=POSI;
            NL(6)=NEGA;NR(6)=BB;
        else
            NL(1)=AA;NR(1)=POSI;
            NL(2)=NEGA;NR(2)=AA;
            NL(3)=BB;NR(3)=POSI;
            NL(4)=NEGA;NR(4)=BB;
            NL(5)=CC;NR(5)=POSI;
            NL(6)=NEGA;NR(6)=CC;
        end
    end



    if VfDevice||VfDiode
        VFSOURCE=1;
        NN=NewNode:NewNode+5;
        NewNode=NewNode+6;
        sps.VF.Tags{end+1}=get_param([BlockName,'/VF'],'GotoTag');
        sps.VF.Mux(end+1)=NumberOfSwitches;
    else
        VFSOURCE=0;
        NN=NL;
    end





    mesurerequest=get_param(block,'Measurements');
    DeCu=strcmp(mesurerequest,'Device currents');
    AllM=strcmp(mesurerequest,'All voltages and currents');
    DeVo=strcmp(mesurerequest,'Device voltages');
    UABv=strcmp(mesurerequest,'UAB UBC UCA UDC voltages');

    ARM={'arm1_1';'arm1_2';'arm2_1';'arm2_2';'arm3_1';'arm3_2'};

    for i=1:NumberOfSwitches

        SW=num2str(i);

        if SNUBBER
            sps.rlc(end+1,1:6)=[NL(i),NR(i),0,Rs,0,Cs*1e6];
            sps.rlcnames{end+1}=['snubber_',SW,': ',BlockNom];
        end

        if VFSOURCE
            dcvf.source(end+1,1:7)=[NL(i),NN(i),0,VfDevice,0,0,21];
            dcvf.srcstr{end+1}=['U_Vf_',SW,': ',BlockNom];
            dcvf.sourcenames(end+1,1)=block;
        end

        if sps.PowerguiInfo.SPID




            if Ron>0
                RonNode=NewNode;
                NewNode=NewNode+1;
                sps.rlc(end+1,1:6)=[NN(i),RonNode,0,Ron,0,0];
                sps.rlcnames{end+1}=['Ron switch ',SW,': ',BlockNom];
            else
                RonNode=NN(i);
            end


            sps.rlc(end+1,1:6)=[RonNode,NR(i),0,1,0,0];
            sps.rlcnames{end+1}=['SPID ',SW,': ',BlockNom];
            sps.SPIDresistors(end+1)=size(sps.rlc,1);

            SWN=RonNode;
            T=1;
            REFMAT=size(sps.rlc,1);

        else



            sps.source(end+1,1:7)=[NN(i),NR(i),1,0,0,0,DeviceIndice];
            sps.srcstr{end+1}=['I_',ARM{i},': ',BlockNom];
            sps.outstr{end+1}=['U_',ARM{i},': ',BlockNom];
            Yu(end+1,1:2)=[NN(i),NR(i)];%#ok 
            sps.sourcenames(end+1,1)=block;

            SWN=NN(i);
            T=2;
            REFMAT=size(sps.source,1);

        end


        sps.switches(end+1,1:5)=[SWN,NR(i),0,Ron,Lon*1e3];
        sps.SwitchNames{end+1}=[SW,': ',BlockNom];


        if DeCu||AllM
            Multimeter.I{end+1}=['Isw',SW,': ',BlockNom];
            Multimeter.Yi{end+1,T}=REFMAT;
        end

        if DeVo||AllM
            Multimeter.Yu(end+1,1:2)=[NL(i),NR(i)];
            Multimeter.V{end+1}=['Usw',SW,': ',BlockNom];
        end

    end




    if DeviceIndice==1
        sps.Rswitch(end+1:end+NumberOfSwitches)=ones(1,NumberOfSwitches)*Ron;
        sps.SwitchVf(1,end+1:end+NumberOfSwitches)=ones(1,NumberOfSwitches)*VfDevice;
        sps.SwitchVf(2,end-NumberOfSwitches+1:end)=ones(1,NumberOfSwitches)*VfDiode;
    end

    if DeviceIndice==6
        sps.Rswitch(end+1:end+NumberOfSwitches)=ones(1,NumberOfSwitches)*Ron;
        sps.SwitchVf(1,end+1:end+NumberOfSwitches)=ones(1,NumberOfSwitches)*VfDevice;
        sps.SwitchVf(2,end-NumberOfSwitches+1:end)=-ones(1,NumberOfSwitches)*VfDiode;
    end

    if DeviceIndice==3||DeviceIndice==4
        sps.Rswitch(end+1:end+NumberOfSwitches)=ones(1,NumberOfSwitches)*Ron;
        sps.SwitchVf(1,end+1:end+NumberOfSwitches)=ones(1,NumberOfSwitches)*VfDevice;
        sps.SwitchVf(2,end-NumberOfSwitches+1:end)=ones(1,NumberOfSwitches)*VfDevice;
    end


    xc=size(sps.modelnames{DeviceIndice},2);
    if DeviceIndice==6

        sps.modelnames{DeviceIndice}(xc+1)=block;
    else
        sps.modelnames{DeviceIndice}(xc+1)=block;
        sps.modelnames{DeviceIndice}(xc+2)=block;
        if arm2||arm3
            sps.modelnames{DeviceIndice}(xc+3)=block;
            sps.modelnames{DeviceIndice}(xc+4)=block;
        end
        if arm3
            sps.modelnames{DeviceIndice}(xc+5)=block;
            sps.modelnames{DeviceIndice}(xc+6)=block;
        end
    end



    if UABv||AllM
        if arm2||arm3
            Multimeter.Yu(end+1,1:2)=[AA,BB];
            Multimeter.V{end+1}=['Uab: ',BlockNom];
        end
        if arm3
            Multimeter.Yu(end+1,1:2)=[BB,CC];
            Multimeter.V{end+1}=['Ubc: ',BlockNom];
            Multimeter.Yu(end+1,1:2)=[CC,AA];
            Multimeter.V{end+1}=['Uca: ',BlockNom];
        end
        Multimeter.Yu(end+1,1:2)=[POSI,NEGA];
        Multimeter.V{end+1}=['Udc: ',BlockNom];
    end


    function SnubberWarning(Ts,Rs,Cs,BlockName)




        ParentBlock=get_param(BlockName,'parent');
        if~strcmp(ParentBlock,bdroot(ParentBlock))
            Exclude_list={'PM Synchronous Motor Drive'};
            ParentMaskType=get_param(ParentBlock,'MaskType');
            if strcmp(ParentMaskType,Exclude_list{1})
                return
            end
        end
        if(Ts>0)&&(Cs==inf||Cs==0||Rs==inf||Rs==0)
            message=['You have not specified Rs-Cs snubbers in the Universal Bridge block named ''',BlockName,'''.',newline,...
            'In order to avoid numerical oscillations, you may have to specify values for Rs and Cs.',...
'You can avoid the use of snubber by selecting the ''Continuous'' Simulation type in the Solver tab of the Powergui and deselecting the ''Disable ideal switching'' option in the Preferences tab of Powergui block.'
            'See documentation  of the Universal Bridge to obtain a guideline for selection of appropriate Rs Cs values. To ignore Simscape Electrical Specialized Power Systems warnings, select "Disable Specialized Power Systems warnings" in the Powergui Preferences tab.'];
            warndlg(message,'Parameter warning');
            warning('SpecializedPowerSystems:SnubberRecommendations',message);
        end
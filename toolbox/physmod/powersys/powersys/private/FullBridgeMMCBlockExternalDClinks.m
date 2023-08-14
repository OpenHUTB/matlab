function[BlockCount,sps,Yu,dcvf,YuNonlinear,NewNode]=FullBridgeMMCBlockExternalDClinks(BLOCKLIST,sps,Yu,dcvf,YuNonlinear,NewNode)





    BlockCount=0;
    idx=BLOCKLIST.filter_type('Full-Bridge MMC (External DC Links)');
    blocks=sort(spsGetFullBlockPath(BLOCKLIST.elements(idx)));

    for k=1:numel(blocks)

        block=get_param(blocks{k},'Handle');
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');


        NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,'Full-Bridge MMC with External DC Links');


        [n,Ron,Rs,Cs,ModelType]=getSPSmaskvalues(BlockName,{'n','Ron','Rs','Cs','ModelType'});

        if sps.PowerguiInfo.SPID&&sps.PowerguiInfo.DisableRon

            Ron=0;
        end

        if Ron==0&&sps.PowerguiInfo.SPID==0
            error(message('physmod:powersys:library:InvalidRonForNonIdealSwitches','Device on-state resistance(Ohms)',BlockName));
        end


        nodes=BLOCKLIST.block_nodes(block);







        for i=1:n

            if i==1
                Vpos=nodes(1);
            else
                Vpos=Vneg;
            end

            if i==n
                Vneg=nodes(2);
            else
                Vneg=NewNode;
                NewNode=NewNode+1;
            end

            Cpos=nodes(2*i+1);
            Cneg=nodes(2*i+2);







            if sps.PowerguiInfo.SPID&&sps.PowerguiInfo.DisableSnubbers

            else
                if(Rs==0&&Cs==Inf)
                    error(message('physmod:powersys:library:IncorrectSnubberParameters',BlockName));
                end
                if(Rs==inf||Cs==0)

                else
                    Css=Cs;
                    if Cs==inf
                        Css=0;
                    end
                    sps.rlc=[sps.rlc;
                    Cpos,Vpos,0,Rs,0,Css*1e6;
                    Vpos,Cneg,0,Rs,0,Css*1e6];
                    sps.rlcnames{end+1}=['snubber_IGBT1_module',num2str(i),': ',BlockNom];
                    sps.rlcnames{end+1}=['snubber_IGBT2_module',num2str(i),': ',BlockNom];
                    sps.rlc=[sps.rlc;
                    Cpos,Vneg,0,Rs,0,Css*1e6;
                    Vneg,Cneg,0,Rs,0,Css*1e6];
                    sps.rlcnames{end+1}=['snubber_IGBT3_module',num2str(i),': ',BlockNom];
                    sps.rlcnames{end+1}=['snubber_IGBT4_module',num2str(i),': ',BlockNom];

                end
            end

            switch ModelType
            case 'Switching devices'






                if sps.PowerguiInfo.SPID


                    if Ron>0

                        RonNode1=NewNode;
                        RonNode2=NewNode+1;
                        RonNode3=NewNode+2;
                        RonNode4=NewNode+3;
                        NewNode=NewNode+4;

                        sps.rlc(end+1,1:6)=[Cpos,RonNode1,0,Ron,0,0];
                        sps.rlcnames{end+1}=['Ron 1 module',num2str(i),': ',BlockNom];
                        sps.rlc(end+1,1:6)=[Vpos,RonNode2,0,Ron,0,0];
                        sps.rlcnames{end+1}=['Ron 2 module',num2str(i),': ',BlockNom];
                        sps.rlc(end+1,1:6)=[Cpos,RonNode3,0,Ron,0,0];
                        sps.rlcnames{end+1}=['Ron 3 module',num2str(i),': ',BlockNom];
                        sps.rlc(end+1,1:6)=[Vneg,RonNode4,0,Ron,0,0];
                        sps.rlcnames{end+1}=['Ron 4 module',num2str(i),': ',BlockNom];

                    else

                        RonNode1=Cpos;
                        RonNode2=Vpos;
                        RonNode3=Cpos;
                        RonNode4=Vneg;

                    end


                    sps.rlc(end+1,1:6)=[RonNode1,Vpos,0,1,0,0];
                    sps.rlcnames{end+1}=['SPID 1 module',num2str(i),': ',BlockNom];
                    sps.SPIDresistors(end+1)=size(sps.rlc,1);
                    sps.rlc(end+1,1:6)=[RonNode2,Cneg,0,1,0,0];
                    sps.rlcnames{end+1}=['SPID 2 module',num2str(i),': ',BlockNom];
                    sps.SPIDresistors(end+1)=size(sps.rlc,1);
                    sps.rlc(end+1,1:6)=[RonNode3,Vneg,0,1,0,0];
                    sps.rlcnames{end+1}=['SPID 3 module',num2str(i),': ',BlockNom];
                    sps.SPIDresistors(end+1)=size(sps.rlc,1);
                    sps.rlc(end+1,1:6)=[RonNode4,Cneg,0,1,0,0];
                    sps.rlcnames{end+1}=['SPID 4 module',num2str(i),': ',BlockNom];
                    sps.SPIDresistors(end+1)=size(sps.rlc,1);

                    sps.switches=[sps.switches;
                    RonNode1,Vpos,0,Ron,0;
                    RonNode2,Cneg,0,Ron,0];
                    sps.SwitchNames{end+1}=['1 module',num2str(i),': ',BlockNom];
                    sps.SwitchNames{end+1}=['2 module',num2str(i),': ',BlockNom];
                    sps.switches=[sps.switches;
                    RonNode3,Vneg,0,Ron,0;
                    RonNode4,Cneg,0,Ron,0];
                    sps.SwitchNames{end+1}=['3 module',num2str(i),': ',BlockNom];
                    sps.SwitchNames{end+1}=['4 module',num2str(i),': ',BlockNom];

                else


                    sps.source=[sps.source;
                    Cpos,Vpos,1,0,0,0,7;
                    Vpos,Cneg,1,0,0,0,7];
                    sps.srcstr{end+1}=['I_IGBT1_module',num2str(i),': ',BlockNom];
                    sps.srcstr{end+1}=['I_IGBT2_module',num2str(i),': ',BlockNom];
                    sps.outstr{end+1}=['U_IGBT1_module',num2str(i),': ',BlockNom];
                    sps.outstr{end+1}=['U_IGBT2_module',num2str(i),': ',BlockNom];
                    sps.source=[sps.source;
                    Cpos,Vneg,1,0,0,0,7;
                    Vneg,Cneg,1,0,0,0,7];
                    sps.srcstr{end+1}=['I_IGBT3_module',num2str(i),': ',BlockNom];
                    sps.srcstr{end+1}=['I_IGBT4_module',num2str(i),': ',BlockNom];
                    sps.outstr{end+1}=['U_IGBT3_module',num2str(i),': ',BlockNom];
                    sps.outstr{end+1}=['U_IGBT4_module',num2str(i),': ',BlockNom];

                    Yu=[Yu;
                    Cpos,Vpos;
                    Vpos,Cneg;
                    Cpos,Vneg;
                    Vneg,Cneg];

                    sps.sourcenames(end+1:end+4,1)=ones(4,1)*get_param(BlockName,'handle');

                    sps.switches=[sps.switches;
                    Cpos,Vpos,0,Ron,0;
                    Vpos,Cneg,0,Ron,0];
                    sps.SwitchNames{end+1}=['IGBT1_module',num2str(i),': ',BlockNom];
                    sps.SwitchNames{end+1}=['IGBT2_module',num2str(i),': ',BlockNom];
                    sps.switches=[sps.switches;
                    Cpos,Vneg,0,Ron,0;
                    Vneg,Cneg,0,Ron,0;
                    ];
                    sps.SwitchNames{end+1}=['IGBT3_module',num2str(i),': ',BlockNom];
                    sps.SwitchNames{end+1}=['IGBT4_module',num2str(i),': ',BlockNom];

                end

                sps.SwitchType(end+1:end+4)=[7,7,7,7];
                sps.SwitchVf(1:2,end+1:end+4)=[0,0,0,0;0,0,0,0];

            otherwise


                sps.source(end+1,1:7)=[Cpos,Cneg,1,0,0,0,28];
                YuNonlinear(end+1,1:2)=[Cpos,Cneg];
                sps.srcstr{end+1}=['I_',BlockNom];
                sps.outstr{end+1}=['U_',BlockNom];

                sps.InputsNonZero(end+1)=size(sps.source,1);





                sps.sourcenames(end+1,1)=block;
            end

        end

        switch ModelType
        case 'Switching devices'
            NumberOfSwitches=4*n;
            sps.Rswitch(end+1:end+NumberOfSwitches)=ones(1,NumberOfSwitches)*Ron;


            sps.Gates.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
            sps.Gates.Mux(end+1)=NumberOfSwitches;

            if sps.PowerguiInfo.SPID==0
                sps.SwitchDevices.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
            end

            sps.SwitchDevices.Demux(end+1)=NumberOfSwitches;

            sps.SwitchGateInitialValue(end+1:end+NumberOfSwitches)=zeros(1,NumberOfSwitches);
            sps.SwitchDevices.qty=sps.SwitchDevices.qty+NumberOfSwitches;

            if sps.PowerguiInfo.SPID
                sps.Status.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');

                sps.Status.Demux(end+1)=2*NumberOfSwitches;
            else
                sps.Status.Tags{end+1}='';
                sps.Status.Demux(end+1)=NumberOfSwitches;
            end

            BlockCount=BlockCount+NumberOfSwitches;

        otherwise

            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=n;
            sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
            sps.U.Mux(end+1)=n;
        end
    end
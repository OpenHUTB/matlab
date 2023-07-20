function[BlockCount,sps,Yu,dcvf,NewNode]=FullBridgeMMCBlock(BLOCKLIST,sps,Yu,dcvf,NewNode,bridgetype)





    BlockCount=0;
    idx=BLOCKLIST.filter_type(bridgetype);
    blocks=sort(spsGetFullBlockPath(BLOCKLIST.elements(idx)));

    for k=1:numel(blocks)

        block=get_param(blocks{k},'Handle');
        BlockName=getfullname(get_param(block,'parent'));
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');


        switch bridgetype
        case 'FullMMC'
            NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,'Full-Bridge MMC');
        otherwise
            NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,'Half-Bridge MMC');
        end


        [n,C,Vc_Initial,Ron,Rs,Cs]=getSPSmaskvalues(BlockName,{'n','C','Vc_Initial','Ron','Rs','Cs'});


        if length(C)==1
            C=C*ones(1,n);
        end
        if length(Vc_Initial)==1
            Vc_Initial=Vc_Initial*ones(1,n);
        end


        if any(C<=0)
            error(message('physmod:powersys:common:GreaterThan',BlockName,'Capacitor value(F)','0'));
        end
        if any(abs(C)==inf)
            error(message('physmod:powersys:common:LesserThan',BlockName,'Capacitor value(F)','inf'));
        end
        if length(C)~=n
            error(message('physmod:powersys:common:InvalidVectorParameter','Capacitor value(F)',BlockName,'1',num2str(n)));
        end
        if any(abs(Vc_Initial)==inf)
            error(message('physmod:powersys:common:LesserThan',BlockName,'Capacitor initial voltage(V)','inf'));
        end
        if length(Vc_Initial)~=n
            error(message('physmod:powersys:common:InvalidVectorParameter','Capacitor initial voltage(V)',BlockName,'1',num2str(n)));
        end

        if sps.PowerguiInfo.SPID&&sps.PowerguiInfo.DisableRon

            Ron=0;
        end

        if sps.PowerguiInfo.SPID==0


            if Ron==-999
                Ron=0;
            end
        end

        if Ron==0&&sps.PowerguiInfo.SPID==0
            error(message('physmod:powersys:library:InvalidRonForNonIdealSwitches','Device on-state resistance(Ohms)',BlockName));
        end





        nodes=BLOCKLIST.block_nodes(block);
        N1=nodes(1);
        N2=nodes(2);


        for i=1:n

            if i==1
                Vpos=N1;
            else
                Vpos=Vneg;
            end

            if i==n
                Vneg=N2;
            else
                Vneg=NewNode;
                NewNode=NewNode+1;
            end

            Cpos=NewNode;
            switch bridgetype
            case 'FullMMC'
                Cneg=NewNode+1;
            case 'HalfMMC'
                Cneg=Vneg;
            end
            NewNode=NewNode+2;







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
                    switch bridgetype
                    case 'FullMMC'
                        sps.rlc=[sps.rlc;
                        Cpos,Vneg,0,Rs,0,Css*1e6;
                        Vneg,Cneg,0,Rs,0,Css*1e6];
                        sps.rlcnames{end+1}=['snubber_IGBT3_module',num2str(i),': ',BlockNom];
                        sps.rlcnames{end+1}=['snubber_IGBT4_module',num2str(i),': ',BlockNom];
                    end
                end
            end








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

                    switch bridgetype
                    case 'FullMMC'
                        sps.rlc(end+1,1:6)=[Cpos,RonNode3,0,Ron,0,0];
                        sps.rlcnames{end+1}=['Ron 3 module',num2str(i),': ',BlockNom];
                        sps.rlc(end+1,1:6)=[Vneg,RonNode4,0,Ron,0,0];
                        sps.rlcnames{end+1}=['Ron 4 module',num2str(i),': ',BlockNom];
                    end

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

                switch bridgetype
                case 'FullMMC'
                    sps.rlc(end+1,1:6)=[RonNode3,Vneg,0,1,0,0];
                    sps.rlcnames{end+1}=['SPID 3 module',num2str(i),': ',BlockNom];
                    sps.SPIDresistors(end+1)=size(sps.rlc,1);
                    sps.rlc(end+1,1:6)=[RonNode4,Cneg,0,1,0,0];
                    sps.rlcnames{end+1}=['SPID 4 module',num2str(i),': ',BlockNom];
                    sps.SPIDresistors(end+1)=size(sps.rlc,1);
                end

                sps.switches=[sps.switches;
                RonNode1,Vpos,0,Ron,0;
                RonNode2,Cneg,0,Ron,0];
                sps.SwitchNames{end+1}=['1 module',num2str(i),': ',BlockNom];
                sps.SwitchNames{end+1}=['2 module',num2str(i),': ',BlockNom];

                switch bridgetype
                case 'FullMMC'
                    sps.switches=[sps.switches;
                    RonNode3,Vneg,0,Ron,0;
                    RonNode4,Cneg,0,Ron,0];
                    sps.SwitchNames{end+1}=['3 module',num2str(i),': ',BlockNom];
                    sps.SwitchNames{end+1}=['4 module',num2str(i),': ',BlockNom];
                end

            else


                sps.source=[sps.source;
                Cpos,Vpos,1,0,0,0,7;
                Vpos,Cneg,1,0,0,0,7];

                sps.srcstr{end+1}=['I_IGBT1_module',num2str(i),': ',BlockNom];
                sps.srcstr{end+1}=['I_IGBT2_module',num2str(i),': ',BlockNom];
                sps.outstr{end+1}=['U_IGBT1_module',num2str(i),': ',BlockNom];
                sps.outstr{end+1}=['U_IGBT2_module',num2str(i),': ',BlockNom];

                switch bridgetype
                case 'FullMMC'
                    sps.source=[sps.source;
                    Cpos,Vneg,1,0,0,0,7;
                    Vneg,Cneg,1,0,0,0,7];
                    sps.srcstr{end+1}=['I_IGBT3_module',num2str(i),': ',BlockNom];
                    sps.srcstr{end+1}=['I_IGBT4_module',num2str(i),': ',BlockNom];
                    sps.outstr{end+1}=['U_IGBT3_module',num2str(i),': ',BlockNom];
                    sps.outstr{end+1}=['U_IGBT4_module',num2str(i),': ',BlockNom];
                end

                Yu=[Yu;
                Cpos,Vpos;
                Vpos,Cneg];

                switch bridgetype
                case 'FullMMC'
                    Yu=[Yu;
                    Cpos,Vneg;
                    Vneg,Cneg];
                end

                switch bridgetype
                case 'FullMMC'
                    sps.sourcenames(end+1:end+4,1)=ones(4,1)*get_param(BlockName,'handle');
                otherwise
                    sps.sourcenames(end+1:end+2,1)=ones(2,1)*get_param(BlockName,'handle');
                end

                sps.switches=[sps.switches;
                Cpos,Vpos,0,Ron,0;
                Vpos,Cneg,0,Ron,0];
                sps.SwitchNames{end+1}=['IGBT1_module',num2str(i),': ',BlockNom];
                sps.SwitchNames{end+1}=['IGBT2_module',num2str(i),': ',BlockNom];

                switch bridgetype
                case 'FullMMC'
                    sps.switches=[sps.switches;
                    Cpos,Vneg,0,Ron,0;
                    Vneg,Cneg,0,Ron,0;
                    ];
                    sps.SwitchNames{end+1}=['IGBT3_module',num2str(i),': ',BlockNom];
                    sps.SwitchNames{end+1}=['IGBT4_module',num2str(i),': ',BlockNom];
                end

            end

            switch bridgetype
            case 'FullMMC'
                sps.SwitchType(end+1:end+4)=[7,7,7,7];
                sps.SwitchVf(1:2,end+1:end+4)=[0,0,0,0;0,0,0,0];
            otherwise
                sps.SwitchType(end+1:end+2)=[7,7];
                sps.SwitchVf(1:2,end+1:end+2)=[0,0;0,0];
            end


            sps.rlc(end+1,1:6)=[Cpos,Cneg,0,0,0,C(i)*1e6];
            sps.rlcnames{end+1}=['Capacitor_module',num2str(i),': ',BlockNom];


            sps.BlockInitialState.value{end+1}=Vc_Initial(i);
            sps.BlockInitialState.state{end+1}=['Uc_',sps.rlcnames{end}];
            sps.BlockInitialState.block{end+1}=BlockName;
            sps.BlockInitialState.type{end+1}='Initial voltage';




        end

        switch bridgetype
        case 'FullMMC'
            NumberOfSwitches=4*n;
        otherwise
            NumberOfSwitches=2*n;
        end

        sps.Rswitch(end+1:end+NumberOfSwitches)=ones(1,NumberOfSwitches)*Ron;


        sps.Gates.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.Gates.Mux(end+1)=NumberOfSwitches;

        if sps.PowerguiInfo.SPID==0
            sps.SwitchDevices.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');
        end

        sps.SwitchDevices.Demux(end+1)=NumberOfSwitches;

        sps.SwitchGateInitialValue(end+1:end+NumberOfSwitches)=zeros(1,NumberOfSwitches);
        sps.SwitchDevices.qty=sps.SwitchDevices.qty+NumberOfSwitches;

        if sps.PowerguiInfo.SPID
            sps.Status.Tags{end+1}=get_param([BlockName,'/Uswitch'],'GotoTag');

            sps.Status.Demux(end+1)=2*NumberOfSwitches;
        else
            sps.Status.Tags{end+1}='';
            sps.Status.Demux(end+1)=NumberOfSwitches;
        end

        BlockCount=BlockCount+NumberOfSwitches;
    end
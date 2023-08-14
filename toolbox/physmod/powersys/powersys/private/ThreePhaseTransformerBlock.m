function[sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode]=ThreePhaseTransformerBlock(TypeOfWindings,nl,sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode)










    switch TypeOfWindings

    case 'Three-Phase Transformer (Two Windings)'

        Zigzag=0;
        ThreeWindings=0;
        TW3=3;
        TW2=2;
        TW1=1;

    case 'Three-Phase Transformer (Three Windings)'

        Zigzag=0;
        ThreeWindings=1;
        TW3=0;
        TW2=0;
        TW1=0;

    case 'Zigzag Phase-Shifting Transformer'

        Zigzag=1;
        ThreeWindings=1;
        TW3=0;
        TW2=0;
        TW1=0;

    end


    idx=nl.filter_type(TypeOfWindings);
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');
        measure=get_param(block,'Measurements');


        SPSVerifyLinkStatus(block);


        [NominalPower,Winding1,Winding2,SetSaturation,Rm,Saturation,InitialFluxes,IM]=getSPSmaskvalues(block,{'NominalPower','Winding1','Winding2','SetSaturation','Rm','Saturation','InitialFluxes','DiscreteSolver'});

        LocallyWantDSS=0;
        if sps.PowerguiInfo.Discrete&&strcmp(get_param(block,'BreakLoop'),'off')&&(strcmp(IM,'Backward Euler robust')||strcmp(IM,'Trapezoidal robust'))
            LocallyWantDSS=1;
        end


        if SetSaturation&&sps.PowerguiInfo.Phasor
            message=['To run your model in phasor mode you need to deactivate the saturation parameter of the following block:',...
            newline,...
            'Block : ',strrep(BlockName,newline,' '),...
            newline,...
            'Type  : ',TypeOfWindings];
            Erreur.message=char(message);
            Erreur.identifier='SimscapePowerSystemsST:NotAllowedForPhasorSimulation';
            psberror(Erreur);
        end


        UNITS=get_param(block,'UNITS');
        puUnits=strcmp('pu',UNITS);

        if Zigzag


            [PrimaryVoltage,Secondary,Winding3,RmLm]=getSPSmaskvalues(block,{'PrimaryVoltage','SecondaryVoltage','Winding3','RmLm'});


            SecondaryConnection=get_param(block,'SecondaryConnection');


            blocinit(block,{NominalPower,PrimaryVoltage,Secondary,SecondaryConnection,Winding1,Winding2,Winding3,SetSaturation,RmLm,Rm,Saturation});


            LeadorLag=sign(Secondary(2));
            SetInitialFlux=getSPSmaskvalues(block,{'SetInitialFlux'});
            PhiAngle=Secondary(2);

            ThreeLimbCore=0;
            L0=1;

        else


            [Lm,L0,Hysteresis,DataFile,SetInitialFlux,InitialFluxes]=getSPSmaskvalues(block,{'Lm','L0','Hysteresis','DataFile','SetInitialFlux','InitialFluxes'});


            type1=get_param(block,'Winding1Connection');
            type2=get_param(block,'Winding2Connection');
            ThreeLimbCore=strcmp('Three-limb core (core-type)',get_param(block,'CoreType'));

            if ThreeWindings

                type3=get_param(block,'Winding3Connection');
                Winding3=getSPSmaskvalues(block,{'Winding3'});

                blocinit(block,{NominalPower,type1,Winding1,type2,Winding2,type3,Winding3,SetSaturation,Rm,Lm,Saturation,Hysteresis,DataFile,SetInitialFlux,InitialFluxes});
            else
                type3='';
                Winding3=[];

                blocinit(block,{NominalPower,type1,Winding1,type2,Winding2,SetSaturation,Rm,Lm,Saturation,Hysteresis,DataFile,SetInitialFlux,InitialFluxes});
            end

        end


        Pnom=NominalPower(1);
        freq=NominalPower(2);
        Ps=Pnom/3;


        if Zigzag


            if SetSaturation
                Lm=0;
            else
                Rm=RmLm(1);
                Lm=RmLm(2);
            end

            Rprim=Winding1(1);
            Lprim=Winding1(2);
            Rsec=Winding2(1);
            Lsec=Winding2(2);
            Rter=Winding3(1);
            Lter=Winding3(2);

        else


            if SetSaturation
                Lm=0;
            end

            Vprim=Winding1(1);
            Rprim=Winding1(2);
            Lprim=Winding1(3);
            Vsec=Winding2(1);
            Rsec=Winding2(2);
            Lsec=Winding2(3);

            if ThreeWindings
                Vter=Winding3(1);
                Rter=Winding3(2);
                Lter=Winding3(3);
            end

        end


        X1=NewNode+1;
        X2=NewNode+2;
        X3=NewNode+3;
        X4=NewNode+4;
        X5=NewNode+5;
        X6=NewNode+6;
        X7=NewNode+7;

        if ThreeLimbCore

            XD1=NewNode+8;
            XD2=NewNode+9;
            XD3=NewNode+10;
        end

        NewNode=NewNode+11;


        nodes=nl.block_nodes(block);


        if Zigzag


            n1=X1;
            n2=nodes(4);
            n5=X2;
            n6=nodes(5);
            n9=X3;
            n10=nodes(6);
            n13=nodes(7);
            n15=nodes(8);
            n17=nodes(9);


            if LeadorLag==-1
                n3=nodes(2);
                n4=X2;
                n7=nodes(3);
                n8=X3;
                n11=nodes(1);
                n12=X1;
            else
                n3=nodes(3);
                n4=X3;
                n7=nodes(1);
                n8=X1;
                n11=nodes(2);
                n12=X2;
            end


            switch SecondaryConnection
            case 'Y'
                n14=X7;
                n16=X7;
                n18=X7;
                U3=Secondary(1)/sqrt(3);
                CodeYD3={'sec_A: ','sec_B: ','sec_C: '};
            case 'Yn'
                n14=nodes(10);
                n16=nodes(10);
                n18=nodes(10);
                U3=Secondary(1)/sqrt(3);
                CodeYD3={'sec_A: ','sec_B: ','sec_C: '};
            case 'Yg'
                n14=0;
                n16=0;
                n18=0;
                U3=Secondary(1)/sqrt(3);
                CodeYD3={'sec_A: ','sec_B: ','sec_C: '};
            case 'Delta D1(-30 deg.)'
                n14=n15;
                n16=n17;
                n18=n13;
                U3=Secondary(1);
                CodeYD3={'sec_AB: ','sec_BC: ','sec_CA: '};
            case 'Delta D11(+30 deg.)'
                n14=n17;
                n16=n13;
                n18=n15;
                U3=Secondary(1);
                CodeYD3={'sec_AB: ','sec_BC: ','sec_CA: '};
            end


            alpha=abs(PhiAngle)*pi/180;
            k=sin(2*pi/3)/sin(2*pi/3-alpha);
            U1=PrimaryVoltage/sqrt(3)/k;
            U2=PrimaryVoltage/sqrt(3)*sin(alpha)/sin(2*pi/3-alpha)/k;

        else


            n1=nodes(1);
            n5=nodes(2);
            n9=nodes(3);


            W1N=0;


            n3=nodes(4);
            n7=nodes(5);
            n11=nodes(6);

            switch type1

            case 'Y'
                n2=X1;
                n6=X1;
                n10=X1;
                U1=Vprim/sqrt(3);
                CodeYD1={'an_w1: ','bn_w1: ','cn_w1: '};

            case 'Yn'

                n3=nodes(5);
                n7=nodes(6);
                n11=nodes(7);
                n2=nodes(4);
                n6=nodes(4);
                n10=nodes(4);
                U1=Vprim/sqrt(3);
                CodeYD1={'an_w1: ','bn_w1: ','cn_w1: '};
                W1N=1;

            case 'Yg'
                n2=0;
                n6=0;
                n10=0;
                U1=Vprim/sqrt(3);
                CodeYD1={'ag_w1: ','bg_w1: ','cg_w1: '};

            case 'Delta (D1)'
                n2=n5;
                n6=n9;
                n10=n1;
                U1=Vprim;
                CodeYD1={'ab_w1: ','bc_w1: ','ca_w1: '};

            case 'Delta (D11)'
                n2=n9;
                n6=n1;
                n10=n5;
                U1=Vprim;
                CodeYD1={'ab_w1: ','bc_w1: ','ca_w1: '};
            end


            W2N=0;


            if ThreeWindings
                n13=nodes(7+W1N);
                n15=nodes(8+W1N);
                n17=nodes(9+W1N);
            end

            switch type2

            case 'Y'
                n4=X2;
                n8=X2;
                n12=X2;
                U2=Vsec/sqrt(3);
                CodeYD2={'an_w2: ','bn_w2: ','cn_w2: '};

            case 'Yn'


                if ThreeWindings
                    n13=nodes(7+W1N+1);
                    n15=nodes(8+W1N+1);
                    n17=nodes(9+W1N+1);
                end

                if strcmp(type1,'Yn')
                    Neutre=nodes(8);
                else
                    Neutre=nodes(7);
                end
                n4=Neutre;
                n8=Neutre;
                n12=Neutre;
                U2=Vsec/sqrt(3);
                CodeYD2={'an_w2: ','bn_w2: ','cn_w2: '};
                W2N=1;

            case 'Yg'
                n4=0;
                n8=0;
                n12=0;
                U2=Vsec/sqrt(3);
                CodeYD2={'ag_w2: ','bg_w2: ','cg_w2: '};

            case 'Delta (D1)'
                n4=n7;
                n8=n11;
                n12=n3;
                U2=Vsec;
                CodeYD2={'ab_w2: ','bc_w2: ','ca_w2: '};

            case 'Delta (D11)'
                n4=n11;
                n8=n3;
                n12=n7;
                U2=Vsec;
                CodeYD2={'ab_w2: ','bc_w2: ','ca_w2: '};
            end

            if ThreeWindings


                switch type3
                case 'Y'
                    n14=X3;
                    n16=X3;
                    n18=X3;
                    U3=Vter/sqrt(3);
                    CodeYD3={'an_w3: ','bn_w3: ','cn_w3: '};
                case 'Yn'
                    Neutre=nodes(10+W1N+W2N);
                    n14=Neutre;
                    n16=Neutre;
                    n18=Neutre;
                    U3=Vter/sqrt(3);
                    CodeYD3={'an_w3: ','bn_w3: ','cn_w3: '};
                case 'Yg'
                    n14=0;
                    n16=0;
                    n18=0;
                    U3=Vter/sqrt(3);
                    CodeYD3={'ag_w3: ','bg_w3: ','cg_w3: '};
                case 'Delta (D1)'
                    n14=n15;
                    n16=n17;
                    n18=n13;
                    U3=Vter;
                    CodeYD3={'ab_w3: ','bc_w3: ','ca_w3: '};
                case 'Delta (D11)'
                    n14=n17;
                    n16=n13;
                    n18=n15;
                    U3=Vter;
                    CodeYD3={'ab_w3: ','bc_w3: ','ca_w3: '};
                end
            end
        end


        if puUnits
            Rps=Rprim*(U1^2)/Ps;
            Lps=Lprim*(U1^2)/Ps/(2*pi*freq)*1e3;
            Rms=Rm*(U1^2)/Ps;
            Lms=Lm*(U1^2)/Ps/(2*pi*freq)*1e3;
            L0=L0*(U1^2)/Ps/(2*pi*freq)*1e3;
            Rss=Rsec*(U2^2)/Ps;
            Lss=Lsec*(U2^2)/Ps/(2*pi*freq)*1e3;
            if ThreeWindings
                Rts=Rter*(U3^2)/Ps;
                Lts=Lter*(U3^2)/Ps/(2*pi*freq)*1e3;
            end
        else
            Rps=Rprim;
            Lps=Lprim*1e3;
            Rms=Rm;
            Lms=Lm*1e3;
            L0=L0*1e3;
            Rss=Rsec;
            Lss=Lsec*1e3;
            if ThreeWindings
                Rts=Rter;
                Lts=Lter*1e3;
            end
        end




        if ThreeWindings
            sps.rlc=[sps.rlc;
            n1,n2,2,Rps,Lps,U1;
            n3,n4,2,Rss,Lss,U2;
            n13,n14,2,Rts,Lts,U3];
            if ThreeLimbCore
                sps.rlc=[sps.rlc;XD1,XD2,2,0,L0,U1];


                HiddenDeltaBranch=size(sps.rlc,1);
            end
            sps.rlc=[sps.rlc;X4,n2,1,Rms,Lms,0];
        else
            sps.rlc=[sps.rlc;
            n1,n2,2,Rps,Lps,U1;
            n3,n4,2,Rss,Lss,U2];
            if ThreeLimbCore
                sps.rlc=[sps.rlc;XD1,XD2,2,0,L0,U1];


                HiddenDeltaBranch=size(sps.rlc,1);
            end
            sps.rlc=[sps.rlc;X4,n2,1,Rms,Lms,0];
        end

        sps=CheckAndPatchL1ZeroRmInf(sps,Lps,Rms,SetSaturation);

        sps.rlcnames{end+1}=['transfo_1_winding_1: ',BlockNom];
        sps.rlcnames{end+1}=['transfo_1_winding_2: ',BlockNom];
        if ThreeWindings
            sps.rlcnames{end+1}=['transfo_1_winding_3: ',BlockNom];
        end
        if ThreeLimbCore
            sps.rlcnames{end+1}=['transfo_1_winding_L0: ',BlockNom];
        end
        sps.rlcnames{end+1}=['transfo_1_Lm: ',BlockNom];

        LinearFlux=0;
        Goto21blockIsGoto=strcmp(get_param([BlockName,'/Goto21'],'BlockType'),'Goto');

        if SetSaturation

            sps.source(end+1,1:7)=[X4,n2,1,0,0,0,18];
            YuNonlinear(end+1,1:2)=[X4,n2];%#ok
            sps.srcstr{end+1}=['I_core_transfo_1: ',BlockNom];
            sps.outstr{end+1}=['U_core_transfo_1: ',BlockNom];
            xc=size(sps.modelnames{18},2);
            sps.modelnames{18}(xc+1)=block;

            if Goto21blockIsGoto
                sps.Flux.Tags{end+1}=get_param([BlockName,'/Goto21'],'GotoTag');
                sps.Flux.Mux(end+1)=1;
            end

            if sps.PowerguiInfo.WantDSS||LocallyWantDSS

                if getSPSmaskvalues(block,{'Hysteresis'})==0
                    sps.DSS.block(end+1).type='Saturable transformer (three-phase block phase A)';
                    sps.DSS.block(end).Blockname=BlockName;
                    BaseVoltage=Winding1(1);
                    switch type1
                    case{'Y','Yn','Yg'}
                        Base=BaseValues(NominalPower,3,BaseVoltage/sqrt(3));
                    otherwise
                        Base=BaseValues(NominalPower,1,BaseVoltage);
                    end
                    switch UNITS
                    case 'pu'

                        [InitialFlux,~,~,SaturationCurrent,SaturationFlux]=CalculateInitialFluxes(Saturation,2,[InitialFluxes(1),0,0],Base);
                    otherwise

                        [InitialFlux,~,~,SaturationCurrent,SaturationFlux]=CalculateInitialFluxes(Saturation,1,[InitialFluxes(1),0,0],Base);
                    end

                    sps.DSS.block(end).size=[1,1,1];
                    sps.DSS.block(end).xInit=InitialFlux;
                    sps.DSS.block(end).yinit=0;
                    sps.DSS.block(end).iterate=1;
                    sps.DSS.block(end).VI=[SaturationFlux',SaturationCurrent'];

                    if sps.PowerguiInfo.WantDSS||LocallyWantDSS&&strcmp(IM,'Trapezoidal robust')

                        sps.DSS.block(end).method=2;
                    elseif LocallyWantDSS&&strcmp(IM,'Backward Euler robust')
                        sps.DSS.block(end).method=1;
                    end

                    sps.DSS.block(end).inputs=size(sps.source,1);
                    sps.DSS.block(end).outputs=length(sps.outstr);

                    sps.DSS.model.inTags{end+1}='';
                    sps.DSS.model.inMux(end+1)=1;

                    sps.DSS.model.outTags{end+1}=get_param([BlockName,'/I_exc1'],'GotoTag');
                    sps.DSS.model.outDemux(end+1)=1;
                end
            end


            ysrc=size(sps.source,1);
            sps.InputsNonZero(end+1)=ysrc;


            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From1'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=1;
            sps.U.Tags{end+1}=get_param([BlockName,'/Goto11'],'GotoTag');
            sps.U.Mux(end+1)=1;

        elseif Goto21blockIsGoto


            LinearFlux=1;

            YuNonlinear(end+1,1:2)=[X4,n2];%#ok
            sps.outstr{end+1}=['U_core_transfo_1: ',BlockNom];

            sps.Flux.Tags{end+1}=get_param([BlockName,'/Goto21'],'GotoTag');
            sps.Flux.Mux(end+1)=3;

            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From1'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=1;


            if ThreeLimbCore
                YiExcTransfos.Yi{end+1,1}=[size(sps.rlc,1),-HiddenDeltaBranch];
            else
                YiExcTransfos.Yi{end+1,1}=size(sps.rlc,1);
            end
            YiExcTransfos.outstr{end+1}=['Iexc_A: ',BlockNom];
            YiExcTransfos.Tags{end+1}=get_param([BlockName,'/I_exc1'],'GotoTag');

        end


        if ThreeWindings
            sps.rlc=[sps.rlc;
            n5,n6,2,Rps,Lps,U1;
            n7,n8,2,Rss,Lss,U2;
            n15,n16,2,Rts,Lts,U3];
            if ThreeLimbCore
                sps.rlc=[sps.rlc;XD2,XD3,2,0,L0,U1];
            end
            sps.rlc=[sps.rlc;X5,n6,1,Rms,Lms,0];
        else
            sps.rlc=[sps.rlc;
            n5,n6,2,Rps,Lps,U1;
            n7,n8,2,Rss,Lss,U2];
            if ThreeLimbCore
                sps.rlc=[sps.rlc;XD2,XD3,2,0,L0,U1];
            end
            sps.rlc=[sps.rlc;X5,n6,1,Rms,Lms,0];
        end

        sps=CheckAndPatchL1ZeroRmInf(sps,Lps,Rms,SetSaturation);

        sps.rlcnames{end+1}=['transfo_2_winding_1: ',BlockNom];
        sps.rlcnames{end+1}=['transfo_2_winding_2: ',BlockNom];
        if ThreeWindings
            sps.rlcnames{end+1}=['transfo_2_winding_3: ',BlockNom];
        end
        if ThreeLimbCore
            sps.rlcnames{end+1}=['transfo_2_winding_L0: ',BlockNom];
        end
        sps.rlcnames{end+1}=['transfo_2_Lm: ',BlockNom];

        Goto22blockIsGoto=strcmp(get_param([BlockName,'/Goto22'],'BlockType'),'Goto');

        if SetSaturation

            sps.source(end+1,1:7)=[X5,n6,1,0,0,0,18];
            YuNonlinear(end+1,1:2)=[X5,n6];%#ok
            sps.srcstr{end+1}=['I_core_transfo_2: ',BlockNom];
            sps.outstr{end+1}=['U_core_transfo_2: ',BlockNom];
            xc=size(sps.modelnames{18},2);
            sps.modelnames{18}(xc+1)=block;

            if Goto22blockIsGoto
                sps.Flux.Tags{end+1}=get_param([BlockName,'/Goto22'],'GotoTag');
                sps.Flux.Mux(end+1)=1;
            end

            if sps.PowerguiInfo.WantDSS||LocallyWantDSS

                if getSPSmaskvalues(block,{'Hysteresis'})==0
                    sps.DSS.block(end+1).type='Saturable transformer (three-phase block phase B)';
                    sps.DSS.block(end).Blockname=BlockName;
                    BaseVoltage=Winding1(1);
                    switch type1
                    case{'Y','Yn','Yg'}
                        Base=BaseValues(NominalPower,3,BaseVoltage/sqrt(3));
                    otherwise
                        Base=BaseValues(NominalPower,1,BaseVoltage);
                    end
                    switch UNITS
                    case 'pu'

                        [InitialFlux,~,~,SaturationCurrent,SaturationFlux]=CalculateInitialFluxes(Saturation,2,[InitialFluxes(2),0,0],Base);
                    otherwise

                        [InitialFlux,~,~,SaturationCurrent,SaturationFlux]=CalculateInitialFluxes(Saturation,1,[InitialFluxes(2),0,0],Base);
                    end

                    sps.DSS.block(end).size=[1,1,1];
                    sps.DSS.block(end).xInit=InitialFlux;
                    sps.DSS.block(end).yinit=0;
                    sps.DSS.block(end).iterate=1;
                    sps.DSS.block(end).VI=[SaturationFlux',SaturationCurrent'];

                    if sps.PowerguiInfo.WantDSS||LocallyWantDSS&&strcmp(IM,'Trapezoidal robust')

                        sps.DSS.block(end).method=2;
                    elseif LocallyWantDSS&&strcmp(IM,'Backward Euler robust')
                        sps.DSS.block(end).method=1;
                    end

                    sps.DSS.block(end).inputs=size(sps.source,1);
                    sps.DSS.block(end).outputs=length(sps.outstr);
                    sps.DSS.model.inTags{end+1}='';
                    sps.DSS.model.inMux(end+1)=1;
                    sps.DSS.model.outTags{end+1}=get_param([BlockName,'/I_exc2'],'GotoTag');
                    sps.DSS.model.outDemux(end+1)=1;
                end
            end


            ysrc=size(sps.source,1);
            sps.InputsNonZero(end+1)=ysrc;

            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From2'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=1;
            sps.U.Tags{end+1}=get_param([BlockName,'/Goto12'],'GotoTag');
            sps.U.Mux(end+1)=1;

        elseif Goto22blockIsGoto



            YuNonlinear(end+1,1:2)=[X5,n6];%#ok
            sps.outstr{end+1}=['U_core_transfo_2: ',BlockNom];

            sps.Flux.Tags{end+1}=get_param([BlockName,'/Goto22'],'GotoTag');
            sps.Flux.Mux(end+1)=3;

            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From2'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=1;


            if ThreeLimbCore
                YiExcTransfos.Yi{end+1,1}=[size(sps.rlc,1),-HiddenDeltaBranch];
            else
                YiExcTransfos.Yi{end+1,1}=size(sps.rlc,1);
            end
            YiExcTransfos.outstr{end+1}=['Iexc_B: ',BlockNom];
            YiExcTransfos.Tags{end+1}=get_param([BlockName,'/I_exc2'],'GotoTag');

        end


        if ThreeWindings
            sps.rlc=[sps.rlc;
            n9,n10,2,Rps,Lps,U1;
            n11,n12,2,Rss,Lss,U2;
            n17,n18,2,Rts,Lts,U3];
            if ThreeLimbCore
                sps.rlc=[sps.rlc;XD3,XD1,2,0,L0,U1];
            end
            sps.rlc=[sps.rlc;X6,n10,1,Rms,Lms,0];
        else
            sps.rlc=[sps.rlc;
            n9,n10,2,Rps,Lps,U1;
            n11,n12,2,Rss,Lss,U2];
            if ThreeLimbCore
                sps.rlc=[sps.rlc;XD3,XD1,2,0,L0,U1];
            end
            sps.rlc=[sps.rlc;X6,n10,1,Rms,Lms,0];
        end

        sps=CheckAndPatchL1ZeroRmInf(sps,Lps,Rms,SetSaturation);

        sps.rlcnames{end+1}=['transfo_3_winding_1: ',BlockNom];
        sps.rlcnames{end+1}=['transfo_3_winding_2: ',BlockNom];
        if ThreeWindings
            sps.rlcnames{end+1}=['transfo_3_winding_3: ',BlockNom];
        end
        if ThreeLimbCore
            sps.rlcnames{end+1}=['transfo_3_winding_L0: ',BlockNom];
        end
        sps.rlcnames{end+1}=['transfo_3_Lm: ',BlockNom];

        Goto23blockIsGoto=strcmp(get_param([BlockName,'/Goto23'],'BlockType'),'Goto');

        if SetSaturation

            sps.source(end+1,1:7)=[X6,n10,1,0,0,0,18];
            YuNonlinear(end+1,1:2)=[X6,n10];%#ok
            sps.srcstr{end+1}=['I_core_transfo_3: ',BlockNom];
            sps.outstr{end+1}=['U_core_transfo_3: ',BlockNom];
            xc=size(sps.modelnames{18},2);
            sps.modelnames{18}(xc+1)=block;

            if Goto23blockIsGoto
                sps.Flux.Tags{end+1}=get_param([BlockName,'/Goto23'],'GotoTag');
                sps.Flux.Mux(end+1)=1;
            end


            sps.sourcenames(end+1:end+3,1)=[block,block,block];
            sps.nbmodels(18)=sps.nbmodels(18)+3;

            if sps.PowerguiInfo.WantDSS||LocallyWantDSS
                if getSPSmaskvalues(block,{'Hysteresis'})==0
                    sps.DSS.block(end+1).type='Saturable transformer (three-phase block phase C)';
                    sps.DSS.block(end).Blockname=BlockName;
                    BaseVoltage=Winding1(1);
                    switch type1
                    case{'Y','Yn','Yg'}
                        Base=BaseValues(NominalPower,3,BaseVoltage/sqrt(3));
                    otherwise
                        Base=BaseValues(NominalPower,1,BaseVoltage);
                    end
                    switch UNITS
                    case 'pu'

                        [InitialFlux,~,~,SaturationCurrent,SaturationFlux]=CalculateInitialFluxes(Saturation,2,[InitialFluxes(3),0,0],Base);
                    otherwise

                        [InitialFlux,~,~,SaturationCurrent,SaturationFlux]=CalculateInitialFluxes(Saturation,1,[InitialFluxes(3),0,0],Base);
                    end

                    sps.DSS.block(end).size=[1,1,1];
                    sps.DSS.block(end).xInit=InitialFlux;
                    sps.DSS.block(end).yinit=0;
                    sps.DSS.block(end).iterate=1;
                    sps.DSS.block(end).VI=[SaturationFlux',SaturationCurrent'];

                    if sps.PowerguiInfo.WantDSS||LocallyWantDSS&&strcmp(IM,'Trapezoidal robust')

                        sps.DSS.block(end).method=2;
                    elseif LocallyWantDSS&&strcmp(IM,'Backward Euler robust')
                        sps.DSS.block(end).method=1;
                    end

                    sps.DSS.block(end).inputs=size(sps.source,1);
                    sps.DSS.block(end).outputs=length(sps.outstr);
                    sps.DSS.model.inTags{end+1}='';
                    sps.DSS.model.inMux(end+1)=1;
                    sps.DSS.model.outTags{end+1}=get_param([BlockName,'/I_exc3'],'GotoTag');
                    sps.DSS.model.outDemux(end+1)=1;
                end
            end


            ysrc=size(sps.source,1);
            sps.InputsNonZero(end+1)=ysrc;

            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From3'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=1;
            sps.U.Tags{end+1}=get_param([BlockName,'/Goto13'],'GotoTag');
            sps.U.Mux(end+1)=1;

        elseif Goto23blockIsGoto



            YuNonlinear(end+1,1:2)=[X6,n10];%#ok
            sps.outstr{end+1}=['U_core_transfo_3: ',BlockNom];

            sps.Flux.Tags{end+1}=get_param([BlockName,'/Goto23'],'GotoTag');
            sps.Flux.Mux(end+1)=3;

            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From3'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=1;


            if ThreeLimbCore
                YiExcTransfos.Yi{end+1,1}=[size(sps.rlc,1),-HiddenDeltaBranch];
            else
                YiExcTransfos.Yi{end+1,1}=size(sps.rlc,1);
            end
            YiExcTransfos.outstr{end+1}=['Iexc_C: ',BlockNom];
            YiExcTransfos.Tags{end+1}=get_param([BlockName,'/I_exc3'],'GotoTag');

        end


        if SetSaturation&&SetInitialFlux==0

            sps.SaturableTransfo(end+1).Name=BlockName;
            sps.SaturableTransfo(end).Output=length(sps.outstr)-2;
            sps.SaturableTransfo(end).Type='Three-Phase';
            sps.SaturableTransfo(end).BaseFlux=(U1/(2*pi*freq))*sqrt(2);
        end


        if isfield(sps,'LoadFlow')

            switch TypeOfWindings

            case{'Three-Phase Transformer (Two Windings)','Three-Phase Transformer (Three Windings)'}

                sps.LoadFlow.xfo.handle{end+1}=block;
                sps.LoadFlow.xfo.nodes{end+1}=nodes(1:3);
                if~isfield(sps.LoadFlow.xfo,'busNumber')
                    sps.LoadFlow.xfo.vnom{1}=Vprim;
                    sps.LoadFlow.xfo.busNumber{1}=NaN;
                else
                    sps.LoadFlow.xfo.vnom{end+1}=Vprim;
                    sps.LoadFlow.xfo.busNumber{end+1}=NaN;
                end


                sps.LoadFlow.xfo.handle{end+1}=block;
                sps.LoadFlow.xfo.nodes{end+1}=nodes((4:6)+W1N);

                if~isfield(sps.LoadFlow.xfo,'busNumber')
                    sps.LoadFlow.xfo.vnom{1}=Vsec;
                    sps.LoadFlow.xfo.busNumber{1}=NaN;
                else
                    sps.LoadFlow.xfo.vnom{end+1}=Vsec;
                    sps.LoadFlow.xfo.busNumber{end+1}=NaN;
                end
            end

            switch TypeOfWindings

            case{'Three-Phase Transformer (Three Windings)'}

                sps.LoadFlow.xfo.handle{end+1}=block;

                sps.LoadFlow.xfo.nodes{end+1}=nodes((7:9)+W1N+W2N);

                if~isfield(sps.LoadFlow.xfo,'busNumber')
                    sps.LoadFlow.xfo.vnom{1}=Vter;
                    sps.LoadFlow.xfo.busNumber{1}=NaN;
                else
                    sps.LoadFlow.xfo.vnom{end+1}=Vter;
                    sps.LoadFlow.xfo.busNumber{end+1}=NaN;
                end
            end

        end

        if isfield(sps,'UnbalancedLoadFlow')

            if Zigzag
                sps.UnbalancedLoadFlow.Transfos.Units{end+1}=get_param(block,'UNITS');
                sps.UnbalancedLoadFlow.Transfos.handle{end+1}=block;
                sps.UnbalancedLoadFlow.Transfos.Type{end+1}='zigzag';
                sps.UnbalancedLoadFlow.Transfos.conW1{end+1}='zigzag';
                sps.UnbalancedLoadFlow.Transfos.conW2{end+1}='zigzag';
                sps.UnbalancedLoadFlow.Transfos.conW3{end+1}=SecondaryConnection;
                sps.UnbalancedLoadFlow.Transfos.Pnom{end+1}=Pnom;
                sps.UnbalancedLoadFlow.Transfos.Fnom{end+1}=freq;
                sps.UnbalancedLoadFlow.Transfos.W1{end+1}=[];
                sps.UnbalancedLoadFlow.Transfos.W2{end+1}=[];
                sps.UnbalancedLoadFlow.Transfos.W3{end+1}=[];
                sps.UnbalancedLoadFlow.Transfos.W1nodes{end+1}=nodes(1:3);
                sps.UnbalancedLoadFlow.Transfos.W2nodes{end+1}=nodes(4:6);
                sps.UnbalancedLoadFlow.Transfos.W3nodes{end+1}=nodes(7:9);
                sps.UnbalancedLoadFlow.Transfos.RmLm{end+1}=[Rm,Lm];
                sps.UnbalancedLoadFlow.Transfos.W1busNumber{end+1}=[];
                sps.UnbalancedLoadFlow.Transfos.W2busNumber{end+1}=[];
                sps.UnbalancedLoadFlow.Transfos.W3busNumber{end+1}=[];

            else
                sps.UnbalancedLoadFlow.Transfos.Units{end+1}=get_param(block,'UNITS');
                sps.UnbalancedLoadFlow.Transfos.handle{end+1}=block;
                switch getSPSmaskvalues(block,{'CoreType'})
                case{1,'Three single-phase transformers'}
                    sps.UnbalancedLoadFlow.Transfos.Type{end+1}='3SinglePhase';
                    sps.UnbalancedLoadFlow.Transfos.L0{end+1}=[];
                case{2,'Three-limb core (core-type)'}
                    sps.UnbalancedLoadFlow.Transfos.Type{end+1}='3PhaseCoreType';
                    sps.UnbalancedLoadFlow.Transfos.L0{end+1}=getSPSmaskvalues(block,{'L0'});
                case{3,'Five-limb core (shell-type)'}
                    sps.UnbalancedLoadFlow.Transfos.Type{end+1}='3SinglePhase';
                    sps.UnbalancedLoadFlow.Transfos.L0{end+1}=[];
                end

                sps.UnbalancedLoadFlow.Transfos.conW1{end+1}=type1;
                sps.UnbalancedLoadFlow.Transfos.conW2{end+1}=type2;
                sps.UnbalancedLoadFlow.Transfos.conW3{end+1}=type3;
                sps.UnbalancedLoadFlow.Transfos.Pnom{end+1}=Pnom;
                sps.UnbalancedLoadFlow.Transfos.Fnom{end+1}=freq;
                sps.UnbalancedLoadFlow.Transfos.W1{end+1}=Winding1;
                sps.UnbalancedLoadFlow.Transfos.W2{end+1}=Winding2;
                sps.UnbalancedLoadFlow.Transfos.W3{end+1}=Winding3;
                sps.UnbalancedLoadFlow.Transfos.W1nodes{end+1}=nodes(1:3);
                sps.UnbalancedLoadFlow.Transfos.W2nodes{end+1}=nodes((4:6)+W1N);
                switch TypeOfWindings
                case{'Three-Phase Transformer (Three Windings)'}
                    sps.UnbalancedLoadFlow.Transfos.W3nodes{end+1}=nodes((7:9)+W1N+W2N);
                otherwise
                    sps.UnbalancedLoadFlow.Transfos.W3nodes{end+1}=[];
                end
                sps.UnbalancedLoadFlow.Transfos.RmLm{end+1}=[Rm,Lm];
                sps.UnbalancedLoadFlow.Transfos.W1busNumber{end+1}=[];
                sps.UnbalancedLoadFlow.Transfos.W2busNumber{end+1}=[];
                sps.UnbalancedLoadFlow.Transfos.W3busNumber{end+1}=[];

            end

        end



        x=size(sps.rlc,1);
        y=size(sps.source,1);




















        if strcmp(measure,'Winding voltages')||(~Zigzag&&strcmp(measure,'All measurements (V I Fluxes)'))

            Multimeter.Yu(end+1,1:2)=sps.rlc(x-11-3*ThreeLimbCore+TW3,1:2);
            Multimeter.V{end+1}=['U',CodeYD1{1},BlockNom];
            Multimeter.Yu(end+1,1:2)=sps.rlc(x-7-2*ThreeLimbCore+TW2,1:2);
            Multimeter.V{end+1}=['U',CodeYD1{2},BlockNom];
            Multimeter.Yu(end+1,1:2)=sps.rlc(x-3-ThreeLimbCore+TW1,1:2);
            Multimeter.V{end+1}=['U',CodeYD1{3},BlockNom];

            Multimeter.Yu(end+1,1:2)=sps.rlc(x-10-3*ThreeLimbCore+TW3,1:2);
            Multimeter.V{end+1}=['U',CodeYD2{1},BlockNom];
            Multimeter.Yu(end+1,1:2)=sps.rlc(x-6-2*ThreeLimbCore+TW2,1:2);
            Multimeter.V{end+1}=['U',CodeYD2{2},BlockNom];
            Multimeter.Yu(end+1,1:2)=sps.rlc(x-2-ThreeLimbCore+TW1,1:2);
            Multimeter.V{end+1}=['U',CodeYD2{3},BlockNom];
            if ThreeWindings

                Multimeter.Yu(end+1,1:2)=sps.rlc(x-9-3*ThreeLimbCore,1:2);
                Multimeter.V{end+1}=['U',CodeYD3{1},BlockNom];
                Multimeter.Yu(end+1,1:2)=sps.rlc(x-5-2*ThreeLimbCore,1:2);
                Multimeter.V{end+1}=['U',CodeYD3{2},BlockNom];
                Multimeter.Yu(end+1,1:2)=sps.rlc(x-1-ThreeLimbCore,1:2);
                Multimeter.V{end+1}=['U',CodeYD3{3},BlockNom];
            end
        end

        if strcmp(measure,'Winding currents')||(~Zigzag&&strcmp(measure,'All measurements (V I Fluxes)'))

            Multimeter.I{end+1}=['I',CodeYD1{1},BlockNom];
            Multimeter.Yi{end+1,1}=x-11-3*ThreeLimbCore+TW3;
            Multimeter.I{end+1}=['I',CodeYD1{2},BlockNom];
            Multimeter.Yi{end+1,1}=x-7-2*ThreeLimbCore+TW2;
            Multimeter.I{end+1}=['I',CodeYD1{3},BlockNom];
            Multimeter.Yi{end+1,1}=x-3-ThreeLimbCore+TW1;

            Multimeter.I{end+1}=['I',CodeYD2{1},BlockNom];
            Multimeter.Yi{end+1,1}=x-10-3*ThreeLimbCore+TW3;
            Multimeter.I{end+1}=['I',CodeYD2{2},BlockNom];
            Multimeter.Yi{end+1,1}=x-6-2*ThreeLimbCore+TW2;
            Multimeter.I{end+1}=['I',CodeYD2{3},BlockNom];
            Multimeter.Yi{end+1,1}=x-2-ThreeLimbCore+TW1;
            if ThreeWindings

                Multimeter.I{end+1}=['I',CodeYD3{1},BlockNom];
                Multimeter.Yi{end+1,1}=x-9-3*ThreeLimbCore;
                Multimeter.I{end+1}=['I',CodeYD3{2},BlockNom];
                Multimeter.Yi{end+1,1}=x-5-2*ThreeLimbCore;
                Multimeter.I{end+1}=['I',CodeYD3{3},BlockNom];
                Multimeter.Yi{end+1,1}=x-1-ThreeLimbCore;
            end
        end


        if strcmp(measure,'Phase voltages')||(Zigzag&&strcmp(measure,'All measurements (V I Fluxes)'))

            Multimeter.Yu(end+1,1:2)=[nodes(1),nodes(4)];
            Multimeter.V{end+1}=['Uprim_A: ',BlockNom];
            Multimeter.Yu(end+1,1:2)=[nodes(2),nodes(5)];
            Multimeter.V{end+1}=['Uprim_B: ',BlockNom];
            Multimeter.Yu(end+1,1:2)=[nodes(3),nodes(6)];
            Multimeter.V{end+1}=['Uprim_C: ',BlockNom];

            Multimeter.Yu(end+1,1:2)=sps.rlc(x-9,1:2);
            Multimeter.V{end+1}=['U',CodeYD3{1},BlockNom];
            Multimeter.Yu(end+1,1:2)=sps.rlc(x-5,1:2);
            Multimeter.V{end+1}=['U',CodeYD3{2},BlockNom];
            Multimeter.Yu(end+1,1:2)=sps.rlc(x-1,1:2);
            Multimeter.V{end+1}=['U',CodeYD3{3},BlockNom];
        end

        if strcmp(measure,'Phase currents')||(Zigzag&&strcmp(measure,'All measurements (V I Fluxes)'))

            Multimeter.I{end+1}=['Iprim_A: ',BlockNom];
            Multimeter.Yi{end+1,1}=x-11;
            Multimeter.I{end+1}=['Iprim_B: ',BlockNom];
            Multimeter.Yi{end+1,1}=x-7;
            Multimeter.I{end+1}=['Iprim_C: ',BlockNom];
            Multimeter.Yi{end+1,1}=x-3;

            Multimeter.I{end+1}=['Isec_A: ',BlockNom];
            Multimeter.Yi{end+1,1}=x-9;
            Multimeter.I{end+1}=['Isec_B: ',BlockNom];
            Multimeter.Yi{end+1,1}=x-5;
            Multimeter.I{end+1}=['Isec_C: ',BlockNom];
            Multimeter.Yi{end+1,1}=x-1;
        end

        if SetSaturation
            sps.mesureFluxes(1,end+1:end+3)=[0,0,0];
        end

        if LinearFlux
            sps.mesureFluxes(1,end+1:end+9)=[0,0,0,0,0,0,0,0,0];
        end

        switch measure

        case{'Fluxes and excitation currents ( Imag + IRm )',...
            'Fluxes and excitation currents (Imag + IRm)',...
            'Fluxes and magnetization currents ( Imag )',...
            'Fluxes and magnetization currents (Imag)',...
            'All measurements (V I Fluxes)'}

            if SetSaturation

                Multimeter=MeasureExcitationCurrents(Multimeter,BlockNom,y,x,TW1,TW2,ThreeLimbCore);

                Multimeter=MeasureSaturableMagnetizationCurrents(Multimeter,BlockNom,y,x,TW1,TW2,ThreeLimbCore);

                [Multimeter,sps]=MeasureTheFluxes(Multimeter,sps,BlockNom);

            elseif LinearFlux

                [Multimeter,sps]=MeasuresLinear(Multimeter,sps,BlockNom);
            end
        end

    end

    function[Multimeter,sps]=MeasureTheFluxes(Multimeter,sps,BlockNom)

        Multimeter.F{end+1}=['Flux_A: ',BlockNom];
        Multimeter.F{end+1}=['Flux_B: ',BlockNom];
        Multimeter.F{end+1}=['Flux_C: ',BlockNom];
        sps.mesureFluxes(1,end-2:end)=[1,1,1];

        function[Multimeter,sps]=MeasuresLinear(Multimeter,sps,BlockNom)


            Multimeter.F{end+1}=['Iexc_A: ',BlockNom];
            Multimeter.F{end+1}=['Iexc_B: ',BlockNom];
            Multimeter.F{end+1}=['Iexc_C: ',BlockNom];


            Multimeter.F{end+1}=['Imag_A: ',BlockNom];
            Multimeter.F{end+1}=['Imag_B: ',BlockNom];
            Multimeter.F{end+1}=['Imag_C: ',BlockNom];


            Multimeter.F{end+1}=['Flux_A: ',BlockNom];
            Multimeter.F{end+1}=['Flux_B: ',BlockNom];
            Multimeter.F{end+1}=['Flux_C: ',BlockNom];

            sps.mesureFluxes(1,end-8:end)=[1,1,1,1,1,1,1,1,1];

            function Multimeter=MeasureSaturableMagnetizationCurrents(Multimeter,BlockNom,y,x,TW1,TW2,ThreeLimbCore)

                Multimeter.I{end+1}=['Imag_A: ',BlockNom];
                Multimeter.I{end+1}=['Imag_B: ',BlockNom];
                Multimeter.I{end+1}=['Imag_C: ',BlockNom];

                W0a=x-11+TW2;
                W0b=x-6+TW1;
                W0c=x-1;

                if ThreeLimbCore
                    Multimeter.Yi{end+1,1}=-W0a;
                    Multimeter.Yi{end,2}=y-2;
                else
                    Multimeter.Yi{end+1,2}=y-2;
                end

                if ThreeLimbCore
                    Multimeter.Yi{end+1,1}=-W0b;
                    Multimeter.Yi{end,2}=y-1;
                else
                    Multimeter.Yi{end+1,2}=y-1;
                end

                if ThreeLimbCore
                    Multimeter.Yi{end+1,1}=-W0c;
                    Multimeter.Yi{end,2}=y;
                else
                    Multimeter.Yi{end+1,2}=y;
                end

                function Multimeter=MeasureExcitationCurrents(Multimeter,BlockNom,y,x,TW1,TW2,ThreeLimbCore)


                    Multimeter.I{end+1}=['Iexc_A: ',BlockNom];
                    Multimeter.I{end+1}=['Iexc_B: ',BlockNom];
                    Multimeter.I{end+1}=['Iexc_C: ',BlockNom];

                    if ThreeLimbCore
                        Rma=x-10+TW2;
                        Rmb=x-5+TW1;
                        Rmc=x;
                    else
                        Rma=x-10+2+TW2;
                        Rmb=x-5+1+TW1;
                        Rmc=x;
                    end

                    W0a=Rma-1;
                    W0b=Rmb-1;
                    W0c=Rmc-1;

                    if ThreeLimbCore
                        Multimeter.Yi{end+1,1}=[Rma,-W0a];
                        Multimeter.Yi{end,2}=y-2;
                    else
                        Multimeter.Yi{end+1,1}=Rma;
                        Multimeter.Yi{end,2}=y-2;
                    end

                    if ThreeLimbCore
                        Multimeter.Yi{end+1,1}=[Rmb,-W0b];
                        Multimeter.Yi{end,2}=y-1;
                    else
                        Multimeter.Yi{end+1,1}=Rmb;
                        Multimeter.Yi{end,2}=y-1;
                    end

                    if ThreeLimbCore
                        Multimeter.Yi{end+1,1}=[Rmc,-W0c];
                        Multimeter.Yi{end,2}=y;
                    else
                        Multimeter.Yi{end+1,1}=Rmc;
                        Multimeter.Yi{end,2}=y;
                    end

                    function sps=CheckAndPatchL1ZeroRmInf(sps,Lps,Rms,SetSaturation)




























                        if SetSaturation==0&&Rms==Inf&&Lps==0
                            sps.rlc(end,4)=1e6;



                        end

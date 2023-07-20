function ThreePhaseTransformersCback(NumberOfWindings,block,flag,p1)










    AUTOTRANSFOMODE=0;

    switch NumberOfWindings

    case 'Two Windings'

        ThreeWindings=0;
        OFFSET=1;

        MaskPrompts=get_param(block,'MaskPrompts');

        SI_Prompts=MaskPrompts;
        SI_Prompts{11}='Winding 1 parameters [ V1 Ph-Ph(Vrms) , R1(Ohm) , L1(H) ]';
        SI_Prompts{12}='Winding 2 parameters [ V2 Ph-Ph(Vrms) , R2(Ohm) , L2(H) ]';
        SI_Prompts{13}='Magnetization resistance  Rm (Ohm)';
        SI_Prompts{14}='Magnetization inductance  Lm (H)';
        SI_Prompts{15}='Inductance L0 of zero-sequence flux path return (H)';
        SI_Prompts{16}='Saturation characteristic [ i1(A) ,  phi1(V.s) ;  i2 , phi2 ; ... ]';
        SI_Prompts{17}='Initial fluxes [ phi0A , phi0B , phi0C ] (V.s):';

        PU_Prompts=MaskPrompts;
        PU_Prompts{11}='Winding 1 parameters [ V1 Ph-Ph(Vrms) , R1(pu) , L1(pu) ]';
        PU_Prompts{12}='Winding 2 parameters [ V2 Ph-Ph(Vrms) , R2(pu) , L2(pu) ]';
        PU_Prompts{13}='Magnetization resistance  Rm (pu)';
        PU_Prompts{14}='Magnetization inductance  Lm (pu)';
        PU_Prompts{15}='Inductance L0 of zero-sequence flux path return (pu)';
        PU_Prompts{16}='Saturation characteristic [ i1 ,  phi1 ;  i2 , phi2 ; ... ] (pu)';
        PU_Prompts{17}='Initial fluxes [ phi0A , phi0B , phi0C ] (pu):';

    case 'Three Windings'

        ThreeWindings=1;
        OFFSET=0;

        MaskPrompts=get_param(block,'MaskPrompts');

        SI_Prompts=MaskPrompts;
        SI_Prompts{12}='Winding 1 parameters [ V1 Ph-Ph(Vrms) , R1(Ohm) , L1(H) ]';
        SI_Prompts{13}='Winding 2 parameters [ V2 Ph-Ph(Vrms) , R2(Ohm) , L2(H) ]';
        SI_Prompts{14}='Winding 3 parameters [ V3 Ph-Ph(Vrms) , R3(Ohm) , L3(H) ]';
        SI_Prompts{15}='Magnetization resistance  Rm (Ohm)';
        SI_Prompts{16}='Magnetization inductance  Lm (H)';
        SI_Prompts{17}='Inductance L0 of zero-sequence flux path return (H)';
        SI_Prompts{18}='Saturation characteristic [ i1(A) ,  phi1(V.s) ;  i2 , phi2 ; ... ]';
        SI_Prompts{19}='Initial fluxes [ phi0A , phi0B , phi0C ] (V.s):';

        PU_Prompts=MaskPrompts;
        PU_Prompts{12}='Winding 1 parameters [ V1 Ph-Ph(Vrms) , R1(pu) , L1(pu) ]';
        PU_Prompts{13}='Winding 2 parameters [ V2 Ph-Ph(Vrms) , R2(pu) , L2(pu) ]';
        PU_Prompts{14}='Winding 3 parameters [ V3 Ph-Ph(Vrms) , R3(pu) , L3(pu) ]';
        PU_Prompts{15}='Magnetization resistance  Rm (pu)';
        PU_Prompts{16}='Magnetization inductance  Lm (pu)';
        PU_Prompts{17}='Inductance L0 of zero-sequence flux path return (pu)';
        PU_Prompts{18}='Saturation characteristic [ i1 ,  phi1 ;  i2 , phi2 ; ... ] (pu)';
        PU_Prompts{19}='Initial fluxes [ phi0A , phi0B , phi0C ] (pu):';

    case 'Two Windings Inductance Matrix'

        OFFSET=1;
        if isequal('on',get_param(block,'AutoTransformer'));
            AUTOTRANSFOMODE=1;
        end

    case 'Three Windings Inductance Matrix'

        OFFSET=0;
        if isequal('on',get_param(block,'AutoTransformer'));
            AUTOTRANSFOMODE=1;
        end

    end



    switch flag

    case{'Saturation','Hysteresis','InitialFluxes','Core','BAL'}

        MaskVisibilities=get_param(block,'Maskvisibilities');
        MaskEnables=get_param(block,'MaskEnables');
        MaskValues=get_param(block,'MaskValues');



        ThreeLimbCore=strcmp('Three-limb core (core-type)',get_param(block,'CoreType'))||strcmp('Three-limb or five-limb core',get_param(block,'CoreType'));

        SetSaturation=strcmp('on',MaskValues{5-OFFSET});
        SetHysteresis=strcmp('on',MaskValues{6-OFFSET});
        SetInitfluxes=strcmp('on',MaskValues{8-OFFSET});

        if SetSaturation

            MaskVisibilities{6-OFFSET}='on';

            if SetHysteresis
                MaskVisibilities{7-OFFSET}='on';
            else
                MaskVisibilities{7-OFFSET}='off';
            end

            MaskVisibilities{8-OFFSET}='on';

            MaskEnables{16-OFFSET-OFFSET}='off';
            MaskEnables{18-OFFSET-OFFSET}='on';

            if SetInitfluxes
                MaskEnables{19-OFFSET-OFFSET}='on';
                MaskVisibilities{19-OFFSET-OFFSET}='on';
            else
                MaskEnables{19-OFFSET-OFFSET}='off';
                MaskVisibilities{19-OFFSET-OFFSET}='off';
            end

        else

            MaskVisibilities{6-OFFSET}='off';
            MaskVisibilities{7-OFFSET}='off';
            MaskVisibilities{8-OFFSET}='off';

            MaskEnables{16-OFFSET-OFFSET}='on';
            MaskEnables{18-OFFSET-OFFSET}='off';
            MaskEnables{19-OFFSET-OFFSET}='off';

            MaskVisibilities{19-OFFSET-OFFSET}='off';

        end

        if ThreeLimbCore
            MaskVisibilities{17-OFFSET-OFFSET}='on';
        else
            MaskVisibilities{17-OFFSET-OFFSET}='off';
        end

        if strcmp(get_param(block,'BreakLoop'),'on')
            MaskVisibilities{21-2*OFFSET}='off';
        else
            MaskVisibilities{21-2*OFFSET}='on';
        end

        set_param(block,'MaskVisibilities',MaskVisibilities)
        set_param(block,'MaskEnables',MaskEnables)

    case{'AutoTransformer','CoreType'}

        MaskVisibilities=get_param(block,'MaskVisibilities');

        ThreeLimbCore=strcmp('Three-limb core (core-type)',get_param(block,'CoreType'))||strcmp('Three-limb or five-limb core',get_param(block,'CoreType'));
        FiveLimbCore=strcmp(get_param(block,'CoreType'),'Five-limb core (shell-type)');

        AutoTransformer=strcmp(get_param(block,'AutoTransformer'),'on');




        if AutoTransformer

            if ThreeLimbCore||FiveLimbCore




                MaskVisibilities{10-OFFSET}='on';
                MaskVisibilities{11-OFFSET}='on';
                MaskVisibilities{13-OFFSET}='on';
                MaskVisibilities{14-OFFSET}='on';
                MaskVisibilities{15-OFFSET}='on';
                MaskVisibilities{17-OFFSET}='on';




                MaskVisibilities{12-OFFSET}='off';
                MaskVisibilities{16-OFFSET}='off';

                if OFFSET==0
                    MaskVisibilities{18}='on';
                end

            else




                MaskVisibilities{10-OFFSET}='on';
                MaskVisibilities{11-OFFSET}='on';
                MaskVisibilities{13-OFFSET}='on';




                MaskVisibilities{12-OFFSET}='off';
                MaskVisibilities{14-OFFSET}='off';
                MaskVisibilities{15-OFFSET}='off';
                MaskVisibilities{16-OFFSET}='off';
                MaskVisibilities{17-OFFSET}='off';

                if OFFSET==0
                    MaskVisibilities{18}='off';
                end

            end

        else

            if ThreeLimbCore||FiveLimbCore




                MaskVisibilities{10-OFFSET}='on';
                MaskVisibilities{11-OFFSET}='on';
                MaskVisibilities{12-OFFSET}='on';
                MaskVisibilities{14-OFFSET}='on';
                MaskVisibilities{15-OFFSET}='on';
                MaskVisibilities{16-OFFSET}='on';




                MaskVisibilities{13-OFFSET}='off';
                MaskVisibilities{17-OFFSET}='off';

                if OFFSET==0
                    MaskVisibilities{18}='on';
                end

            else




                MaskVisibilities{10-OFFSET}='on';
                MaskVisibilities{11-OFFSET}='on';
                MaskVisibilities{12-OFFSET}='on';




                MaskVisibilities{13-OFFSET}='off';
                MaskVisibilities{14-OFFSET}='off';
                MaskVisibilities{15-OFFSET}='off';
                MaskVisibilities{16-OFFSET}='off';
                MaskVisibilities{17-OFFSET}='off';

                if OFFSET==0
                    MaskVisibilities{18}='off';
                end

            end

        end

        set_param(block,'MaskVisibilities',MaskVisibilities);

    end

    switch flag

    case{'Saturation','Hysteresis','InitialFluxes','Core','AutoTransformer','CoreType'}

        aMaskObj=Simulink.Mask.get(block);
        AdvancedTab=aMaskObj.getDialogControl('Advanced');

        PowerguiInfo=getPowerguiInfo(bdroot(block),block);
        if PowerguiInfo.Continuous||PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor
            AdvancedTab.Visible='off';
        else
            if PowerguiInfo.AutomaticDiscreteSolvers
                AdvancedTab.Visible='off';
            else
                AdvancedTab.Visible='on';
            end
        end

    end



    switch flag
    case 'AccessToNeutrals'

        switch p1

        case 1

            LConnTags=get_param([block,'/Three-PhaseTransformer'],'LConnTags');
            switch length(LConnTags)
            case 3
                HaveYn=0;
                NewLConnTags={'A','B','C','N'};
            case 4
                HaveYn=1;
                NewLConnTags={'A','B','C'};
            end
            WantYn=strcmp(get_param(block,'Winding1Connection'),'Yn');
            if WantYn&&~HaveYn

                add_block('built-in/PMIOPort',[block,'/N']);
                set_param([block,'/N'],'port','4');
                set_param([block,'/N'],'Position',[25,143,55,157],'side','Left','orientation','right');
                set_param([block,'/Three-PhaseTransformer'],'LConnTags',NewLConnTags);
                TPTPortHandles=get_param([block,'/Three-PhaseTransformer'],'PortHandles');
                NPortHandle=get_param([block,'/N'],'PortHandles');
                add_line(block,TPTPortHandles.LConn(4),NPortHandle.RConn)

            elseif~WantYn&&HaveYn

                PortHandles=get_param([block,'/Three-PhaseTransformer'],'PortHandles');
                ligne=get_param(PortHandles.LConn(4),'line');
                delete_line(ligne);
                delete_block([block,'/N']);
                set_param([block,'/Three-PhaseTransformer'],'LConnTags',NewLConnTags);
            end

        case 2

            RConnTags=get_param([block,'/Three-PhaseTransformer'],'RConnTags');
            switch length(RConnTags)
            case 3
                HaveYn=0;
                NewRConnTags={'a','b','c','n'};
            case 4
                HaveYn=1;
                NewRConnTags={'a','b','c'};
            case 6
                HaveYn=0;
                NewRConnTags={'a2','b2','c2','n2','a3','b3','c3'};
            case 7
                RConnTags=get_param([block,'/Three-PhaseTransformer'],'RConnTags');
                if isequal('a3',RConnTags{4})
                    HaveYn=0;
                    NewRConnTags={'a2','b2','c2','n2','a3','b3','c3','n3'};
                else
                    HaveYn=1;
                    NewRConnTags={'a2','b2','c2','a3','b3','c3'};
                end
            case 8
                HaveYn=1;
                NewRConnTags={'a2','b2','c2','a3','b3','c3','n3'};
            end

            if strcmp(get_param(block,'Winding1Connection'),'Yn');
                n2Port='8';
            else
                n2Port='7';
            end

            WantYn=strcmp(get_param(block,'Winding2Connection'),'Yn');




            if AUTOTRANSFOMODE

                WantYn=0;
            end

            if WantYn&&~HaveYn

                if~AUTOTRANSFOMODE



                    add_block('built-in/PMIOPort',[block,'/n2']);
                    set_param([block,'/n2'],'port',n2Port);
                    set_param([block,'/n2'],'Position',[355,123,385,137],'side','right','orientation','left');
                    set_param([block,'/Three-PhaseTransformer'],'RConnTags',NewRConnTags);
                    TPTPortHandles=get_param([block,'/Three-PhaseTransformer'],'PortHandles');
                    nPortHandle=get_param([block,'/n2'],'PortHandles');
                    add_line(block,TPTPortHandles.RConn(4),nPortHandle.RConn)
                end
            elseif~WantYn&&HaveYn

                PortHandles=get_param([block,'/Three-PhaseTransformer'],'PortHandles');
                ligne=get_param(PortHandles.RConn(4),'line');
                delete_line(ligne);
                delete_block([block,'/n2']);
                set_param([block,'/Three-PhaseTransformer'],'RConnTags',NewRConnTags);
            end

        case 3


            RConnTags=get_param([block,'/Three-PhaseTransformer'],'RConnTags');
            switch length(RConnTags)
            case 6
                HaveYn=0;
                NewRConnTags={'a2','b2','c2','a3','b3','c3','n3'};
            case 7
                RConnTags=get_param([block,'/Three-PhaseTransformer'],'RConnTags');
                if isequal('a3',RConnTags{4})
                    HaveYn=1;
                    NewRConnTags={'a2','b2','c2','a3','b3','c3'};
                else
                    HaveYn=0;
                    NewRConnTags={'a2','b2','c2','n2','a3','b3','c3','n3'};
                end
            case 8
                HaveYn=1;
                NewRConnTags={'a2','b2','c2','n2','a3','b3','c3'};
            end

            WantYn=strcmp(get_param(block,'Winding3Connection'),'Yn');

            if WantYn&&~HaveYn

                add_block('built-in/PMIOPort',[block,'/n3']);
                set_param([block,'/n3'],'Position',[355,123,385,137],'side','right','orientation','left');
                set_param([block,'/Three-PhaseTransformer'],'RConnTags',NewRConnTags);
                TPTPortHandles=get_param([block,'/Three-PhaseTransformer'],'PortHandles');
                nPortHandle=get_param([block,'/n3'],'PortHandles');
                add_line(block,TPTPortHandles.RConn(end),nPortHandle.RConn)

            elseif~WantYn&&HaveYn

                PortHandles=get_param([block,'/Three-PhaseTransformer'],'PortHandles');
                ligne=get_param(PortHandles.RConn(end),'line');
                delete_line(ligne);
                delete_block([block,'/n3']);
                set_param([block,'/Three-PhaseTransformer'],'RConnTags',NewRConnTags);
            end

        end

    end



    switch flag
    case 'selected units'


        UNITS=get_param(block,'UNITS');
        WantSIunits=strcmp('SI',UNITS);
        WantPUunits=~WantSIunits;


        HaveSIunits=strcmp('on',get_param(block,'DataType'));
        HavePUunits=~HaveSIunits;


        if WantSIunits
            Prompts=SI_Prompts;
        end
        if WantPUunits
            Prompts=PU_Prompts;
        end

        set_param(block,'MaskPrompts',Prompts);


        if(WantSIunits&&HavePUunits)||(WantPUunits&&HaveSIunits)

            NominalParameters=getSPSmaskvalues(block,{'NominalPower'},0,1);
            Winding1=getSPSmaskvalues(block,{'Winding1'},0,1);
            Winding2=getSPSmaskvalues(block,{'Winding2'},0,1);
            Rm=getSPSmaskvalues(block,{'Rm'},0,1);
            Lm=getSPSmaskvalues(block,{'Lm'},0,1);
            L0=getSPSmaskvalues(block,{'L0'},0,1);
            Saturation=getSPSmaskvalues(block,{'Saturation'},0,1);
            InitialFluxes=getSPSmaskvalues(block,{'InitialFluxes'},0,1);

            Pnom=NominalParameters(1);
            freq=NominalParameters(2);
            Ps=Pnom/3;

            switch get_param(block,'Winding1Connection')
            case{'Y','Yn','Yg'}
                V1base=Winding1(1)/sqrt(3);
            case{'Delta (D1)','Delta (D11)'}
                V1base=Winding1(1);
            end
            switch get_param(block,'Winding2Connection')
            case{'Y','Yn','Yg'}
                V2base=Winding2(1)/sqrt(3);
            case{'Delta (D1)','Delta (D11)'}
                V2base=Winding2(1);
            end
            if ThreeWindings
                Winding3=getSPSmaskvalues(block,{'Winding3'},0,1);
                switch get_param(block,'Winding3Connection')
                case{'Y','Yn','Yg'}
                    V3base=Winding3(1)/sqrt(3);
                case{'Delta (D1)','Delta (D11)'}
                    V3base=Winding3(1);
                end
                R3base=V3base^2/Ps;
                L3base=V3base^2/Ps/(2*pi*freq);
            end
            R1base=V1base^2/Ps;
            R2base=V2base^2/Ps;
            L1base=V1base^2/Ps/(2*pi*freq);
            L2base=V2base^2/Ps/(2*pi*freq);
            Rmbase=R1base;
            Lmbase=L1base;%#ok
            BaseFlux=(V1base/(2*pi*freq))*sqrt(2);
            BaseCurrent=(Ps/V1base)*sqrt(2);
        end

        if(WantSIunits&&HavePUunits)

            Winding1=[Winding1(1),Winding1(2)*R1base,Winding1(3)*L1base];
            Winding2=[Winding2(1),Winding2(2)*R2base,Winding2(3)*L2base];
            Rm=Rm*Rmbase;
            Lm=Lm*Lmbase;
            L0=L0*Lmbase;
            Saturation=[Saturation(:,1)*BaseCurrent,Saturation(:,2)*BaseFlux];
            InitialFluxes=InitialFluxes*BaseFlux;
            set_param(block,'DataType','on');
            set_param(block,'Winding1',mat2str(Winding1,5));
            set_param(block,'Winding2',mat2str(Winding2,5));
            if ThreeWindings
                Winding3=[Winding3(1),Winding3(2)*R3base,Winding3(3)*L3base];
                set_param(block,'Winding3',mat2str(Winding3,5));
            end
            set_param(block,'Rm',mat2str(Rm,5));
            set_param(block,'Lm',mat2str(Lm,5));
            set_param(block,'L0',mat2str(L0,5));
            set_param(block,'Saturation',mat2str(Saturation,5));
            set_param(block,'InitialFluxes',mat2str(InitialFluxes,5));
        elseif(WantPUunits&&HaveSIunits)

            Winding1=[Winding1(1),Winding1(2)/R1base,Winding1(3)/L1base];
            Winding2=[Winding2(1),Winding2(2)/R2base,Winding2(3)/L2base];
            Rm=Rm/Rmbase;
            Lm=Lm/Lmbase;
            L0=L0/Lmbase;
            Saturation=[Saturation(:,1)/BaseCurrent,Saturation(:,2)/BaseFlux];
            InitialFluxes=InitialFluxes/BaseFlux;
            set_param(block,'DataType','off');
            set_param(block,'Winding1',mat2str(Winding1,5));
            set_param(block,'Winding2',mat2str(Winding2,5));
            if ThreeWindings
                Winding3=[Winding3(1),Winding3(2)/R3base,Winding3(3)/L3base];
                set_param(block,'Winding3',mat2str(Winding3,5));
            end
            set_param(block,'Rm',mat2str(Rm,5));
            set_param(block,'Lm',mat2str(Lm,5));
            set_param(block,'L0',mat2str(L0,5));
            set_param(block,'Saturation',mat2str(Saturation,5));
            set_param(block,'InitialFluxes',mat2str(InitialFluxes,5));
        end

    end
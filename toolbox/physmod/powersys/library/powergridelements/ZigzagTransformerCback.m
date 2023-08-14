function ZigzagTransformerCback(block,Option)







    switch Option
    case{'Saturation','BAL'}

        MaskEnables=get_param(block,'MaskEnables');
        MaskValues=get_param(block,'MaskValues');
        MaskVisibilities=get_param(block,'MaskVisibilities');


        SetSaturation=strcmp('on',MaskValues{2});
        SetInitialFlux=strcmp('on',MaskValues{3});

        if SetSaturation
            MaskEnables{3}='on';
            MaskEnables{12}='off';
            MaskEnables{13}='on';
            MaskEnables{14}='on';
            if SetInitialFlux
                MaskEnables{15}='on';
            else
                MaskEnables{15}='off';
            end
        else
            MaskEnables{3}='off';
            MaskEnables{12}='on';
            MaskEnables{13}='off';
            MaskEnables{14}='off';
            MaskEnables{15}='off';
        end

        set_param(block,'MaskEnables',MaskEnables)

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

        if strcmp(get_param(block,'BreakLoop'),'on')
            MaskVisibilities{17}='off';
        else
            MaskVisibilities{17}='on';
        end

        set_param(block,'MaskVisibilities',MaskVisibilities);

    end



    switch Option
    case 'AccessToNeutrals'


        ports=get_param(block,'ports');
        WantYn=strcmp(get_param(block,'SecondaryConnection'),'Yn');
        HaveYn=ports(7)==4;

        if WantYn&&~HaveYn


            add_block('built-in/PMIOPort',[block,'/n']);
            set_param([block,'/n'],'Position',[175,143,205,157],'side','right','orientation','left');
            set_param([block,'/Three-PhaseTransformer'],'RConnTags',{'a','b','c','n'});
            TPTPortHandles=get_param([block,'/Three-PhaseTransformer'],'PortHandles');
            nPortHandle=get_param([block,'/n'],'PortHandles');
            add_line(block,TPTPortHandles.RConn(4),nPortHandle.RConn)

        elseif~WantYn&&HaveYn


            RConnTags=get_param([block,'/Three-PhaseTransformer'],'RConnTags');
            PortHandles=get_param([block,'/Three-PhaseTransformer'],'PortHandles');
            ligne=get_param(PortHandles.RConn(4),'line');
            delete_line(ligne);
            delete_block([block,'/n']);
            set_param([block,'/Three-PhaseTransformer'],'RConnTags',RConnTags(1:end-1));

        end

    end



    switch Option
    case 'selected units'


        UNITS=get_param(block,'UNITS');
        WantSIunits=strcmp('SI',UNITS);
        WantPUunits=~WantSIunits;


        HaveSIunits=strcmp('on',get_param(block,'DataType'));
        HavePUunits=~HaveSIunits;

        MaskPrompts=get_param(block,'MaskPrompts');


        if WantSIunits

            MaskPrompts{9}='Winding 1 (zig-zag)  [R1(Ohm) L1(H)]';
            MaskPrompts{10}='Winding 2 (zig-zag)  [R2(Ohm) L2(H)]';
            MaskPrompts{11}='Winding 3 (secondary)  [R3(Ohm) L3(H)]';
            MaskPrompts{12}='Magnetizing branch  [Rm(Ohm) Lm(H)]';
            MaskPrompts{13}='Magnetization resistance  Rm (Ohm)';
            MaskPrompts{14}='Saturation characteristic  [i1(A), phi1(V.s); i2, phi2; ... ]';

        end
        if WantPUunits

            MaskPrompts{9}='Winding 1 zig-zag  [R1 L1] (pu)';
            MaskPrompts{10}='Winding 2 zig-zag  [R2 L2] (pu)';
            MaskPrompts{11}='Winding 3 secondary  [R3 L3] (pu)';
            MaskPrompts{12}='Magnetizing branch  [Rm Lm] (pu)';
            MaskPrompts{13}='Magnetization resistance  Rm (pu)';
            MaskPrompts{14}='Saturation characteristic  [i1, phi1; i2, phi2; ... ] (pu)';

        end
        set_param(block,'MaskPrompts',MaskPrompts);


        if(WantSIunits&&HavePUunits)||(WantPUunits&&HaveSIunits)

            NominalParameters=getSPSmaskvalues(block,{'NominalPower'},0,1);
            PrimaryVoltage=getSPSmaskvalues(block,{'PrimaryVoltage'},0,1);
            SecondaryData=getSPSmaskvalues(block,{'SecondaryVoltage'},0,1);
            Winding1=getSPSmaskvalues(block,{'Winding1'},0,1);
            Winding2=getSPSmaskvalues(block,{'Winding2'},0,1);
            Winding3=getSPSmaskvalues(block,{'Winding3'},0,1);
            RmLm=getSPSmaskvalues(block,{'RmLm'},0,1);
            Rm=getSPSmaskvalues(block,{'Rm'},0,1);
            Saturation=getSPSmaskvalues(block,{'Saturation'},0,1);
            InitialFluxes=getSPSmaskvalues(block,{'InitialFluxes'},0,1);
            SecondaryConnection=get_param(block,'SecondaryConnection');

            Pnom=NominalParameters(1);
            freq=NominalParameters(2);
            SecondaryVoltage=SecondaryData(1);
            switch SecondaryConnection
            case{'Y','Yn','Yg'}
                SecondaryVoltage=SecondaryVoltage/sqrt(3);
            case{'Delta D1(-30 deg.)','Delta D11(+30 deg.)'}
                SecondaryVoltage=SecondaryVoltage;%#ok mlint
            end
            PhiAngle=SecondaryData(2);
            alpha=abs(PhiAngle)*pi/180;
            k=sin(2*pi/3)/sin(2*pi/3-alpha);
            Ps=Pnom/3;

            V1base=PrimaryVoltage/sqrt(3)/k;
            V2base=PrimaryVoltage/sqrt(3)*sin(alpha)/sin(2*pi/3-alpha)/k;
            V3base=SecondaryVoltage;
            R1base=V1base^2/Ps;
            R2base=V2base^2/Ps;
            R3base=V3base^2/Ps;
            L1base=V1base^2/Ps/(2*pi*freq);
            L2base=V2base^2/Ps/(2*pi*freq);
            L3base=V3base^2/Ps/(2*pi*freq);
            Rmbase=R1base;
            Lmbase=L1base;
            BaseFlux=(V1base/(2*pi*freq))*sqrt(2);
            BaseCurrent=(Ps/V1base)*sqrt(2);
        end

        if(WantSIunits&&HavePUunits)

            Winding1=[Winding1(1)*R1base,Winding1(2)*L1base];
            Winding2=[Winding2(1)*R2base,Winding2(2)*L2base];
            Winding3=[Winding3(1)*R3base,Winding3(2)*L3base];
            Rm=Rm*Rmbase;
            RmLm=[RmLm(1)*Rmbase,RmLm(2)*Lmbase];
            Saturation=[Saturation(:,1)*BaseCurrent,Saturation(:,2)*BaseFlux];
            InitialFluxes=InitialFluxes*BaseFlux;
            set_param(block,'DataType','on');
            set_param(block,'Winding1',mat2str(Winding1,5));
            set_param(block,'Winding2',mat2str(Winding2,5));
            set_param(block,'Winding3',mat2str(Winding3,5));
            set_param(block,'Rm',mat2str(Rm,5));
            set_param(block,'RmLm',mat2str(RmLm,5));
            set_param(block,'Saturation',mat2str(Saturation,5));
            set_param(block,'InitialFluxes',mat2str(InitialFluxes,5));
        elseif(WantPUunits&&HaveSIunits)

            Winding1=[Winding1(1)/R1base,Winding1(2)/L1base];
            Winding2=[Winding2(1)/R2base,Winding2(2)/L2base];
            Winding3=[Winding3(1)/R3base,Winding3(2)/L3base];
            Rm=Rm/Rmbase;
            RmLm=[RmLm(1)/Rmbase,RmLm(2)/Lmbase];
            Saturation=[Saturation(:,1)/BaseCurrent,Saturation(:,2)/BaseFlux];
            InitialFluxes=InitialFluxes/BaseFlux;
            set_param(block,'DataType','off');
            set_param(block,'Winding1',mat2str(Winding1,5));
            set_param(block,'Winding2',mat2str(Winding2,5));
            set_param(block,'Winding3',mat2str(Winding3,5));
            set_param(block,'Rm',mat2str(Rm,5));
            set_param(block,'RmLm',mat2str(RmLm,5));
            set_param(block,'Saturation',mat2str(Saturation,5));
            set_param(block,'InitialFluxes',mat2str(InitialFluxes,5));
        end

    end
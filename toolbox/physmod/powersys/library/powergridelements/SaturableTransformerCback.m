function SaturableTransformerCback(block,option)













    if strcmp(bdroot(block),'powerlib')
        return
    end

    IsLibrary=strcmp(get_param(bdroot(block),'BlockDiagramType'),'library');

    SimulationStatus=get_param(bdroot(block),'SimulationStatus');
    if isequal('initializing',SimulationStatus)



        return
    end

    WantThreeWindings=strcmp('on',get_param(block,'ThreeWindings'));

    switch option

    case{'Parameters','BAL'}

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

        MaskEnables=get_param(block,'MaskEnables');
        MaskVisibilities=get_param(block,'MaskVisibilities');

        if WantThreeWindings
            MaskEnables{9}='on';
        else
            MaskEnables{9}='off';
        end

        if strcmp(get_param(block,'Hysteresis'),'on')
            MaskEnables{10}='off';
            MaskVisibilities{3}='on';
        else
            MaskEnables{10}='on';
            MaskVisibilities{3}='off';
        end

        if strcmp(get_param(block,'BreakLoop'),'on')
            MaskVisibilities{13}='off';
        else
            MaskVisibilities{13}='on';
        end

        set_param(block,'MaskEnables',MaskEnables);
        set_param(block,'MaskVisibilities',MaskVisibilities);

    case 'winding 3'

        ports=get_param(block,'ports');
        HaveThreeWindings=ports(7)==4;

        Winding3=get_param(block,'Winding3');

        MesureFlux=contains(get_param(block,'Measurements'),'Flux');


        Multimeter=~isempty(find_system(bdroot(block),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','Functional','FollowLinks','on','MaskType','Multimeter'));
        FluxRequested=Multimeter&MesureFlux;
        HaveGoto2Block=strcmp(get_param([block,'/Goto21'],'BlockType'),'Goto');


        if strcmp('0',Winding3)||strcmp('[0]',Winding3)
            set_param(block,'ThreeWindings','off');
            WantThreeWindings=0;
            Windings2=get_param(block,'Winding2');
            set_param(block,'Winding3',Windings2);
        end


        if WantThreeWindings&&~HaveThreeWindings
            add_block('built-in/PMIOPort',[block,'/3']);
            set_param([block,'/3'],'Position',[220,25,250,45],'side','Right','orientation','left');
            add_block('built-in/PMIOPort',[block,'/4']);
            set_param([block,'/4'],'Position',[220,60,250,80],'side','Right','orientation','left');
            XFOPortHandles=get_param([block,'/SaturableTransformer'],'PortHandles');
            TPortHandle=get_param([block,'/3'],'PortHandles');
            FPortHandle=get_param([block,'/4'],'PortHandles');
            add_line(block,XFOPortHandles.RConn(3),TPortHandle.RConn)
            add_line(block,XFOPortHandles.RConn(4),FPortHandle.RConn)
        elseif~WantThreeWindings&&HaveThreeWindings
            PortHandles=get_param([block,'/SaturableTransformer'],'PortHandles');
            ligne3=get_param(PortHandles.RConn(3),'line');
            ligne4=get_param(PortHandles.RConn(4),'line');
            delete_line(ligne3);
            delete_line(ligne4);
            delete_block([block,'/3']);
            delete_block([block,'/4']);
        end

        if FluxRequested&&~HaveGoto2Block
            replace_block(block,'Followlinks','on','Name','Goto21','BlockType','Terminator','Goto','noprompt');
            SetNewGotoTag([block,'/Goto21'],IsLibrary);
        end
        if~FluxRequested&&HaveGoto2Block
            replace_block(block,'Followlinks','on','Name','Goto21','BlockType','Goto','Terminator','noprompt');
        end

    case 'selected units'


        UNITS=get_param(block,'UNITS');
        WantSIunits=strcmp('SI',UNITS);
        WantPUunits=~WantSIunits;


        HaveSIunits=strcmp('on',get_param(block,'DataType'));
        HavePUunits=~HaveSIunits;


        MaskPrompts=get_param(block,'MaskPrompts');
        if WantSIunits

            MaskPrompts{7}='Winding 1 parameters [V1(Vrms) R1(ohm) L1(H)]';
            MaskPrompts{8}='Winding 2 parameters [V2(Vrms) R2(ohm) L2(H)]';
            MaskPrompts{9}='Winding 3 parameters [V3(Vrms) R3(ohm) L3(H)]';
            MaskPrompts{10}='Saturation characteristic [i1(A) phi1(V.s); i2 phi2; ...]';
            MaskPrompts{11}='Core loss resistance and initial flux [Rm(ohm) phi0(V.s)] or [Rm(ohm)]';

        end
        if WantPUunits

            MaskPrompts{7}='Winding 1 parameters [V1(Vrms) R1(pu) L1(pu)]';
            MaskPrompts{8}='Winding 2 parameters [V2(Vrms) R2(pu) L2(pu)]';
            MaskPrompts{9}='Winding 3 parameters [V3(Vrms) R3(pu) L3(pu)]';
            MaskPrompts{10}='Saturation characteristic [i1 phi1; i2 phi2; ...] (pu)';
            MaskPrompts{11}='Core loss resistance and initial flux [Rm phi0] or [Rm] (pu)';

        end
        set_param(block,'MaskPrompts',MaskPrompts);


        if(WantSIunits&&HavePUunits)||(WantPUunits&&HaveSIunits)
            NominalParameters=getSPSmaskvalues(block,{'NominalPower'},0,1);
            Winding1=getSPSmaskvalues(block,{'Winding1'},0,1);
            Winding2=getSPSmaskvalues(block,{'Winding2'},0,1);
            Winding3=getSPSmaskvalues(block,{'Winding3'},0,1);
            CoreLoss=getSPSmaskvalues(block,{'CoreLoss'},0,1);
            Saturation=getSPSmaskvalues(block,{'Saturation'},0,1);

            Pnom=NominalParameters(1);
            freq=NominalParameters(2);

            V1base=Winding1(1);
            V2base=Winding2(1);
            V3base=Winding3(1);
            R1base=V1base^2/Pnom;
            R2base=V2base^2/Pnom;
            R3base=V3base^2/Pnom;
            L1base=V1base^2/Pnom/(2*pi*freq);
            L2base=V2base^2/Pnom/(2*pi*freq);
            L3base=V3base^2/Pnom/(2*pi*freq);
            Rmbase=R1base;
            BaseFlux=(V1base/(2*pi*freq))*sqrt(2);
            BaseCurrent=(Pnom/V1base)*sqrt(2);
        end

        if(WantSIunits&&HavePUunits)

            Winding1=[Winding1(1),Winding1(2)*R1base,Winding1(3)*L1base];
            Winding2=[Winding2(1),Winding2(2)*R2base,Winding2(3)*L2base];
            Winding3=[Winding3(1),Winding3(2)*R3base,Winding3(3)*L3base];
            if length(CoreLoss)==1
                CoreLoss=CoreLoss(1)*Rmbase;
            else
                CoreLoss=[CoreLoss(1)*Rmbase,CoreLoss(2)*BaseFlux];
            end
            Saturation=[Saturation(:,1)*BaseCurrent,Saturation(:,2)*BaseFlux];
            set_param(block,'DataType','on');
            set_param(block,'Winding1',mat2str(Winding1,5));
            set_param(block,'Winding2',mat2str(Winding2,5));
            set_param(block,'Winding3',mat2str(Winding3,5));
            set_param(block,'CoreLoss',mat2str(CoreLoss,5));
            set_param(block,'Saturation',mat2str(Saturation,5));

        elseif(WantPUunits&&HaveSIunits)

            Winding1=[Winding1(1),Winding1(2)/R1base,Winding1(3)/L1base];
            Winding2=[Winding2(1),Winding2(2)/R2base,Winding2(3)/L2base];
            Winding3=[Winding3(1),Winding3(2)/R3base,Winding3(3)/L3base];
            if length(CoreLoss)==1
                CoreLoss=CoreLoss(1)/Rmbase;
            else
                CoreLoss=[CoreLoss(1)/Rmbase,CoreLoss(2)/BaseFlux];
            end
            Saturation=[Saturation(:,1)/BaseCurrent,Saturation(:,2)/BaseFlux];
            set_param(block,'DataType','off');
            set_param(block,'winding1',mat2str(Winding1,5));
            set_param(block,'winding2',mat2str(Winding2,5));
            set_param(block,'winding3',mat2str(Winding3,5));
            set_param(block,'CoreLoss',mat2str(CoreLoss,5));
            set_param(block,'Saturation',mat2str(Saturation,5));
        end

    end
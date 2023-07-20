function SinglePhaseAsynchronousMachineCback(block,Option,Update)






    if~exist('Update','var')
        Update='';
    end

    if strcmp(bdroot(block),'powerlib')
        return
    end
    MachineType=get_param(block,'MachineType');

    switch Option

    case 'Machine type'


        ports=get_param(block,'ports');
        HaveAuxiliaryPorts=ports(6)==4||ports(6)==5;

        switch MachineType
        case 'Split Phase'
            set_param(block,'MaskVisibilities',{'on','on','on','on','on','on','on','on','on','on',...
            'off','off','on','on','off','off','on'});
            if HaveAuxiliaryPorts
                DeleteAuxiliaryPorts(block);
            end

        case 'Capacitor-Start'
            set_param(block,'MaskVisibilities',{'on','on','on','on','on','on','on','on','on','on',...
            'on','off','on','on','off','off','on'});
            if HaveAuxiliaryPorts
                DeleteAuxiliaryPorts(block);
            end

        case 'Capacitor-Start-Run'
            set_param(block,'MaskVisibilities',{'on','on','on','on','on','on','on','on','on','on',...
            'on','on','on','on','off','off','on'});
            if HaveAuxiliaryPorts
                DeleteAuxiliaryPorts(block);
            end

        case 'Main & auxiliary windings'
            set_param(block,'MaskVisibilities',{'on','on','on','on','on','on','on','on','on','on',...
            'off','off','off','on','off','off','on'});
            if~HaveAuxiliaryPorts
                add_block('built-in/PMIOPort',[block,'/A+']);
                set_param([block,'/A+'],'Position',[220,25,250,45],'side','Left','orientation','left');
                add_block('built-in/PMIOPort',[block,'/A']);
                set_param([block,'/A'],'Position',[220,60,250,80],'side','Left','orientation','left');
                ASMPortHandles=get_param([block,'/AsynchronousMotor'],'PortHandles');
                ApPortHandle=get_param([block,'/A+'],'PortHandles');
                AmPortHandle=get_param([block,'/A'],'PortHandles');
                add_line(block,ASMPortHandles.RConn(1),ApPortHandle.RConn)
                add_line(block,ASMPortHandles.RConn(2),AmPortHandle.RConn)
            end

        end

    case 'Units'

        UNITS=get_param(block,'UNITS');
        WantSIunits=strcmp('SI',UNITS);
        WantPUunits=~WantSIunits;



        MaskVisibilities=get_param(block,'Maskvisibilities');
        set_param(block,'Maskvisibilities',{'on','on','on','on','on','on','on','on','on','on','on','on','on','on','on','off','on'});

        HaveSIunits=strcmp('SI',get_param(block,'DataType'));
        HavePUunits=strcmp('pu',get_param(block,'DataType'));
        HaveDefaultUnits=strcmp('default',get_param(block,'DataType'));


        if HaveDefaultUnits
            if WantSIunits
                HaveSIunits=1;
                WantPUunits=0;
                set_param(block,'DataType','SI');
            else
                HaveSIunits=0;
                WantPUunits=1;
                set_param(block,'DataType','pu');
            end
        end


        Prompts=get_param(block,'MaskPrompts');

        if WantSIunits

            Prompts{5+1}='Main winding stator [ Rs(ohm), Lls(H) ]';
            Prompts{6+1}='Main winding rotor [ Rr''(ohm), Llr''(H) ]';
            Prompts{7+1}='Main winding mutual inductance Lms(H)';
            Prompts{8+1}='Auxiliary  winding stator [ RS(ohm), LlS(H) ]';
            Prompts{9+1}='Inertia, friction factor, pole pairs, turn ratio(aux/main) [J(kg.m^2), F(N.m.s), p, NS/Ns]';
            Prompts{10+1}='Capacitor-Start [ Rst(ohm), Cs(farad) ]';
            Prompts{11+1}='Capacitor-Run [ Rru(ohm), Cru(farad) ]';

        end
        if WantPUunits

            Prompts{5+1}='Main winding stator [ Rs, Lls ] (pu)';
            Prompts{6+1}='Main winding rotor [ Rr'', Llr'' ](pu)';
            Prompts{7+1}='Main winding mutual inductance Lms (pu)';
            Prompts{8+1}='Auxiliary  winding stator [ RS, LlS ] (pu)';
            Prompts{9+1}='Inertia, friction factor, pole pairs, turn ratio(aux/main) [H(s), F(pu), p, NS/Ns]';
            Prompts{10+1}='Capacitor-Start [ Rst, Cs ] (pu)';
            Prompts{11+1}='Capacitor-Run [ Rru, Cru ] (pu)';

        end
        switch Update
        case 'UpdateBlock'
            set_param(block,'MaskPrompts',Prompts);


            if(WantSIunits&&HavePUunits)||(WantPUunits&&HaveSIunits)

                [MainWindingStator,MainWindingRotor,MutualInductance,AuxiliaryWinding,Mechanical,CapacitorStart,CapacitorRun]=SinglePhaseAsynchronousMachineConvert(block,UNITS);

                set_param(block,'MainWindingStator',mat2str(MainWindingStator,5));
                set_param(block,'MainWindingRotor',mat2str(MainWindingRotor,5));
                set_param(block,'MutualInductance',mat2str(MutualInductance,5));
                set_param(block,'AuxiliaryWinding',mat2str(AuxiliaryWinding,5));
                set_param(block,'Mechanical',mat2str(Mechanical,5));
                set_param(block,'CapacitorStart',mat2str(CapacitorStart,5));
                set_param(block,'CapacitorRun',mat2str(CapacitorRun,5));
                set_param(block,'DataType',UNITS);
            end
        end

        set_param(block,'Maskvisibilities',MaskVisibilities);

    end


    function DeleteAuxiliaryPorts(block)
        PortHandles=get_param([block,'/AsynchronousMotor'],'PortHandles');
        ligne1=get_param(PortHandles.RConn(1),'line');
        ligne2=get_param(PortHandles.RConn(2),'line');
        delete_line(ligne1);
        delete_line(ligne2);
        delete_block([block,'/A+']);
        delete_block([block,'/A']);




















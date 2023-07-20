function LinearTransformerCback(block,option)




    if strcmp(bdroot(block),'powerlib')
        return
    end

    WantThreeWindings=strcmp('on',get_param(block,'ThreeWindings'));

    switch option

    case 'winding 3'

        ports=get_param(block,'ports');
        HaveThreeWindings=ports(7)==4;

        MaskEnables=get_param(block,'MaskEnables');

        x=[0,0,0,1,5,11,17,24,29,32,33,31,28,28,24,23,25,28,34,41,47,52,56,56,54,51,51,47,46,48,52,57,64,70,76,79,80,78,74,74,71,70,71,75,81,87,94,99,100,100,100,100];
        y=[-40,0,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,-2,-12,-18,-18,-9,1,11,19,24,25,23,17,8,0,0,-40];
        barre1x=[-5,-5];
        barre1y=[70,-70];
        barre2x=[+5,+5];

        Winding3=get_param(block,'Winding3');

        if strcmp('0',Winding3)||strcmp('[0]',Winding3)
            set_param(block,'ThreeWindings','off');
            WantThreeWindings=0;
            Winding2=get_param(block,'Winding2');
            set_param(block,'Winding3',Winding2);
        end

        if WantThreeWindings
            MaskEnables{6}='on';
            PlotIcon=['plot(-85,-100,85,100,',mat2str(y-45),',',mat2str(x-50),',',mat2str(-y+45),',',mat2str((x*0.5)+25),',',mat2str((-y)+45),',',mat2str((-x*0.5)-25),',',mat2str(barre1x),',',mat2str(barre1y),',',mat2str(barre2x),',',mat2str(barre1y),')'];
            PlotIcon=[PlotIcon,';text(-85,0, ''1'');text(70,50, ''2'');text(70,-50, ''3'');color(''red'');port_label(''Lconn'',1,''+'');port_label(''Rconn'',1,''+'');port_label(''Rconn'',3,''+'');'];
        else
            MaskEnables{6}='off';
            PlotIcon=['plot(-85,-100,85,100,',mat2str(y-45),',',mat2str(x-50),',',mat2str(-y+45),',',mat2str(x-50),',',mat2str(barre1x),',',mat2str(barre1y),',',mat2str(barre2x),',',mat2str(barre1y),')'];
            PlotIcon=[PlotIcon,';text(-85,0, ''1'');text(70,0, ''2'');color(''red'');port_label(''Lconn'',1,''+'');port_label(''Rconn'',1,''+'');'];
        end


        if WantThreeWindings&&~HaveThreeWindings
            add_block('built-in/PMIOPort',[block,'/3']);
            set_param([block,'/3'],'Position',[220,25,250,45],'side','Right','orientation','left');
            add_block('built-in/PMIOPort',[block,'/4']);
            set_param([block,'/4'],'Position',[220,60,250,80],'side','Right','orientation','left');
            XFOPortHandles=get_param([block,'/LinearTransformer'],'PortHandles');
            TPortHandle=get_param([block,'/3'],'PortHandles');
            FPortHandle=get_param([block,'/4'],'PortHandles');
            add_line(block,XFOPortHandles.RConn(3),TPortHandle.RConn)
            add_line(block,XFOPortHandles.RConn(4),FPortHandle.RConn)
        elseif~WantThreeWindings&&HaveThreeWindings
            PortHandles=get_param([block,'/LinearTransformer'],'PortHandles');
            ligne3=get_param(PortHandles.RConn(3),'line');
            ligne4=get_param(PortHandles.RConn(4),'line');
            delete_line(ligne3);
            delete_line(ligne4);
            delete_block([block,'/3']);
            delete_block([block,'/4']);
        end

        set_param(block,'MaskEnables',MaskEnables);
        set_param(block,'MaskDisplay',PlotIcon);

    case 'selected units'


        UNITS=get_param(block,'UNITS');
        WantSIunits=strcmp('SI',UNITS);
        WantPUunits=~WantSIunits;


        HaveSIunits=strcmp('on',get_param(block,'DataType'));
        HavePUunits=~HaveSIunits;


        MaskPrompts=get_param(block,'MaskPrompts');

        if WantSIunits

            MaskPrompts{3}='Winding 1 parameters [V1(Vrms) R1(ohm) L1(H)]:';
            MaskPrompts{4}='Winding 2 parameters [V2(Vrms) R2(ohm) L2(H)]:';
            MaskPrompts{6}='Winding 3 parameters [V3(Vrms) R3(ohm) L3(H)]:';
            MaskPrompts{7}='Magnetization resistance and inductance [Rm(ohm) Lm(H)]:';

        else

            MaskPrompts{3}='Winding 1 parameters [V1(Vrms) R1(pu) L1(pu)]:';
            MaskPrompts{4}='Winding 2 parameters [V2(Vrms) R2(pu) L2(pu)]:';
            MaskPrompts{6}='Winding 3 parameters [V3(Vrms) R3(pu) L3(pu)]:';
            MaskPrompts{7}='Magnetization resistance and inductance [Rm(pu) Lm(pu)]:';

        end

        set_param(block,'MaskPrompts',MaskPrompts);


        if(WantSIunits&&HavePUunits)||(WantPUunits&&HaveSIunits)
            NominalParameters=getSPSmaskvalues(block,{'NominalPower'},0,1);
            Winding1=getSPSmaskvalues(block,{'winding1'},0,1);
            Winding2=getSPSmaskvalues(block,{'winding2'},0,1);
            Winding3=getSPSmaskvalues(block,{'winding3'},0,1);
            RmLm=getSPSmaskvalues(block,{'RmLm'},0,1);

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
            Lmbase=L1base;
        end


        if(WantSIunits&&HavePUunits)

            Winding1=[Winding1(1),Winding1(2)*R1base,Winding1(3)*L1base];
            Winding2=[Winding2(1),Winding2(2)*R2base,Winding2(3)*L2base];
            Winding3=[Winding3(1),Winding3(2)*R3base,Winding3(3)*L3base];
            RmLm=[RmLm(1)*Rmbase,RmLm(2)*Lmbase];
            set_param(block,'winding1',mat2str(Winding1,5));
            set_param(block,'winding2',mat2str(Winding2,5));
            set_param(block,'winding3',mat2str(Winding3,5));
            set_param(block,'RmLm',mat2str(RmLm,5));
            set_param(block,'DataType','on');
        elseif(WantPUunits&&HaveSIunits)

            Winding1=[Winding1(1),Winding1(2)/R1base,Winding1(3)/L1base];
            Winding2=[Winding2(1),Winding2(2)/R2base,Winding2(3)/L2base];
            Winding3=[Winding3(1),Winding3(2)/R3base,Winding3(3)/L3base];
            RmLm=[RmLm(1)/Rmbase,RmLm(2)/Lmbase];
            set_param(block,'winding1',mat2str(Winding1,5));
            set_param(block,'winding2',mat2str(Winding2,5));
            set_param(block,'winding3',mat2str(Winding3,5));
            set_param(block,'RmLm',mat2str(RmLm,5));
            set_param(block,'DataType','off');
        end

    end
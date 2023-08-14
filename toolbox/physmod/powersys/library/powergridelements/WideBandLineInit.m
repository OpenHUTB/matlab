function WB=WideBandLineInit(block,WBfile)







    WB.CmodYc=[];
    WB.CmodH=[];
    WB.tauj=[];
    WB.epsarr=[];
    WB.alfaYc=[];
    WB.alfaH=[];
    WB.GYc=[];
    WB.GH=[];
    WB.tau=[];
    WB.Ng=[];
    WB.Nc=[];
    WB.NH=[];
    WB.NYc=[];
    WB.Ts=[];
    power_initmask();
    IsLibrary=strcmp(get_param(bdroot(block),'BlockDiagramType'),'library');
    SetNewGotoTag([block,'/From'],IsLibrary);
    SetNewGotoTag([block,'/Goto'],IsLibrary);
    if isempty(WBfile)
        Erreur.message='Undefined MAT file';
        Erreur.identifier='SpecializedPowerSystems:FrequencyDependentLineBlock:UndefinedMATfile';
        error(Erreur.message,Erreur.identifier);
        return
    end
    DATA=power_cableparam(WBfile,'NoError');
    if isfield(DATA,'GMD_phi')
        Erreur.message='The specified MAT file does not contain valid cable or line parameters';
        Erreur.identifier='SpecializedPowerSystems:FrequencyDependentLineBlock:UndefinedMATfile';
        error(Erreur.message,Erreur.identifier);
        return
    end
    if isempty(DATA)
        DATA=power_lineparam(WBfile,'NoError');
    end
    if isempty(DATA)
        Erreur.message='The specified MAT file does not contain valid cable or line parameters';
        Erreur.identifier='SpecializedPowerSystems:FrequencyDependentLineBlock:UndefinedMATfile';
        error(Erreur.message,Erreur.identifier);
        return
    end
    N=size(DATA.R,1);
    Cback(block,N);
    Icon(block,N);
    set_param(block,'L',num2str(DATA.length));
    set_param(block,'NbPhases',num2str(N));
    set_param(block,'Frange',[num2str(10^DATA.frequencyRange(1),'%5.2e\n'),' Hz to ',num2str(10^DATA.frequencyRange(2),'%5.2e\n'),' Hz, ',num2str(DATA.frequencyRange(3)),' points.']);
    if ischar(DATA.comments)
        set_param(block,'Comments',DATA.comments);
    else
        set_param(block,'Comments',char(DATA.comments));
    end


    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    DATA.WB.Ts=PowerguiInfo.Ts;
    WB=powericon('TimeDomainWB',DATA.WB);

    function Cback(block,Phases)
        WantPhases=round(max(1,Phases));
        ports=get_param(block,'ports');
        HavePhases=ports(6);
        if WantPhases<HavePhases
            PortHandles=get_param([block,'/WideBandLine'],'PortHandles');
            RConnTags=get_param([block,'/WideBandLine'],'RConnTags');
            LConnTags=get_param([block,'/WideBandLine'],'LConnTags');
            for i=HavePhases:-1:WantPhases+1
                ligne_o=get_param(PortHandles.RConn(i),'line');
                ligne_i=get_param(PortHandles.LConn(i),'line');
                delete_line(ligne_o);
                delete_line(ligne_i);
                delete_block([block,'/i',num2str(i)]);
                delete_block([block,'/o',num2str(i)]);
            end
            set_param([block,'/WideBandLine'],'RConnTags',RConnTags(1:WantPhases));
            set_param([block,'/WideBandLine'],'LConnTags',LConnTags(1:WantPhases));
        end
        if WantPhases>HavePhases
            for i=HavePhases+1:WantPhases
                RConnTags=get_param([block,'/WideBandLine'],'RConnTags');
                LConnTags=get_param([block,'/WideBandLine'],'LConnTags');
                RConnTags{end+1}=['o',num2str(i)];%#ok
                LConnTags{end+1}=['i',num2str(i)];%#ok
                set_param([block,'/WideBandLine'],'RConnTags',RConnTags);
                set_param([block,'/WideBandLine'],'LConnTags',LConnTags);
                PortHandles=get_param([block,'/WideBandLine'],'PortHandles');
                P=38+35*(i-1);
                add_block('built-in/PMIOPort',[block,'/o',num2str(i)]);
                set_param([block,'/o',num2str(i)],'Position',[225,P,255,P+14],'side','Right','orientation','left');
                add_block('built-in/PMIOPort',[block,'/i',num2str(i)]);
                set_param([block,'/i',num2str(i)],'Position',[35,P,65,P+14],'side','Left','orientation','right');
                iPortHandle=get_param([block,'/i',num2str(i)],'PortHandles');
                oPortHandle=get_param([block,'/o',num2str(i)],'PortHandles');
                add_line(block,PortHandles.LConn(i),iPortHandle.RConn);
                add_line(block,PortHandles.RConn(i),oPortHandle.RConn);
            end
        end

        function Icon(block,Phases)
            nphase=round(max(1,Phases));
            if nphase==1
                set_param(block,'MaskIconFrame','off')
                PlotIcon='plot([0 20 20 80 80 100 80 80 20 20],[0 0 5 5 0 0 0 -5 -5 0]+20,0,0,100,40);color(''red'');port_label(''Lconn'',1,''+'')';
            end
            if nphase==2
                set_param(block,'MaskIconFrame','off')
                PlotIcon='plot([0 20 20 80 80 100 80 80 20 20],[0 0 5 5 0 0 0 -5 -5 0]+90,[0 20 20 80 80 100 80 80 20 20],[0 0 5 5 0 0 0 -5 -5 0]+30,0,0,100,120);color(''red'');port_label(''Lconn'',1,''+'')';
            end
            if nphase==3
                set_param(block,'MaskIconFrame','off')
                PlotIcon='plot([0 20 20 80 80 100 80 80 20 20],[0 0 5 5 0 0 0 -5 -5 0]+100,[0 20 20 80 80 100 80 80 20 20],[0 0 5 5 0 0 0 -5 -5 0]+60,[0 20 20 80 80 100 80 80 20 20],[0 0 5 5 0 0 0 -5 -5 0]+20,0,0,100,120);color(''red'');port_label(''Lconn'',1,''+'')';
            end
            if nphase>3
                set_param(block,'MaskIconFrame','on')
                PlotIcon='plot([0 20 20 80 80 100 80 80 20 20],([0 0 5 5 0 0 0 -5 -5 0]+50),-10,0,110,100);color(''red'');port_label(''Lconn'',1,''+'')';
            end
            set_param(block,'Maskdisplay',[PlotIcon,';color(''blue'');disp(''Frequency\n\nDependent'');']);
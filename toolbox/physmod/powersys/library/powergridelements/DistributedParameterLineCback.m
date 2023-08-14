function DistributedParameterLineCback(block)





    WantPhases=max(1,getSPSmaskvalues(block,{'Phases'}));
    ports=get_param(block,'ports');
    HavePhases=ports(6);

    MV=get_param(block,'MaskVisibilities');
    ME=get_param(block,'MaskEnables');

    ME{18}='off';
    MV{19}='off';
    MV{20}='off';
    MV{21}='off';
    MV{22}='off';
    MV{23}='off';
    MV{24}='off';
    MV{25}='off';
    MV{26}='off';

    if WantPhases==3||WantPhases==1
        switch get_param(block,'Decoupling')
        case 'on'
            ME{18}='on';
            MV{19}='on';
            MV{20}='on';
            MV{21}='on';
            MV{22}='on';
            MV{23}='on';
            MV{24}='on';
            MV{25}='on';
            MV{26}='on';
        end
    end

    set_param(block,'MaskEnables',ME);
    set_param(block,'MaskVisibilities',MV);

    if WantPhases<HavePhases
        PortHandles=get_param([block,'/DistributedParametersLine'],'PortHandles');
        RConnTags=get_param([block,'/DistributedParametersLine'],'RConnTags');
        LConnTags=get_param([block,'/DistributedParametersLine'],'LConnTags');
        for i=HavePhases:-1:WantPhases+1
            ligne_o=get_param(PortHandles.RConn(i),'line');
            ligne_i=get_param(PortHandles.LConn(i),'line');
            delete_line(ligne_o);
            delete_line(ligne_i);
            delete_block([block,'/i',num2str(i)]);
            delete_block([block,'/o',num2str(i)]);
        end
        set_param([block,'/DistributedParametersLine'],'RConnTags',RConnTags(1:WantPhases));
        set_param([block,'/DistributedParametersLine'],'LConnTags',LConnTags(1:WantPhases));
    end

    if WantPhases>HavePhases
        for i=HavePhases+1:WantPhases

            RConnTags=get_param([block,'/DistributedParametersLine'],'RConnTags');
            LConnTags=get_param([block,'/DistributedParametersLine'],'LConnTags');
            RConnTags{end+1}=['o',num2str(i)];%#ok
            LConnTags{end+1}=['i',num2str(i)];%#ok
            set_param([block,'/DistributedParametersLine'],'RConnTags',RConnTags);
            set_param([block,'/DistributedParametersLine'],'LConnTags',LConnTags);
            PortHandles=get_param([block,'/DistributedParametersLine'],'PortHandles');

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
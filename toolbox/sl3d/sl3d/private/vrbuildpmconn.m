function vrbuildpmconn(count,transformnames,bodies,subsys,xoffset,yoffset,nonUniqueSourceFields)
    for n=1:count

        bodyBlk=bodies{n};
        transform=transformnames{n};
        bodyPos=get_param(bodyBlk,'Position');
        off=[bodyPos(3)+40,bodyPos(4)+30];
        wf=get_param(bodyBlk,'WorkingFrames');
        rconn=get_param(bodyBlk,'RConnTagsString');
        lconn=get_param(bodyBlk,'LConnTagsString');
        portNumL=0;
        portNumR=0;

        findcs=findstr(wf,'$[0 0 0]$WORLD$WORLD$m$[0 0 0]$Euler X-Y-Z$rad$WORLD$true$none');
        no_open_port=false;

        if~isempty(findcs)

            for ii=1:length(findcs)
                cs=findcs(ii);

                n2=str2num(wf(cs-1));%#ok<ST2NM>
                n1=str2num(wf(cs-2));%#ok<ST2NM>
                if(~isempty(n1))

                    nc=['n1','n2'];
                else

                    nc=num2str(n2);
                end
                ph=get_param(bodyBlk,'PortHandles');
                if(~isempty(findstr(rconn,['CS',nc])))
                    portNumR=length(findstr(rconn(1:findstr(rconn,['CS',nc])-1),'|'))+1;
                    if(get(ph.RConn(portNumR),'Line')~=-1)
                        portNumR=0;
                    end
                elseif(~isempty(findstr(lconn,['CS',nc])))
                    portNumL=length(findstr(lconn(1:findstr(lconn,['CS',nc])-1),'|'))+1;
                    if(get(ph.LConn(portNumL),'Line')~=-1)
                        portNumL=0;
                    end
                end
                if(portNumR==0)&&(portNumL==0)
                    no_open_port=true;
                else

                    no_open_port=false;
                    break;
                end

            end

        else

            nested_addNewCSToBody()
        end
        physmod=get_param(bodyBlk,'Parent');
        body=get_param(bodyBlk,'Name');
        rotGotoTag=strrep([transform,'_rotation_vrphysmod'],'-','__');
        posGotoTag=strrep([transform,'_translation_vrphysmod'],'-','__');

        a_pm=add_block(['mblibv1/Sensors & ',newline,'Actuators/Body Sensor'],...
        [physmod,'/Sensor'],'MakeNameUnique','on',...
        'Position',[off(1),off(2),off(1)+50,off(2)+50],...
        'Muxed','off','Pose','on','ShowName','off','Tag','vrphysmod');
        b_pm=add_block(['simulink/Signal',newline,'Routing/Goto'],...
        [physmod,'/Goto'],'MakeNameUnique','on',...
        'Position',[off(1)+70,off(2)+27,off(1)+135,off(2)+49],...
        'ShowName','off','GotoTag',rotGotoTag,...
        'TagVisibility','global','Tag','vrphysmod');
        c_pm=add_block(['simulink/Signal',newline,'Routing/Goto'],...
        [physmod,'/Goto'],'MakeNameUnique','on',...
        'Position',[off(1)+70,off(2)+2,off(1)+135,off(2)+24],...
        'ShowName','off','GotoTag',posGotoTag,...
        'TagVisibility','global','Tag','vrphysmod');
        a_portConnect=get(a_pm,'PortConnectivity');
        autoConnect=0;
        for iPort=1:length(a_portConnect)
            if(a_portConnect(iPort).DstBlock>0)
                autoConnect=1;
                break;
            end
        end

        if(~autoConnect)
            if(no_open_port==true)
                nested_addNewCSToBody()
            end

            if(portNumR>=portNumL)
                lh1_pm=add_line(physmod,[body,'/RConn',num2str(portNumR)],...
                [get_param(a_pm,'name'),'/LConn1'],'autorouting','on');
            else
                lh1_pm=add_line(physmod,[body,'/LConn',num2str(portNumL)],...
                [get_param(a_pm,'name'),'/LConn1'],'autorouting','on');
            end

            lh2_pm=add_line(physmod,[get_param(a_pm,'name'),'/1'],[get_param(c_pm,'name'),'/1']);
            lh3_pm=add_line(physmod,[get_param(a_pm,'name'),'/2'],[get_param(b_pm,'name'),'/1']);
            set(lh1_pm,'Tag','vrphysmod');
            set(lh2_pm,'Tag','vrphysmod');
            set(lh3_pm,'Tag','vrphysmod');
        end

        a_vr=add_block(['vrlib/Utilities/Rotation Matrix',newline,'to VR Rotation'],...
        [subsys,'/Rotation Matrix'],'MakeNameUnique','on','position',[xoffset+240,yoffset+50*(n-1)+2,xoffset+240+90,yoffset+50*(n-1)+28],...
        'ShowName','off','Tag','vrphysmod_vss');
        b_vr=add_block(['simulink/Signal',newline,'Routing/From'],...
        [subsys,'/From'],'MakeNameUnique','on','position',[xoffset,yoffset+50*(n-1)+5,xoffset+110,yoffset+50*(n-1)+25],...
        'ShowName','off','GotoTag',rotGotoTag,'Tag','vrphysmod_vss');
        c_vr=add_block(['simulink/Signal',newline,'Routing/From'],...
        [subsys,'/From'],'MakeNameUnique','on','position',[xoffset+105,yoffset+50*(n-1)+30,xoffset+105+110,yoffset+50*(n-1)+50],...
        'ShowName','off','GotoTag',posGotoTag,'Tag','vrphysmod_vss');

        lh1_vr=add_line(subsys,[get_param(b_vr,'name'),'/1'],[get_param(a_vr,'name'),'/1']);
        lh2_vr=add_line(subsys,[get_param(a_vr,'name'),'/1'],['VR Sink/',num2str(2*n-1)]);
        lh3_vr=add_line(subsys,[get_param(c_vr,'name'),'/1'],['VR Sink/',num2str(2*n)]);
        set(lh1_vr,'Tag','vrphysmod_vss');
        set(lh2_vr,'Tag','vrphysmod_vss');
        set(lh3_vr,'Tag','vrphysmod_vss');
        if(~isempty(strfind(nonUniqueSourceFields,[transform,'.rotation'])))
            delete_line(lh1_vr);
            delete_line(lh2_vr);
            delete_block(a_vr);
            delete_block(b_vr);
        end
        if(~isempty(strfind(nonUniqueSourceFields,[transform,'.translation'])))
            delete_line(lh3_vr);
            delete_block(c_vr);
        end

    end


    function nested_addNewCSToBody()
        csNums=regexp(wf,'CS(\d+)','tokens');
        lastCS=max(cellfun(@str2num,[csNums{:}]));
        nc=num2str(lastCS+1);

        if isempty(rconn)
            rconn=['CS',nc];
            portNumR=1;
        else
            rconn=[rconn,'|CS',nc];
            portNumR=length(findstr(rconn,'|'))+1;
        end
        set_param(bodyBlk,'RConnTagsString',rconn);

        wf=[wf,'#Right$CS',nc,'$[0 0 0]$WORLD$WORLD$m$[0 0 0]$Euler X-Y-Z$rad$WORLD$true$none'];
        set_param(bodyBlk,'WorkingFrames',wf);

        set_param(bodyBlk,['CS',nc,'Pos'],'[0 0 0]');
        set_param(bodyBlk,['CS',nc,'Rot'],'[0 0 0]');
        set_param(bodyBlk,'Tag',num2str(portNumR));
    end

end

function simrfV2_lcladder_setup(mdl,topology,L,C)





    libMod='simrfV2elements';
    load_system(libMod)
    libNode='simrfV2_lib';
    load_system(libNode)


    OldLines=find_system(mdl,'LookUnderMasks','all',...
    'FollowLinks','on','SearchDepth',1,'FindAll','on',...
    'Type','Line');
    delete_line(OldLines)
    OldElems=find_system(mdl,'LookUnderMasks','all',...
    'FollowLinks','on','SearchDepth',1,'FindAll','on',...
    'RegExp','on',...
    'Classname',...
    ['inductor\w*|capacitor\w*|resistor\w*|short_rf\w*|'...
    ,'s2port_rf\w*|f2port_rf\w*']);
    delete(OldElems)



    xLenElem=40;
    yLenElem=40;
    termSep=60;
    termLen=20;


    h=get_param([mdl,'/1+'],'Handle');
    pos=get_param([mdl,'/1+'],'Position');
    xpos=pos(3)+termSep;
    ypos=floor((pos(4)+pos(2))/2);
    ph=get_param(h,'PortHandles');
    lastconn=ph.RConn;

    Cnum=length(C);
    Lnum=length(L);


    fs=struct('mdl',mdl,'L',L,'C',C,'teeElem',0,...
    'xpos',xpos,'ypos',ypos,'lastconn',lastconn,...
    'xLenElem',xLenElem,'yLenElem',yLenElem,'termSep',termSep,...
    'termLen',termLen,'libMod',libMod,'libNode',libNode,...
    'xposStart',pos(1));


    switch lower(regexprep(topology,' +',''))
    case 'lclowpasstee'
        fs.armLen=termSep+xLenElem;
        xposEnd=fs.xpos+fs.armLen*Lnum;
        fs=place_end_term(fs,xposEnd);
        xposMid=fs.xpos-fs.termSep/2+(Cnum+1)*fs.armLen/2;
        fs=place_bot_term(fs,xposMid);
        fs.shunt='C';
        fs.series='L';
        fs=seriesElem(fs,1);
        fs.teeElem=1;
        fs=pi_section(fs);
        add_line(mdl,fs.lastconn,fs.phEnd.RConn,'autorouting','on');
    case 'lclowpasspi'
        fs.armLen=termSep+xLenElem;
        xposEnd=fs.xpos+fs.armLen*Lnum;
        fs=place_end_term(fs,xposEnd);
        xposMid=fs.xpos-fs.termSep/2+(Cnum-1)*fs.armLen/2;
        fs=place_bot_term(fs,xposMid);
        fs.shunt='C';
        fs.series='L';
        fs=pi_section(fs);
        add_line(mdl,fs.lastconn,fs.phEnd.RConn,'autorouting','on');
    case 'lchighpasstee'
        fs.armLen=termSep+xLenElem;
        xposEnd=fs.xpos+fs.armLen*Cnum;
        fs=place_end_term(fs,xposEnd);
        xposMid=fs.xpos-fs.termSep/2+(Lnum+1)*fs.armLen/2;
        fs=place_bot_term(fs,xposMid);
        fs.shunt='L';
        fs.series='C';
        fs=seriesElem(fs,1);
        fs.teeElem=1;
        fs=pi_section(fs);
        add_line(mdl,fs.lastconn,fs.phEnd.RConn,'autorouting','on');
    case 'lchighpasspi'
        fs.armLen=termSep+xLenElem;
        xposEnd=fs.xpos+fs.armLen*Cnum;
        fs=place_end_term(fs,xposEnd);
        xposMid=fs.xpos-fs.termSep/2+(Lnum-1)*fs.armLen/2;
        fs=place_bot_term(fs,xposMid);
        fs.shunt='L';
        fs.series='C';
        fs=pi_section(fs);
        add_line(mdl,fs.lastconn,fs.phEnd.RConn,'autorouting','on');
    case 'lcbandpasstee'
        fs.armLen=termSep+2*xLenElem;
        xposEnd=xpos+fs.armLen*ceil(Cnum/2)+...
        2*yLenElem*floor(Cnum/2)+fs.termSep;
        fs=place_end_term(fs,xposEnd);
        xposMid=xpos+fs.armLen/2+...
        floor(Cnum/2)*(fs.armLen+2*yLenElem)/2;
        fs=place_bot_term(fs,xposMid);
        fs=seriesPass(fs,1);
        fs=pi_pass_section(fs,2);
        add_line(mdl,fs.lastconn,fs.phEnd.RConn,'autorouting','on');
    case 'lcbandpasspi'
        fs.armLen=termSep+2*xLenElem;
        xposEnd=xpos+fs.armLen*floor(Cnum/2)+...
        2*yLenElem*ceil(Cnum/2)+fs.termSep;
        fs=place_end_term(fs,xposEnd);
        xposMid=xpos+yLenElem+...
        floor((Cnum-1)/2)*(fs.armLen+2*yLenElem)/2;
        fs=place_bot_term(fs,xposMid);
        fs=pi_pass_section(fs,1);
        add_line(mdl,fs.lastconn,fs.phEnd.RConn,'autorouting','on');
        add_line(mdl,fs.lastLine);
    case 'lcbandstoptee'
        fs.lastpoint=get_param(fs.lastconn,'Position');
        fs.xpos=fs.xpos-termSep+xLenElem;
        fs.armLen=5*xLenElem;
        xposEnd=fs.xpos+3*xLenElem*ceil(Cnum/2)+xLenElem;
        fs=place_end_term(fs,xposEnd);
        xposMid=fs.xpos+ceil((Cnum+1)/2)*3*xLenElem/2;
        fs=place_bot_term(fs,xposMid);
        fs=seriesStop(fs,1);
        fs=pi_stop_section(fs,2);
        ph_Cap=get_param(...
        [mdl,'/C',num2str(Cnum-1+mod(Cnum,2))],'PortHandles');
        lh=add_line(mdl,fs.phEnd.RConn,ph_Cap.RConn,...
        'autorouting','on');
        newPts=get(lh,'Points')-[0,0;15,0;15,0;0,0];
        set(lh,'Points',newPts);
    case 'lcbandstoppi'
        fs.lastpoint=get_param(fs.lastconn,'Position');
        fs.xpos=fs.xpos-termSep+xLenElem;
        fs.armLen=5*xLenElem;
        xposEnd=fs.xpos+3*xLenElem*floor(Cnum/2)+xLenElem;
        fs=place_end_term(fs,xposEnd);
        xposMid=fs.xpos+floor((Cnum-1)/2)*3*xLenElem/2;
        fs=place_bot_term(fs,xposMid);
        fs=pi_stop_section(fs,1);
        ph_Cap=get_param([mdl,'/C',num2str(Cnum-mod(Cnum,2))],...
        'PortHandles');
        lh=add_line(mdl,fs.phEnd.RConn,ph_Cap.RConn,...
        'autorouting','on');
        newPts=get(lh,'Points')-[0,0;15,0;15,0;0,0];
        set(lh,'Points',newPts);
    end

    function fs=place_end_term(fs,xpos)

        h=get_param([fs.mdl,'/2+'],'Handle');
        fs.xposEnd=xpos+fs.termLen;
        set_param([fs.mdl,'/2+'],'Position',[xpos,fs.ypos-fs.termLen/2...
        ,fs.xposEnd,fs.ypos+fs.termLen/2],'NamePlacement','alternate');
        fs.phEnd=get_param(h,'PortHandles');

        function fs=place_bot_term(fs,xposMid)

            xleft=xposMid-fs.termLen/4;
            nodeLen=5;
            xright=xleft+nodeLen;
            ytop=fs.ypos+fs.armLen+fs.termSep;
            add_block([fs.libNode,'/Elements/SHORT_RF'],[fs.mdl,'/Node'],...
            'Position',[xleft,ytop,xright,ytop+nodeLen],'Orientation','down')

            fs.botTerm=get_param([fs.mdl,'/Node'],'PortHandles');
            fs.botPos=get_param(fs.botTerm.LConn,'Position');

            negGnd=find_system(fs.mdl,'LookUnderMasks','all',...
            'FollowLinks','on','SearchDepth',1,'FindAll','on',...
            'Name','Gnd1');
            if isempty(negGnd)
                leftTerm=[fs.mdl,'/1-'];
                rightTerm=[fs.mdl,'/2-'];
                ph=get_param(leftTerm,'PortHandles');
                phLeft=ph.RConn;
                ph=get_param(rightTerm,'PortHandles');
                phRight=ph.RConn;
            else
                leftTerm=negGnd;
                rightTerm=[fs.mdl,'/Gnd2'];
                ph=get_param(leftTerm,'PortHandles');
                phLeft=ph.LConn;
                ph=get_param(rightTerm,'PortHandles');
                phRight=ph.LConn;
            end
            yposBot=ytop+2*fs.xLenElem;
            set_param(leftTerm,'Position',[fs.xposStart,yposBot-fs.termLen...
            ,fs.xposStart+fs.termLen,yposBot]);
            set_param(rightTerm,'Position',[fs.xposEnd-fs.termLen...
            ,yposBot-fs.termLen,fs.xposEnd,yposBot]);
            add_line(fs.mdl,fs.botTerm.RConn,phLeft,'autorouting','on');
            add_line(fs.mdl,fs.botTerm.RConn,phRight,'autorouting','on');


            function fs=pi_section(fs)
                for idx=1:numel(fs.(fs.shunt))
                    shuntElem(fs,idx);
                    if(idx+fs.teeElem)<=numel(fs.(fs.series))
                        fs=seriesElem(fs,idx+fs.teeElem);
                    end
                end

                function fs=seriesElem(fs,idx)
                    xpos=fs.xpos;
                    type=fs.series;
                    if strcmp(type,'C')
                        param='Capacitance';
                    else
                        param='Inductance';
                    end
                    h=add_block([fs.libMod,'/',type],[fs.mdl,'/',type,num2str(idx)],...
                    param,num2str(fs.(type)(idx),16),...
                    'Position',[xpos,fs.ypos-fs.yLenElem/2...
                    ,xpos+fs.xLenElem,fs.ypos+fs.yLenElem/2],...
                    'Orientation','right','NamePlacement','alternate');
                    ph=get_param(h,'PortHandles');
                    add_line(fs.mdl,fs.lastconn,ph.LConn);
                    fs.xpos=xpos+fs.xLenElem+fs.termSep;
                    fs.lastconn=ph.RConn;

                    function shuntElem(fs,idx)
                        ytop=fs.ypos+fs.termSep;
                        ybot=ytop+fs.xLenElem;
                        xleft=fs.xpos-(fs.yLenElem+fs.termSep)/2;
                        type=fs.shunt;
                        if strcmp(type,'C')
                            param='Capacitance';
                        else
                            param='Inductance';
                        end
                        h=add_block([fs.libMod,'/',type],[fs.mdl,'/',type,num2str(idx)],...
                        param,num2str(fs.(type)(idx),16),...
                        'Position',[xleft,ytop,xleft+fs.yLenElem,ybot],...
                        'Orientation','down','NamePlacement','alternate');
                        ph=get_param(h,'PortHandles');
                        add_line(fs.mdl,fs.lastconn,ph.LConn,'autorouting','on');
                        add_line(fs.mdl,ph.RConn,fs.botTerm.LConn,'autorouting','on');


                        function fs=pi_pass_section(fs,idxStart)

                            for idx=idxStart:2:numel(fs.L)
                                fs=shuntPass(fs,idx);
                                if idx<numel(fs.L)
                                    fs=seriesPass(fs,idx+1);
                                end
                            end

                            function fs=seriesPass(fs,idx)
                                xpos=fs.xpos;
                                h=add_block([fs.libMod,'/L'],[fs.mdl,'/L',num2str(idx)],...
                                'Inductance',num2str(fs.L(idx),16),'Position',...
                                [xpos,fs.ypos-fs.yLenElem/2,xpos+fs.xLenElem,fs.ypos+fs.yLenElem/2],...
                                'Orientation','right','NamePlacement','alternate');
                                ph_Ind=get_param(h,'PortHandles');

                                xpos=xpos+fs.xLenElem+fs.termSep;
                                h=add_block([fs.libMod,'/C'],[fs.mdl,'/C',num2str(idx)],...
                                'Capacitance',num2str(fs.C(idx),16),'Position',...
                                [xpos,fs.ypos-fs.yLenElem/2,xpos+fs.xLenElem,fs.ypos+fs.yLenElem/2],...
                                'Orientation','right','NamePlacement','alternate');
                                ph_Cap=get_param(h,'PortHandles');

                                add_line(fs.mdl,fs.lastconn,ph_Ind.LConn);
                                add_line(fs.mdl,ph_Ind.RConn,ph_Cap.LConn);
                                fs.xpos=xpos+fs.xLenElem;
                                fs.lastconn=ph_Cap.RConn;

                                function fs=shuntPass(fs,idx)
                                    ytop=fs.ypos+fs.termSep;
                                    ybot=ytop+fs.xLenElem;
                                    h=add_block([fs.libMod,'/L'],[fs.mdl,'/L',num2str(idx)],...
                                    'Inductance',num2str(fs.L(idx),16),'Position',...
                                    [fs.xpos,ytop,fs.xpos+fs.yLenElem,ybot],...
                                    'Orientation','down','NamePlacement','alternate');
                                    ph_Ind=get_param(h,'PortHandles');

                                    xpos=fs.xpos+fs.yLenElem;
                                    h=add_block([fs.libMod,'/C'],[fs.mdl,'/C',num2str(idx)],...
                                    'Capacitance',num2str(fs.C(idx),16),'Position',...
                                    [xpos,ytop,xpos+fs.yLenElem,ybot],...
                                    'Orientation','down');
                                    ph_Cap=get_param(h,'PortHandles');

                                    ht=add_line(fs.mdl,ph_Ind.LConn,ph_Cap.LConn,'autorouting','on');
                                    htPts=get_param(ht,'Points');
                                    ppos=get(fs.lastconn,'Position');
                                    if idx==1
                                        fs.lastLine=[xpos,ppos(2);xpos,htPts(2,2)];
                                    else
                                        add_line(fs.mdl,[ppos;xpos,ppos(2);xpos,htPts(2,2)]);
                                    end
                                    hb=add_line(fs.mdl,ph_Ind.RConn,ph_Cap.RConn,'autorouting','on');
                                    hbPts=get_param(hb,'Points');
                                    if idx>2
                                        add_line(fs.mdl,...
                                        [xpos,hbPts(2,2);xpos,fs.ymid;fs.botPos(1),fs.ymid]);
                                    else
                                        fs.ymid=floor((fs.botPos(2)+hbPts(2,2))/2);
                                        add_line(fs.mdl,...
                                        [xpos,hbPts(2,2);xpos,fs.ymid;fs.botPos(1),fs.ymid;fs.botPos]);
                                    end
                                    fs.xpos=xpos+fs.yLenElem;



                                    function fs=pi_stop_section(fs,idxStart)
                                        for idx=idxStart:2:numel(fs.L)
                                            fs=shuntStop(fs,idx);
                                            if idx<numel(fs.L)
                                                fs=seriesStop(fs,idx+1);
                                            end
                                        end

                                        function fs=seriesStop(fs,idx)
                                            xpos=fs.xpos+fs.xLenElem;
                                            h=add_block([fs.libMod,'/L'],[fs.mdl,'/L',num2str(idx)],...
                                            'Inductance',num2str(fs.L(idx),16),'Position',...
                                            [xpos,fs.ypos-fs.yLenElem,xpos+fs.xLenElem,fs.ypos],...
                                            'Orientation','right','NamePlacement','alternate');
                                            ph_Ind=get_param(h,'PortHandles');

                                            h=add_block([fs.libMod,'/C'],[fs.mdl,'/C',num2str(idx)],...
                                            'Capacitance',num2str(fs.C(idx),16),'Position',...
                                            [xpos,fs.ypos,xpos+fs.xLenElem,fs.ypos+fs.yLenElem],...
                                            'Orientation','right');
                                            ph_Cap=get_param(h,'PortHandles');

                                            h1=add_line(fs.mdl,ph_Ind.LConn,ph_Cap.LConn,'autorouting','on');
                                            h1Pts=get_param(h1,'Points');
                                            if idx==1
                                                ha=add_line(fs.mdl,fs.lastconn,ph_Cap.LConn,'autorouting','on');
                                                ha_pts=get(ha,'Points');
                                                ha_pts(2,1)=h1Pts(2,1);
                                                ha_pts(3,1)=h1Pts(2,1);
                                                set(ha,'Points',ha_pts);
                                            else
                                                add_line(fs.mdl,[fs.lastpoint;h1Pts(2,1),fs.ypos]);
                                            end
                                            h2=add_line(fs.mdl,ph_Ind.RConn,ph_Cap.RConn,'autorouting','on');
                                            h2Pts=get_param(h2,'Points');
                                            fs.lastpoint=[h2Pts(2,1),fs.ypos];
                                            fs.xpos=xpos+2*fs.xLenElem;

                                            function fs=shuntStop(fs,idx)
                                                ypos=fs.ypos+fs.termSep;
                                                xpos=fs.xpos-fs.xLenElem/2;
                                                h=add_block([fs.libMod,'/L'],[fs.mdl,'/L',num2str(idx)],...
                                                'Inductance',num2str(fs.L(idx),16),...
                                                'Position',[xpos,ypos,xpos+fs.yLenElem,ypos+fs.xLenElem],...
                                                'Orientation','down','NamePlacement','alternate');
                                                ph_Ind=get_param(h,'PortHandles');

                                                ypos=ypos+2*fs.xLenElem;
                                                h=add_block([fs.libMod,'/C'],[fs.mdl,'/C',num2str(idx)],...
                                                'Capacitance',num2str(fs.C(idx),16),...
                                                'Position',[xpos,ypos,xpos+fs.yLenElem,ypos+fs.xLenElem],...
                                                'Orientation','down','NamePlacement','alternate');
                                                ph_Cap=get_param(h,'PortHandles');

                                                add_line(fs.mdl,ph_Cap.LConn,ph_Ind.RConn,'autorouting','on');
                                                add_line(fs.mdl,ph_Cap.RConn,fs.botTerm.LConn,'autorouting','on');
                                                add_line(fs.mdl,[fs.lastpoint;fs.xpos,fs.ypos;...
                                                get_param(ph_Ind.LConn,'Position')]);
                                                fs.lastpoint=[fs.xpos,fs.ypos];
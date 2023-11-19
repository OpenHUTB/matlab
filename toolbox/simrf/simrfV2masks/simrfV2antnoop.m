function simrfV2antnoop(block,action,blkType)

    top_sys=bdroot(block);
    isRunningorPaused=any(strcmpi(get_param(top_sys,'SimulationStatus'),...
    {'running','paused'}));

    if strcmpi(top_sys,'simrfV2private')
        return
    end

    switch(action)
    case 'simrfInit'

        if isRunningorPaused
            return
        end
        MaskWSValues=simrfV2getblockmaskwsvalues(block);

        ports=MaskWSValues.PortNum;
        hPorts=find_system(block,'LookUnderMasks','all',...
        'FollowLinks','on','SearchDepth',1,'FindAll','on',...
        'RegExp','on','Name',...
        'RF[1-9]\d*\+');
        portNum=length(hPorts)+1;
        if ports~=portNum
            OldElems=find_system(block,'LookUnderMasks','all',...
            'FollowLinks','on','SearchDepth',1,'FindAll','on',...
            'RegExp','on','Name','RF[1-9]\d*[\+-]');
            if~isempty(OldElems)
                OldElems2Rm=OldElems(str2double(regexp(get(OldElems,...
                'name'),'[0-9]+','match','once'))>ports);
                delete(OldElems2Rm)
                unconnLines=find_system(block,'LookUnderMasks',...
                'all','FollowLinks','on','SearchDepth',1,...
                'FindAll','on','Type','Line','Connected','off');
                delete_line(unconnLines)
            end
            posConnPortp=get_param([block,'/RF+'],'Position');
            posConnPortn=get_param([block,'/RF-'],'Position');
            connPortDist=posConnPortn(2)-posConnPortp(2);
            if strcmp(blkType,'rec')
                Blkside='Right';
            else
                Blkside='Left';
            end
            load_system('simrfV2util1');
            for portInd=2:ports
                connPortp=[block,'/RF',num2str(portInd),'+'];
                if portInd>portNum
                    add_block('simrfV2util1/Connection Port',...
                    connPortp,'Orientation','Left','Side',...
                    Blkside,'Position',...
                    posConnPortp+(portInd-1)*connPortDist*[1,0,1,0]);
                    connPortn=[block,'/RF',num2str(portInd),'-'];
                    add_block('simrfV2util1/Connection Port',...
                    connPortn,'Orientation','Left','Side',...
                    Blkside,'Position',...
                    posConnPortn+(portInd-1)*connPortDist*[1,0,1,0]);
                    phConnPortp=get_param(connPortp,'PortHandles');
                    phConnPortn=get_param(connPortn,'PortHandles');
                    add_line(block,phConnPortn.RConn,...
                    phConnPortp.RConn,'autorouting','on');
                else
                    set_param(connPortp,'Orientation','Left',...
                    'Side',Blkside,...
                    'Position',...
                    posConnPortp+(portInd-1)*connPortDist*[1,0,1,0]);
                    connPortn=[block,'/RF',num2str(portInd),'-'];
                    set_param(connPortn,'Orientation','Left',...
                    'Side',Blkside,...
                    'Position',...
                    posConnPortn+(portInd-1)*connPortDist*[1,0,1,0]);
                end
            end
        end
        return
    end

end
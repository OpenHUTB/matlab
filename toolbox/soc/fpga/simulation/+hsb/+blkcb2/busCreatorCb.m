function varargout=busCreatorCb(varargin)
    if nargout==0
        feval(varargin{:});
    else
        [varargout{1:nargout}]=feval(varargin{:});
    end
end

function MaskInitFcn(blkH,~)%#ok<DEFNU>
    blkPath=hsb.blkcb2.cbutils('GetBlkPath',blkH);
    Protocol=get_param(blkPath,'Protocol');
    ctrltype=get_param(blkPath,'ctrltype');
    inPorts=find_system(blkPath,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport');
    portnames=get_param(inPorts,'Name')';

    if strcmp(Protocol,'Data stream')
        if strcmp(ctrltype,'Valid')
            BusObjName='StreamM2SBusObj';
            portnamesNew={'valid','tlast'};
            modifyblock(portnamesNew,portnames,blkPath,BusObjName);
        else
            BusObjName='StreamS2MBusObj';
            portnamesNew={'ready'};
            modifyblock(portnamesNew,portnames,blkPath,BusObjName);
        end
    elseif strcmp(Protocol,'Pixel stream')
        if strcmp(ctrltype,'Valid')
            BusObjName='pixelcontrol';
            portnamesNew={'hStart','hEnd','vStart','vEnd','valid'};
            modifyblock(portnamesNew,portnames,blkPath,BusObjName);
        elseif strcmp(ctrltype,'Ready')
            BusObjName='StreamVideoS2MBusObj';
            portnamesNew={'ready'};
            modifyblock(portnamesNew,portnames,blkPath,BusObjName);
        else
            BusObjName='StreamVideoFsyncS2MBusObj';
            portnamesNew={'ready','fsync'};
            modifyblock(portnamesNew,portnames,blkPath,BusObjName);
        end
    elseif strcmp(Protocol,'Random access read')
        BusObjName='ReadControlM2SBusObj';
        portnamesNew={'rd_addr','rd_len','rd_avalid','rd_dready'};
        modifyblock(portnamesNew,portnames,blkPath,BusObjName);
    elseif strcmp(Protocol,'Random access write')
        BusObjName='WriteControlM2SBusObj';
        portnamesNew={'wr_addr','wr_len','wr_valid'};
        modifyblock(portnamesNew,portnames,blkPath,BusObjName);
    else
        error('(internal) illegal bus type');
    end
    soc.internal.setBlockIcon(blkH,'socicons.BusCreator');
end

function modifyblock(portnamesNew,portnames,blkPath,BusObjName)
    set_param([blkPath,'/Bus Creator'],'OutDataTypeStr',['Bus: ',BusObjName]);
    if isequal(portnames,portnamesNew)
        return;
    end
    if length(portnamesNew)>=length(portnames)
        set_param([blkPath,'/Bus Creator'],'Inputs',num2str(length(portnamesNew)));
        renameports(portnames,blkPath,portnamesNew,length(portnames));
        for i=length(portnames)+1:length(portnamesNew)
            add_block('simulink/Sources/In1',[blkPath,'/',portnamesNew{i}]);
            set_param([blkPath,'/',portnamesNew{i}],'position',[-15,(33+(i-1)*20),15,(47+(i-1)*20)]);
            add_line(blkPath,[portnamesNew{i},'/1'],['Bus Creator/',num2str(i)],'autorouting','on');
        end
    elseif length(portnamesNew)<length(portnames)
        for i=length(portnamesNew)+1:length(portnames)
            delete_line(blkPath,[portnames{i},'/1'],['Bus Creator/',num2str(i)]);
            delete_block([blkPath,'/',portnames{i}]);
        end
        set_param([blkPath,'/Bus Creator'],'Inputs',num2str(length(portnamesNew)));
        renameports(portnames,blkPath,portnamesNew,length(portnamesNew));
    end
    l=get_param([gcb,'/Bus Creator'],'linehandles');
    for i=1:length(portnamesNew)
        set_param(l.Inport(i),'Name',portnamesNew{i});
    end
end

function renameports(portnames,blkPath,portnamesNew,cnt)
    for i=1:cnt
        PortHandle=get_param([blkPath,'/',portnames{i}],'Handle');
        set_param(PortHandle,'Name',portnamesNew{i});
    end
end

function controltype(blkH)%#ok<DEFNU>
    blkPath=hsb.blkcb2.cbutils('GetBlkPath',blkH);
    prot=get_param(blkPath,'Protocol');
    Mobj=get_param(blkPath,'maskobject');
    ctrl=Mobj.getParameter('ctrltype');
    switch prot
    case 'Data stream'
        ctrl.TypeOptions={'Valid','Ready'};
        ctrl.Enabled='on';
    case 'Pixel stream'
        ctrl.TypeOptions={'Valid','Ready','Ready with frame sync'};
        ctrl.Enabled='on';
    case 'Random access read'
        ctrl.TypeOptions={'Ready'};
        ctrl.Enabled='off';
    case 'Random access write'
        ctrl.TypeOptions={'Valid'};
        ctrl.Enabled='off';
    end
end
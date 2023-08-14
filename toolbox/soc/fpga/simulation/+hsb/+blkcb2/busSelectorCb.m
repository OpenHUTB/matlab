function varargout=busSelectorCb(varargin)
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
    outPorts=find_system(blkPath,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport');
    portnames=get_param(outPorts,'Name')';

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
        else
            BusObjName='StreamVideoS2MBusObj';
            portnamesNew={'ready'};
            modifyblock(portnamesNew,portnames,blkPath,BusObjName);
        end
    elseif strcmp(Protocol,'Random access read')
        BusObjName='ReadControlS2MBusObj';
        portnamesNew={'rd_aready','rd_dvalid'};
        modifyblock(portnamesNew,portnames,blkPath,BusObjName);
    elseif strcmp(Protocol,'Random access write')
        BusObjName='WriteControlS2MBusObj';
        portnamesNew={'wr_ready','wr_bvalid','wr_complete'};
        modifyblock(portnamesNew,portnames,blkPath,BusObjName);
    else
        error('(internal) illegal bus type');
    end
    soc.internal.setBlockIcon(blkH,'socicons.BusSelector');
end

function modifyblock(portnamesNew,portnames,blkPath,BusObjName)
    set_param([blkPath,'/ctrlBus'],'OutDataTypeStr',['Bus: ',BusObjName]);
    if isequal(portnames,portnamesNew)
        return;
    end
    if length(portnamesNew)>=length(portnames)
        for i=1:length(portnames)
            delete_line(blkPath,['Bus Selector/',num2str(i)],[portnames{i},'/1']);
        end
        renameports(portnames,blkPath,portnamesNew,length(portnames));
        set_param([blkPath,'/Bus Selector'],'OutputSignals',strjoin(portnamesNew,','));
        for i=length(portnames)+1:length(portnamesNew)
            add_block('simulink/Sinks/Out1',[blkPath,'/',portnamesNew{i}]);
            set_param([blkPath,'/',portnamesNew{i}],'position',[165,(8+(i-1)*20),195,(22+(i-1)*20)]);
            add_line(blkPath,['Bus Selector/',num2str(i)],[portnamesNew{i},'/1']);
        end
        for i=1:length(portnames)
            add_line(blkPath,['Bus Selector/',num2str(i)],[portnamesNew{i},'/1']);
        end
    elseif length(portnamesNew)<length(portnames)
        for i=length(portnamesNew)+1:length(portnames)
            delete_line(blkPath,['Bus Selector/',num2str(i)],[portnames{i},'/1']);
            delete_block([blkPath,'/',portnames{i}]);
        end
        set_param([blkPath,'/Bus Selector'],'OutputSignals',strjoin(portnamesNew,','));
        renameports(portnames,blkPath,portnamesNew,length(portnamesNew));
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
    case{'Data stream','Pixel stream'}
        ctrl.TypeOptions={'Valid','Ready'};
        ctrl.Enabled='on';
    case 'Random access read'
        ctrl.TypeOptions={'Valid'};
        ctrl.Enabled='off';
    case 'Random access write'
        ctrl.TypeOptions={'Ready'};
        ctrl.Enabled='off';
    end
end
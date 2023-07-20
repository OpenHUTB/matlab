function varargout=AudioPlaybackInterfaceCb(func,blkH,varargin)




    if nargout==0
        feval(func,blkH,varargin{:});
    else
        [varargout{1:nargout}]=feval(func,blkH,varargin{:});
    end
end


function MaskParamCb(blkH,paramName)
    cbH=eval(['@',paramName,'Cb']);
    soc.blkcb.cbutils('MaskParamCb',paramName,blkH,cbH);
end


function LoadFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end


function InitFcn(~)
    soc.internal.HWSWMessageTypeDef();
end


function PreSaveFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end


function MaskInitFcn(blkH)%#ok<*DEFNU>
    persistent hadError
    if isempty(hadError)
        hadError=false;
    end
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');
    sysH=bdroot(blkH);
    locSetMaskHelp(blkH);
    try
        hSinkVariant=[blkPath,'/Variant/SIM/Sink Variant'];
        switch blkP.OutputSink
        case 'To output port'
            set_param(hSinkVariant,'OverrideUsingVariant','ToOutputPort');
            set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'DiscardMessage','off');
        case 'To terminator'
            set_param(hSinkVariant,'OverrideUsingVariant','ToTerminator');
            set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'DiscardMessage','on');
        end
        dataPortH=find_system(blkH,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','regexp','on','BlockType','Inport','Name','Data');
        set_param(dataPortH,'Name','Data');
        blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');
        locUpdateReceiveBlockParams(blkH,blkPath,sysH,blkP);


        if isequal(get_param(bdroot(blkH),'SimulationStatus'),'stopped')
            locUpdateSubsystemPorts(blkH,blkPath,sysH,blkP);
        end
        locSetMaskDisplay(blkH,blkP);
        soc.internal.setBlockIcon(blkH,'socicons.AudioPlaybackInterface');
    catch ME
        hadError=true;
        rethrow(ME);
    end
end


function[vis,ens]=OutputSinkCb(blkH,val,vis,ens,idxMap)
    switch val
    case 'To output port'
        vis{idxMap('DataType')}='on';
        ens{idxMap('DataType')}='on';
        vis{idxMap('NumberOfChannels')}='on';
        ens{idxMap('NumberOfChannels')}='on';
        vis{idxMap('SamplesPerFrame')}='on';
        ens{idxMap('SamplesPerFrame')}='on';
    case 'To terminator'
        vis{idxMap('DataType')}='off';
        ens{idxMap('DataType')}='off';
        vis{idxMap('NumberOfChannels')}='off';
        ens{idxMap('NumberOfChannels')}='off';
        vis{idxMap('SamplesPerFrame')}='off';
        ens{idxMap('SamplesPerFrame')}='off';
    otherwise
        error('(internal) illegal input type');
    end
end


function[dataPortH,donePortH,eventPortH,msgPortH]=locFindPorts(blkH,blkPath,dataPortStr,donePortStr,eventPortStr,msgPortStr)
    blkportH=get_param(blkH,'PortHandles');
    if strcmp(get_param([blkPath,'/',dataPortStr],'BlockType'),'Outport')
        dataPortH=blkportH.Outport(1);
    else
        dataPortH=[];
    end
    if strcmp(get_param([blkPath,'/',donePortStr],'BlockType'),'Outport')
        donePortH=blkportH.Outport(1);
    else
        donePortH=[];
    end
    if strcmp(get_param([blkPath,'/',eventPortStr],'BlockType'),'Outport')
        eventPortH=blkportH.Outport(end);
    else
        eventPortH=[];
    end
    if strcmp(get_param([blkPath,'/',msgPortStr],'BlockType'),'Inport')
        msgPortH=blkportH.Inport(end);
    else
        msgPortH=[];
    end
end


function locUpdateSubsystemPorts(blkH,blkPath,~,blkP)
    dataPortStr='data';
    donePortStr='done';
    eventPortStr='event';
    msgPortStr='msg';
    [dataPortH,donePortH,eventPortH,msgPortH]=locFindPorts(blkH,blkPath,dataPortStr,donePortStr,eventPortStr,msgPortStr);
    interfaceChange=false;
    msgPort=true;
    eventPort=false;
    if eventPortH
        interfaceChange=true;
        dataBlk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',eventPortStr,'Terminator','noprompt');
        assert(~isempty(dataBlk),message('soc:msgs:InternalNoNewBlkFor','event ground'));
        set_param(dataBlk{1},'Name',eventPortStr);
    end
    donePort=false;
    if donePortH
        interfaceChange=true;
        newdblk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',donePortStr,'Terminator','noprompt');
        assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','done ground'));
        set_param(newdblk{1},'Name',donePortStr);
    end
    switch blkP.OutputSink
    case 'To output port'
        outPort=true;
        if isempty(dataPortH)
            interfaceChange=true;
            dataBlock=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',dataPortStr,'Outport','noprompt');
            assert(~isempty(dataBlock),message('soc:msgs:InternalNoNewBlkFor','data outport'));
            set_param(dataBlock{1},'Name',dataPortStr);
        end
    case 'To terminator'
        outPort=false;
        if dataPortH
            interfaceChange=true;
            dataBlock=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',dataPortStr,'Terminator','noprompt');
            assert(~isempty(dataBlock),message('soc:msgs:InternalNoNewBlkFor','data terminator'));
            set_param(dataBlock{1},'Name',dataPortStr);
        end
    end
    s=soc.blkcb.GenPortSchema('IO Data Sink',outPort,donePort,eventPort,msgPort);
    set_param(blkH,'PortSchema',s);
    if interfaceChange


        pos=get_param(blkPath,'Position');
        set_param(blkPath,'Position',pos-[10,10,20,20]);
        set_param(blkPath,'Position',pos);
    end
end


function locUpdateReceiveBlockParams(blkH,blkPath,~,blkP)
    blk=[blkPath,'/Variant/SIM/HWSW Message Receive'];
    set_param(blk,'DataTypeStr',locGetDataTypeStr(blkP.DataType));
    set_param(blk,'Dimensions',num2str(blkP.NumberOfChannels*blkP.SamplesPerFrame));
end


function locSetMaskDisplay(blkH,blkP)
end


function locSetMaskHelp(blkH)
    helpcmd='eval(''soc.internal.helpview(''''soc_audioplaybackinterface'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end


function res=locGetDataTypeStr(blockDataType)
    switch(blockDataType)
    case '8-bit integer'
        res='int8';
    case '16-bit integer'
        res='int16';
    case '32-bit integer'
        res='int32';
    end
end

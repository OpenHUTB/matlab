function varargout=IODataSinkCb(func,blkH,varargin)




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

function InitFcn(blkH)
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');

    if isequal(blkP.OutputSink,'To file')
        validateattributes(blkP.DatasetName,{'char','string'},{'nonempty','vector'},'','Dataset name');
        validateattributes(blkP.SourceName,{'char','string'},{'nonempty','vector'},'','Source name');
    end

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

    l_SetMaskHelp(blkH);

    try
        hSinkVariant=[blkPath,'/Variant/SIM/Sink Variant'];
        hHWSWMessageReceive=[blkPath,'/Variant/SIM/HWSW Message Receive'];
        hToOuputDataPort=[blkPath,'/Variant/SIM/Sink Variant/To Output Port/DataOut'];

        set_param(hHWSWMessageReceive,'MessageType',blkP.DeviceType);

        set_param(hToOuputDataPort,'OutDataTypeStr',get_param(blkH,'DataTypeStr'));
        set_param(hToOuputDataPort,'PortDimensions',get_param(blkH,'Dimensions'));

        switch blkP.OutputSink
        case 'To file'
            set_param(hSinkVariant,'LabelModeActiveChoice','ToFile');

            [~,~,ext]=fileparts(blkP.DatasetName);
            if isempty(ext)||isequal(ext,'.tgz')
            else
                error(message('ioplayback:general:InvalidDatasetExtension',ext,'tgz'));
            end

            l_SinkInit(blkH,blkP.DeviceType);
        case 'To output port'
            set_param(hSinkVariant,'LabelModeActiveChoice','ToOutputPort');
            set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'DiscardMessage','off');
        case 'To terminator'
            set_param(hSinkVariant,'LabelModeActiveChoice','ToTerminator');

            if~isequal(get_param(bdroot(blkH),'SimulationStatus'),'external')
                set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'DiscardMessage','on');
            end
        end

        switch blkP.DeviceType
        case 'Stream'
            set_param(blkH,'EnableDonePort','on');
        otherwise
            set_param(blkH,'EnableDonePort','off');
        end

        DataPortH=find_system(blkH,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','regexp','on','BlockType','Inport','Name','Data');
        set_param(DataPortH,'Name',[blkP.DeviceType,' Data']);

        blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');
        if~isequal(get_param(bdroot(blkH),'SimulationStatus'),'external')
            update_receiveBlock_params(blkH,blkPath,sysH,blkP);
        end


        if isequal(get_param(bdroot(blkH),'SimulationStatus'),'stopped')
            update_subsystem_ports(blkH,blkPath,sysH,blkP);
        end
        l_SetMaskDisplay(blkH,blkP);
        soc.internal.setBlockIcon(blkH,'socicons.IODataSink');
    catch ME
        hadError=true;
        rethrow(ME);
    end

end

function[vis,ens]=OutputSinkCb(blkH,val,vis,ens,idxMap)

    mobj=Simulink.Mask.get(blkH);
    paramgrp=mobj.getDialogControl('ParameterGroupVar');
    tofilepan=paramgrp.getDialogControl('ToFilePanel');
    switch val
    case 'To file'
        tofilepan.Visible='on';
        vis{idxMap('DataTypeStr')}='on';
        ens{idxMap('DataTypeStr')}='on';
        vis{idxMap('Dimensions')}='on';
        ens{idxMap('Dimensions')}='on';

    case 'To output port'
        tofilepan.Visible='off';
        vis{idxMap('DataTypeStr')}='on';
        ens{idxMap('DataTypeStr')}='on';
        vis{idxMap('Dimensions')}='on';
        ens{idxMap('Dimensions')}='on';

    case 'To terminator'
        tofilepan.Visible='off';
        vis{idxMap('DataTypeStr')}='off';
        ens{idxMap('DataTypeStr')}='off';
        vis{idxMap('Dimensions')}='off';
        ens{idxMap('Dimensions')}='off';

    otherwise
        error('(internal) illegal input type');
    end
end

function[vis,ens]=DeviceTypeCb(~,val,vis,ens,idxMap)
    if isequal(val,'Stream')
        vis{idxMap('QueueLength')}='on';
        ens{idxMap('QueueLength')}='on';
    else
        vis{idxMap('QueueLength')}='off';
    end
end


function[DataportH,DoneportH,EventportH,MsgportH]=l_findPorts(blkH,blkPath,DataPortStr,DonePortStr,EventPortStr,MsgPortStr)

    blkportH=get_param(blkH,'PortHandles');
    if strcmp(get_param([blkPath,'/',DataPortStr],'BlockType'),'Outport')
        DataportH=blkportH.Outport(1);
    else
        DataportH=[];
    end

    if strcmp(get_param([blkPath,'/',DonePortStr],'BlockType'),'Outport')
        DoneportH=blkportH.Outport(1);
    else
        DoneportH=[];
    end
    if strcmp(get_param([blkPath,'/',EventPortStr],'BlockType'),'Outport')
        EventportH=blkportH.Outport(end);
    else
        EventportH=[];
    end
    if strcmp(get_param([blkPath,'/',MsgPortStr],'BlockType'),'Inport')
        MsgportH=blkportH.Inport(end);
    else
        MsgportH=[];
    end

end

function update_subsystem_ports(blkH,blkPath,~,blkP)
    DataPortStr='data';
    ValidPortStr='valid';
    LengthPortStr='length';
    DonePortStr='done';
    EventPortStr='event';
    MsgPortStr='msg';

    [DataportH,DoneportH,EventportH,MsgportH]=l_findPorts(blkH,blkPath,DataPortStr,DonePortStr,EventPortStr,MsgPortStr);

    interfaceChange=false;

    switch blkP.EventDataPort
    case 'Data and Event'
        MsgPort=true;
        EventPort=true;
        if isempty(EventportH)
            interfaceChange=true;

            dataBlk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',EventPortStr,'Outport','noprompt');
            assert(~isempty(dataBlk),message('soc:msgs:InternalNoNewBlkFor','event outport'));
            set_param(dataBlk{1},'Name',EventPortStr);
            set_param(dataBlk{1},'Port','1');
        end

    case 'Data'
        MsgPort=true;
        EventPort=false;
        if EventportH
            interfaceChange=true;

            dataBlk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',EventPortStr,'Terminator','noprompt');
            assert(~isempty(dataBlk),message('soc:msgs:InternalNoNewBlkFor','event ground'));
            set_param(dataBlk{1},'Name',EventPortStr);
        end
    end

    switch blkP.EnableDonePort
    case 'on'
        DonePort=true;
        if isempty(DoneportH)
            interfaceChange=true;

            dataBlk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',DonePortStr,'Outport','noprompt');
            assert(~isempty(dataBlk),message('soc:msgs:InternalNoNewBlkFor','done outport'));
            set_param(dataBlk{1},'Name',DonePortStr);
            if~EventPort
                set_param(dataBlk{1},'Port','1');
            else
                set_param(dataBlk{1},'Port','2');
            end
        end

    case 'off'
        DonePort=false;
        if DoneportH
            interfaceChange=true;

            newdblk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',DonePortStr,'Terminator','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','done ground'));
            set_param(newdblk{1},'Name',DonePortStr);
        end
    end

    switch blkP.OutputSink
    case 'To output port'
        OutPort=true;
        if isempty(DataportH)
            interfaceChange=true;

            dataBlock=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',DataPortStr,'Outport','noprompt');
            assert(~isempty(dataBlock),message('soc:msgs:InternalNoNewBlkFor','data outport'));
            set_param(dataBlock{1},'Name',DataPortStr);

            lengthBlock=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',LengthPortStr,'Outport','noprompt');
            assert(~isempty(lengthBlock),message('soc:msgs:InternalNoNewBlkFor','length outport'));
            set_param(lengthBlock{1},'Name',LengthPortStr);

            validBlock=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',ValidPortStr,'Outport','noprompt');
            assert(~isempty(validBlock),message('soc:msgs:InternalNoNewBlkFor','valid outport'));
            set_param(validBlock{1},'Name',ValidPortStr);

        end

    case{'To file'}
        OutPort=false;
        if DataportH
            interfaceChange=true;

            dataBlock=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',DataPortStr,'Terminator','noprompt');
            assert(~isempty(dataBlock),message('soc:msgs:InternalNoNewBlkFor','data terminator'));
            set_param(dataBlock{1},'Name',DataPortStr);

            lengthBlock=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',LengthPortStr,'Terminator','noprompt');
            assert(~isempty(lengthBlock),message('soc:msgs:InternalNoNewBlkFor','length terminator'));
            set_param(lengthBlock{1},'Name',LengthPortStr);

            validBlock=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',ValidPortStr,'Terminator','noprompt');
            assert(~isempty(validBlock),message('soc:msgs:InternalNoNewBlkFor','valid terminator'));
            set_param(validBlock{1},'Name',ValidPortStr);
        end
    case 'To terminator'
        OutPort=false;
        if DataportH
            interfaceChange=true;

            dataBlock=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',DataPortStr,'Terminator','noprompt');
            assert(~isempty(dataBlock),message('soc:msgs:InternalNoNewBlkFor','data terminator'));
            set_param(dataBlock{1},'Name',DataPortStr);

            lengthBlock=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',LengthPortStr,'Terminator','noprompt');
            assert(~isempty(lengthBlock),message('soc:msgs:InternalNoNewBlkFor','length terminator'));
            set_param(lengthBlock{1},'Name',LengthPortStr);

            validBlock=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',ValidPortStr,'Terminator','noprompt');
            assert(~isempty(validBlock),message('soc:msgs:InternalNoNewBlkFor','valid terminator'));
            set_param(validBlock{1},'Name',ValidPortStr);

        end

    end

    s=soc.blkcb.GenPortSchema('IO Data Sink',OutPort,DonePort,EventPort,MsgPort);
    set_param(blkH,'PortSchema',s);

    if interfaceChange


        pos=get_param(blkPath,'Position');
        set_param(blkPath,'Position',pos-[10,10,20,20]);
        set_param(blkPath,'Position',pos);
    end
end

function update_receiveBlock_params(blkH,blkPath,~,blkP)
    switch blkP.DeviceType
    case 'Register'
        set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'QueueOverwriting','on');
        set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'QueueType','LIFO');
        set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'ValueSourceWhenQueueIsEmpty','Hold last value');
        set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'QueueLength','1');

    case 'Stream'
        set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'QueueOverwriting','off');
        set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'QueueType','FIFO');
        set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'ValueSourceWhenQueueIsEmpty','Use initial value');
        set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'QueueLength',get_param(blkH,'QueueLength'));

    otherwise

        set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'QueueOverwriting','off');
        set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'QueueType','FIFO');
        set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'ValueSourceWhenQueueIsEmpty','Use initial value');
        set_param([blkPath,'/Variant/SIM/HWSW Message Receive'],'QueueLength','65535');
    end
end

function l_SinkInit(blkH,DeviceType)
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    hSinkBlock=[blkPath,'/Variant/SIM/Sink Variant/To File/MATLAB System'];
    set_param(hSinkBlock,'MessageType',DeviceType);
end

function l_SetMaskDisplay(blkH,blkP)
    fulltext1=sprintf('color(''black'')');
    fulltext2=sprintf('text(0.5, 1, ''%s'',''texmode'',''off'',''horizontalAlignment'',''center'',''verticalAlignment'',''top'');',blkP.DeviceType);
    switch(blkP.OutputSink)
    case 'To output port'
        fulltext3=sprintf('text(0.5, 0.9,''%s'',''horizontalAlignment'',''center'',''verticalAlignment'',''top'',''texmode'',''off'')',blkP.OutputSink);
        fulltext4='';
    case 'To file'
        fulltext3=sprintf('text(0.5, 0.9,''%s'',''horizontalAlignment'',''center'',''verticalAlignment'',''top'',''texmode'',''off'')',blkP.OutputSink);
        fulltext4=sprintf('text(0.5, 0.1,''%s'',''horizontalAlignment'',''center'',''texmode'',''off'')',blkP.DatasetName);
    case 'To terminator'
        fulltext3=sprintf('text(0.5, 0.9,''%s'',''horizontalAlignment'',''center'',''verticalAlignment'',''top'',''texmode'',''off'')',blkP.OutputSink);
        fulltext4=sprintf('');
    end

    md=sprintf('%s;\n%s;\n%s;\n%s;',fulltext1,fulltext2,fulltext3,fulltext4);
    set_param(blkH,'MaskDisplay',md);
end

function l_SetMaskHelp(blkH)
    helpcmd='eval(''soc.internal.helpview(''''soc_iodatasink'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end

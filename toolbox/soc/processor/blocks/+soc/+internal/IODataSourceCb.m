function varargout=IODataSourceCb(func,blkH,varargin)

    if nargout==0
        feval(func,blkH,varargin{:});
    else
        [varargout{1:nargout}]=feval(func,blkH,varargin{:});
    end
end

function MaskParamCb(blkH,paramName)
    cbH=eval(['@',paramName,'Cb']);
    soc.blkcb.cbutils('MaskParamCb',paramName,blkH,cbH)
end

function LoadFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end

function InitFcn(blkH)
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');
    if isequal(blkP.InputSource,'From file')
        validateattributes(blkP.DatasetName,{'char','string'},{'nonempty','vector'},'','Dataset name');
        validateattributes(blkP.SourceName,{'char','string'},{'nonempty','vector'},'','Source name');
    end
    if isequal(blkP.InputSource,'From dialog')

        validateInput(blkP.Value);
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
        hSourceVariant=[blkPath,'/Variant/SIM/Source Variant'];
        SampleTime=get_param(blkH,'SampleTime');
        switch blkP.InputSource
        case 'From input port'
            set_param(hSourceVariant,'LabelModeActiveChoice','FromInputPort');
            set_param(blkH,'InternalSampleTime','-1');


            hHWSWMessageSendBlock=[blkPath,'/Variant/SIM/Source Variant/From Input Port/HWSW Message Send'];
            SetHWSWMessageSendBlockParams(blkH,blkP,hHWSWMessageSendBlock);
        case 'From dialog'
            set_param(hSourceVariant,'LabelModeActiveChoice','FromDialog');
            set_param(blkH,'InternalSampleTime',SampleTime);


            hHWSWMessageSendBlock=[blkPath,'/Variant/SIM/Source Variant/From Constant/HWSW Message Send'];
            SetHWSWMessageSendBlockParams(blkH,blkP,hHWSWMessageSendBlock);
        case 'From file'
            set_param(hSourceVariant,'LabelModeActiveChoice','FromFile');
            set_param(blkH,'SampleTime','-1');
            set_param(blkH,'InternalSampleTime',SampleTime);



            if~isfile(blkP.DatasetName)||isempty(blkP.DatasetName)
                update_subsystem_ports(blkH,blkPath,sysH,blkP);
            end
            hHWSWMessageSendBlock=[blkPath,'/Variant/SIM/Source Variant/From File/Trigger Generator/HWSW Message Send'];
            set_param(hHWSWMessageSendBlock,'MessageType',blkP.DeviceType);
            if isequal(blkP.EventDataPort,'Event')||isequal(blkP.EventDataPort,'Data and Event')
                set_param(blkPath,'ShowEventPort','on');
            else
                set_param(blkPath,'ShowEventPort','off');
            end

            if~soc.blkcb.cbutils('IsLibContext',blkH)
                l_SourceInitFromFile(blkH);
            end
        case 'From timeseries object'
            set_param(hSourceVariant,'LabelModeActiveChoice','FromTimeseriesObject');
            set_param(blkH,'SampleTime','-1');
            set_param(blkH,'InternalSampleTime',SampleTime);
            msgSendPath=[blkPath,'/Variant/SIM/Source Variant/From Timeseries Object'];
            hHWSWMessageSendBlock=[msgSendPath,'/Trigger Generator/HWSW Message Send'];
            set_param(hHWSWMessageSendBlock,'MessageType',blkP.DeviceType);
            if~soc.blkcb.cbutils('IsLibContext',blkH)
                l_SourceInitFromTimeseries(blkH);
            end
        end

        blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');
        switch blkP.DeviceType
        case 'Stream'
            set_param(blkH,'ShowDonePort','on');
        otherwise
            set_param(blkH,'ShowDonePort','off');
        end
        DataPortH=find_system(blkH,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','regexp','on','BlockType','Outport','Name','Data');
        set_param(DataPortH,'Name',[blkP.DeviceType,' Data']);
        blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');


        if isequal(get_param(bdroot(blkH),'SimulationStatus'),'stopped')||isequal(get_param(bdroot(blkH),'SimulationStatus'),'updating')
            update_subsystem_ports(blkH,blkPath,sysH,blkP);
        end
        l_SetMaskDisplay(blkH,blkP);
        soc.internal.setBlockIcon(blkH,'socicons.IODataSource');
    catch ME
        hadError=true;
        rethrow(ME);
    end
end

function[vis,ens]=InputSourceCb(blkH,val,vis,ens,idxMap)
    mobj=Simulink.Mask.get(blkH);
    paramgrp=mobj.getDialogControl('ParameterGroupVar');
    fromfilepan=paramgrp.getDialogControl('FromFilePanel');
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');
    switch val
    case 'From file'
        fromfilepan.Visible='on';
        vis{idxMap('Value')}='off';
        vis{idxMap('DataTypeStr')}='on';
        ens{idxMap('DataTypeStr')}='off';
        vis{idxMap('Dimensions')}='on';
        if isequal(blkP.DeviceType,'UDP')||isequal(blkP.DeviceType,'TCP')
            ens{idxMap('Dimensions')}='on';
        else
            ens{idxMap('Dimensions')}='off';
        end
        ens{idxMap('DeviceType')}='off';
        vis{idxMap('SampleTime')}='off';
        ens{idxMap('SampleTime')}='off';
        vis{idxMap('ObjectName')}='off';
        ens{idxMap('ObjectName')}='off';
    case 'From dialog'
        fromfilepan.Visible='off';
        vis{idxMap('Value')}='on';
        vis{idxMap('DataTypeStr')}='off';
        ens{idxMap('DataTypeStr')}='off';
        vis{idxMap('Dimensions')}='off';
        ens{idxMap('Dimensions')}='off';
        vis{idxMap('SampleTime')}='on';
        ens{idxMap('SampleTime')}='on';
        vis{idxMap('DeviceType')}='on';
        ens{idxMap('DeviceType')}='on';
        vis{idxMap('ObjectName')}='off';
        ens{idxMap('ObjectName')}='off';
    case 'From input port'
        fromfilepan.Visible='off';
        vis{idxMap('Value')}='off';
        vis{idxMap('DataTypeStr')}='off';
        ens{idxMap('DataTypeStr')}='off';
        ens{idxMap('Dimensions')}='off';
        vis{idxMap('Dimensions')}='off';
        vis{idxMap('DeviceType')}='on';
        ens{idxMap('DeviceType')}='on';
        vis{idxMap('SampleTime')}='off';
        ens{idxMap('SampleTime')}='off';
        vis{idxMap('ObjectName')}='off';
        ens{idxMap('ObjectName')}='off';
    case 'From timeseries object'
        fromfilepan.Visible='off';
        vis{idxMap('Value')}='off';
        vis{idxMap('DataTypeStr')}='off';
        ens{idxMap('DataTypeStr')}='off';
        vis{idxMap('Dimensions')}='off';
        ens{idxMap('Dimensions')}='off';
        vis{idxMap('SampleTime')}='off';
        ens{idxMap('SampleTime')}='off';
        vis{idxMap('DeviceType')}='on';
        ens{idxMap('DeviceType')}='on';
        vis{idxMap('ObjectName')}='on';
        ens{idxMap('ObjectName')}='on';
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

function[vis,ens]=SourceNameCb(blkH,~,vis,ens,idxMap)
    ens{idxMap('QueueLength')}='on';
    get_param(blkH,'Sourcename');
    DataSetName=get_param(blkH,'DatasetName');
    SourceName=get_param(blkH,'SourceName');
    if~isempty(DataSetName)
        DataSetName=DatasetValidation(DataSetName);
        ds=RecordedData(DataSetName);


        if~isempty(SourceName)
            validatestring(SourceName,ds.Sources);
        end

        if any(strcmp(ds.Sources,SourceName))
            src=getDataSource(ds,SourceName);
        else
            src=getDataSource(ds,ds.Sources{1});
        end

        PeripheralName=src.params.PeripheralName;

        DataTypeStr=src.params.DataType;

        Dimensions=prod(src.params.HWSignalInfo.Dimensions);

        if isequal(src.SourceType,'ioplayback.SourceSystem')
            switch(PeripheralName)
            case 'AXI4_Lite'
                DeviceType='Register';
            case 'AXI4_IIO_Stream'
                DeviceType='Stream';
            case 'UDP_Receive'
                DeviceType='UDP';
            case 'TCP_Receive'
                DeviceType='TCP';
            end
        else
            DeviceType=PeripheralName;
        end

        if isequal(DeviceType,'Register')
            ens{idxMap('Dimensions')}='off';
            vis{idxMap('QueueLength')}='off';
            set_param(blkH,'DeviceType','Register');
            set_param(blkH,'Dimensions',num2str(Dimensions));
            set_param(blkH,'DataTypeStr',DataTypeStr);
        elseif isequal(DeviceType,'Stream')
            ens{idxMap('Dimensions')}='off';
            vis{idxMap('QueueLength')}='on';
            set_param(blkH,'DeviceType','Stream');
            set_param(blkH,'Dimensions',num2str(Dimensions));
            set_param(blkH,'DataTypeStr',DataTypeStr);
        elseif isequal(DeviceType,'UDP')
            ens{idxMap('Dimensions')}='on';
            vis{idxMap('QueueLength')}='off';
            set_param(blkH,'DeviceType','UDP');
            set_param(blkH,'DataTypeStr',DataTypeStr);
        elseif isequal(DeviceType,'TCP')
            ens{idxMap('Dimensions')}='on';
            vis{idxMap('QueueLength')}='off';
            set_param(blkH,'DeviceType','TCP');
            set_param(blkH,'DataTypeStr',DataTypeStr);
        end
    end
end

function l_SourceInitFromFile(blkH)
    soc.internal.IODataSourceCb('MaskParamCb',blkH,'SourceName');
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    DataSetName=get_param(blkH,'DatasetName');
    SourceName=get_param(blkH,'SourceName');
    if~isempty(DataSetName)
        DataSetName=DatasetValidation(DataSetName);
        ds=RecordedData(DataSetName);

        if any(strcmp(ds.Sources,SourceName))
            src=getDataSource(ds,SourceName);
        else
            src=getDataSource(ds,ds.Sources{1});
        end
        DataTypeStr=src.params.DataType;

        Dimensions=prod(src.params.HWSignalInfo.Dimensions);


        hPlayBackBlock=[blkPath,'/Variant/SIM/Source Variant/From File/Trigger Generator/Generic Playback'];
        EntityGenBlock=[blkPath,'/Variant/SIM/Source Variant/From File/Event Generator'];
        set_param(EntityGenBlock,'DataSetName',DataSetName);
        set_param(EntityGenBlock,'SourceName',SourceName);
        set_param(blkH,'DataTypeStr',DataTypeStr);
        set_param(hPlayBackBlock,'DataType',DataTypeStr);
        if Dimensions~=-1
            set_param(blkH,'Dimensions',num2str(Dimensions));
            set_param(hPlayBackBlock,'Dimensions',num2str(Dimensions));
        else
            Dimensions=get_param(blkH,'Dimensions');
            set_param(hPlayBackBlock,'Dimensions',num2str(Dimensions));
        end
    end
end

function l_SourceInitFromTimeseries(blkH)
    soc.internal.IODataSourceCb('MaskParamCb',blkH,'SourceName');
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    tsObjName=get_param(blkH,'ObjectName');
    try
        blockType='IO Data Source';
        tsObj=soc.internal.getTimeseriesObject(tsObjName,blockType);
        dataTypeStr=class(tsObj.Data);
        [~,length]=size(tsObj.Data);
        dimensions=length;
    catch me %#ok<NASGU>
        dataTypeStr='uint32';
        dimensions=1;
    end
    msgSendPath=[blkPath,'/Variant/SIM/Source Variant/From Timeseries Object'];
    hPlayBackBlock=[msgSendPath,'/Trigger Generator/Generic Playback'];
    hEntityGenBlock=[msgSendPath,'/Event Generator'];
    set_param(hPlayBackBlock,'ObjectName',tsObjName);
    set_param(hEntityGenBlock,'ObjectName',tsObjName);
    set_param(blkH,'DataTypeStr',dataTypeStr);
    set_param(hPlayBackBlock,'DataType',dataTypeStr);
    if dimensions~=-1
        set_param(blkH,'Dimensions',num2str(dimensions));
        set_param(hPlayBackBlock,'Dimensions',num2str(dimensions));
    else
        dimensions=get_param(blkH,'Dimensions');
        set_param(hPlayBackBlock,'Dimensions',num2str(dimensions));
    end
end

function l_SetMaskDisplay(blkH,blkP)
    fulltext1=sprintf('color(''black'')');
    fulltext2=sprintf('text(0.5, 1, ''%s'',''texmode'',''off'',''horizontalAlignment'',''center'',''verticalAlignment'',''top'');',blkP.DeviceType);
    switch(blkP.InputSource)
    case 'From file'
        fulltext3=sprintf('text(0.5, 0.9,''%s'',''horizontalAlignment'',''center'',''verticalAlignment'',''top'',''texmode'',''off'')',blkP.InputSource);
        fulltext4=sprintf('text(0.5, 0.1,''%s'',''horizontalAlignment'',''center'',''texmode'',''off'')',blkP.DatasetName);
    case 'From dialog'
        fulltext3=sprintf('text(0.5, 0.9,''%s'',''horizontalAlignment'',''center'',''verticalAlignment'',''top'',''texmode'',''off'')',blkP.InputSource);
        fulltext4=sprintf('text(0.5, 0.1,''%s'',''horizontalAlignment'',''center'',''texmode'',''off'')',strrep(get_param(blkH,'Value'),'''',''''''));
    case 'From input port'
        fulltext3=sprintf('text(0.5, 0.9,''%s'',''horizontalAlignment'',''center'',''verticalAlignment'',''top'',''texmode'',''off'')',blkP.InputSource);
        fulltext4='';
    case 'From timeseries object'
        fulltext3=sprintf('text(0.5, 0.8,''%s'',''horizontalAlignment'',''center'',''verticalAlignment'',''top'',''texmode'',''off'')',blkP.InputSource);
        fulltext4='';
    end
    md=sprintf('%s;\n%s\n;%s;\n%s;',fulltext1,fulltext2,fulltext3,fulltext4);
    set_param(blkH,'MaskDisplay',md);
end

function l_SetMaskHelp(blkH)
    helpcmd='eval(''soc.internal.helpview(''''soc_iodatasource'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end

function update_subsystem_ports(blkH,blkPath,sysH,blkP)




    if(soc.blkcb.cbutils('SimStatusIsRunning',blkH,sysH))
        return;
    end

    DataPortStr='data';
    ValidPortStr='valid';
    LengthPortStr='length';
    DonePortStr='done';
    EventPortStr='event';
    MsgPortStr='msg';

    [DataportH,DoneportH,EventportH,MsgportH]=l_findPorts(blkH,blkPath,DataPortStr,DonePortStr,EventPortStr,MsgPortStr);

    interfaceChange=false;

    switch blkP.InputSource
    case 'From input port'
        InPort=true;
        if isempty(DataportH)
            interfaceChange=true;

            dataBlk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',DataPortStr,'Inport','noprompt');
            assert(~isempty(dataBlk),message('soc:msgs:InternalNoNewBlkFor','data inport'));
            set_param(dataBlk{1},'Name',DataPortStr);
            set_param(dataBlk{1},'Port','1');

            lengthBlk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',LengthPortStr,'Inport','noprompt');
            assert(~isempty(lengthBlk),message('soc:msgs:InternalNoNewBlkFor','length inport'));
            set_param(lengthBlk{1},'Name',LengthPortStr);
            set_param(lengthBlk{1},'Port','2');

            validBlk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',ValidPortStr,'Inport','noprompt');
            assert(~isempty(validBlk),message('soc:msgs:InternalNoNewBlkFor','valid inport'));
            set_param(validBlk{1},'Name',ValidPortStr);
            set_param(validBlk{1},'Port','3');
        end
    case{'From dialog','From file','From timeseries object'}
        InPort=false;
        if DataportH
            interfaceChange=true;

            newdblk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',DataPortStr,'Ground','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','data ground'));
            set_param(newdblk{1},'Name',DataPortStr);

            newdblk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',LengthPortStr,'Ground','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','length ground'));
            set_param(newdblk{1},'Name',LengthPortStr);

            newdblk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',ValidPortStr,'Ground','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','valid ground'));
            set_param(newdblk{1},'Name',ValidPortStr);
        end
    end

    switch blkP.ShowDonePort
    case 'on'
        DonePort=true;
        if isempty(DoneportH)
            interfaceChange=true;

            dataBlk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',DonePortStr,'Inport','noprompt');
            assert(~isempty(dataBlk),message('soc:msgs:InternalNoNewBlkFor','done outnport'));
            set_param(dataBlk{1},'Name',DonePortStr);
        end
    case 'off'
        DonePort=false;
        if DoneportH
            interfaceChange=true;

            newdblk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',DonePortStr,'Ground','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','done ground'));
            set_param(newdblk{1},'Name',DonePortStr);
        end
    end

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
        if isempty(MsgportH)
            interfaceChange=true;
            dataBlk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',MsgPortStr,'Outport','noprompt');
            assert(~isempty(dataBlk),message('soc:msgs:InternalNoNewBlkFor','msg outport'));
            set_param(dataBlk{1},'Name',MsgPortStr);
            set_param(dataBlk{1},'Port','2');
        end

    case 'Data'
        MsgPort=true;
        EventPort=false;
        if isempty(MsgportH)
            interfaceChange=true;
            dataBlk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',MsgPortStr,'Outport','noprompt');
            assert(~isempty(dataBlk),message('soc:msgs:InternalNoNewBlkFor','msg outport'));
            set_param(dataBlk{1},'Name',MsgPortStr);
        end
        if EventportH
            interfaceChange=true;

            dataBlk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',EventPortStr,'Terminator','noprompt');
            assert(~isempty(dataBlk),message('soc:msgs:InternalNoNewBlkFor','event ground'));
            set_param(dataBlk{1},'Name',EventPortStr);
        end

    case 'Event'
        EventPort=true;
        MsgPort=false;
        if isempty(EventportH)
            interfaceChange=true;
            newdblk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',EventPortStr,'Outport','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','event Outport'));
            set_param(newdblk{1},'Name',EventPortStr);
            set_param(newdblk{1},'Port','1');
        end
        if MsgportH
            interfaceChange=true;
            newdblk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks','all','FollowLinks','on','Name',MsgPortStr,'Terminator','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','msg ground'));
            set_param(newdblk{1},'Name',MsgPortStr);
        end
    end

    s=soc.blkcb.GenPortSchema('IO Data Source',InPort,DonePort,EventPort,MsgPort);
    set_param(blkH,'PortSchema',s);
    if interfaceChange


        pos=get_param(blkPath,'Position');
        set_param(blkPath,'Position',pos-[10,10,20,20]);
        set_param(blkPath,'Position',pos);
    end
end

function[DataportH,DoneportH,EventportH,MsgportH]=l_findPorts(blkH,blkPath,DataPortStr,DonePortStr,EventPortStr,MsgPortStr)
    blkportH=get_param(blkH,'PortHandles');
    if strcmp(get_param([blkPath,'/',DataPortStr],'BlockType'),'Inport')
        DataportH=blkportH.Inport(1);
    else
        DataportH=[];
    end
    if strcmp(get_param([blkPath,'/',DonePortStr],'BlockType'),'Inport')
        DoneportH=blkportH.Inport(end);
    else
        DoneportH=[];
    end
    if strcmp(get_param([blkPath,'/',EventPortStr],'BlockType'),'Outport')
        EventportH=blkportH.Outport(end);
    else
        EventportH=[];
    end
    if strcmp(get_param([blkPath,'/',MsgPortStr],'BlockType'),'Outport')
        MsgportH=blkportH.Outport(end);
    else
        MsgportH=[];
    end
end

function DataSetName=DatasetValidation(DataSetName)

    [~,~,ext]=fileparts(DataSetName);
    if isempty(ext)
        DataSetName=[DataSetName,'.tgz'];
        ext='.tgz';
    end
    if~isequal(ext,'.tgz')
        error(message('ioplayback:general:InvalidDatasetExtension',ext,'tgz'));
    end
end

function SetHWSWMessageSendBlockParams(blkH,blkP,hHWSWMessageSendBlock)
    DeviceType=get_param(blkH,'DeviceType');
    if isequal(blkP.EventDataPort,'Event')||isequal(blkP.EventDataPort,'Data and Event')
        set_param(hHWSWMessageSendBlock,'EnableEventPort','on');
    else
        set_param(hHWSWMessageSendBlock,'EnableEventPort','off');
    end
    QueueLength=get_param(blkH,'QueueLength');
    set_param(hHWSWMessageSendBlock,'MessageType',DeviceType);

    switch blkP.DeviceType
    case 'Stream'
        set_param(hHWSWMessageSendBlock,'EnableDonePort','on');
        set_param(hHWSWMessageSendBlock,'QueueLength',QueueLength);
    otherwise
        set_param(hHWSWMessageSendBlock,'EnableDonePort','off');
    end
end

function validateInput(In)
    if(isstruct(In))
        signalsInStruct=fieldnames(In);
        for i=1:numel(signalsInStruct)
            if(isstruct(In.(signalsInStruct{i})))
                validateInput(In.(signalsInStruct{i}));
            else
                validateattributes(In.(signalsInStruct{i}),{'numeric','logical','embedded.fi'},{'vector','real','nonempty'},'Value');
            end
        end
    else
        validateattributes(In,{'numeric','logical','embedded.fi'},{'vector','real','nonempty'},'Value');
    end
end

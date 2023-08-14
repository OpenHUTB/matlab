function varargout=AudioCaptureInterfaceCb(func,blkH,varargin)




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
    try
        srcVariant=[blkPath,'/Variant/SIM/Source Variant'];
        sampleTime=get_param(blkH,'SampleTime');
        switch blkP.InputSource
        case 'From input port'
            set_param(srcVariant,'OverrideUsingVariant','FromInputPort');
            set_param(blkH,'InternalSampleTime','-1');
        case 'From dialog'
            set_param(srcVariant,'OverrideUsingVariant','FromDialog');
            set_param(blkH,'InternalSampleTime',sampleTime);
        case 'From timeseries object'
            set_param(srcVariant,'OverrideUsingVariant','FromTimeseriesObject');
            set_param(blkH,'SampleTime','-1');
            set_param(blkH,'InternalSampleTime',sampleTime);
            if~soc.blkcb.cbutils('IsLibContext',blkH)
                locInitSourceFromTimeseries(blkH);
            end
        end
        blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');


        if isequal(get_param(bdroot(blkH),'SimulationStatus'),'stopped')||...
            isequal(get_param(bdroot(blkH),'SimulationStatus'),'updating')
            locUpdateSubsystemPorts(blkH,blkPath,sysH,blkP);
        end
        locSetMaskDisplay(blkH,blkP);
        soc.internal.setBlockIcon(blkH,'socicons.AudioCaptureInterface');
        locSetMaskHelp(blkH);
    catch ME
        hadError=true;
        rethrow(ME);
    end
end


function[vis,ens]=InputSourceCb(blkH,val,vis,ens,idxMap)
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');%#ok<NASGU>
    switch val
    case 'From dialog'
        vis{idxMap('Value')}='on';
        ens{idxMap('Value')}='on';
        vis{idxMap('SampleTime')}='on';
        ens{idxMap('SampleTime')}='on';
        vis{idxMap('ObjectName')}='off';
        ens{idxMap('ObjectName')}='off';
    case 'From input port'
        vis{idxMap('Value')}='off';
        ens{idxMap('Value')}='off';
        vis{idxMap('SampleTime')}='off';
        ens{idxMap('SampleTime')}='off';
        vis{idxMap('ObjectName')}='off';
        ens{idxMap('ObjectName')}='off';
    case 'From timeseries object'
        vis{idxMap('Value')}='off';
        ens{idxMap('Value')}='off';
        vis{idxMap('SampleTime')}='off';
        ens{idxMap('SampleTime')}='off';
        vis{idxMap('ObjectName')}='on';
        ens{idxMap('ObjectName')}='on';
    otherwise
        error('(internal) illegal input type');
    end
end




function locInitSourceFromTimeseries(blkH)
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    tsObjName=get_param(blkH,'ObjectName');
    try
        tsObj=soc.internal.getTimeseriesObject(tsObjName);
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
    set_param(hPlayBackBlock,'DataType',dataTypeStr);
    set_param(hPlayBackBlock,'Dimensions',num2str(dimensions));
end


function locSetMaskDisplay(blkH,blkP)
    fulltext1=sprintf('color(''black'')');
    fulltext3=sprintf('text(0.5,0.95,''%s'',''horizontalAlignment'',''center'',''verticalAlignment'',''top'',''texmode'',''off'')',blkP.InputSource);
    md=sprintf('%s;\n%s;',fulltext1,fulltext3);
    set_param(blkH,'MaskDisplay',md);
end


function locSetMaskHelp(blkH)
    helpcmd='eval(''soc.internal.helpview(''''soc_audiocaptureinterface'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end


function locUpdateSubsystemPorts(blkH,blkPath,sysH,blkP)

    if(soc.blkcb.cbutils('SimStatusIsRunning',blkH,sysH))
        return;
    end
    evntPortStr='event';
    dataPortStr='data';
    blkportH=get_param(blkH,'PortHandles');
    switch blkP.ShowEventPort
    case 'on'
        if~isequal(numel(blkportH.Outport),2)
            b=i_ReplacePort(blkPath,evntPortStr,'Outport','event ouport');
            set_param(b{1},'Port','1');
        end
    case 'off'
        if~isequal(numel(blkportH.Outport),1)
            i_ReplacePort(blkPath,evntPortStr,'Terminator','msg ground');
        end
    end
    switch blkP.InputSource
    case 'From input port'
        if~isequal(numel(blkportH.Inport),1)
            b=i_ReplacePort(blkPath,dataPortStr,'Inport','data inport');
            set_param(b{1},'Port','1');
        end
    case{'From dialog','From timeseries object'}
        if~isequal(numel(blkportH.Inport),0)
            b=i_ReplacePort(blkPath,dataPortStr,'Ground','data ground');%#ok<NASGU>
        end
    end
    function b=i_ReplacePort(blkPath,portStr,portType,msg)
        b=replace_block(blkPath,'SearchDepth','1','LookUnderMasks',...
        'all','FollowLinks','on','Name',portStr,portType,'noprompt');
        assert(~isempty(b),message('soc:msgs:InternalNoNewBlkFor',msg));
        set_param(b{1},'Name',portStr);
    end
end

function varargout=EventSourceCb(func,blkH,varargin)




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
    locSetMaskHelp(blkH);
    try
        srcVariant=[blkPath,'/Variant/SIM/Source Variant'];
        sampleTime=get_param(blkH,'SampleTime');
        switch blkP.InputSource
        case 'From input port'
            set_param(srcVariant,'LabelModeActiveChoice','FromInputPort');
            set_param(blkH,'InternalSampleTime','-1');
        case 'From dialog'
            set_param(srcVariant,'LabelModeActiveChoice','FromDialog');
            set_param(blkH,'InternalSampleTime',sampleTime);
        case 'From timeseries object'
            set_param(srcVariant,'LabelModeActiveChoice','FromTimeseriesObject');
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
        soc.internal.setBlockIcon(blkH,'socicons.EventSource');
    catch ME
        hadError=true;
        rethrow(ME);
    end
end


function[vis,ens]=InputSourceCb(blkH,val,vis,ens,idxMap)
    mobj=Simulink.Mask.get(blkH);
    paramgrp=mobj.getDialogControl('ParameterGroupVar');
    fromfilepan=paramgrp.getDialogControl('FromFilePanel');
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');%#ok<NASGU>
    switch val
    case 'From dialog'
        fromfilepan.Visible='off';
        vis{idxMap('SampleTime')}='on';
        ens{idxMap('SampleTime')}='on';
        vis{idxMap('ObjectName')}='off';
        ens{idxMap('ObjectName')}='off';
    case 'From input port'
        vis{idxMap('SampleTime')}='off';
        ens{idxMap('SampleTime')}='off';
        vis{idxMap('ObjectName')}='off';
        ens{idxMap('ObjectName')}='off';
    case 'From timeseries object'
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
        blockType='Interrupt Event Source';
        tsObj=soc.internal.getTimeseriesObject(tsObjName,blockType);%#ok<NASGU>
    catch me %#ok<NASGU>


    end
    dataTypeStr='uint32';
    dimensions=1;
    msgSendPath=[blkPath,'/Variant/SIM/Source Variant/From Timeseries Object'];
    hPlayBackBlock=[msgSendPath,'/Trigger Generator/Generic Playback'];
    hEntityGenBlock=[msgSendPath,'/Event Generator'];
    set_param(hPlayBackBlock,'ObjectName',tsObjName);
    set_param(hPlayBackBlock,'TopBlockType','Interrupt Event Source');
    set_param(hEntityGenBlock,'ObjectName',tsObjName);
    set_param(hEntityGenBlock,'TopBlockType','Interrupt Event Source');
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
    helpcmd='eval(''soc.internal.helpview(''''soc_eventsource'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end


function locUpdateSubsystemPorts(blkH,blkPath,sysH,blkP)

    if(soc.blkcb.cbutils('SimStatusIsRunning',blkH,sysH))
        return;
    end
    dataPortStr='data';
    donePortStr='done';
    evntPortStr='event';
    mssgPortStr='msg';
    [dataPortH,~,~,~]=locFindPorts(...
    blkH,blkPath,dataPortStr,donePortStr,evntPortStr,mssgPortStr);
    switch blkP.InputSource
    case 'From input port'
        if isempty(dataPortH)
            blk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks',...
            'all','FollowLinks','on','Name',dataPortStr,'Inport','noprompt');
            assert(~isempty(blk),message('soc:msgs:InternalNoNewBlkFor','data inport'));
            set_param(blk{1},'Name',dataPortStr);
            set_param(blk{1},'Port','1');
        end
    case{'From dialog','From timeseries object'}
        if dataPortH
            blk=replace_block(blkPath,'SearchDepth','1','LookUnderMasks',...
            'all','FollowLinks','on','Name',dataPortStr,'Ground','noprompt');
            assert(~isempty(blk),message('soc:msgs:InternalNoNewBlkFor','data ground'));
            set_param(blk{1},'Name',dataPortStr);
        end
    end
end


function[dataPortH,donePortH,eventPortH,msgPortH]=locFindPorts(...
    blkH,blkPath,dataPortStr,donePortStr,eventPortStr,msgPortStr)
    blkportH=get_param(blkH,'PortHandles');
    if strcmp(get_param([blkPath,'/',dataPortStr],'BlockType'),'Inport')
        dataPortH=blkportH.Inport(1);
    else
        dataPortH=[];
    end
    if strcmp(get_param([blkPath,'/',donePortStr],'BlockType'),'Inport')
        donePortH=blkportH.Inport(end);
    else
        donePortH=[];
    end
    if strcmp(get_param([blkPath,'/',eventPortStr],'BlockType'),'Outport')
        eventPortH=blkportH.Outport(end);
    else
        eventPortH=[];
    end
    if strcmp(get_param([blkPath,'/',msgPortStr],'BlockType'),'Outport')
        msgPortH=blkportH.Outport(end);
    else
        msgPortH=[];
    end
end

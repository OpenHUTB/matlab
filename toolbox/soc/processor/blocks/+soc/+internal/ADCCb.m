function varargout=ADCCb(func,blkH,varargin)




    if nargout==0
        feval(func,blkH,varargin{:});
    else
        [varargout{1:nargout}]=feval(func,blkH,varargin{:});
    end
end

function MaskParamCb(paramName,blkH)
    cbH=eval(['@',paramName,'Cb']);
    soc.blkcb.cbutils('MaskParamCb',paramName,blkH,cbH)
end

function MaskInitFcn(blkH)%#ok<*DEFNU>
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    validateattributes(blkP.AcqTime,{'numeric'},{'real','nonnan','finite','nonempty','vector','>',0},'','Acquistion time');
    validateattributes(blkP.ConvTime,{'numeric'},{'real','nonnan','finite','nonempty','scalar','>',0},'','Conversion time');
    acqTime=str2num(get_param(gcb,'AcqTime'));
    numAcqTime=numel(acqTime);
    numChannels=get_param(blkH,'NumCh');
    if(numAcqTime>1)
        assert(isequal(numAcqTime,str2double(numChannels)),message('soc:iosim:AcqTimMismatch',numAcqTime,str2double(numChannels)));
    end

    ConvType=blkP.ConvType;



    hEventOutMode=[blkPath,'/Variant Sim_Codegen/SIM/NumChannelControl'];
    labelName=['channel',numChannels];
    set_param(hEventOutMode,'LabelModeActiveChoice',labelName);

    set_param([blkPath,'/Variant Sim_Codegen/SIM/NumChannelControl/',labelName,'/Simulink Function/ADCSim'],'ADCResolution',num2str(blkP.ADCResolution));
    set_param([blkPath,'/Variant Sim_Codegen/SIM/NumChannelControl/',labelName,'/Simulink Function/ADCSim'],'HighVref',num2str(blkP.HighVref));
    set_param([blkPath,'/Variant Sim_Codegen/SIM/NumChannelControl/',labelName,'/Simulink Function/ADCSim'],'AcqTime',num2str(blkP.AcqTime));
    set_param([blkPath,'/Variant Sim_Codegen/SIM/NumChannelControl/',labelName,'/Simulink Function/ADCSim'],'ConvTime',num2str(blkP.ConvTime));
    set_param([blkPath,'/Variant Sim_Codegen/SIM/NumChannelControl/',labelName,'/Simulink Function/ADCSim'],'TimeConstant',num2str(blkP.TimeConstant));

    overSampleControl=[blkPath,'/Variant Sim_Codegen/SIM/NumChannelControl/',labelName,'/IsOversampling'];
    if strcmpi(ConvType,'Sequential')||strcmpi(ConvType,'Simultaneous')
        set_param([blkPath,'/analog'],'PortDimensions',numChannels);
        if(str2double(numChannels)>1)
            set_param(overSampleControl,'LabelModeActiveChoice','NoOversampling');
        end
    else
        set_param([blkPath,'/analog'],'PortDimensions','1');
        if(str2double(numChannels)>1)
            set_param(overSampleControl,'LabelModeActiveChoice','Oversampling');
        end
    end




    isSoftwareTrigger=get_param(blkH,'SoftTrig');
    hEventOutMode=[blkPath,'/Variant Sim_Codegen/SIM/StartCondition'];
    labelEventTrig='EventTrig';
    labelSoftwareTrig='SoftwareTrig';
    if strcmpi(isSoftwareTrigger,'on')
        set_param(hEventOutMode,'LabelModeActiveChoice',labelSoftwareTrig);
        interfaceChange=true;
        if strcmpi(get_param([blkPath,'/start'],'BlockType'),'Inport')
            newdblk=replace_block([blkPath,'/start'],'Inport','Ground','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','start Ground'));
            set_param(newdblk{1},'Name','start');
        end
    else
        set_param(hEventOutMode,'LabelModeActiveChoice',labelEventTrig);
        interfaceChange=true;
        if strcmpi(get_param([blkPath,'/start'],'BlockType'),'Ground')
            newdblk=replace_block([blkPath,'/start'],'Ground','Inport','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','start Inport'));
            set_param(newdblk{1},'Name','start');
            set_param(newdblk{1},'Port','1');
        end
    end



    isEnInterrupt=get_param(blkH,'EnInterrupt');
    hEventOutMode=[blkPath,'/Variant Sim_Codegen/SIM/InterruptControl'];

    lEarlyInt='EarlyInt';
    lLateInt='LateInt';
    lEvent1Off='Event1Off';
    if strcmpi(isEnInterrupt,'on')
        IntCondition=get_param(blkH,'IntCondition');
        if strcmpi(IntCondition,'Acquisition + Conversion time')
            set_param(hEventOutMode,'LabelModeActiveChoice',lLateInt);
        else
            set_param(hEventOutMode,'LabelModeActiveChoice',lEarlyInt);
        end
        interfaceChange=true;
        if strcmpi(get_param([blkPath,'/event'],'BlockType'),'Terminator')
            newdblk=replace_block([blkPath,'/event'],'Terminator','Outport','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','event Ground'));
            set_param(newdblk{1},'Name','event');
            set_param(newdblk{1},'Port','1');
        end
    else
        set_param(hEventOutMode,'LabelModeActiveChoice',lEvent1Off);
        interfaceChange=true;
        if strcmpi(get_param([blkPath,'/event'],'BlockType'),'Outport')
            newdblk=replace_block([blkPath,'/event'],'Outport','Terminator','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','event Terminator'));
            set_param(newdblk{1},'Name','event');
        end
    end



    isEnWatchdog=get_param(blkH,'EnWatchdog');
    hEventOutMode=[blkPath,'/Variant Sim_Codegen/SIM/WatchdogControl'];

    lThreshold='ThresholdEvent';
    lEvent2Off='Event2Off';
    if strcmpi(isEnWatchdog,'on')
        set_param(hEventOutMode,'LabelModeActiveChoice',lThreshold);
        interfaceChange=true;
        if strcmpi(get_param([blkPath,'/wd event'],'BlockType'),'Terminator')
            newdblk=replace_block([blkPath,'/wd event'],'Terminator','Outport','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','wd event Ground'));
            set_param(newdblk{1},'Name','wd event');
            if strcmpi(isEnInterrupt,'on')
                set_param(newdblk{1},'Port','2');
                set_param([blkPath,'/digital'],'Port','3');
            else
                set_param(newdblk{1},'Port','1');
                set_param([blkPath,'/digital'],'Port','2');
            end
        end
    else
        set_param(hEventOutMode,'LabelModeActiveChoice',lEvent2Off);
        interfaceChange=true;
        if strcmpi(get_param([blkPath,'/wd event'],'BlockType'),'Outport')
            newdblk=replace_block([blkPath,'/wd event'],'Outport','Terminator','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','wd event Terminator'));
            set_param(newdblk{1},'Name','wd event');
        end
    end


    if interfaceChange


        pos=get_param(blkPath,'Position');
        set_param(blkPath,'Position',pos-[10,10,20,20]);
        set_param(blkPath,'Position',pos);
    end

    l_SetMaskDisplay(blkH);

    l_SetMaskHelp(blkH);
    soc.internal.setBlockIcon(blkH,'socicons.ADCInterface');

end

function EventportH=l_eventPort_in(blkH,blkPath,EventPortStr)
    blkportH=get_param(blkH,'PortHandles');
    if strcmp(get_param([blkPath,'/',EventPortStr],'BlockType'),'Inport')
        EventportH=blkportH.Outport(end);
    else
        EventportH=[];
    end
end

function EventportH=l_eventPort_out(blkH,blkPath,EventPortStr)
    blkportH=get_param(blkH,'PortHandles');
    if strcmp(get_param([blkPath,'/',EventPortStr],'BlockType'),'Outport')
        EventportH=blkportH.Outport(end);
    else
        EventportH=[];
    end
end


function l_SetMaskHelp(blkH)

    helpcmd='eval(''soc.internal.helpview(''''soc_adcinterface'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end


function l_SetMaskDisplay(blkH)
    fullLabel=l_SetMask_Util(blkH);
    set_param(blkH,'MaskDisplay',fullLabel);
end



function fullLabel=l_SetMask_Util(blkH)
    blkPath=[get(blkH,'Path'),'/',get(blkH,'Name')];
    commonargs={'Regexp','on','LookUnderMasks','all','FollowLinks','on','SearchDepth',1};
    allInpPorts=find_system(blkPath,commonargs{:},'BlockType','Inport');
    allOutPorts=find_system(blkPath,commonargs{:},'BlockType','Outport');
    numIn=length(allInpPorts);
    numOut=length(allOutPorts);

    outputLabels=cell(numOut*2,1);
    outputLabels(1:2:end)=cellfun(@str2num,get_param(allOutPorts,'Port'),'UniformOutput',false);
    outputLabels(2:2:end)=get_param(allOutPorts,'Name');
    inputLabels=cell(numIn*2,1);
    inputLabels(1:2:end)=cellfun(@str2num,get_param(allInpPorts,'Port'),'UniformOutput',false);
    inputLabels(2:2:end)=get_param(allInpPorts,'Name');

    inPorts=sprintf('port_label(''input'', %d, ''%s'');\n',inputLabels{1:end});
    outPorts=sprintf('port_label(''output'', %d, ''%s'');\n',outputLabels{1:end});

    fullLabel=sprintf('\n %s;\n %s',...
    inPorts,outPorts);
    set_param(blkH,'MaskDisplay',fullLabel);

end

function InitFcn(blkH)

    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end

    soc.internal.HWSWMessageTypeDef();
end


function[vis,ens]=SoftTrigCb(blkH,val,vis,ens,idxMap)%#ok<INUSL>
    switch val
    case 'on'
        vis{idxMap('SampleTime')}='on';
    case 'off'
        vis{idxMap('SampleTime')}='off';
    end
end

function[vis,ens]=EnInterruptCb(blkH,val,vis,ens,idxMap)%#ok<INUSL>
    switch val
    case 'on'
        vis{idxMap('IntCondition')}='on';
    case 'off'
        vis{idxMap('IntCondition')}='off';
    end
end

function[vis,ens]=EnWatchdogCb(blkH,val,vis,ens,idxMap)%#ok<INUSL>
    switch val
    case 'on'
        vis{idxMap('LowThreshold')}='on';
        vis{idxMap('HighThreshold')}='on';
    case 'off'
        vis{idxMap('LowThreshold')}='off';
        vis{idxMap('HighThreshold')}='off';
    end
end

function[vis,ens]=NumChCb(blkH,val,vis,ens,idxMap)%#ok<INUSL>
    if(str2double(val)>1)
        ens{idxMap('ConvType')}='on';
    else
        ens{idxMap('ConvType')}='off';
    end
end
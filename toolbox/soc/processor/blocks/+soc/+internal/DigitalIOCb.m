function varargout=DigitalIOCb(func,blkH,varargin)




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
    validateattributes(blkP.LowThreshold,{'numeric'},{'real','nonnan','finite','nonempty','scalar','>=',0,'<=',5},'','Low input voltage');
    validateattributes(blkP.HighThreshold,{'numeric'},{'real','nonnan','finite','nonempty','scalar','>',blkP.LowThreshold,'<=',5},'','High input voltage');


    hEventOutMode=[blkPath,'/Variant Sim_Codegen/SIM/DirectionControl'];
    lInput='Input';
    lOutput='Output';
    if strcmpi(get_param(blkH,'IODir'),'Input')
        set_param(hEventOutMode,'LabelModeActiveChoice',lInput);
        interfaceChange=true;
        if strcmpi(get_param([blkPath,'/msg'],'BlockType'),'Inport')
            newdblk=replace_block([blkPath,'/msg'],'Inport','Ground','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','msg Ground'));
            set_param(newdblk{1},'Name','msg');
        end
        if strcmpi(get_param([blkPath,'/in'],'BlockType'),'Ground')
            newdblk=replace_block([blkPath,'/in'],'Ground','Inport','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','in Inport'));
            set_param(newdblk{1},'Name','in');
            set_param(newdblk{1},'Port','1');
        end
        if strcmpi(get_param([blkPath,'/message'],'BlockType'),'Terminator')
            newdblk=replace_block([blkPath,'/message'],'Terminator','Outport','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','message Terminator'));
            set_param(newdblk{1},'Name','message');
            set_param(newdblk{1},'Port','1');
        end
        if strcmpi(get_param([blkPath,'/out'],'BlockType'),'Outport')
            newdblk=replace_block([blkPath,'/out'],'Outport','Terminator','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','out Terminator'));
            set_param(newdblk{1},'Name','out');
        end
    else
        set_param(hEventOutMode,'LabelModeActiveChoice',lOutput);
        interfaceChange=true;
        if strcmpi(get_param([blkPath,'/msg'],'BlockType'),'Ground')
            newdblk=replace_block([blkPath,'/msg'],'Ground','Inport','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','msg Inport'));
            set_param(newdblk{1},'Name','msg');
            set_param(newdblk{1},'Port','2');
        end
        if strcmpi(get_param([blkPath,'/in'],'BlockType'),'Inport')
            newdblk=replace_block([blkPath,'/in'],'Inport','Ground','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','in Ground'));
            set_param(newdblk{1},'Name','in');
        end
        if strcmpi(get_param([blkPath,'/out'],'BlockType'),'Terminator')
            newdblk=replace_block([blkPath,'/out'],'Terminator','Outport','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','out Outport'));
            set_param(newdblk{1},'Name','out');
            set_param(newdblk{1},'Port','1');
        end
        if strcmpi(get_param([blkPath,'/message'],'BlockType'),'Outport')
            newdblk=replace_block([blkPath,'/message'],'Outport','Terminator','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','message Terminator'));
            set_param(newdblk{1},'Name','message');
        end
        if strcmpi(get_param([blkPath,'/event'],'BlockType'),'Outport')
            newdblk=replace_block([blkPath,'/event'],'Outport','Terminator','noprompt');
            assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','event Outport'));
            set_param(newdblk{1},'Name','event');
        end

    end



    if strcmpi(get_param(blkH,'IODir'),'Input')
        hEventOutMode=[blkPath,'/Variant Sim_Codegen/SIM/EventControl'];
        lRisingEdge='RisingEdge';
        lFallingEdge='FallingEdge';
        lBoth='Both';
        if strcmpi(get_param(blkH,'EventCondition'),'Rising edge')
            set_param(hEventOutMode,'LabelModeActiveChoice',lRisingEdge);
        elseif strcmpi(get_param(blkH,'EventCondition'),'Falling edge')
            set_param(hEventOutMode,'LabelModeActiveChoice',lFallingEdge);
        else
            set_param(hEventOutMode,'LabelModeActiveChoice',lBoth);
        end

        if strcmpi(get_param(blkH,'EnEvent'),'on')
            interfaceChange=true;
            if strcmpi(get_param([blkPath,'/event'],'BlockType'),'Terminator')
                newdblk=replace_block([blkPath,'/event'],'Terminator','Outport','noprompt');
                assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','event Outport'));
                set_param(newdblk{1},'Name','event');
                set_param(newdblk{1},'Port','1');
            end
        else
            interfaceChange=true;
            if strcmpi(get_param([blkPath,'/event'],'BlockType'),'Outport')
                newdblk=replace_block([blkPath,'/event'],'Outport','Terminator','noprompt');
                assert(~isempty(newdblk),message('soc:msgs:InternalNoNewBlkFor','event Terminator'));
                set_param(newdblk{1},'Name','event');
            end
        end
    end






    if strcmpi(get_param(blkH,'IODir'),'Input')
        BlkPath=[blkPath,'/Variant Sim_Codegen/SIM/DirectionControl/Input'];
        BlkSampleTime=get_param(blkH,'SampleTime');
        try
            set_param(BlkPath,'SystemSampleTime',BlkSampleTime);
        catch ME
            rethrow(ME);
        end
    end


    if interfaceChange


        pos=get_param(blkPath,'Position');
        set_param(blkPath,'Position',pos-[10,10,20,20]);
        set_param(blkPath,'Position',pos);
    end

    l_SetMaskDisplay(blkH);

    l_SetMaskHelp(blkH);
    soc.internal.setBlockIcon(blkH,'socicons.DigitalO');

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



function[vis,ens]=IODirCb(blkH,val,vis,ens,idxMap)%#ok<INUSL>
    switch val
    case 'Input'
        vis{idxMap('LowThreshold')}='on';
        vis{idxMap('HighThreshold')}='on';
        vis{idxMap('SampleTime')}='on';
        vis{idxMap('EnEvent')}='on';
        if strcmp(get_param(blkH,'EnEvent'),'on')
            vis{idxMap('EventCondition')}='on';
        else
            vis{idxMap('EventCondition')}='off';
        end
    case 'Output'
        vis{idxMap('LowThreshold')}='off';
        vis{idxMap('HighThreshold')}='off';
        vis{idxMap('SampleTime')}='off';
        vis{idxMap('EnEvent')}='off';
        vis{idxMap('EventCondition')}='off';
    end
end

function[vis,ens]=EnEventCb(blkH,val,vis,ens,idxMap)
    if strcmpi(get_param(blkH,'IODir'),'Input')
        switch val
        case 'on'
            vis{idxMap('EventCondition')}='on';
        case 'off'
            vis{idxMap('EventCondition')}='off';
        end
    end
end


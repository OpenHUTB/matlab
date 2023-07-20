function varargout=BoardHMIOutputsCb(varargin)
    if nargout==0
        feval(varargin{:});
    else
        [varargout{1:nargout}]=feval(varargin{:});
    end
end
function MaskParamCb(paramName,blkH)
    cbH=eval(['@',paramName,'Cb']);
    hsb.blkcb2.cbutils('MaskParamCb',paramName,blkH,cbH)
end

function MaskLinkCb(paramName,blkH)
    cbH=eval(['@',paramName,'Cb']);
    cbH(blkH);
end



function ImageViewLoc(blkH,~)%#ok<*DEFNU>
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);
    currBoard=blkP.LastTargetBoard;
    [~,ImageName]=hsb.blkcb2.cbutils('GetSystemConstant','MAX_LEDS',currBoard);
    figure('Name','LEDs Location','IntegerHandle','Off');
    image(imread(fullfile(matlabroot,'toolbox/soc/fpga/resources/images',ImageName)));
    axis off;
end

function MaskInitFcn(blkH,~)%#ok<*DEFNU>
    MAX_NUM_LEDS=16;
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);
    sysH=bdroot(blkH);

    SetMaskHelp(blkH);

    Leds=get_param(blkH,'MaskObject');
    NoOfOpts=Leds.getParameter('NumLeds');
    currBoard=blkP.LastTargetBoard;

    max_board_leds=hsb.blkcb2.cbutils('GetSystemConstant','MAX_LEDS',currBoard,NoOfOpts);

    blkP=l_setDerivedMaskValues(blkH,sysH,blkP,blkPath);

    update_subsystem_ports(blkH,blkPath,sysH,blkP,max_board_leds);
    SetMaskDisplay(blkH,blkP,currBoard);

    maskType=regexprep(get_param(blkH,'MaskType'),'\s','');
    soc.internal.setBlockIcon(blkH,['socicons.',maskType]);
end

function SetMaskHelp(blkH)
    topic='soc_led';
    fullhelp=sprintf('eval(''soc.internal.helpview(''''%s'''')'')',topic);
    set_param(blkH,'MaskHelp',fullhelp);
end


function blkP=l_setDerivedMaskValues(blkH,sysH,blkP,blkPath)
    mobj=Simulink.Mask.get(blkH);
    dc=mobj.getDialogControl('HardwareBoardLink');
    ledloc=mobj.getDialogControl('LedLocation');
    currBoard=hsb.blkcb2.cbutils('GetHardwareBoard',blkH);
    dc.Prompt=currBoard;
    Leds=get_param(blkH,'MaskObject');
    NoOfOpts=Leds.getParameter('NumLeds');
    oprt=mobj.getDialogControl('signalIOpolarityoprt');
    if~strcmp(blkP.LastTargetBoard,currBoard)

        set_param(blkH,'LastTargetBoard',currBoard);
    end

    if strcmp(blkP.LastTargetBoard,'ZedBoard')||...
        strcmpi(blkP.LastTargetBoard,'Xilinx Zynq ZC706 evaluation kit')||...
        strcmpi(blkP.LastTargetBoard,'Xilinx Kintex-7 KC705 development board')||...
        strcmpi(blkP.LastTargetBoard,'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit')||...
        strcmpi(blkP.LastTargetBoard,'Artix-7 35T Arty FPGA evaluation kit')
        ledloc.Enabled='on';
        NoOfOpts.Enabled='on';
        oprt.Prompt='Active High';
    elseif strcmpi(blkP.LastTargetBoard,'Altera Arria 10 SoC development kit')||...
        strcmpi(blkP.LastTargetBoard,'Altera Cyclone V SoC development kit')
        ledloc.Enabled='on';
        NoOfOpts.Enabled='on';
        oprt.Prompt='Active Low';
    elseif any(strcmpi(blkP.LastTargetBoard,codertarget.internal.getCustomHardwareBoardNamesForSoC))
        if strcmp(blkP.LastTargetBoard,'Xilinx Zynq UltraScale+ RFSoC ZCU111 Evaluation Kit')||...
            strcmpi(blkP.LastTargetBoard,'Xilinx Zynq UltraScale+ RFSoC ZCU216 Evaluation Kit')||...
            strcmpi(blkP.LastTargetBoard,'Xilinx Zynq UltraScale+ RFSoC ZCU208 Evaluation Kit')
            ledloc.Enabled='on';
        else
            ledloc.Enabled='off';
        end
        NoOfOpts.Enabled='on';
        IOInfo=soc.internal.getIOInfo(blkP.LastTargetBoard);
        oprt.Prompt=IOInfo.LED.Logic;
    else
        ledloc.Enabled='off';
        NoOfOpts.Enabled='on';
        oprt.Prompt='None';
    end

end

function HardwareBoardLinkCb(blkH)
    cs=getActiveConfigSet(bdroot(blkH));
    configset.showParameterGroup(cs,{'Hardware Implementation'});

end

function UseTHRLinkCb(blkH)
    cs=getActiveConfigSet(bdroot(blkH));
    configset.showParameterGroup(cs,{'Hardware Implementation'});

end

function SetMaskDisplay(blkH,blkP,currBoard)




    numLed=blkP.NumLeds;
    inputLabels=cell(numLed*2,1);
    [~,~,PortName]=hsb.blkcb2.cbutils('GetSystemConstant','MAX_LEDS',currBoard);
    pidx=0;
    for r=1:numLed
        pidx=pidx+1;
        inputLabels{pidx}=r;
        pidx=pidx+1;
        inputLabels{pidx}=[PortName,num2str(r)];
    end

    inPorts=sprintf('port_label(''input'', %d, ''%s'');\n',inputLabels{:});
    fullIcon=sprintf('%s\n%s\n',inPorts);
    set_param(blkH,'MaskDisplay',fullIcon);
end




function update_subsystem_ports(blkH,blkPath,sysH,blkP,max_board_leds)




    if(soc.blkcb.cbutils('SimStatusIsRunning',blkH,sysH))
        return;
    end

    commonargs={'Regexp','on','LookUnderMasks','all','FollowLinks','on','SearchDepth',1};
    allInPorts=find_system(blkPath,commonargs{:},'BlockType','Inport');
    allInGrounds=find_system(blkPath,commonargs{:},'BlockType','Ground');

    if blkP.NumLeds<length(allInPorts)

        for pidx=blkP.NumLeds+1:length(allInPorts)
            ledname=['LED',num2str(pidx)];
            newwrblk=replace_block(blkPath,'FollowLinks','On','Name',ledname,'Ground','noprompt');
            assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','ground'));
            set_param(newwrblk{1},'Name',ledname);
        end
    elseif blkP.NumLeds>length(allInPorts)

        for pidx=length(allInPorts)+1:blkP.NumLeds
            ledname=['LED',num2str(pidx)];
            newwrblk=replace_block(blkPath,'FollowLinks','On','Name',ledname,'Inport','noprompt');
            assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','inport'));
            set_param(newwrblk{1},'Name',ledname);
            set_param(newwrblk{1},'OutDataTypeStr','boolean');
        end

    else

    end

end


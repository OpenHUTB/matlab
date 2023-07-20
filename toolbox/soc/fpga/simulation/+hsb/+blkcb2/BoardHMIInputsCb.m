function varargout=BoardHMIInputsCb(varargin)
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




function MaskInitFcn(blkH,~)%#ok<*DEFNU>

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);
    sysH=bdroot(blkH);

    mode=get_param(blkH,'MaskObject');
    m=mode.getDialogControl('HMIInputsGroup');


    hmiKind=blkP.HMIKind;
    SetMaskHelp(blkH,hmiKind);

    numHMI=blkP.NumHMI;
    currBoard=blkP.LastTargetBoard;
    DPSwsPbs=get_param(blkH,'MaskObject');
    NoOfOpts=DPSwsPbs.getParameter('NumHMI');
    maxSubsysHMI=hsb.blkcb2.cbutils('GetSystemConstant',hmiKind,currBoard,NoOfOpts);
    Mode_1=blkP.SimMode;

    switch Mode_1
    case 'InputPort'
        m.Visible='off';
    case 'Dialog'
        m.Visible='on';

        switch blkP.NumHMI
        case 1
            set_param(gcb,'maskvisibilities',{'on','on','on','off','off','off','off','off','off','off','on','off','off','off'});
        case 2
            set_param(gcb,'maskvisibilities',{'on','on','on','on','off','off','off','off','off','off','on','off','off','off'});
        case 3
            set_param(gcb,'maskvisibilities',{'on','on','on','on','on','off','off','off','off','off','on','off','off','off'});
        case 4
            set_param(gcb,'maskvisibilities',{'on','on','on','on','on','on','off','off','off','off','on','off','off','off'});
        case 5
            set_param(gcb,'maskvisibilities',{'on','on','on','on','on','on','on','off','off','off','on','off','off','off'});
        case 6
            set_param(gcb,'maskvisibilities',{'on','on','on','on','on','on','on','on','off','off','on','off','off','off'});
        case 7
            set_param(gcb,'maskvisibilities',{'on','on','on','on','on','on','on','on','on','off','on','off','off','off'});
        case 8
            set_param(gcb,'maskvisibilities',{'on','on','on','on','on','on','on','on','on','on','on','off','off','off'});
        end
    end

    blkP=l_setDerivedMaskValues(blkH,sysH,blkP,blkPath);
    hmiLabel=blkP.HMILabel;
    update_subsystem_ports(blkH,blkPath,sysH,numHMI,hmiLabel,blkP,Mode_1,maxSubsysHMI);
    SetMaskDisplay(blkH,blkP,currBoard,hmiKind);

    maskType=regexprep(get_param(blkH,'MaskType'),'\s','');
    soc.internal.setBlockIcon(blkH,['socicons.',maskType]);
end
function ImageViewLoc(blkH,~)%#ok<*DEFNU>
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);
    currBoard=blkP.LastTargetBoard;
    hmiKind=blkP.HMIKind;
    [~,ImageName]=hsb.blkcb2.cbutils('GetSystemConstant',hmiKind,currBoard);
    switch hmiKind
    case 'pushbuttons'
        figTitle='Push Buttons Location';
    case 'dipswitches'
        figTitle='DIP Switches Location';
    otherwise
        figTitle='Push Buttons Location';
    end
    figure('Name',figTitle,'IntegerHandle','Off');
    image(imread(fullfile(matlabroot,'toolbox/soc/fpga/resources/images',ImageName)));
    axis off;
end

function SetMaskHelp(blkH,hmiKind)
    switch hmiKind
    case 'pushbuttons'
        topic='soc_pushbutton';
    case 'dipswitches'
        topic='soc_dipswitch';
    otherwise
        topic='soc_pushbutton';
    end

    fullhelp=sprintf('eval(''soc.internal.helpview(''''%s'''')'')',topic);
    set_param(blkH,'MaskHelp',fullhelp);

end

function blkP=l_setDerivedMaskValues(blkH,sysH,blkP,blkPath)
    mobj=Simulink.Mask.get(blkH);
    dc=mobj.getDialogControl('HardwareBoardLink');
    hmiloc=mobj.getDialogControl('HMIlocation');
    currBoard=hsb.blkcb2.cbutils('GetHardwareBoard',blkH);
    oprt=mobj.getDialogControl('signalIOpolarityoprt');
    dc.Prompt=currBoard;
    DPSwsPbs=get_param(blkH,'MaskObject');
    NoOfOpts=DPSwsPbs.getParameter('NumHMI');

    if~strcmp(blkP.LastTargetBoard,currBoard)

        set_param(blkH,'LastTargetBoard',currBoard);
    end

    if strcmp(blkP.LastTargetBoard,'ZedBoard')||...
        strcmpi(blkP.LastTargetBoard,'Xilinx Zynq ZC706 evaluation kit')||...
        strcmpi(blkP.LastTargetBoard,'Xilinx Kintex-7 KC705 development board')||...
        strcmpi(blkP.LastTargetBoard,'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit')||...
        strcmpi(blkP.LastTargetBoard,'Artix-7 35T Arty FPGA evaluation kit')
        hmiloc.Enabled='on';
        NoOfOpts.Enabled='on';
        oprt.Prompt='Active High';
    elseif strcmpi(blkP.LastTargetBoard,'Altera Arria 10 SoC development kit')||...
        strcmpi(blkP.LastTargetBoard,'Altera Cyclone V SoC development kit')
        hmiloc.Enabled='on';
        NoOfOpts.Enabled='on';
        oprt.Prompt='Active Low';
    elseif any(strcmpi(blkP.LastTargetBoard,codertarget.internal.getCustomHardwareBoardNamesForSoC))
        if strcmp(blkP.LastTargetBoard,'Xilinx Zynq UltraScale+ RFSoC ZCU111 Evaluation Kit')||...
            strcmpi(blkP.LastTargetBoard,'Xilinx Zynq UltraScale+ RFSoC ZCU216 Evaluation Kit')||...
            strcmpi(blkP.LastTargetBoard,'Xilinx Zynq UltraScale+ RFSoC ZCU208 Evaluation Kit')

            hmiloc.Enabled='on';
        else
            hmiloc.Enabled='off';
        end
        NoOfOpts.Enabled='on';
        IOInfo=soc.internal.getIOInfo(blkP.LastTargetBoard);
        if strcmp(blkP.HMIKind,'dipswitches')
            oprt.Prompt=IOInfo.DIP.Logic;
        else
            oprt.Prompt=IOInfo.PB.Logic;
        end
    else
        hmiloc.Enabled='off';
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

function SetMaskDisplay(blkH,blkP,currBoard,hmiKind)



    Mode_1=blkP.SimMode;
    numhmi=blkP.NumHMI;
    inputLabels=cell(numhmi*2,1);
    outputLabels=cell(numhmi*2,1);
    [~,~,PortName]=hsb.blkcb2.cbutils('GetSystemConstant',hmiKind,currBoard);
    pidx=0;
    for r=1:numhmi
        pidx=pidx+1;
        inputLabels{pidx}=r;
        outputLabels{pidx}=r;
        pidx=pidx+1;
        inputLabels{pidx}=[PortName,'In',num2str(r)];
        outputLabels{pidx}=[PortName,num2str(r)];
    end
    if strcmp(Mode_1,'InputPort')
        inPorts=sprintf('port_label(''input'', %d, ''%s'');\n',inputLabels{:});
        outPorts=sprintf('port_label(''output'', %d, ''%s'');\n',outputLabels{:});
        fullIcon=sprintf('%s\n%s\n',inPorts,outPorts);
        set_param(blkH,'MaskDisplay',fullIcon);
    end
    if strcmp(Mode_1,'Dialog')
        outPorts=sprintf('port_label(''output'', %d, ''%s'');\n',outputLabels{:});
        fullIcon=sprintf('%s\n%s\n',outPorts);
        set_param(blkH,'MaskDisplay',fullIcon);
    end
end




function[vis,ens]=NumHMICb(blkH,val,vis,ens,idxMap)
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);

    hmiKind=blkP.HMIKind;
    hmiLabel=blkP.HMILabel;

    val=evalin('base',val);
    maxSubsysHMI=hsb.blkcb2.cbutils('GetSystemConstant','MAX_BLK_HMI_INPUTS');
    if val>maxSubsysHMI
        error('current block implementation supports up to %d %s',maxSubsysHMI,hmiKind);
    end
    for idx=1:maxSubsysHMI
        pname=[hmiLabel,num2str(idx)];
        if idx<=val
            ens{idxMap(pname)}='on';
        else
            ens{idxMap(pname)}='off';
        end
    end
end




function update_subsystem_ports(blkH,blkPath,sysH,numHMI,hmiLabel,blkP,Mode_1,maxSubsysHMI)




    if(soc.blkcb.cbutils('SimStatusIsRunning',blkH,sysH))
        return;
    end

    maxSubsysHMI=hsb.blkcb2.cbutils('GetSystemConstant','MAX_BLK_HMI_INPUTS');
    if numHMI>maxSubsysHMI
        error('current block implementation supports up to %d %s',maxSubsysHMI,blkP.HMIKind);
    end

    commonargs={'Regexp','on','LookUnderMasks','all','FollowLinks','on','SearchDepth',1};
    allOutPorts=find_system(blkPath,commonargs{:},'BlockType','Outport','Name',[hmiLabel,'*']);
    allOutTerms=find_system(blkPath,commonargs{:},'BlockType','Terminator','Name',[hmiLabel,'*']);
    allInPorts=find_system(blkPath,commonargs{:},'BlockType','Inport');
    allInConstants=find_system(blkPath,commonargs{:},'BlockType','Constant');

    switch Mode_1
    case 'Dialog'
        if~isempty(allInPorts)
            replace_block(blkPath,'FollowLinks','On','BlockType','Inport','Constant','noprompt');
        end
        if numHMI<length(allOutPorts)

            for pidx=numHMI+1:maxSubsysHMI-length(allOutTerms)
                rdname=[hmiLabel,num2str(pidx)];
                newrdblk=replace_block(blkPath,'FollowLinks','On','Name',rdname,'Terminator','noprompt');
                assert(~isempty(newrdblk),message('soc:msgs:InternalNoNewBlkFor','terminator'));
                set_param(newrdblk{1},'Name',rdname);
            end

        elseif numHMI>length(allOutPorts)

            for pidx=length(allOutPorts)+1:numHMI
                rdname=[hmiLabel,num2str(pidx)];
                newrdblk=replace_block(blkPath,'FollowLinks','On','Name',rdname,'Outport','noprompt');
                assert(~isempty(newrdblk),message('soc:msgs:InternalNoNewBlkFor','outport'));
                set_param(newrdblk{1},'Name',rdname);

            end
        else

        end
        update_hmi_values(blkPath,blkP);
    case 'InputPort'
        if numHMI<length(allInPorts)

            for pidx=numHMI+1:maxSubsysHMI-length(allInConstants)
                rdname=[hmiLabel,'In',num2str(pidx)];
                rdname1=[hmiLabel,num2str(pidx)];
                newrdblk1=replace_block(blkPath,'FollowLinks','On','Name',rdname1,'Terminator','noprompt');
                newrdblk=replace_block(blkPath,'FollowLinks','On','Name',rdname,'Constant','noprompt');
                assert(~isempty(newrdblk),message('soc:msgs:InternalNoNewBlkFor','constant'));
                set_param(newrdblk{1},'Name',rdname);
                set_param(newrdblk1{1},'Name',rdname1);
            end
        elseif numHMI>length(allInPorts)

            for pidx=length(allInPorts)+1:numHMI
                rdname=[hmiLabel,'In',num2str(pidx)];
                rdname1=[hmiLabel,num2str(pidx)];
                newrdblk=replace_block(blkPath,'FollowLinks','On','Name',rdname,'Inport','noprompt');
                if pidx>length(allOutPorts)
                    newrdblk1=replace_block(blkPath,'FollowLinks','On','Name',rdname1,'Outport','noprompt');
                    set_param(newrdblk1{1},'Name',rdname1);
                end
                assert(~isempty(newrdblk),message('soc:msgs:InternalNoNewBlkFor','inport'));
                set_param(newrdblk{1},'Name',rdname);
                set_param(newrdblk{1},'OutDataTypeStr','boolean');
            end
        else

        end
    end

end


function update_hmi_values(blkPath,blkP)
    maxSubsysHMI=hsb.blkcb2.cbutils('GetSystemConstant','MAX_BLK_HMI_INPUTS');
    [~,~,~,Value]=hsb.blkcb2.cbutils('GetSystemConstant',blkP.HMIKind,blkP.LastTargetBoard);
    for idx=1:maxSubsysHMI
        switch blkP.([blkP.HMILabel,num2str(idx)])
        case 'On',val=num2str(Value);
        case 'Off',val=num2str(~Value);
        end
        set_param([blkPath,'/',blkP.HMILabel,'In',num2str(idx)],'Value',val,'OutDataTypeStr','boolean');
        set_param([blkPath,'/',blkP.HMILabel,'In',num2str(idx)],'Value',val,'SampleTime','HMISampleTime');
    end
end

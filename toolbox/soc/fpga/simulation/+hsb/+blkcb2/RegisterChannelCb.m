function varargout=RegisterChannelCb(varargin)




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


function LoadFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end
function InitFcn(blkH)
    hsb.blkcb2.defineTypes(bdroot(blkH));
end
function PreSaveFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end


function MaskInitFcn(blkH,~)%#ok<*DEFNU>
    persistent hadError
    if isempty(hadError)
        hadError=false;
    end

    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    MAX_NUM_REGS=10;
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);
    sysH=bdroot(blkH);

    SetMaskHelp(blkH);

    try

        wamBlk=[blkPath,'/Writer Access Model'];
        ramBlk=[blkPath,'/Reader Access Model'];
        switch blkP.RegisterAccess
        case 'Processor write channel'
            wamVar='ProcessorAccessModel_Variant';
            ramVar='HardwareAccessModel_Variant';
        case 'Processor read channel'
            wamVar='HardwareAccessModel_Variant';
            ramVar='ProcessorAccessModel_Variant';
        otherwise
            error(message('soc:msgs:InternalBadRegAccessType',blkP.RegisterAccess));
        end
        set_param(wamBlk,'LabelModeActiveChoice',wamVar);
        set_param(ramBlk,'LabelModeActiveChoice',ramVar);

        assert(blkP.NumRegisters<=MAX_NUM_REGS,message('soc:msgs:MaxRegistersExceeded',MAX_NUM_REGS));

        if blkP.NumRegisters~=length(blkP.RegTableNames)
            msg=message('soc:msgs:MustEditRegTable',blkPath);
            switch get_param(sysH,'SimulationStatus')
            case{'updating','initializing','running'}
                error(msg);
            otherwise
                warndlg(msg.getString(),'Must edit register table','replace');
                return;
            end
        end


        rlstrcell=blkP.RegTableVectorLengths;
        if(length(rlstrcell)<MAX_NUM_REGS)
            rlstrcell(end+1:MAX_NUM_REGS)=deal({'1'});
        end
        rlnumcell=cellfun(@(x)(eval(x)),rlstrcell,'UniformOutput',false);
        rlnumarr=['[',sprintf('%d ',rlnumcell{:}),']'];
        set_param(blkH,'RegisterVectorLengths',rlnumarr);

        update_subsystem_ports(blkH,blkPath,sysH,blkP,MAX_NUM_REGS);
        SetMaskDisplay(blkH,blkP);

    catch ME
        hadError=true;
        rethrow(ME);
    end
end
function SetMaskHelp(blkH)




    fullhelp='eval(''soc.internal.openDoc()'')';

    set_param(blkH,'MaskHelp',fullhelp);
end
function SetMaskDisplay(blkH,blkP)




    numReg=blkP.NumRegisters;
    inputLabels=cell(numReg*2,1);
    outputLabels=cell(numReg*2,1);
    pidx=0;
    for r=1:numReg
        pidx=pidx+1;
        inputLabels{pidx}=r;
        outputLabels{pidx}=r;
        pidx=pidx+1;
        inputLabels{pidx}=['wr_',blkP.RegTableNames{r}];
        outputLabels{pidx}=['rd_',blkP.RegTableNames{r}];
    end

    fulltext1=sprintf('color(''black'');\n');
    fulltext2=sprintf('text(0.5,0.5,''{\\bfObsolete}'',''horizontalAlignment'',''center'',''texmode'',''on'');\n');

    inPorts=sprintf('port_label(''input'', %d, ''%s'');\n',inputLabels{:});
    outPorts=sprintf('port_label(''output'', %d, ''%s'');\n',outputLabels{:});

    fullIcon=sprintf('%s\n%s\n',fulltext1,fulltext2,inPorts,outPorts);
    set_param(blkH,'MaskDisplay',fullIcon);
end

function EditRegisterTableBtnCb(blkH)
    d=hsb.blkcb2.RegTableDDG(blkH);
    dh=DAStudio.Dialog(d);
end





function update_subsystem_ports(blkH,blkPath,sysH,blkP,MAX_NUM_REGS)




    if(soc.blkcb.cbutils('SimStatusIsRunning',blkH,sysH))
        return;
    end

    commonargs={'Regexp','on','LookUnderMasks','all','FollowLinks','on','SearchDepth',1};
    allInPorts=find_system(blkPath,commonargs{:},'BlockType','Inport');
    allInConsts=find_system(blkPath,commonargs{:},'BlockType','Constant');
    allOutPorts=find_system(blkPath,commonargs{:},'BlockType','Outport');
    allOutTerms=find_system(blkPath,commonargs{:},'BlockType','Terminator');



    allInGrounds=find_system(blkPath,commonargs{:},'BlockType','Ground');
    for g=allInGrounds'
        [~,wrname]=fileparts(g{1});
        newwrblk=replace_block(blkPath,'FollowLinks','On','Name',wrname,'Constant','noprompt');
        assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','constant'));
        set_param(newwrblk{1},...
        'Name',wrname,...
        'SampleTime','ChSampleTimeWriter');
        allInConsts=find_system(blkPath,commonargs{:},'BlockType','Constant');
    end

    interfaceChange=false;
    if blkP.NumRegisters<length(allInPorts)

        interfaceChange=true;
        for pidx=blkP.NumRegisters+1:MAX_NUM_REGS-length(allInConsts)
            wrname=['wr_reg',num2str(pidx)];
            newwrblk=replace_block(blkPath,'FollowLinks','On','Name',wrname,'Constant','noprompt');
            assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','constant'));
            set_param(newwrblk{1},...
            'Name',wrname,...
            'SampleTime','ChSampleTimeWriter');
        end
    elseif blkP.NumRegisters>length(allInPorts)

        interfaceChange=true;
        for pidx=length(allInPorts)+1:blkP.NumRegisters
            wrname=['wr_reg',num2str(pidx)];
            newwrblk=replace_block(blkPath,'FollowLinks','On','Name',wrname,'Inport','noprompt');
            assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','inport'));
            set_param(newwrblk{1},'Name',wrname);
        end
    else

    end
    if blkP.NumRegisters<length(allOutPorts)

        interfaceChange=true;
        for pidx=blkP.NumRegisters+1:MAX_NUM_REGS-length(allOutTerms)
            rdname=['rd_reg',num2str(pidx)];
            newrdblk=replace_block(blkPath,'FollowLinks','On','Name',rdname,'Terminator','noprompt');
            assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','terminator'));
            set_param(newrdblk{1},'Name',rdname);
        end
    elseif blkP.NumRegisters>length(allInPorts)

        interfaceChange=true;
        for pidx=length(allOutPorts)+1:blkP.NumRegisters
            rdname=['rd_reg',num2str(pidx)];
            newrdblk=replace_block(blkPath,'FollowLinks','On','Name',rdname,'Outport','noprompt');
            assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','outport'));
            set_param(newrdblk{1},'Name',rdname);
        end
    else

    end

    if interfaceChange


        pos=get_param(blkPath,'Position');
        set_param(blkPath,'Position',pos-[10,10,20,20]);
        set_param(blkPath,'Position',pos);
    end
end


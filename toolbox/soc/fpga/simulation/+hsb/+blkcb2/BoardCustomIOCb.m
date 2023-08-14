function varargout=BoardCustomIOCb(varargin)




    if nargout==0
        feval(varargin{:});
    else
        [varargout{1:nargout}]=feval(varargin{:});
    end
end


function MaskParamCb(paramName,blkH)
    cbH=eval(['@',paramName,'Cb']);
    soc.blkcb.cbutils('MaskParamCb',paramName,blkH,cbH);
end



function InitFcn(~)
    soc.internal.HWSWMessageTypeDef();
end

function LoadFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
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
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH);
    sysH=bdroot(blkH);

    blkP.NumIOs=size(blkP.IOTable,1);
    blkP.IOTableCols=size(blkP.IOTable,2);
    blkP.InputInd=[];
    blkP.OutputInd=[];
    for r=1:blkP.NumIOs

        if strcmpi(string(blkP.IOTable(r,2)),'output')
            blkP.InputInd(end+1)=r;
        else
            blkP.OutputInd(end+1)=r;
        end
    end
    numInputs=size(blkP.InputInd,2);
    numOutputs=size(blkP.OutputInd,2);
    MAX_NUM_INPUTS=getMaxNumInputs();
    MAX_NUM_OUTPUTS=getMaxNumOutputs();
    try
        assert(numInputs<=MAX_NUM_INPUTS,message('soc:msgs:MaxIOsExceeded',MAX_NUM_INPUTS));
        assert(numOutputs<=MAX_NUM_OUTPUTS,message('soc:msgs:MaxIOsExceeded',MAX_NUM_OUTPUTS));
        update_subsystem_ports(blkH,blkPath,sysH,blkP);
        SetMaskDisplay(blkH,blkP);

    catch ME
        hadError=true;
        rethrow(ME);
    end
end

function SetMaskDisplay(blkH,blkP)




    numInputs=size(blkP.InputInd,2);
    numOutputs=size(blkP.OutputInd,2);

    inputLabels=cell(numInputs*2,1);
    outputLabels=cell(numOutputs*2,1);
    blkP.Map=containers.Map('KeyType','char','ValueType','char');
    pidx=0;
    for r=1:numInputs
        pidx=pidx+1;
        inputLabels{pidx}=r;
        pidx=pidx+1;
        inputLabels{pidx}=blkP.IOTable{blkP.InputInd(r),1};
        blkP.Map(blkP.IOTable{blkP.InputInd(r),1})=['CIO_In',num2str(r)];
    end

    pidx=0;
    for r=1:numOutputs
        pidx=pidx+1;
        outputLabels{pidx}=r;
        pidx=pidx+1;
        outputLabels{pidx}=blkP.IOTable{blkP.OutputInd(r),1};
        blkP.Map(blkP.IOTable{blkP.OutputInd(r),1})=['CIO_Out',num2str(r)];
    end
    inPorts='';
    outPorts='';
    if numInputs>0
        inPorts=sprintf('port_label(''input'', %d, ''%s'');\n',inputLabels{:});
    end
    if numOutputs>0
        outPorts=sprintf('port_label(''output'', %d, ''%s'');\n',outputLabels{:});
    end
    fullIcon=sprintf('%s\n%s\n',inPorts,outPorts);
    set_param(blkH,'MaskDisplay',fullIcon);
end




function update_subsystem_ports(blkH,blkPath,sysH,blkP)




    if(soc.blkcb.cbutils('SimStatusIsRunning',blkH,sysH))
        return;
    end

    commonargs={'Regexp','on','LookUnderMasks','all','FollowLinks','on','SearchDepth',1};
    allInPorts=find_system(blkPath,commonargs{:},'BlockType','Inport');
    allInGrounds=find_system(blkPath,commonargs{:},'BlockType','Ground');
    allOutPorts=find_system(blkPath,commonargs{:},'BlockType','Outport');
    allOutTerms=find_system(blkPath,commonargs{:},'BlockType','Terminator','Name','CIO_Out\w*');

    numInputs=size(blkP.InputInd,2);
    numOutputs=size(blkP.OutputInd,2);
    MAX_NUM_INPUTS=getMaxNumInputs();
    MAX_NUM_OUTPUTS=getMaxNumOutputs();
    allInputs=allInPorts;
    allInputs(end+1:end+size(allInGrounds,1))=allInGrounds;
    allOutputs=allOutPorts;
    allOutputs(end+1:end+size(allOutTerms,1))=allOutTerms;

    for i=1:MAX_NUM_INPUTS
        if i<=numInputs
            oldportname=erase(string(allInputs(i)),strcat(string(blkPath),"/"));
            newportname=string(blkP.IOTable(blkP.InputInd(i),1));
            if~strcmp(oldportname,newportname)
                newwrblk=replace_block(blkPath,'FollowLinks','On','Name',oldportname,'Inport','noprompt');
                assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','inport'));
                set_param(newwrblk{1},'Name',newportname);
                set_param(strcat(string(blkPath),"/",newportname),'OutDataTypeStr',string(blkP.IOTable(blkP.InputInd(i),3)));
            end
        else
            oldportname=erase(string(allInputs(i)),strcat(string(blkPath),"/"));
            if strlength(oldportname)<9||not(strcmp(extractBetween(oldportname,1,7),"CIO_In1"))
                newportname=['CIO_In',num2str(100+i)];
            else
                newportname=oldportname;
            end
            if~strcmp(oldportname,newportname)
                newwrblk=replace_block(blkPath,'FollowLinks','On','Name',oldportname,'Ground','noprompt');
                assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','ground'));
                set_param(newwrblk{1},'Name',newportname);
            end
        end
    end

    for i=1:MAX_NUM_OUTPUTS
        if i<=numOutputs
            oldportname=erase(string(allOutputs(i)),strcat(string(blkPath),"/"));
            newportname=string(blkP.IOTable(blkP.OutputInd(i),1));
            if~strcmp(oldportname,newportname)
                newwrblk=replace_block(blkPath,'FollowLinks','On','Name',oldportname,'Outport','noprompt');
                assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','Outport'));
                set_param(newwrblk{1},'Name',newportname);
            end
        else
            oldportname=erase(string(allOutputs(i)),strcat(string(blkPath),"/"));
            if strlength(oldportname)<8||not(strcmp(extractBetween(oldportname,1,7),"CIO_OUT"))
                newportname=['CIO_Out',num2str(100+i)];
            else
                newportname=oldportname;
            end
            if~strcmp(oldportname,newportname)
                newrdblk=replace_block(blkPath,'FollowLinks','On','Name',oldportname,'Terminator','noprompt');
                assert(~isempty(newrdblk),message('soc:msgs:InternalNoNewBlkFor','terminator'));
                set_param(newrdblk{1},'Name',newportname);
            end
        end
    end
end



function SetMaskHelp(blkH)

    helpTopic='soc_customIO';
    fullhelp=sprintf('eval(''soc.internal.helpview(''''%s'''')'')',helpTopic);

    set_param(blkH,'MaskHelp',fullhelp);

end

function MAX_NUM_INPUTS=getMaxNumInputs()
    MAX_NUM_INPUTS=16;
end

function MAX_NUM_OUTPUTS=getMaxNumOutputs()
    MAX_NUM_OUTPUTS=16;
end


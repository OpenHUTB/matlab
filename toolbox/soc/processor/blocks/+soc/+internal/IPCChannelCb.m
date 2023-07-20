function varargout=IPCChannelCb(func,blkH,varargin)




    if nargout==0
        feval(func,blkH,varargin{:});
    else
        [varargout{1:nargout}]=feval(func,blkH,varargin{:});
    end
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
        update_subsystem_ports(blkH,blkPath,sysH,blkP);
        validateattributes(blkP.NumBuffers,{'numeric'},{'integer','nonnan','finite','nonempty','scalar','>',0},'','number of buffers');
        validateattributes(blkP.PropagationDelay,{'numeric'},{'real','nonnan','finite','nonempty','scalar','>=',0},'','propagation delay');
    catch ME
        hadError=true;
        rethrow(ME);
    end
    soc.internal.setBlockIcon(blkH,'socicons.IPCChannel');
end


function locSetMaskHelp(blkH)
    helpcmd='eval(''soc.internal.helpview(''''soc_ipcchannel'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end


function update_subsystem_ports(blkH,blkPath,sysH,blkP)


    if(soc.blkcb.cbutils('SimStatusIsRunning',blkH,sysH))
        return;
    end
    eventPortStr='event';
    eventTerminatorStr='Terminator';
    switch(blkP.ShowEventPort)
    case 'on'
        if isempty(find_system(blkPath,'LookUnderMasks','all','FollowLinks',...
            'on','SearchDepth',1,'BlockType','Outport','Name',eventPortStr))
            newBlk=replace_block(blkPath,'SearchDepth','1',...
            'LookUnderMasks','all','FollowLinks','on','Name',...
            eventTerminatorStr,'Outport','noprompt');
            assert(~isempty(newBlk),...
            message('soc:msgs:InternalNoNewBlkFor','event Outport'));
            set_param(newBlk{1},'Port','1');
            set_param(newBlk{1},'Name',eventPortStr);
        end
    case 'off'
        if~isempty(find_system(blkPath,'LookUnderMasks','all','FollowLinks',...
            'on','SearchDepth',1,'BlockType','Outport','Name',eventPortStr))
            newBlk=replace_block(blkPath,'SearchDepth','1',...
            'LookUnderMasks','all','FollowLinks','on','Name',...
            eventPortStr,'Terminator','noprompt');
            assert(~isempty(newBlk),...
            message('soc:msgs:InternalNoNewBlkFor','msg ground'));
            set_param(newBlk{1},'Name',eventTerminatorStr);
        end
    end
    usedOutPortStr='used';
    usedTerminatorStr='TerminatorUsed';
    switch(blkP.ShowNumUsedBuffers)
    case 'on'
        if isempty(find_system(blkPath,'LookUnderMasks','all','FollowLinks',...
            'on','SearchDepth',1,'BlockType','Outport','Name',...
            usedOutPortStr))
            newBlk=replace_block(blkPath,'SearchDepth','1',...
            'LookUnderMasks','all','FollowLinks','on','Name',...
            usedTerminatorStr,'Outport','noprompt');
            assert(~isempty(newBlk),...
            message('soc:msgs:InternalNoNewBlkFor','Used Outport'));
            portIdx=isequal(blkP.ShowEventPort,'on')+2;
            set_param(newBlk{1},'Port',num2str(portIdx));
            set_param(newBlk{1},'Name',usedOutPortStr);
        end
    case 'off'
        if~isempty(find_system(blkPath,'LookUnderMasks','all','FollowLinks',...
            'on','SearchDepth',1,'BlockType','Outport','Name',...
            usedOutPortStr))
            newBlk=replace_block(blkPath,'SearchDepth','1',...
            'LookUnderMasks','all','FollowLinks','on','Name',...
            usedOutPortStr,'Terminator','noprompt');
            assert(~isempty(newBlk),...
            message('soc:msgs:InternalNoNewBlkFor','msg ground'));
            set_param(newBlk{1},'Name',usedTerminatorStr);
        end
    end
    overwrittenOutPortStr='overwritten';
    overwrittenTerminatorStr='TerminatorOverwritten';
    switch(blkP.ShowBufferOverwritten)
    case 'on'
        if isempty(find_system(blkPath,'LookUnderMasks','all','FollowLinks',...
            'on','SearchDepth',1,'BlockType','Outport','Name',...
            overwrittenOutPortStr))
            newBlk=replace_block(blkPath,'SearchDepth','1',...
            'LookUnderMasks','all','FollowLinks','on','Name',...
            overwrittenTerminatorStr,'Outport','noprompt');
            assert(~isempty(newBlk),...
            message('soc:msgs:InternalNoNewBlkFor','Used Outport'));
            portIdx=isequal(blkP.ShowEventPort,'on')+...
            isequal(blkP.ShowNumUsedBuffers,'on')+2;
            set_param(newBlk{1},'Port',num2str(portIdx));
            set_param(newBlk{1},'Name',overwrittenOutPortStr);
        end
    case 'off'
        if~isempty(find_system(blkPath,'LookUnderMasks','all','FollowLinks',...
            'on','SearchDepth',1,'BlockType','Outport','Name',...
            overwrittenOutPortStr))
            newBlk=replace_block(blkPath,'SearchDepth','1',...
            'LookUnderMasks','all','FollowLinks','on','Name',...
            overwrittenOutPortStr,'Terminator','noprompt');
            assert(~isempty(newBlk),...
            message('soc:msgs:InternalNoNewBlkFor','msg ground'));
            set_param(newBlk{1},'Name',overwrittenTerminatorStr);
        end
    end
end

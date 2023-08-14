function varargout=add_exec_event_listener(varargin)






























































    listenerUseTid=false;
    if nargin==4
        listenerUseTid=true;
        listenerTids=varargin{4};
    elseif nargin~=3
        DAStudio.error('Simulink:tools:AddExecEventListenerInvalidInputArgs');
    end

    block=varargin{1};
    eventType=convertStringsToChars(varargin{2});
    listenerCallback=varargin{3};

    if nargout==0
        DAStudio.error('Simulink:tools:AddExecEventListenerRequireOneOutputArg');
    end

    if isa(block,'Simulink.RunTimeBlock')
        rtih=block;
    else
        rtih=get_param(block,'RuntimeObject');
    end

    if listenerUseTid
        for k=1:length(rtih)
            rtih(k).EventListenerTIDs=listenerTids;
        end
    end

    if isempty(rtih)
        isVirtualBlock=get_param(block,'Virtual');
        ss=get_param(bdroot(block),'simulationstatus');
        if strcmp(isVirtualBlock,'on')||strcmp(ss,'running')
            DAStudio.error('Simulink:tools:AddExecEventListenerOnlyToNonVirtualBlocks',block);
        else
            DAStudio.error('Simulink:tools:AddExecEventListenerOnlyDuringExecuting',block);
        end
    end

    rtih=handle(rtih);

    ret_handle=[];

    for k=1:length(rtih)
        hl=handle.listener(rtih(k),eventType,listenerCallback);

        ret_handle=[ret_handle,hl];
    end

    varargout{1}=ret_handle;



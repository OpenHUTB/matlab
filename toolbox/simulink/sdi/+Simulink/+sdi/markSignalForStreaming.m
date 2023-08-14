function markSignalForStreaming(varargin)



    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        if nargin==3

            locMarkBlockOutportForStreaming(varargin{:});
        else

            p=inputParser;
            p.addRequired('handle',@ishandle);
            p.addRequired('state');
            p.parse(varargin{:});
            res=p.Results;
            res.Object=get(res.handle,'Object');
            if isa(res.Object,'Simulink.Segment')
                locMarkLineForStreaming(res.handle,res.state);
            else
                locMarkPortForStreaming(res.handle,res.state);
            end
        end
    catch me
        throwAsCaller(me);
    end
end


function locMarkBlockOutportForStreaming(blk,portIdx,state)

    if ishandle(blk)
        obj=get(blk,'Object');
        blk=obj.getFullName();
    end


    validateattributes(blk,{'char'},{'nonempty'},...
    'markSignalForStreaming','block',1);
    validateattributes(portIdx,{'numeric'},{'integer','positive','nonzero','scalar'},...
    'markSignalForStreaming','port',2);


    sig.BlockPath=Simulink.BlockPath(blk);
    sig.OutputPortIndex=portIdx;
    validate(sig.BlockPath);
    ph=get_param(blk,'PortHandles');
    validateattributes(portIdx,{'numeric'},{'scalar','<=',length(ph.Outport)},...
    'markSignalForStreaming','port',2);


    locMarkPortForStreaming(ph.Outport(portIdx),state);
end


function locMarkPortForStreaming(hPort,state)
    validatestring(get(hPort,'Type'),{'port'},'markSignalForStreaming','handle type',1);
    validatestring(get(hPort,'PortType'),{'outport'},'markSignalForStreaming','port type',1);

    if ischar(state)
        validatestring(lower(state),{'on','off'},...
        'markSignalForStreaming','state');
        bAdd=strcmpi(state,'on');
    else
        validateattributes(state,{'numeric','logical'},{'scalar'},...
        'markSignalForStreaming','state');
        bAdd=logical(state);
    end

    if bAdd
        state='on';
    else
        state='off';
    end
    set_param(hPort,'DataLogging',state);
end


function locMarkLineForStreaming(hLine,state)
    hPort=get(hLine,'SrcPortHandle');
    if ishandle(hPort)
        locMarkPortForStreaming(hPort,state);
    end
end

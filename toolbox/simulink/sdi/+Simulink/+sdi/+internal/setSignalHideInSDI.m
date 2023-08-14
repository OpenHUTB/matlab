function setSignalHideInSDI(varargin)



















    try
        narginchk(3,4);
        [blk,pIdx,val,domain]=locProcessInputs(varargin{:});

        mdl=bdroot(blk);
        sigs=get_param(mdl,'InstrumentedSignals');

        [sig,idx]=locFindSignal(blk,pIdx,sigs,domain);

        if~isempty(sig)
            sig.HideInSDI_=double(val);
            sig.DomainType_=domain;
            sigs.set(idx,sig);
            set_param(mdl,'InstrumentedSignals',sigs);
        elseif val
            error('Signal must be marked for logging')
        end
    catch me
        me.throwAsCaller();
    end
end


function[blk,pIdx,val,domain]=locProcessInputs(varargin)
    [varargin{:}]=convertStringsToChars(varargin{:});


    if nargin==4
        blk=varargin{1};
        pIdx=varargin{2};
        val=varargin{3};
        domain=varargin{4};
        validateattributes(blk,{'char'},{'nonempty'},...
        'setSignalHideInSDI','block',1);
        validateattributes(pIdx,{'numeric'},{'integer','positive','nonzero','scalar'},...
        'setSignalHideInSDI','port',2);
        validateattributes(val,{'logical'},{'scalar'},...
        'setSignalHideInSDI','value',3);
        validateattributes(domain,{'char'},{},...
        'setSignalHideInSDI','domain',4);


    else
        p=inputParser;
        p.addRequired('handle',@locIsValidHandle);
        p.addRequired('value',@islogical);
        p.addRequired('domain',@ischar);
        p.parse(varargin{:});
        res=p.Results;
        [blk,pIdx]=locGetBlkAndPort(res.handle);
        val=res.value;
        domain=res.domain;
    end


    ph=get_param(blk,'PortHandles');
    if length(ph.Outport)<pIdx
        error('Port index is not valid');
    end
end


function ret=locIsValidHandle(val)

    ret=ishandle(val);
    if ret
        obj=get(val,'Object');
        if isa(obj,'Simulink.Segment')

            hPort=get(val,'SrcPortHandle');
            ret=ishandle(hPort);
        else

            ret=isa(obj,'Simulink.Port')&&strcmpi(get(val,'PortType'),'outport');
        end
    end
end


function[blk,portIdx]=locGetBlkAndPort(val)
    obj=get(val,'Object');
    if isa(obj,'Simulink.Segment')
        hPort=get(val,'SrcPortHandle');
    else
        hPort=val;
    end

    blk=get(hPort,'Parent');
    portIdx=get(hPort,'PortNumber');
end


function[sig,idx]=locFindSignal(blk,pIdx,sigs,domain)
    sig=Simulink.HMI.SignalSpecification.empty;
    idx=0;
    if~isempty(sigs)
        for curIdx=1:sigs.Count
            s=sigs.get(curIdx);
            if s.OutputPortIndex==pIdx&&strcmp(s.BlockPath.getBlock(1),blk)&&...
                (isempty(s.DomainType_)||strcmp(s.DomainType_,domain))
                sig=s;
                idx=curIdx;
                return
            end
        end
    end
end

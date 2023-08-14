function setSignalInputProcessingMode(varargin)













    narginchk(2,3);
    try
        [blk,pIdx,val]=locProcessInputs(varargin{:});

        mdl=bdroot(blk);
        sigs=get_param(mdl,'InstrumentedSignals');

        [sig,idx]=locFindSignal(blk,pIdx,sigs);
    catch me %#ok<NASGU>
        err=MException('SDI:sdi:SetFramesUsage',message('SDI:sdi:SetFramesUsage'));
        err.throwAsCaller();
    end

    if~isempty(sig)
        sig.FrameProcessingMode=val;
        sigs.set(idx,sig);
        set_param(mdl,'InstrumentedSignals',sigs);
    elseif~strcmpi(val,'sample')
        err=MException('SDI:sdi:SetFramesNoLogging',message('SDI:sdi:SetFramesNoLogging'));
        err.throwAsCaller();
    end
end


function[blk,pIdx,val]=locProcessInputs(varargin)
    narginchk(2,3);
    [varargin{:}]=convertStringsToChars(varargin{:});


    if nargin==3
        blk=varargin{1};
        pIdx=varargin{2};
        val=varargin{3};
        validateattributes(blk,{'char'},{'nonempty'},...
        'setSignalInputProcessingMode','block',1);
        validateattributes(pIdx,{'numeric'},{'integer','positive','nonzero','scalar'},...
        'setSignalInputProcessingMode','port',2);
        validateattributes(val,{'char'},{'nonempty'},...
        'setSignalInputProcessingMode','value',3);


    else
        p=inputParser;
        p.addRequired('handle',@locIsValidHandle);
        p.addRequired('value',@ischar);
        p.parse(varargin{:});
        res=p.Results;
        [blk,pIdx]=locGetBlkAndPort(res.handle);
        val=res.value;
    end


    ph=get_param(blk,'PortHandles');
    if length(ph.Outport)<pIdx
        error(message('SDI:sdi:SetFramesUsage'));
    end


    validatestring(lower(val),{'sample','frame'},...
    'setSignalInputProcessingMode','value');
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


function[sig,idx]=locFindSignal(blk,pIdx,sigs)
    sig=Simulink.HMI.SignalSpecification.empty;
    idx=0;


    blk=Simulink.SimulationData.BlockPath.manglePath(blk);

    if~isempty(sigs)

        sigs.applyRebindingRules();

        for curIdx=1:sigs.Count
            s=sigs.get(curIdx);
            if s.OutputPortIndex==pIdx&&isempty(s.DomainType_)
                if strcmp(s.BlockPath.getBlock(1),blk)||strcmp(s.getAlignedBlockPath(),blk)
                    sig=s;
                    idx=curIdx;
                    return
                end
            end
        end
    end
end

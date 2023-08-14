function ret=getSignalInputProcessingMode(varargin)




















    narginchk(1,2);
    ret="sample";


    try
        [blk,pIdx]=locProcessInputs(varargin{:});
        sigs=get_param(bdroot(blk),'InstrumentedSignals');
    catch me %#ok<NASGU>
        err=MException('SDI:sdi:GetFramesUsage',message('SDI:sdi:GetFramesUsage'));
        err.throwAsCaller();
    end



    sig=locFindSignal(blk,pIdx,sigs);
    if~isempty(sig)
        ret=sig.FrameProcessingMode;
    end
end


function[blk,pIdx]=locProcessInputs(varargin)
    narginchk(1,2);
    [varargin{:}]=convertStringsToChars(varargin{:});


    if nargin==2
        blk=varargin{1};
        pIdx=varargin{2};
        validateattributes(blk,{'char'},{'nonempty'},...
        'getSignalInputProcessingMode','block',1);
        validateattributes(pIdx,{'numeric'},{'integer','positive','nonzero','scalar'},...
        'getSignalInputProcessingMode','port',2);


    else
        p=inputParser;
        p.addRequired('handle',@locIsValidHandle);
        p.parse(varargin{:});
        res=p.Results;
        [blk,pIdx]=locGetBlkAndPort(res.handle);
    end


    ph=get_param(blk,'PortHandles');
    if length(ph.Outport)<pIdx
        error(message('SDI:sdi:GetFramesUsage'));
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

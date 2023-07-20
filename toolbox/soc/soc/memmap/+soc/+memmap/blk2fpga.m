function comp=blk2fpga(vendor,blk,varargin)







    switch soc.util.getRefBlk(blk)
    case 'socmemlib/Memory Channel'
        if any(strcmpi(get_param(blk,'ProtocolReader'),{'AXI4-Stream Software','AXI4-Stream'}))...
            &&any(strcmpi(get_param(blk,'ProtocolWriter'),{'AXI4-Stream Software','AXI4-Stream'}))
            if isWritePort(varargin{1})
                comp='DMAWrite';
            else
                comp='DMARead';
            end
        elseif strcmpi(get_param(blk,'ProtocolReader'),'AXI4-Stream Video with Frame Sync')...
            &&strcmpi(get_param(blk,'ProtocolWriter'),'AXI4-Stream Video')
            if strcmpi(vendor,'intel')
                error(message('soc:msgs:checkFpgaVDMAIntel'));
            end
            comp='VDMAFrameBuffer';
        elseif strcmpi(get_param(blk,'ProtocolReader'),'AXI4')...
            &&strcmpi(get_param(blk,'ProtocolWriter'),'AXI4')
            comp='';
        elseif strcmpi(get_param(blk,'ProtocolReader'),'AXI4-Stream Video')...
            &&strcmpi(get_param(blk,'ProtocolWriter'),'AXI4-Stream Video')
            if strcmpi(vendor,'intel')
                error(message('soc:msgs:checkFpgaVDMAIntel'));
            end
            if isWritePort(varargin{1})
                comp='VDMAWrite';
            else
                comp='VDMARead';

            end
        end
    case 'socmemlib/AXI4-Stream to Software'
        comp='DMAWrite';
    case 'socmemlib/Software to AXI4-Stream'
        comp='DMARead';
    case 'socmemlib/AXI4 Random Access Memory'
        comp='';
    case 'socmemlib/AXI4 Video Frame Buffer'
        if strcmpi(vendor,'intel')
            error(message('soc:msgs:checkFpgaVDMAIntel'));
        end
        comp='VDMAFrameBuffer';
    case 'socmemlib/Memory Traffic Generator'
        comp='DummyMaster';
    otherwise
        comp='';
    end
end

function result=isWritePort(portName)
    if any(strcmpi(portName,{'wrdata','wrctrlin','wrctrlout'}))
        result=true;
    else
        result=false;
    end
end

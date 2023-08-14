function forwardFPGAParameters(hCS,param)





    fpgaDesign=codertarget.data.getParameterValue(hCS,param);

    if isfield(fpgaDesign,'AXIMemorySubsystemClock')
        if fpgaDesign.IncludeProcessingSystem
            fpgaDesign.AXIMemorySubsystemClockPS=fpgaDesign.AXIMemorySubsystemClock;
        else
            fpgaDesign.AXIMemorySubsystemClockPL=fpgaDesign.AXIMemorySubsystemClock;
        end
        fpgaDesign=rmfield(fpgaDesign,'AXIMemorySubsystemClock');
    end

    if isfield(fpgaDesign,'AXIMemorySubsystemDataWidth')
        if fpgaDesign.IncludeProcessingSystem
            fpgaDesign.AXIMemorySubsystemDataWidthPS=fpgaDesign.AXIMemorySubsystemDataWidth;
        else
            fpgaDesign.AXIMemorySubsystemDataWidthPL=fpgaDesign.AXIMemorySubsystemDataWidth;
        end
        fpgaDesign=rmfield(fpgaDesign,'AXIMemorySubsystemDataWidth');
    end

    if isfield(fpgaDesign,'RefreshOverhead')
        if fpgaDesign.IncludeProcessingSystem
            fpgaDesign.RefreshOverheadPS=fpgaDesign.RefreshOverhead;
        else
            fpgaDesign.RefreshOverheadPL=fpgaDesign.RefreshOverhead;
        end
        fpgaDesign=rmfield(fpgaDesign,'RefreshOverhead');
    end

    if isfield(fpgaDesign,'WriteFirstTransferLatency')
        if fpgaDesign.IncludeProcessingSystem
            fpgaDesign.WriteFirstTransferLatencyPS=fpgaDesign.WriteFirstTransferLatency;
        else
            fpgaDesign.WriteFirstTransferLatencyPL=fpgaDesign.WriteFirstTransferLatency;
        end
        fpgaDesign=rmfield(fpgaDesign,'WriteFirstTransferLatency');
    end

    if isfield(fpgaDesign,'WriteLastTransferLatency')
        if fpgaDesign.IncludeProcessingSystem
            fpgaDesign.WriteLastTransferLatencyPS=fpgaDesign.WriteLastTransferLatency;
        else
            fpgaDesign.WriteLastTransferLatencyPL=fpgaDesign.WriteLastTransferLatency;
        end
        fpgaDesign=rmfield(fpgaDesign,'WriteLastTransferLatency');
    end

    if isfield(fpgaDesign,'ReadFirstTransferLatency')
        if fpgaDesign.IncludeProcessingSystem
            fpgaDesign.ReadFirstTransferLatencyPS=fpgaDesign.ReadFirstTransferLatency;
        else
            fpgaDesign.ReadFirstTransferLatencyPL=fpgaDesign.ReadFirstTransferLatency;
        end
        fpgaDesign=rmfield(fpgaDesign,'ReadFirstTransferLatency');
    end

    if isfield(fpgaDesign,'ReadLastTransferLatency')
        if fpgaDesign.IncludeProcessingSystem
            fpgaDesign.ReadLastTransferLatencyPS=fpgaDesign.ReadLastTransferLatency;
        else
            fpgaDesign.ReadLastTransferLatencyPL=fpgaDesign.ReadLastTransferLatency;
        end
        fpgaDesign=rmfield(fpgaDesign,'ReadLastTransferLatency');
    end

    if isfield(fpgaDesign,'AXIMemoryInterconnectInputClock')
        fpgaDesign=rmfield(fpgaDesign,'AXIMemoryInterconnectInputClock');
    end

    if isfield(fpgaDesign,'AXIMemoryInterconnectInputDataWidth')
        fpgaDesign=rmfield(fpgaDesign,'AXIMemoryInterconnectInputDataWidth');
    end

    if isfield(fpgaDesign,'AXIMemoryInterconnectFIFODepth')
        fpgaDesign=rmfield(fpgaDesign,'AXIMemoryInterconnectFIFODepth');
    end

    if isfield(fpgaDesign,'AXIMemoryInterconnectFIFOAFullDepth')
        fpgaDesign=rmfield(fpgaDesign,'AXIMemoryInterconnectFIFOAFullDepth');
    end


    codertarget.data.setParameterValue(hCS,param,fpgaDesign);

end
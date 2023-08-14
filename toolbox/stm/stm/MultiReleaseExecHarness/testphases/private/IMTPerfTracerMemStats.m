function tracerData=IMTPerfTracerMemStats()

    tracerData=[];
    try
        try
            PerfTools.Tracer.enable('UsePerfTracerMemStats',true);
            PerfTools.Tracer.clearRawData('grouping','UsePerfTracerMemStats');
            PerfTools.Tracer.enableDetailedMemStats(true);


            PerfTools.Tracer.logMATLABData('UsePerfTracerMemStats','tempPhase',true);
            PerfTools.Tracer.logMATLABData('UsePerfTracerMemStats','tempPhase',false);
            tracerData=PerfTools.Tracer.getProcessedData('grouping','UsePerfTracerMemStats');

            PerfTools.Tracer.enableDetailedMemStats(false);
            PerfTools.Tracer.enable('UsePerfTracerMemStats',false);
            PerfTools.Tracer.clearRawData('grouping','UsePerfTracerMemStats');
        catch

            SLPerfTools.Tracer.enable('UsePerfTracerMemStats',true);
            SLPerfTools.Tracer.clearRawData('grouping','UsePerfTracerMemStats');
            SLPerfTools.Tracer.enableDetailedMemStats(true);


            SLPerfTools.Tracer.logMATLABData('UsePerfTracerMemStats','tempPhase',true);
            SLPerfTools.Tracer.logMATLABData('UsePerfTracerMemStats','tempPhase',false);
            tracerData=SLPerfTools.Tracer.getProcessedData('grouping','UsePerfTracerMemStats');

            SLPerfTools.Tracer.enableDetailedMemStats(false);
            SLPerfTools.Tracer.enable('UsePerfTracerMemStats',false);
            SLPerfTools.Tracer.clearRawData('grouping','UsePerfTracerMemStats');
        end

    catch
        disp(lasterr);
        tracerData=[];
    end
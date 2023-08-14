function[timing,synarea,metadata]=readLiberoResultsFromFile(this)

    metadata.liberoSythRpt='';
    metadata.liberoSythRptTimestamp=0;
    metadata.resourceUtilRptFileLibero='';
    metadata.resourceUtilRptFileLiberoTimestamp=0;
    metadata.PRlogFile='';
    metadata.PRlogFileTimestamp=0;

    if this.testMode
        metadata.latencyFileName='';
        metadata.latencyFileTimeStamp=0;
    end

    timing.cp=NaN;
    timing.logic=NaN;
    timing.route=NaN;
    timing.fmax=NaN;

    timing.latency=NaN;

    synarea.LUT4s=NaN;
    synarea.DFFs=NaN;
    synarea.RAM64x18s=NaN;
    synarea.RAM1K18s=NaN;
    synarea.RAMs=NaN;
    synarea.DSPs=NaN;
    synarea.LogicElements=NaN;





    if this.testMode&&this.readTiming

        [metadata.latencyFileName,metadata.latencyFileTimeStamp]=systemFindUnique(this,'hdlcodegenstatus.mat','the generated Latency File','');

        cg_results=load(metadata.latencyFileName);
        timing.latency=cg_results.Latency;
    end







    if this.readTiming

        [metadata.liberoSythRpt,metadata.liberoSythRptTimestamp]=systemFindUnique(this,[this.dutName,'.srr'],'Libero Synthesis report','');

        fh=fopen(metadata.liberoSythRpt,'r');

        delayE='Total\s+path\s+delay\s+\(propagation\s+time\s+\+\s+setup\)\s+of\s+([0-9,.]*)\s+is\s+([0-9,.]*)\(([0-9,.]*)\%\)\s+logic\s+and\s+([0-9,.]*)\(([0-9,.]*)\%\)\s+route';
        FmaxE='\|clk\s+([0-9,.]*)\s+MHz\s+([0-9,.]*)\s+MHz\s+([0-9,.]*)\s+([0-9,.]*)\s+';




        while~feof(fh)
            line=fgetl(fh);

            l=regexp(line,delayE,'tokens');
            if~isempty(l)&&isnan(timing.cp)
                timing.cp=str2double(l{1}{1});
                timing.logic=str2double(l{1}{2});
                timing.route=str2double(l{1}{4});
            end

            l=regexp(line,FmaxE,'tokens');
            if~isempty(l)&&isnan(timing.fmax)
                timing.fmax=str2double(l{1}{2});
            end
        end

        fclose(fh);
    end


















    if this.readResources


        [metadata.resourceUtilRptFileLibero,metadata.resourceUtilRptFileLiberoTimestamp]=systemFindUnique(this,[this.dutName,'_compile.rpt'],'Libero Resource Utilization report','');

        fh_compile=fopen(metadata.resourceUtilRptFileLibero,'r');

        LUT4='\|\s+4LUT\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|';
        DFFs='\|\s+DFF\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|';
        RAM64x18='\|\s+RAM64x18\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|';
        RAM1K18='\|\s+RAM1K18\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|';
        MACCs='\|\s+MACC\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|';




        while~feof(fh_compile)
            line=fgetl(fh);

            l=regexp(line,LUT4,'tokens');
            if~isempty(l)&&isnan(synarea.LUT4s)
                synarea.LUT4s=str2double(l{1}{1});
            end

            l=regexp(line,DFFs,'tokens');
            if~isempty(l)&&isnan(synarea.DFFs)
                synarea.DFFs=str2double(l{1}{1});
            end

            l=regexp(line,RAM64x18,'tokens');
            if~isempty(l)&&isnan(synarea.RAM64x18s)
                synarea.RAM64x18s=str2double(l{1}{1});
            end

            l=regexp(line,RAM1K18,'tokens');
            if~isempty(l)&&isnan(synarea.RAM1K18s)
                synarea.RAM1K18s=str2double(l{1}{1});
            end

            l=regexp(line,MACCs,'tokens');
            if~isempty(l)&&isnan(synarea.DSPs)
                synarea.DSPs=str2double(l{1}{1});
            end
        end

        synarea.RAMs=synarea.RAM64x18s+synarea.RAM1K18s;

        fclose(fh_compile);


        [metadata.PRlogFile,metadata.PRlogFileTimestamp]=systemFindUnique(this,[this.dutName,'_layout_log.log'],'Libero PR Log file','');

        f_PostRouteLog=fopen(metadata.PRlogFile,'r');

        LogicEle='\|\s+Logic\s+Element\s+\|\s+(\d+)\s+\|\s+(\d+)\s+\|\s+([\d\.])*\s+\|';




        while~feof(fh_compile)
            line=fgetl(f_PostRouteLog);

            l=regexp(line,LogicEle,'tokens');
            if~isempty(l)&&isnan(synarea.LogicElements)
                synarea.LogicElements=str2double(l{1}{1});
                break;
            end
        end
        fclose(f_PostRouteLog);
    end
end
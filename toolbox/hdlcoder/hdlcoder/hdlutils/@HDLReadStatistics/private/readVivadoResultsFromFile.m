
function[timing,synarea,metadata]=readVivadoResultsFromFile(this,stage)
    metadata.dut='';
    metadata.synthTool='';
    metadata.chipName='';
    metadata.chipSpeed='';
    metadata.RPTFileName='';
    metadata.RPTFileTimestamp=0;
    metadata.UtilReportFileName='';
    metadata.UtilReportFileTimestamp=0;

    if this.testMode
        metadata.latencyFileName='';
        metadata.latencyFileTimeStamp=0;
    end

    timing.dataPathDelay=NaN;
    timing.levels=NaN;
    timing.logic=NaN;
    timing.route=NaN;
    timing.slack=NaN;
    timing.clkPeriod='';

    metadata.dataPathDelayStr='';
    metadata.levelsStr='';
    metadata.logicStr='';
    metadata.routeStr='';
    metadata.slackStr='';
    metadata.clkPeriodStr='';

    timing.fmax=NaN;
    timing.latency=NaN;

    synarea.slices=NaN;
    synarea.sliceRegs=NaN;
    synarea.luts=NaN;
    synarea.DSPs=NaN;
    synarea.DSP58=NaN;
    synarea.RAMs=NaN;
    synarea.URAMs=NaN;

    metadata.slicesStr='';
    metadata.sliceRegsStr='';
    metadata.lutsStr='';
    metadata.DSPsStr='';
    metadata.DSP58Str='';
    metadata.RAMsStr='';
    metadata.URAMsStr='';

    synarea.maxSlices=NaN;
    synarea.maxSliceRegs=NaN;
    synarea.maxLuts=NaN;
    synarea.maxDSPs=NaN;
    synarea.maxDSP58=NaN;
    synarea.maxRAMs=NaN;
    synarea.maxURAMs=NaN;





    if this.testMode&&this.readTiming

        [metadata.latencyFileName,metadata.latencyFileTimeStamp]=systemFindUnique(this,'hdlcodegenstatus.mat','the generated Latency File','');

        cg_results=load(metadata.latencyFileName);
        timing.latency=cg_results.Latency;
    end





    if this.readTiming

        if strcmpi(stage,'Synthesis')

            [metadata.RPTFileName,metadata.RPTFileTimestamp]=systemFindUnique(this,'timing_post_map.rpt','Xilinx Post Map Timing Summary Report file','Please ensure that you have performed the "Run Synthesis" step in the HDL Workflow Advisor before parsing the results.');
        else

            [metadata.RPTFileName,metadata.RPTFileTimestamp]=systemFindUnique(this,'timing_post_route.rpt','Xilinx Post Route Timing Summary Report file','Please ensure that you have performed the "Run Implementation" step in the HDL Workflow Advisor before parsing the results.');
        end

        fh=fopen(metadata.RPTFileName,'r');










        dutE='\|\s+Design\s+:\s+(\w+)';
        synthToolE='\|\s+Tool Version\s+:\s*(Vivado)?\s+([a-zA-z0-9\(\):. ]*)';
        chipNameE='\|\s+Device\s+:\s+([a-zA-Z0-9\-]*)';
        chipSpeedE='\|\s+Speed File\s+:\s+(-\d)';












        metadata.dataPathDelayStr='Data Path Delay';
        metadata.levelsStr='Logic Levels';
        metadata.logicStr='logic';
        metadata.routeStr='route';
        metadata.slackStr='Slack';
        metadata.clkPeriodStr='Period';

        slack_E=['\s*',metadata.slackStr,'\s*([\(\)a-zA-Z]*)?\s*:\s+(inf|([-0-9,.]*))'];
        delayE=['\s+',metadata.dataPathDelayStr,':\s+([0-9,.]*)ns\s+\(',metadata.logicStr,'\s+([0-9,.]*)ns\s+\(([0-9,.]*)\%\)\s+',metadata.routeStr,'\s+([0-9,.]*)ns\s+\(([0-9,.]*)\%\)\)'];
        logicLevelsE=['\s+',metadata.levelsStr,':\s+([0-9,.]*)\s+'];
        clkPeriodE=['\s*',metadata.clkPeriodStr,'\(ns\):\s+([0-9,.]*)\s*'];




        while~feof(fh)
            line=fgetl(fh);





            l=regexp(line,dutE,'tokens');
            if~isempty(l)&&isempty(metadata.dut)
                metadata.dut=l{1}{1};
            end





            l=regexp(line,synthToolE,'tokens');
            if~isempty(l)&&isempty(metadata.synthTool)
                if isempty(l{1}{1})
                    error('HDLReadStatistics:WorkflowMismatch',['The logs in the target directory: ''',strrep(this.targetDir,'\','\\'),''' were made using unsupported synthesis tool. Please rerun the synthesis using ''Xilinx Vivado'' and provide the corresponding target directory.']);
                end

                metadata.synthTool=l{1}{2};
            end





            l=regexp(line,chipNameE,'tokens');
            if~isempty(l)&&isempty(metadata.chipName)
                metadata.chipName=l{1}{1};
            end





            l=regexp(line,chipSpeedE,'tokens');
            if~isempty(l)&&isempty(metadata.chipSpeed)
                metadata.chipSpeed=l{1}{1};
            end





            l=regexp(line,slack_E,'tokens');
            if~isempty(l)
                timing.slack=[timing.slack,str2double(l{1}{2})];
            end





            l=regexp(line,clkPeriodE,'tokens');
            if~isempty(l)
                timing.clkPeriod=str2double(l{1}{1});
            end

            l=regexp(line,delayE,'tokens');
            if~isempty(l)
                timing.dataPathDelay=[timing.dataPathDelay,str2double(l{1}{1})];
                timing.logic=[timing.logic,str2double(l{1}{2})];
                timing.route=[timing.route,str2double(l{1}{4})];
                if this.testMode
                    timing.fmax=[timing.fmax,1000/str2double(l{1}{1})];
                end
            end





            l=regexp(line,logicLevelsE,'tokens');
            if~isempty(l)
                timing.levels=[timing.levels,str2double(l{1}{1})];
            end
        end
        fclose(fh);


        allNaNIndices=isnan(timing.dataPathDelay);

        timing.dataPathDelay=timing.dataPathDelay(~allNaNIndices);
        timing.slack=timing.slack(~allNaNIndices);
        timing.logic=timing.logic(~allNaNIndices);
        timing.route=timing.route(~allNaNIndices);
        timing.levels=timing.levels(~allNaNIndices);
        if this.testMode
            timing.fmax=timing.fmax(~allNaNIndices);
        end


        if all(isinf(timing.slack))
            [~,maxDataDelayIndex]=max(timing.dataPathDelay(~isinf(timing.dataPathDelay)));
        else
            [~,maxDataDelayIndex]=max(timing.dataPathDelay(~isinf(timing.slack)&~isinf(timing.dataPathDelay)));
        end


        if isempty(maxDataDelayIndex)
            timing.dataPathDelay=timing.dataPathDelay(1);
            timing.logic=timing.logic(1);
            timing.route=timing.route(1);
            timing.slack=timing.slack(1);
            timing.levels=timing.levels(1);
            if this.testMode&&isinf(timing.slack)
                timing.fmax=timing.fmax(1);
            end
        else
            timing.dataPathDelay=timing.dataPathDelay(maxDataDelayIndex);
            timing.logic=timing.logic(maxDataDelayIndex);
            timing.route=timing.route(maxDataDelayIndex);
            timing.slack=timing.slack(maxDataDelayIndex);
            timing.levels=timing.levels(maxDataDelayIndex);



            if this.testMode&&isinf(timing.slack)
                timing.fmax=timing.fmax(maxDataDelayIndex);
            end
        end



        if this.testMode&&~isinf(timing.slack)&&~isempty(timing.clkPeriod)
            timing.fmax=1000/(timing.clkPeriod-timing.slack);
        end
    end





    if this.readResources
        if strcmpi(stage,'Synthesis')

            [metadata.UtilReportFileName,metadata.UtilReportFileTimestamp]=systemFindUnique(this,[this.dutName,'_utilization_synth.rpt'],'Xilinx Utilization Design Information file','Please ensure that you have performed the "Run Synthesis" step in the HDL Workflow Advisor before parsing the results.');
        else

            [metadata.UtilReportFileName,metadata.UtilReportFileTimestamp]=systemFindUnique(this,[this.dutName,'_utilization_placed.rpt'],'Xilinx Utilization Design Information file','Please ensure that you have performed the "Run Implementation" step in the HDL Workflow Advisor before parsing the results.');
        end

        fh_impl=fopen(metadata.UtilReportFileName,'r');









        dutE='\|\s+Design\s+:\s+(\w+)';
        synthToolE='\|\s+Tool Version\s+:\s*(Vivado)?\s+([a-zA-z0-9\(\):. ]*)';
        chipNameE='\|\s+Device\s+:\s+([a-zA-Z0-9\-]*)';


























        metadata.RAMsStr='Block RAM Tile';
        metadata.DSPsStr='DSPs';
        metadata.DSP58Str='DSP58';
        metadata.URAMsStr='URAM';

        DSPsE=['\|\s+',metadata.DSPsStr,'\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+'];
        DSP58E=['\|\s+',metadata.DSP58Str,'\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+'];
        BlockRamE=['\|\s+',metadata.RAMsStr,'\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+'];
        UltraRamE=['\|\s+',metadata.URAMsStr,'\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+'];

        slicesE='\|\s+(Slice|CLB)\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+';
        lutsE='\|\s+(Slice\s+LUTs|CLB\s+LUTs)(\*)?\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+';
        sliceRegsE='\|\s+(Slice\s+Registers|CLB\s+Registers)\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+\|\s+([0-9,.]*)\s+';




        while~feof(fh_impl)
            line=fgetl(fh_impl);





            l=regexp(line,dutE,'tokens');
            if~isempty(l)&&isempty(metadata.dut)
                metadata.dut=l{1}{1};
            end





            l=regexp(line,synthToolE,'tokens');
            if~isempty(l)&&isempty(metadata.synthTool)
                if isempty(l{1}{1})
                    error('HDLReadStatistics:WorkflowMismatch',['The logs in the target directory: ''',strrep(this.targetDir,'\','\\'),''' were made using unsupported synthesis tool. Please rerun the synthesis using ''Xilinx Vivado'' and provide the corresponding target directory.']);
                end

                metadata.synthTool=l{1}{2};
            end





            l=regexp(line,chipNameE,'tokens');
            if~isempty(l)&&isempty(metadata.chipName)
                metadata.chipName=l{1}{1};

                if isempty(metadata.chipSpeed)
                    metadata.chipSpeed=metadata.chipName(end-1:end);
                end
                metadata.chipName(end-1:end)=[];
            end





            l=regexp(line,slicesE,'tokens');
            if~isempty(l)&&isnan(synarea.slices)
                metadata.slicesStr=l{1}{1};
                synarea.slices=str2double(l{1}{2});
                synarea.maxSlices=str2double(l{1}{4});
            end




            l=regexp(line,sliceRegsE,'tokens');
            if~isempty(l)&&isnan(synarea.sliceRegs)
                metadata.sliceRegsStr=l{1}{1};
                synarea.sliceRegs=str2double(l{1}{2});
                synarea.maxSliceRegs=str2double(l{1}{4});
            end





            l=regexp(line,lutsE,'tokens');
            if~isempty(l)&&isnan(synarea.luts)
                metadata.lutsStr=l{1}{1};
                synarea.luts=str2double(l{1}{3});
                synarea.maxLuts=str2double(l{1}{5});
            end





            l=regexp(line,BlockRamE,'tokens');
            if~isempty(l)&&isnan(synarea.RAMs)
                synarea.RAMs=str2double(l{1}{1});
                synarea.maxRAMs=str2double(l{1}{3});
            end





            l=regexp(line,DSPsE,'tokens');
            if~isempty(l)&&isnan(synarea.DSPs)
                synarea.DSPs=str2double(l{1}{1});
                synarea.maxDSPs=str2double(l{1}{3});
                break;
            end





            l=regexp(line,DSP58E,'tokens');
            if~isempty(l)&&isnan(synarea.DSP58)
                synarea.DSP58=str2double(l{1}{1});
                synarea.maxDSP58=str2double(l{1}{3});
                break;
            end





            l=regexp(line,UltraRamE,'tokens');
            if~isempty(l)&&isnan(synarea.URAMs)
                synarea.URAMs=str2double(l{1}{1});
                synarea.maxURAMs=str2double(l{1}{3});
            end
        end
        fclose(fh_impl);

        if isnan(synarea.maxURAMs)
            synarea.URAMs=0;
            synarea.maxURAMs=0;
        end
    end
end

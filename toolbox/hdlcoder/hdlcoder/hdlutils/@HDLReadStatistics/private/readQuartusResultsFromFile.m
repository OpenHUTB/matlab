











function[timing,synarea,metadata]=readQuartusResultsFromFile(this,stage)
    metadata.dut='';
    metadata.synthTool='';
    metadata.chipName='';
    metadata.deviceName='';
    metadata.RPTFileName='';
    metadata.RPTFileTimestamp=0;
    metadata.TQRFileName='';
    metadata.TQRFileTimestamp=0;

    if this.testMode
        metadata.LOGFileName='';
        metadata.LOGFileTimestamp=0;
        metadata.latencyFileName='';
        metadata.latencyFileTimeStamp=0;
    end

    timing.slack=NaN;
    timing.dataDelay=NaN;

    metadata.slackStr='';
    metadata.dataDelayStr='';

    timing.fmax=NaN;
    timing.latency=NaN;

    synarea.ALMs=NaN;
    synarea.LABs=NaN;
    synarea.M9ks=NaN;
    synarea.M10ks=NaN;
    synarea.M20ks=NaN;
    synarea.M144ks=NaN;
    synarea.FloatDSPs=NaN;
    synarea.FixedDSPs=NaN;
    synarea.DSPs=NaN;

    metadata.ALMsStr='';
    metadata.LABsStr='';
    metadata.M9KsStr='';
    metadata.M10KsStr='';
    metadata.M20KsStr='';
    metadata.M144KsStr='';
    metadata.FloatDSPsStr='';
    metadata.FixedDSPsStr='';
    metadata.DSPsStr='';

    synarea.combALUT=NaN;
    synarea.memALUT=NaN;
    synarea.logicReg=NaN;

    metadata.combALUTStr='';
    metadata.memALUTStr='';
    metadata.logicRegStr='';

    synarea.MaxALMs=NaN;
    synarea.MaxLABs=NaN;
    synarea.MaxM9ks=NaN;
    synarea.MaxM10ks=NaN;
    synarea.MaxM20ks=NaN;
    synarea.MaxM144ks=NaN;
    synarea.MaxDSPs=NaN;
    synarea.MaxlogicReg=NaN;





    if this.testMode&&this.readTiming

        [metadata.latencyFileName,metadata.latencyFileTimeStamp]=systemFindUnique(this,'hdlcodegenstatus.mat','the generated Latency File','');

        cg_results=load(metadata.latencyFileName);
        timing.latency=cg_results.Latency;
    end





    if this.readResources
        if strcmpi(stage,'Synthesis')||strcmpi(stage,'Map')


            [metadata.RPTFileName,metadata.RPTFileTimestamp]=systemFindUnique(this,[this.dutName,'_quartus.map.rpt'],'Altera Analysis & Synthesis Report file','Please ensure that you have run "Perform Logic Synthesis" step in the HDL Workflow Advisor before parsing the results.');

            fh0=fopen(metadata.RPTFileName,'r');










            dutE='Analysis\s+&\s+Synthesis\s+report\s+for\s+(\w+)_quartus';
            synthToolE='(Quartus)?\s+([a-zA-Z0-9./ ]*)';
            chipFamilyE=';\s+Family\s+;\s+([a-zA-Z0-9 ]*)\s+;';
            deviceE=';\s+Device\s+;\s+(\w+)\s+;';































            almE=';\s+(Estimate\s*of\s*Logic\s*utilization\s*\(ALMs\s*needed\)|Estimated\s*Total\s*logic\s*elements)\s+;\s+([0-9,.]*)\s+';

            combALUTE=';\s+(--)?\s*(Combinational\s*ALUT\s*usage\s*for\s*logic|Combinational\s*ALUTs)\s+;\s+([0-9,.]*)\s+';
            LUTE1=';\s+-- normal mode\s+;\s*([0-9,.]*)\s+';
            LUTE2=';\s+-- arithmetic mode\s+;\s*([0-9,.]*)\s+';

            memALUTE=';\s+--\s*(Memory\s*ALUTs)\s+;\s+([0-9,.]*)\s+';

            logicRegE=';\s+(--)?\s*(Dedicated\s*logic\s*registers)\s+;\s*([0-9,.]*)\s+';

            FloatDSPsE=';\s+--\s*Total\s*(Floating\s*Point\s*DSP\s*Blocks)\s+;\s+([0-9,.]*)\s+';
            FixedDSPsE=';\s+--\s*Total\s*(Fixed\s*Point\s*DSP\s*Blocks)\s+;\s+([0-9,.]*)\s+';
            DSPsE=';\s+(Total)?\s*(DSP\s*Blocks|DSP\s*block\s*18-bit\s*elements|Embedded\s*Multiplier\s*9-bit\s*elements)\s+;\s+([0-9,.]*)\s+';

            readLUTs=false;




            while~feof(fh0)
                line=fgetl(fh0);





                l=regexp(line,dutE,'tokens');
                if~isempty(l)
                    metadata.dut=l{1}{1};

                    fgetl(fh0);
                    line=fgetl(fh0);

                    l=regexp(line,synthToolE,'tokens');
                    if isempty(l{1}{1})
                        error('HDLReadStatistics:WorkflowMismatch',['The logs in the target directory: ''',strrep(this.targetDir,'\','\\'),''' were made using unsupported synthesis tool. Please rerun the synthesis using ''Altera QUARTUS II'' and provide the corresponding target directory.']);
                    end

                    metadata.synthTool=strtrim(l{1}{2});
                end





                l=regexp(line,chipFamilyE,'tokens');
                if~isempty(l)&&isempty(metadata.chipName)
                    metadata.chipName=strtrim(l{1}{1});
                end





                l=regexp(line,deviceE,'tokens');
                if~isempty(l)&&isempty(metadata.deviceName)
                    metadata.deviceName=l{1}{1};
                end





                l=regexp(line,almE,'tokens');
                if~isempty(l)&&isnan(synarea.ALMs)
                    metadata.ALMsStr=l{1}{1};
                    synarea.ALMs=str2double(l{1}{2});
                end





                l=regexp(line,memALUTE,'tokens');
                if~isempty(l)&&isnan(synarea.memALUT)
                    metadata.memALUTStr=l{1}{1};
                    synarea.memALUT=str2double(l{1}{2});
                end





                l=regexp(line,combALUTE,'tokens');
                if~isempty(l)&&isnan(synarea.combALUT)
                    metadata.combALUTStr=l{1}{2};
                    synarea.combALUT=str2double(l{1}{3});
                end





                l=regexp(line,LUTE1,'tokens');
                if~isempty(l)&&readLUTs
                    if isnan(synarea.combALUT)
                        synarea.combALUT=str2double(l{1}{1});
                    else
                        synarea.combALUT=synarea.combALUT+str2double(l{1}{1});
                        readLUTs=false;
                    end
                end

                l=regexp(line,LUTE2,'tokens');
                if~isempty(l)&&readLUTs
                    if isnan(synarea.combALUT)
                        synarea.combALUT=str2double(l{1}{1});
                    else
                        synarea.combALUT=synarea.combALUT+str2double(l{1}{1});
                        readLUTs=false;
                    end
                end

                if contains(line,'; Logic elements by mode')&&isnan(synarea.combALUT)
                    metadata.combALUTStr='Logic elements';
                    readLUTs=true;
                end





                l=regexp(line,logicRegE,'tokens');
                if~isempty(l)&&isnan(synarea.logicReg)
                    metadata.logicRegStr=l{1}{2};
                    synarea.logicReg=str2double(l{1}{3});
                end





                l=regexp(line,FixedDSPsE,'tokens');
                if~isempty(l)&&isnan(synarea.FixedDSPs)
                    metadata.FixedDSPsStr=l{1}{1};
                    synarea.FixedDSPs=str2double(l{1}{2});
                end

                l=regexp(line,FloatDSPsE,'tokens');
                if~isempty(l)&&isnan(synarea.FloatDSPs)
                    metadata.FloatDSPsStr=l{1}{1};
                    synarea.FloatDSPs=str2double(l{1}{2});
                end

                l=regexp(line,DSPsE,'tokens');
                if~isempty(l)&&isnan(synarea.DSPs)
                    metadata.DSPsStr=l{1}{2};
                    synarea.DSPs=str2double(l{1}{3});
                end
            end
            fclose(fh0);

        else


            [metadata.RPTFileName,metadata.RPTFileTimestamp]=systemFindUnique(this,[this.dutName,'_quartus.fit.rpt'],'Altera Fitter Report file','Please ensure that you have run "Perform Place and Route" step in the HDL Workflow Advisor before parsing the results.');

            fh0=fopen(metadata.RPTFileName,'r');










            dutE='Fitter\s+report\s+for\s+(\w+)_quartus';
            synthToolE='(Quartus)?\s+([a-zA-Z0-9./ ]*)';
            chipFamilyE=';\s+Family\s+;\s+([a-zA-Z0-9 ]*)\s+;';
            deviceE=';\s+Device\s+;\s+(\w+)\s+;';


















































            almE=';\s+(Logic\s*utilization\s*\(ALMs\s*needed\s*/\s*total\s*ALMs\s*on\s*device\)|ALMs:\s+partially\s+or\s+completely\s+used|Total\s*logic\s*elements)\s+;\s+([0-9,.]*)\s*/\s*([0-9,.]*)\s*';

            labsE=';\s+Total\s*(LABs:\s*partially\s*or\s*completely\s*used)\s+;\s+([0-9,.]*)\s*/\s*([0-9,.]*)\s*';

            RAMsE_version20k=';\s+(M20K\s*blocks|M20Ks)\s+;\s+([0-9,.]*)\s*/\s*([0-9,.]*)\s*';
            RAMsE_version10k=';\s+(M10K\s*blocks|M10Ks)\s+;\s+([0-9,.]*)\s*/\s*([0-9,.]*)\s*';
            RAMsE_version144k=';\s+(M144K\s*blocks|M144Ks)\s+;\s+([0-9,.]*)\s*/\s*([0-9,.]*)\s*';
            RAMsE_version9k=';\s+(M9K\s*blocks|M9Ks)\s+;\s+([0-9,.]*)\s*/\s*([0-9,.]*)\s*';

            combALUTE=';\s+(--)?\s*(Combinational\s*ALUT\s*usage\s*for\s*logic|Combinational\s*ALUTs)\s+;\s+([0-9,.]*)\s+';
            memALUTE=';\s+(--)?\s*(Memory\s*ALUT\s*usage|Memory\s*ALUTs)\s+;\s+([0-9,.]*)\s+';
            LUTE1=';\s+-- normal mode\s+;\s*([0-9,.]*)\s+';
            LUTE2=';\s+-- arithmetic mode\s+;\s*([0-9,.]*)\s+';

            logicRegE=';\s+(--)?\s*(Dedicated\s*logic\s*registers)\s+;\s+([0-9,.]*)\s*(/)?\s*([0-9,.]*)?\s*';
            logicRegOptionalE1=';\s+--\s*Primary\s*logic\s*registers\s+;\s+([0-9,.]*)\s*/\s*([0-9,.]*)\s*';
            logicRegOptionalE2=';\s+--\s*Secondary\s*logic\s*registers\s+;\s+([0-9,.]*)\s*/\s*([0-9,.]*)\s*';

            FloatDSPsE=';\s+--\s*Total\s*(Floating\s*Point\s*DSP\s*Blocks)\s+;\s+([0-9,.]*)\s+';
            FixedDSPsE=';\s+--\s*Total\s*(Fixed\s*Point\s*DSP\s*Blocks)\s+;\s+([0-9,.]*)\s+';
            DSPsE=';\s+(Total)?\s*(DSP\s*Blocks|DSP\s*block\s*18-bit\s*elements|Embedded\s*Multiplier\s*9-bit\s*elements)\s+;\s+([0-9,.]*)\s*/\s*([0-9,.]*)\s*';





            readFlag=false;
            readLUTs=false;




            while~feof(fh0)
                line=fgetl(fh0);





                l=regexp(line,dutE,'tokens');
                if~isempty(l)
                    metadata.dut=l{1}{1};

                    fgetl(fh0);
                    line=fgetl(fh0);

                    l=regexp(line,synthToolE,'tokens');
                    if isempty(l{1}{1})
                        error('HDLReadStatistics:WorkflowMismatch',['The logs in the target directory: ''',strrep(this.targetDir,'\','\\'),''' were made using unsupported synthesis tool. Please rerun the synthesis using ''Altera QUARTUS II'' and provide the corresponding target directory.']);
                    end

                    metadata.synthTool=strtrim(l{1}{2});
                end





                l=regexp(line,chipFamilyE,'tokens');
                if~isempty(l)&&isempty(metadata.chipName)
                    metadata.chipName=strtrim(l{1}{1});
                end





                l=regexp(line,deviceE,'tokens');
                if~isempty(l)&&isempty(metadata.deviceName)
                    metadata.deviceName=l{1}{1};
                end


                if contains(line,'; Fitter Resource Usage Summary')
                    readFlag=true;
                elseif contains(line,'; Fitter Partition Statistics')
                    readFlag=false;
                end




                l=regexp(line,almE,'tokens');
                if~isempty(l)&&isnan(synarea.ALMs)
                    metadata.ALMsStr=l{1}{1};
                    synarea.ALMs=str2double(l{1}{2});
                    synarea.MaxALMs=str2double(l{1}{3});
                end




                l=regexp(line,labsE,'tokens');
                if~isempty(l)&&isnan(synarea.LABs)
                    metadata.LABsStr=l{1}{1};
                    synarea.LABs=str2double(l{1}{2});
                    synarea.MaxLABs=str2double(l{1}{3});
                end






                l=regexp(line,RAMsE_version20k,'tokens');
                if~isempty(l)&&readFlag&&isnan(synarea.M20ks)
                    metadata.M20KsStr=l{1}{1};
                    synarea.M20ks=str2double(l{1}{2});
                    synarea.MaxM20ks=str2double(l{1}{3});
                end


                l=regexp(line,RAMsE_version10k,'tokens');
                if~isempty(l)&&readFlag&&isnan(synarea.M10ks)
                    metadata.M10KsStr=l{1}{1};
                    synarea.M10ks=str2double(l{1}{2});
                    synarea.MaxM10ks=str2double(l{1}{3});
                end


                l=regexp(line,RAMsE_version144k,'tokens');
                if~isempty(l)&&readFlag&&isnan(synarea.M144ks)
                    metadata.M144KsStr=l{1}{1};
                    synarea.M144ks=str2double(l{1}{2});
                    synarea.MaxM144ks=str2double(l{1}{3});
                end


                l=regexp(line,RAMsE_version9k,'tokens');
                if~isempty(l)&&readFlag&&isnan(synarea.M9ks)
                    metadata.M9KsStr=l{1}{1};
                    synarea.M9ks=str2double(l{1}{2});
                    synarea.MaxM9ks=str2double(l{1}{3});
                end





                l=regexp(line,combALUTE,'tokens');
                if~isempty(l)&&isnan(synarea.combALUT)
                    metadata.combALUTStr=l{1}{2};
                    synarea.combALUT=str2double(l{1}{3});
                end





                l=regexp(line,memALUTE,'tokens');
                if~isempty(l)&&isnan(synarea.memALUT)
                    metadata.memALUTStr=l{1}{2};
                    synarea.memALUT=str2double(l{1}{3});
                end





                l=regexp(line,LUTE1,'tokens');
                if~isempty(l)&&readLUTs
                    if isnan(synarea.combALUT)
                        synarea.combALUT=str2double(l{1}{1});
                    else
                        synarea.combALUT=synarea.combALUT+str2double(l{1}{1});
                        readLUTs=false;
                    end
                end

                l=regexp(line,LUTE2,'tokens');
                if~isempty(l)&&readLUTs
                    if isnan(synarea.combALUT)
                        synarea.combALUT=str2double(l{1}{1});
                    else
                        synarea.combALUT=synarea.combALUT+str2double(l{1}{1});
                        readLUTs=false;
                    end
                end

                if contains(line,'; Logic elements by mode')&&isnan(synarea.combALUT)
                    metadata.combALUTStr='Logic elements';
                    readLUTs=true;
                end





                l=regexp(line,logicRegE,'tokens');
                if~isempty(l)&&isnan(synarea.logicReg)
                    metadata.logicRegStr=l{1}{2};
                    synarea.logicReg=str2double(l{1}{3});

                    if~isempty(l{1}{5})
                        synarea.MaxlogicReg=str2double(l{1}{5});
                    else
                        fgetl(fh0);

                        line=fgetl(fh0);
                        l=regexp(line,logicRegOptionalE1,'tokens');
                        synarea.MaxlogicReg=str2double(l{1}{2});

                        line=fgetl(fh0);
                        l=regexp(line,logicRegOptionalE2,'tokens');
                        synarea.MaxlogicReg=synarea.MaxlogicReg+str2double(l{1}{2});
                    end
                end





                l=regexp(line,FixedDSPsE,'tokens');
                if~isempty(l)&&isnan(synarea.FixedDSPs)&&readFlag
                    metadata.FixedDSPsStr=l{1}{1};
                    synarea.FixedDSPs=str2double(l{1}{2});
                end

                l=regexp(line,FloatDSPsE,'tokens');
                if~isempty(l)&&isnan(synarea.FloatDSPs)&&readFlag
                    metadata.FloatDSPsStr=l{1}{1};
                    synarea.FloatDSPs=str2double(l{1}{2});
                end

                l=regexp(line,DSPsE,'tokens');
                if~isempty(l)&&isnan(synarea.DSPs)&&readFlag
                    metadata.DSPsStr=l{1}{2};
                    synarea.DSPs=str2double(l{1}{3});
                    synarea.MaxDSPs=str2double(l{1}{4});
                end
            end
            fclose(fh0);
        end
    end











    if this.readTiming
        fh=[];

        if strcmpi(stage,'Map')

            [metadata.TQRFileName,metadata.TQRFileTimestamp]=systemFindUnique(this,[this.dutName,'_preroute.tqr'],'Altera Pre-Route Timing Report file','Please ensure that you have run "Perform Logic Mapping" step in the HDL Workflow Advisor before parsing the results.');

            fh=fopen(metadata.TQRFileName,'r');

        elseif strcmpi(stage,'PAR')

            [metadata.TQRFileName,metadata.TQRFileTimestamp]=systemFindUnique(this,[this.dutName,'_postroute.tqr'],'Altera Post-Route Timing Report file','Please ensure that you have run "Perform Place and Route" step in the HDL Workflow Advisor before parsing the results.');

            fh=fopen(metadata.TQRFileName,'r');
        end

        if~isempty(fh)









            metadata.slackStr='Slack';
            metadata.dataDelayStr='Data Delay';

            slackStartE=[';\s+',metadata.slackStr,'\s+;\s+From\s+Node\s+;\s+To\s+Node\s+;\s+Launch\s+Clock\s+;\s+Latch\s+Clock\s+;\s+Relationship\s+;\s+Clock\s+Skew\s+;\s+',metadata.dataDelayStr,'\s+;'];
            slackE=';\s+([-0-9,.]*)\s+;.*;.*;.*;.*;.*;.*;\s+([0-9,.]*)\s+;';
            slackEndE='\+-*\+-*\+-*\+-*\+-*\+-*\+-*\+';




            readFlag=false;

            while~feof(fh)
                line=fgetl(fh);

                l=regexp(line,slackStartE,'match');
                if~isempty(l)
                    fgetl(fh);
                    readFlag=true;
                end

                l=regexp(line,slackEndE,'tokens');
                if~isempty(l)&&readFlag
                    break
                end

                l=regexp(line,slackE,'tokens');
                if~isempty(l)&&readFlag&&~(timing.dataDelay>=str2double(l{1}{2}))
                    timing.slack=str2double(l{1}{1});
                    timing.dataDelay=str2double(l{1}{2});
                end
            end
            fclose(fh);
        end
    end









    if this.readTiming&&this.testMode
        fh2=[];

        if strcmpi(stage,'Map')

            [metadata.LOGFileName,metadata.LOGFileTimestamp]=systemFindUnique(this,'workflow_task_PerformMapping.log','Altera Perform Mapping Workflow Log file','Please ensure that you have run "Perform Logic Mapping" step in the HDL Workflow Advisor before parsing the results.');

            fh2=fopen(metadata.LOGFileName,'r');

        elseif strcmpi(stage,'PAR')

            [metadata.LOGFileName,metadata.LOGFileTimestamp]=systemFindUnique(this,'workflow_task_PerformPlaceAndRoute.log','Altera Place And Route Workflow Log file','Please ensure that you have run "Perform Place and Route" step in the HDL Workflow Advisor before parsing the results.');

            fh2=fopen(metadata.LOGFileName,'r');
        end

        if~isempty(fh2)










            fmaxE='\s+Fmax\s+Fmax\s+Clock\s+Note';
            fmaxE2='\s+([0-9,.]*)\s+MHz\s+([0-9,.]*)\s+MHz\s+clk';


            while~feof(fh2)
                line=fgetl(fh2);


                l=regexp(line,fmaxE,'match');
                if~isempty(l)&&isnan(timing.fmax)
                    fgetl(fh2);
                    line=fgetl(fh2);
                    l=regexp(line,fmaxE2,'tokens');
                    timing.fmax=str2double(l{1}(2));
                    break;
                end
            end
            fclose(fh2);
        end
    end
end
classdef SynthesisDriver<handle





    properties(Access=private)
        hHDLDriver;
        hTopFunctionName;
        hTopScriptName;
        hEMLHDLConfig;
    end

    methods


        function this=SynthesisDriver(hdlConfig,hdlDriver)

            this.hHDLDriver=hdlDriver;
            this.hEMLHDLConfig=hdlConfig;

            this.hTopFunctionName=hdlConfig.DesignFunctionName;
            this.hTopScriptName=hdlConfig.TestBenchScriptName;
        end



        function hdlDrv=getHDLDriver(~)
            hdlDrv=this.hHDLDriver;
        end


        function createProject(this,dumpResults)

            if~this.hEMLHDLConfig.GenerateHDLCode
                hdldisp(message('hdlcoder:hdldisp:SkipSynthPrjCrOnOnHDLCodegenFail'));
                return;
            end

            hdlDrv=this.hHDLDriver;




            [~,topFcnName]=fileparts(this.hTopFunctionName);

            if strcmpi(this.hEMLHDLConfig.Workflow,'Generic ASIC/FPGA')
                hdi=downstream.integration('Model',topFcnName,'HDLDriver',hdlDrv,'isMLHDLC',true);
                hdi.isMLHDLC=true;
                tool=this.hEMLHDLConfig.SynthesisTool;
                family=this.hEMLHDLConfig.SynthesisToolChipFamily;
                device=this.hEMLHDLConfig.SynthesisToolDeviceName;
                pkg=this.hEMLHDLConfig.SynthesisToolPackageName;
                speed=this.hEMLHDLConfig.SynthesisToolSpeedValue;


                hdi.set('Tool',tool);
                hdi.set('Family',family);
                hdi.set('Device',device);
                hdi.set('Package',pkg);
                hdi.set('Speed',speed);
            elseif strcmpi(this.hEMLHDLConfig.Workflow,'IP Core Generation')
                error(message('hdlcoder:matlabhdlcoder:IPCoreWorkflowSynthesisAndPARNotSupported'));
            else
                hdi=hdlDrv.DownstreamIntegrationDriver;
            end




            filePathStr=this.hEMLHDLConfig.AdditionalSynthesisProjectFiles;
            hdi.setCustomHDLFile(filePathStr);

            toolprjdir=hdi.getRelativeFPGADir;
            gpp=fullfile(hdlDrv.hdlGetCodegendir,toolprjdir);
            hdi.setProjectPath(gpp);

            disp(' ');
            hdldisp(message('hdlcoder:hdldisp:SynthProjectCreate',topFcnName));
            [status,msg]=hdi.run('CreateProject');

            if(dumpResults)
                disp(msg);
            end

            if status
                hdldisp(message('hdlcoder:hdldisp:SynthProjectSuccess'));
            else
                hdldisp(message('hdlcoder:hdldisp:SynthProjectFailure'));
            end

            disp(' ');
        end


        function runSynthesis(this,dumpResults)
            if strcmpi(this.hEMLHDLConfig.Workflow,'IP Core Generation')
                error(message('hdlcoder:matlabhdlcoder:IPCoreWorkflowSynthesisAndPARNotSupported'));
            end
            if~this.hEMLHDLConfig.GenerateHDLCode
                hdldisp(message('hdlcoder:hdldisp:SkipSynthOnHDLCodegenFail'));
                return;
            end

            hdlDrv=this.hHDLDriver;

            if strcmpi(this.hEMLHDLConfig.Workflow,'High Level Synthesis')
                hdi=downstream.DownstreamIntegrationDriver(this.hTopFunctionName,false,false,'',downstream.queryflowmodesenum.NONE,hdlDrv,true);
                hdi.set('Workflow',this.hEMLHDLConfig.Workflow);
                hdi.set('Tool',this.hEMLHDLConfig.SynthesisTool);
            else
                hdi=hdlDrv.DownstreamIntegrationDriver;
            end

            [~,topFcnName]=fileparts(this.hTopFunctionName);

            disp(' ');
            hdldisp(message('hdlcoder:hdldisp:SynthRun',topFcnName));

            if strcmpi(hdi.getToolName(),'Xilinx Vivado')
                [status,msg1,~,hardwareResults]=hdi.run({'Synthesis','PostMapTiming'});
                skipTiming=false;
            else
                [status,msg1,~,hardwareResults]=hdi.run({'Synthesis'});
                skipTiming=true;
            end

            if~hdi.isHLSWorkflow

                synResultsFileName=[hdlgetparameter('module_prefix'),topFcnName,'_syn_results.txt'];
                fullPath=fullfile(hdi.getProjectPath,synResultsFileName);
                fid=fopen(fullPath,'w');
                if fid==-1
                    error(message('hdlcoder:matlabhdlcoder:openfile',synResultsFileName));
                end
                fprintf(fid,'%s',msg1);
                fclose(fid);

                msg=sprintf('%s',msg1);
                hdldisp(message('hdlcoder:hdldisp:SynthGenReport',hdlgetfilelink(fullPath)));
            end

            if status
                hdldisp(message('hdlcoder:hdldisp:SynthSuccess'));

                this.displayHardwareResults(hardwareResults,skipTiming);
            else
                error(message('hdlcoder:matlabhdlcoder:hdlsynthfailure'));
            end

            if(dumpResults)
                disp(msg);%#ok<DSPS>
            end

            disp(' ');
        end



        function runPAR(this,dumpResults)

            hdlDrv=this.hHDLDriver;

            hdi=hdlDrv.DownstreamIntegrationDriver;

            if strcmpi(hdi.getToolName(),'Xilinx Vivado')||strcmpi(hdi.getToolName(),'Microchip Libero SoC')
                this.runImplementation(dumpResults);
            else
                this.runPARDefault(dumpResults);
            end

        end


        function runPARDefault(this,dumpResults)
            if strcmpi(this.hEMLHDLConfig.Workflow,'IP Core Generation')
                error(message('hdlcoder:matlabhdlcoder:IPCoreWorkflowSynthesisAndPARNotSupported'));
            end
            if~this.hEMLHDLConfig.GenerateHDLCode
                hdldisp(message('hdlcoder:hdldisp:SkipPAROnHDLCodegenFail'));
                return;
            end

            hdlDrv=this.hHDLDriver;

            hdi=hdlDrv.DownstreamIntegrationDriver;

            if strcmpi(hdi.getToolName(),'Xilinx Vivado')
                error(message('hdlcoder:matlabhdlcoder:hdlsynthfailure'))
            end

            [~,topFcnName]=fileparts(this.hTopFunctionName);

            hdldisp(message('hdlcoder:hdldisp:SynthPAR',topFcnName));
            [result1,logTxt1]=hdi.run({'Map','PostMapTiming'});
            if result1
                [result2,logTxt2,~,hardwareResults]=hdi.run({'PAR','PostPARTiming'});
                status=result1&&result2;
                msg=sprintf('%s\n%s',logTxt1,logTxt2);
            else
                status=result1;
                msg=logTxt1;
            end

            if status
                hdldisp(message('hdlcoder:hdldisp:SynthPARSuccess'));

                this.displayHardwareResults(hardwareResults,false);
            else
                error(message('hdlcoder:hdldisp:SynthPARFailure'));
            end

            if(dumpResults)
                disp(msg);
            end

            disp(' ');
        end


        function runImplementation(this,dumpResults)
            if strcmpi(this.hEMLHDLConfig.Workflow,'IP Core Generation')
                error(message('hdlcoder:matlabhdlcoder:IPCoreWorkflowSynthesisAndPARNotSupported'));
            end
            if~this.hEMLHDLConfig.GenerateHDLCode
                hdldisp(message('hdlcoder:hdldisp:SkipImplOnOnHDLCodegenFail'));
                return;
            end

            hdlDrv=this.hHDLDriver;

            hdi=hdlDrv.DownstreamIntegrationDriver;
            [~,topFcnName]=fileparts(this.hTopFunctionName);

            hdldisp(message('hdlcoder:hdldisp:SynthPAR',topFcnName));
            [result2,logTxt2,~,hardwareResults]=hdi.run({'Implementation','PostPARTiming'});
            status=result2;
            msg=logTxt2;

            if status
                hdldisp(message('hdlcoder:hdldisp:SynthPARSuccess'));

                this.displayHardwareResults(hardwareResults,false);
            else
                error(message('hdlcoder:hdldisp:SynthPARFailure'));
            end

            if(dumpResults)
                disp(msg);
            end

            disp(' ');
        end



        function runReportCriticalPath(this)

            if strcmpi(this.hEMLHDLConfig.SynthesisTool,'Xilinx Vivado')
                warning(message('hdlcoder:backannotate:NotSupportedTargetTool'));
                return;
            end
            if this.hEMLHDLConfig.ReportCriticalPath
                hDI=this.hHDLDriver.DownstreamIntegrationDriver;
                isCriticalPathSourcePreroute=strcmpi(this.hEMLHDLConfig.CriticalPathSource,'Pre-route');
                if isCriticalPathSourcePreroute
                    timingFile=hDI.getPostMapTimingReportPath;
                else
                    timingFile=hDI.getPostPARTimingReportPath;
                end

                if(isequal(this.hEMLHDLConfig.SynthesisTool,'Xilinx ISE'))

                    parserFactory=BA.Parser.XilinxFactory;

                    annotationStrategy=BA.Algorithm.pirInterpolationStrategy(true,this.hHDLDriver.hdlGetCodegendir,this.hTopFunctionName,true);
                else

                    parserFactory=BA.Parser.AlteraFactory;

                    annotationStrategy=BA.Algorithm.pirInterpolationWithBlkTypesStrategy(true,this.hHDLDriver.hdlGetCodegendir,this.hTopFunctionName,true);
                end

                CP_IR=parserFactory.makeCP_IR(timingFile);

                if CP_IR.getNumCPs==0

                    warning(message('hdlcoder:backannotate:EmptyCP'));
                else





                    CP_IR.setStrategy(annotationStrategy);
                    annotationStrategy.setTargetModel('Original');
                    annotationStrategy.applyPath(CP_IR,1,'',0,1,1,1,0);






                end
            end
        end


        function doIt(this,runPAR)

            if~this.hEMLHDLConfig.GenerateHDLCode
                hdldisp(message('hdlcoder:hdldisp:SkipSynthOnHDLCodegenFail'));
                return;
            end

            hdlDrv=this.hHDLDriver;
            this.runSynthesis(hdlDrv,runPAR);

        end

        function displayHardwareResults(this,hardwareResults,skipTiming)%#ok<INUSL>

            if~isempty(hardwareResults)

                resourceVariables=hardwareResults.ResourceVariables;
                usage=hardwareResults.ResourceData;
                availableResources=hardwareResults.AvailableResources;
                utilization=hardwareResults.Utilization;

                resourceFile=hardwareResults.ResourceFile;


                disp([newline,message('hdlcoder:hdldisp:ParsedResourceReport',hdlgetfilelink(resourceFile)).getString(),newline]);

                disp(table(resourceVariables,usage,availableResources,utilization,...
                'VariableNames',{'Resource','Usage','Available','Utilization (%)'}));

                if~skipTiming

                    timingVariables=hardwareResults.TimingVariables;
                    timingData=hardwareResults.TimingData;

                    timingFile=hardwareResults.TimingFile;


                    disp([newline,message('hdlcoder:hdldisp:ParsedTimingReport',hdlgetfilelink(timingFile)).getString(),newline]);

                    disp(table(timingVariables,timingData,'VariableNames',{'Timing','Value'}));
                end
            end
        end
    end
end




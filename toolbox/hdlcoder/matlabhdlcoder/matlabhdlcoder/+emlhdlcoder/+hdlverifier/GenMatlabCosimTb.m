


classdef GenMatlabCosimTb<emlhdlcoder.hdlverifier.GenMatlabTb

    properties(Constant)
        FeatureName=message('hdlcoder:hdlverifier:Cosim').getString;
        FeatureAbbrev='cosim';
        FeatureFullName=message('hdlcoder:hdlverifier:CosimFull').getString;
    end

    properties(Abstract,Constant)
        SimulatorName;
    end
    properties(Access=protected)
        isBatchMode;
    end

    methods
        function this=GenMatlabCosimTb(cgInfo,runMode)
            this=this@emlhdlcoder.hdlverifier.GenMatlabTb(cgInfo);
            this.isBatchMode=strcmpi(runMode,'Batch');
        end



        function generateFeatureSpecificFiles(this)
            generateLaunchScript(this);
        end



        function generateLaunchScript(this)

            launchCmdFcn=getTclCmdFcnName(this);
            tclPath=getTclFileWithPath(this);
            hdldisp(message('hdlcoder:hdlverifier:DispGenerateScript',this.SimulatorName,hdlgetfilelink(tclPath)));

            generator=emlhdlcoder.hdlverifier.GenMCode(tclPath);
            generator.addComment(['Auto generated function to compile/launch ',this.SimulatorName,' simulator']);
            generator.addComment('');
            generator.addGeneratedHeader;
            generator.addNewLine;


            generator.addFuncDecl(launchCmdFcn);


            tclcmdstr=getTclCmds(this);

            launchCmd=this.getLaunchCmd;
            switch launchCmd
            case 'CUSTOM_LAUNCHER'

                str=this.getCustomCosimLaunchCmd(tclcmdstr);
                generator.appendCode(str);

            otherwise
                generator.addComment('Make sure there is no HDL simulator using the communication channel');
                generator.appendCode('pid = pingHdlSim(1);');

                generator.addIfStatement('pid > 0');
                generator.appendCode('error(''hdlverifier:mlhdlc:HDLServerExist'',''Another instance of HDL simulator exists. Close all HDL simulator instances and try again'');');
                generator.addEndStatement;

                generator.appendCode(['currentdir = cd(''',this.getCodeGenDir,''');']);
                generator.appendCode('onCleanupObj = onCleanup(@() cd(currentdir));');

                generator.addComment('Pre-sim TCL commands');
                generator.appendCode(['tclCmds = { ...',newline,tclcmdstr,'};']);

                generator.addComment('Launch HDL simulator');

                if this.isBatchMode
                    runMode='''Batch''';
                else
                    runMode='''GUI''';
                end
                if this.codeInfo.codegenSettings.DebugLevel

                    commOption=sprintf(',''socketmatlabsysobj'',%s',this.getDebugSocketPort);
                else

                    commOption='';
                end
                generator.appendCode([launchCmd,'(''tclstart'',tclCmds,''runmode'',',runMode,commOption,');']);

                generator.addNewLine;
                generator.addComment('Wait for HDL simulator to ready');
                generator.addExecFunction('disp',['''### Waiting for ',this.SimulatorName,' to start ''']);

                if this.codeInfo.codegenSettings.DebugLevel
                    args={180,sprintf('''%s''',this.getDebugSocketPort)};
                    generator.addExecFunction('pingHdlSim',args);
                else
                    generator.addExecFunction('pingHdlSim',180);
                end
            end

            generator.addNewLine;

        end

        function generateRunScript(this)
            fileName=fullfile(this.projDir,[this.cosimRunScriptName,'.m']);
            hdldisp(message('hdlcoder:hdlverifier:DispCosimExceFcn',hdlgetfilelink(fileName)));

            generator=emlhdlcoder.hdlverifier.GenMCode(fileName);
            generator.addComment(['Auto generated function to execute the generated ',this.FeatureName,' test bench']);
            generator.addComment('');
            generator.addGeneratedHeader;
            generator.addNewLine;

            generator.addFuncDecl(this.cosimRunScriptName);
            generator.addNewLine;

            generator.addComment('Launch HDL simulator');
            generator.addExecFunction('disp',['''### Launching ',this.SimulatorName,' for cosimulation ''']);
            generator.addExecFunction(this.cosimLaunchFuncName);
            generator.addNewLine;

            this.getCommonRunScriptText(generator);
        end

        function generateSysObjInst(this,generator,sysobjVar)

            InputSignalsVar=emlhdlcoder.hdlverifier.getUniqueVarName('InputSignals');
            generator.addAssignVar(InputSignalsVar,getInputSignalNames(this));

            OutputSignalsVar=emlhdlcoder.hdlverifier.getUniqueVarName('OutputSignals');
            generator.addAssignVar(OutputSignalsVar,getOutputSignalNames(this));

            OutputSignedVar=emlhdlcoder.hdlverifier.getUniqueVarName('OutputSigned');
            generator.addAssignVar(OutputSignedVar,getOutputSigned(this));

            OutputFractionLengthsVar=emlhdlcoder.hdlverifier.getUniqueVarName('OutputFractionLengths');
            generator.addAssignVar(OutputFractionLengthsVar,getOutputFractionLengths(this));

            tclPreSimCommand=this.getTclPreSimCommand();
            if~isempty(tclPreSimCommand)
                TCLPreSimulationCommandVar=emlhdlcoder.hdlverifier.getUniqueVarName('TCLPreSimulationCommand');
                generator.addAssignVar(TCLPreSimulationCommandVar,tclPreSimCommand);
                TCLPostSimulationCommandVar=emlhdlcoder.hdlverifier.getUniqueVarName('TCLPostSimulationCommand');
                generator.addAssignVar(TCLPostSimulationCommandVar,'echo "done"');
            end

            PreRunTimeVar=emlhdlcoder.hdlverifier.getUniqueVarName('PreRunTime');
            generator.addAssignVar(PreRunTimeVar,{this.computeResetRunTime(),'ns'});

            SampleTimeVar=emlhdlcoder.hdlverifier.getUniqueVarName('SampleTime');
            generator.addAssignVar(SampleTimeVar,{this.getCosimSampleTime(),'ns'});

            HDLSimulatorVar=emlhdlcoder.hdlverifier.getUniqueVarName('HDLSimulator');
            generator.addAssignVar(HDLSimulatorVar,this.getHDLSimulator());

            crSignals=this.getClockResetSignals();
            crTypes=this.getClockResetTypes();
            crTimes=this.getClockResetTimes();
            xsiData=this.getXSIData();
            if~isempty(crSignals)
                ClockResetSignalsVar=emlhdlcoder.hdlverifier.getUniqueVarName('ClockResetSignals');
                generator.appendCode([ClockResetSignalsVar,' = ',crSignals,';']);
                ClockResetTypesVar=emlhdlcoder.hdlverifier.getUniqueVarName('ClockResetTypes');
                generator.appendCode([ClockResetTypesVar,' = ',crTypes,';']);
                ClockResetTimesVar=emlhdlcoder.hdlverifier.getUniqueVarName('ClockResetTimes');
                generator.appendCode([ClockResetTimesVar,' = ',crTimes,';']);
            end
            if~isempty(xsiData)
                XSIDataVar=emlhdlcoder.hdlverifier.getUniqueVarName('XSIData');
                generator.appendCode([XSIDataVar,'= ',xsiData]);
            end

            generator.appendCode([sysobjVar,' = hdlcosim( ...']);
            generator.addIndent;
            generator.appendCode(['''HDLSimulator'', ',HDLSimulatorVar,', ...']);
            generator.appendCode(['''InputSignals'', ',InputSignalsVar,', ...']);
            generator.appendCode(['''OutputSignals'',',OutputSignalsVar,', ...']);
            generator.appendCode(['''OutputSigned'',',OutputSignedVar,', ...']);
            generator.appendCode(['''OutputFractionLengths'',',OutputFractionLengthsVar,', ...']);
            if~isempty(tclPreSimCommand)
                generator.appendCode(['''TCLPreSimulationCommand'',',TCLPreSimulationCommandVar,', ...']);
                generator.appendCode(['''TCLPostSimulationCommand'',',TCLPostSimulationCommandVar,',...']);
            end
            generator.appendCode(['''PreRunTime'', ',PreRunTimeVar,', ...']);
            if~isempty(crSignals)
                generator.appendCode(['''ClockResetSignals'', ',ClockResetSignalsVar,', ...']);
                generator.appendCode(['''ClockResetTypes'', ',ClockResetTypesVar,', ...']);
                generator.appendCode(['''ClockResetTimes'', ',ClockResetTimesVar,', ...']);
            end
            if~isempty(xsiData)
                generator.appendCode(['''XSIData'', ',XSIDataVar,', ...']);
            end

            if this.codeInfo.codegenSettings.DebugLevel
                cmd=sprintf('''Connection'', {''Socket'',%s}, ...',this.getDebugSocketPort);
                generator.appendCode(cmd);
            else
                generator.appendCode('''Connection'', {''Shared''}, ...');
            end
            generator.appendCode(['''SampleTime'',  ',SampleTimeVar,');']);
            generator.reduceIndent;

        end

        function r=getInputSignalNames(this)
            r=arrayfun(@(x)x.Name,this.codeInfo.hdlDutPortInfo(this.inputDataPortIndx),...
            'UniformOutput',false);
        end
        function r=getOutputSignalNames(this)
            r=arrayfun(@(x)x.Name,this.codeInfo.hdlDutPortInfo(this.outputDataPortIndx),...
            'UniformOutput',false);
        end

        function r=getOutputSigned(this)

            r=arrayfun(@(x)x.TypeInfo.issigned==1,this.codeInfo.hdlDutPortInfo(this.outputDataPortIndx),...
            'UniformOutput',true);
        end
        function r=getOutputFractionLengths(this)

            r=arrayfun(@(x)-x.TypeInfo.binarypoint,this.codeInfo.hdlDutPortInfo(this.outputDataPortIndx),...
            'UniformOutput',true);
        end

        function r=getClockName(this)
            r=this.codeInfo.hdlDutPortInfo(this.clockPortIndx).Name;
        end
        function r=getTimingUnit(~)
            r='ns';
        end
        function r=getClockLowTime(this)
            r=this.codeInfo.codegenSettings.CosimClockLowTime;
        end
        function r=getClockPeriod(this)
            r=this.codeInfo.codegenSettings.CosimClockLowTime+...
            this.codeInfo.codegenSettings.CosimClockHighTime;
        end

        function r=getCosimSampleTime(this)
            r=getClockPeriod(this)*this.codeInfo.baseRateScaling;
        end


        function r=getDutName(this)
            r=this.codeInfo.topName;
        end

        function r=getGoldenMdlDutPath(this)

            r=this.codeInfo.topName;
        end
        function r=getTargetLanguage(this)
            r=this.codeInfo.codegenSettings.TargetLanguage;
        end
        function r=getCodeGenDir(this)
            r=this.codeInfo.targetDir;
        end
        function r=dutHasClock(this)
            r=~isempty(this.clockPortIndx);
        end
        function r=dutHasClockEnable(this)
            r=~isempty(this.clkenPortIndx);
        end
        function r=getClockEnableName(this)
            r=this.codeInfo.hdlDutPortInfo(this.clkenPortIndx).Name;
        end

        function r=getResetLength(this)
            r=this.codeInfo.codegenSettings.CosimResetLength;
        end

        function r=getHoldTime(this)
            r=this.codeInfo.codegenSettings.CosimHoldTime;
        end





        function rLen=computeResetRunTime(this)

            resetLen=getResetLength(this);
            if~dutHasClockEnable(this)
                clkEnDelay=0;
            else
                clkEnDelay=getClockEnableDelay(this);
            end

            rLen=(resetLen+clkEnDelay+1)*getClockPeriod(this);
        end

        function rLen=computeResetLength(this)
            resetLen=getResetLength(this)*getClockPeriod(this);

            clkLowTime=getClockLowTime(this);

            holdTime=getHoldTime(this);

            rLen=(clkLowTime+resetLen+holdTime);
        end

        function r=getClockEnableDelay(this)
            r=this.codeInfo.codegenSettings.CosimClockEnableDelay;
        end

        function r=getResetAssertLevel(this)
            r=this.codeInfo.codegenSettings.ResetAssertedLevel;
        end

        function clkEnHigh=getClockEnableHigh(this)
            clkLowTime=getClockLowTime(this);

            holdTime=getHoldTime(this);

            resetLen=getResetLength(this);

            clkEnDelay=getClockEnableDelay(this);

            t=(resetLen+clkEnDelay)*getClockPeriod(this);

            clkEnHigh=t+clkLowTime+holdTime;
        end
        function r=dutHasReset(this)
            r=~isempty(this.resetPortIndx);
        end
        function r=getResetName(this)
            r=this.codeInfo.codegenSettings.ResetInputPort;
        end


        function tclCmdFcn=getTclCmdFcnName(this)
            tclCmdFcn=this.cosimLaunchFuncName;
        end


        function tclPath=getTclFileWithPath(this)
            tclCmdFcn=this.getTclCmdFcnName;
            tclCmdFileName=[tclCmdFcn,'.m'];
            tclPath=[this.projDir,filesep,tclCmdFileName];
        end

        function isvhdl=isCodingForVhdl(this)
            isvhdl=strcmpi(this.getTargetLanguage,'vhdl');
        end

        function r=getEntityFileNames(this)
            r=this.codeInfo.listOfGeneratedFiles;
        end

        function port=getDebugSocketPort(~)
            port=getenv('HDL_VERIFIER_COSIM_TB_SOCKET');
        end
    end
end





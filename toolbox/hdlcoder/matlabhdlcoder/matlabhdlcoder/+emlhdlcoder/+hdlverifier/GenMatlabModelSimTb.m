


classdef GenMatlabModelSimTb<emlhdlcoder.hdlverifier.GenMatlabCosimTb
    properties(Constant)
        SimulatorName=message('hdlcoder:hdlverifier:ModelSim').getString;
    end

    methods
        function this=GenMatlabModelSimTb(varargin)
            this=this@emlhdlcoder.hdlverifier.GenMatlabCosimTb(varargin{:});
        end


        function cmd=getClockForceCommand(this)
            cmd='';
            if dutHasClock(this)
                clkName=getClockName(this);
                timeMode=getTimingUnit(this);


                clkLowTime=uint64(getClockLowTime(this));
                clkPeriod=uint64(getClockPeriod(this));



                clockLowAt=sprintf('%d%s',0,timeMode);


                clockHighAt=sprintf('%d%s',clkLowTime,timeMode);

                repeatEvery=sprintf('%d%s',clkPeriod,timeMode);

                pattern=sprintf('0 %s, 1 %s -r %s',clockLowAt,clockHighAt,repeatEvery);
                cmd=sprintf('force /%s/%s %s;',this.getDutName,clkName,pattern);
            end
        end

        function cmd=getClockEnableForceCommand(this)
            cmd='';
            if dutHasClockEnable(this)
                clkName=getClockEnableName(this);
                clkEnPath=sprintf('/%s/%s',this.getDutName,clkName);

                timeMode=getTimingUnit(this);

                clockEnHigh=uint64(getClockEnableHigh(this));

                if isClkEnableAtInputDataRate(this)
                    clkPeriod=uint64(getClockPeriod(this));
                    clkenDuration=sprintf('%d%s',clkPeriod,timeMode);
                    repeatEvery=sprintf('%d%s',clkPeriod*this.codeInfo.baseRateScaling,timeMode);

                    clockEnLowAt=sprintf('%d%s',0,timeMode);
                    clockEnHighAt=sprintf('%d%s',clockEnHigh,timeMode);

                    cmd1=sprintf('force %s 0 %s;',clkEnPath,clockEnLowAt);
                    cmd2=sprintf('when {$now == %s} {force %s 1 0%s, 0 %s -r %s;};',...
                    clockEnHighAt,clkEnPath,timeMode,clkenDuration,repeatEvery);

                    cmd=[cmd1,cmd2];
                else

                    clockEnLowAt=sprintf('%d%s',0,timeMode);
                    clockEnHighAt=sprintf('%d%s',clockEnHigh,timeMode);
                    pattern=sprintf('0 %s, 1 %s',clockEnLowAt,clockEnHighAt);
                    cmd=sprintf('force %s %s;',clkEnPath,pattern);
                end
            end
        end

        function cmd=getResetForceCommand(this)
            cmd='';
            if dutHasReset(this)
                timeMode=getTimingUnit(this);







                resetLength=uint64(computeResetLength(this));

                if strcmpi(getResetAssertLevel(this),'ActiveHigh')
                    resetHigh=1;
                    resetLow=0;
                else
                    resetHigh=0;
                    resetLow=1;
                end

                pattern=sprintf('%d 0%s, %d %d%s',resetHigh,timeMode,resetLow,resetLength,timeMode);
                cmd=sprintf('force /%s/%s %s;',this.getDutName,this.getResetName,pattern);
            end
        end

        function cmd=getTclPreSimCommand(this)
            cmd=sprintf('puts "Running Simulink Cosimulation block.";\n');
            cmd=[cmd,' ',sprintf('puts "Chip Name: --> %s";\n',getGoldenMdlDutPath(this))];
            cmd=[cmd,' ',sprintf('puts "Target language: --> %s";\n',getTargetLanguage(this))];
            cmd=[cmd,' ',sprintf('puts "Target directory: --> %s";\n',getCodeGenDir(this))];
            cmd=[cmd,' ',sprintf('puts [clock format [clock seconds]];\n')];


            clkForce=getClockForceCommand(this);
            if dutHasClock(this)&&~isempty(clkForce)
                cmd=[cmd,'# Clock force command;',char(10)];%#ok<I18N_Concatenated_Msg>
                cmd=[cmd,clkForce,char(10)];
            end


            clkEnForce=getClockEnableForceCommand(this);
            if~isempty(clkEnForce)
                cmd=[cmd,'# Clock enable force command;',char(10)];%#ok<I18N_Concatenated_Msg>
                cmd=[cmd,clkEnForce,char(10)];
            end


            resetForce=getResetForceCommand(this);
            if~isempty(resetForce)
                cmd=[cmd,'# Reset force command;',char(10)];%#ok<I18N_Concatenated_Msg>
                cmd=[cmd,resetForce,char(10)];
            end
        end




        function cmd=getLaunchCmd(~)
            cmd='vsim';
        end


        function cmd=getCompileCmd(this)
            if isCodingForVhdl(this)
                cmd='vcom';
            else
                cmd='vlog';
            end
        end

        function c=getTargetLibName(~)
            c='work';
        end


        function cmdstr=getTclCmds(this)

            cmds{1}='Comment: Compile the generated code';


            dutName=getDutName(this);

            fileNameList=getEntityFileNames(this);
            cmds{end+1}='vlib work';
            for ii=1:length(fileNameList)
                cmds{end+1}=sprintf('%s %s',getCompileCmd(this),fileNameList{ii});%#ok<*AGROW>
            end


            cmds{end+1}='Comment: Initiate cosimulation';
            cmds{end+1}=sprintf('vsimmatlabsysobj -voptargs=+acc %s.%s',getTargetLibName(this),dutName);


            cmds{end+1}='Comment: Set simulation time unit';
            cmds{end+1}=sprintf('set UserTimeUnit %s',getTimingUnit(this));


            if~this.isBatchMode
                waveCmds=getAddWaveCommand(this);
                for ii=1:length(waveCmds)
                    cmds{end+1}=sprintf('%s',waveCmds{ii});
                end
            end

            cmds{end+1}='puts ""';
            cmds{end+1}='puts "Ready for cosimulation..."';

            cmdstr='';
            for ii=1:length(cmds)
                cmd=cmds{ii};

                if(regexp(cmd,'^Comment: '))
                    comment=cmd(9:end);
                    continue;
                end

                if~isempty(comment)
                    cmdstr=[cmdstr,sprintf('%s''%s'',...%%%s\n','    ',cmd,comment)];%#ok<I18N_Sprintf_Constant>
                    comment='';
                else
                    cmdstr=[cmdstr,sprintf('%s''%s'',...\n','    ',cmd)];%#ok<I18N_Sprintf_Constant>
                end
            end
        end


        function cmds=getAddWaveCommand(this)
            cmds{1}='Comment: Add wave commands for chip input signals';
            cmds{2}=sprintf('add wave /%s/*',getDutName(this));
        end




        function str=getHDLSimulator(~)
            str='ModelSim';
        end
        function crNames=getClockResetSignals(~)
            crNames='';
        end
        function crModes=getClockResetTypes(~)
            crModes='';
        end
        function crTimes=getClockResetTimes(~)
            crTimes='';
        end
        function xsiData=getXSIData(~)
            xsiData='';
        end
    end
end


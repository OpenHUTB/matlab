


classdef GenMatlabIncisiveTb<emlhdlcoder.hdlverifier.GenMatlabCosimTb

    properties(Constant)
        SimulatorName=message('hdlcoder:hdlverifier:Incisive').getString;
    end

    methods
        function this=GenMatlabIncisiveTb(varargin)
            this=this@emlhdlcoder.hdlverifier.GenMatlabCosimTb(varargin{:});


            for m=1:length(this.codeInfo.hdlDutPortInfo)
                this.codeInfo.hdlDutPortInfo(m).Name=getIncisiveName(this,this.codeInfo.hdlDutPortInfo(m).Name);
            end
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
                low=getLevelLow(this);
                high=getLevelHigh(this);

                pattern=sprintf('%s -after %s %s -after %s -repeat %s',low,clockLowAt,high,clockHighAt,repeatEvery);
                cmd=sprintf('force %s %s;',clkName,pattern);
            end
        end

        function cmd=getClockEnableForceCommand(this)
            cmd='';
            if dutHasClockEnable(this)
                clkEnName=getClockEnableName(this);
                timeMode=getTimingUnit(this);
                low=getLevelLow(this);
                high=getLevelHigh(this);
                clkPeriod=getClockPeriod(this);

                if isClkEnableAtInputDataRate(this)
                    clkLowTime=getClockLowTime(this);

                    holdTime=getHoldTime(this);

                    resetLen=getResetLength(this);
                    clkEnDelay=getClockEnableDelay(this);
                    delayTime=(resetLen+clkEnDelay)*clkPeriod;
                    clkEnHigh=clkLowTime+holdTime;
                    cmd1=sprintf('deposit %s %s -after %d%s %s -after %d%s %s -after %d%s -repeat %d%s;',...
                    clkEnName,...
                    low,0,timeMode,...
                    high,clkEnHigh,timeMode,...
                    low,clkEnHigh+clkPeriod,timeMode,...
                    this.codeInfo.baseRateScaling*clkPeriod,timeMode);
                    cmd2=sprintf('force %s %s -after %d%s -release %d%s;',...
                    clkEnName,...
                    low,0,timeMode,...
                    delayTime,timeMode);
                    cmd=[cmd1,cmd2];

                else
                    clockEnHigh=uint64(getClockEnableHigh(this));

                    clockEnLowAt=sprintf('%d%s',0,timeMode);
                    clockEnHighAt=sprintf('%d%s',clockEnHigh,timeMode);
                    pattern=sprintf('%s -after %s %s -after %s',low,clockEnLowAt,high,clockEnHighAt);
                    cmd=sprintf('force %s %s;',clkEnName,pattern);
                end
            end
        end

        function cmd=getResetForceCommand(this)
            cmd='';
            if dutHasReset(this)
                timeMode=getTimingUnit(this);







                resetLength=uint64(computeResetLength(this));

                if strcmpi(getResetAssertLevel(this),'ActiveHigh')

                    resetHigh=getLevelHigh(this);
                    resetLow=getLevelLow(this);
                else

                    resetHigh=getLevelLow(this);
                    resetLow=getLevelHigh(this);
                end

                pattern=sprintf('%s -after 0%s %s -after %d%s',resetHigh,timeMode,resetLow,resetLength,timeMode);
                cmd=sprintf('force %s %s;',this.getResetName,pattern);
            end
        end

        function cmd=getTclPreSimCommand(this)
            cmd=sprintf('puts "Running Simulink Cosimulation block.";\n');
            cmd=[cmd,' ',sprintf('puts "Chip Name: --> %s";\n',getGoldenMdlDutPath(this))];
            cmd=[cmd,' ',sprintf('puts "Target language: --> %s";\n',getTargetLanguage(this))];
            cmd=[cmd,' ',sprintf('puts "Target directory: --> %s";\n',getCodeGenDir(this))];


            clkForce=getClockForceCommand(this);
            if~isempty(clkForce)
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
            cmd='nclaunch';
        end


        function cmd=getCompileCmd(this)
            if isCodingForVhdl(this)
                cmd='exec ncvhdl -64bit -v93';
            else
                cmd='exec ncvlog -64bit ';
            end
        end



        function c=getTargetLibName(~)
            c='work';
        end


        function cmdstr=getTclCmds(this)

            cmds{1}='Comment: Compile the generated code';


            dutName=getDutName(this);
            fieNameList=getEntityFileNames(this);
            for ii=1:length(fieNameList)
                cmds{end+1}=sprintf('%s %s',getCompileCmd(this),fieNameList{ii});%#ok<*AGROW>
            end
            cmds{end+1}=['exec ncelab -64bit -access +wc ',dutName];%#ok<I18N_Concatenated_Msg>

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

            comment='Comment: Initiate cosimulation';

            ncsimcmd=sprintf('hdlsimmatlabsysobj %s',dutName);

            cmdstr=sprintf('%s    [''%s'',...%%%s\n',cmdstr,ncsimcmd,comment);
            siminputs={};


            if~this.isBatchMode
                waveCmds=getAddWaveCommand(this);
                for ii=1:length(waveCmds)
                    siminputs{end+1}=sprintf('%s',waveCmds{ii});
                end
            end

            siminputs{end+1}=sprintf(' -input "{@puts \\"\\"}"');
            siminputs{end+1}=sprintf(' -input "{@puts \\"Ready for cosimulation...\\"}"');


            for ii=1:length(siminputs)
                inp=siminputs{ii};

                if(regexp(inp,'^Comment: '))
                    comment=inp(9:end);
                    continue;
                end

                if~isempty(comment)
                    cmdstr=[cmdstr,sprintf('%s''%s'',...%%%s\n','    ',inp,comment)];%#ok<I18N_Sprintf_Constant>
                    comment='';
                else
                    cmdstr=[cmdstr,sprintf('%s''%s'',...\n','    ',inp)];%#ok<I18N_Sprintf_Constant>
                end
            end
            cmdstr=sprintf('%s   ]\n',cmdstr);
        end


        function cmds=getAddWaveCommand(this)

            cmds{1}='Comment: Add wave commands for chip input/output signals';
            cmds{end+1}=sprintf(' -input "{@simvision  {set w \\[waveform new\\]}}"');
            for ii=1:length(this.codeInfo.hdlDutPortInfo)
                cmds{end+1}=sprintf(' -input "{@simvision {waveform add -using \\$w -signals %s}}"',this.codeInfo.hdlDutPortInfo(ii).Name);
                cmds{end+1}=sprintf(' -input "{@probe -create -shm %s }"',this.codeInfo.hdlDutPortInfo(ii).Name);
            end

        end

        function lvl=getLevelHigh(this)
            if isCodingForVhdl(this)
                lvl='{B"1"}';
            else
                lvl='1';
            end
        end


        function lvl=getLevelLow(this)
            if isCodingForVhdl(this)
                lvl='{B"0"}';
            else
                lvl='0';
            end
        end

        function n=getIncisiveName(this,name)
            dutName=getDutName(this);
            if isCodingForVhdl(this)
                n=sprintf(':%s',name);
            else
                n=sprintf('%s.%s',dutName,name);
            end
        end




        function str=getHDLSimulator(~)
            str='Xcelium';
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



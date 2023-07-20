classdef gencosimin<cosimtb.gencosim







    methods






        function this=gencosimin(varargin)
            this=this@cosimtb.gencosim(varargin{:});
        end
    end



    methods

        function linkSuffix=getCurrentLinkOpt(~)
            linkSuffix='in';
        end


        function libName=getLibraryName(~)
            libName='lfilinklib';
        end



        function hl=checkEDALinkLicense(this)



            cosimOpt=getCurrentLinkOpt(this);
            hl=hasLicense(this);
            if~(strcmpi(cosimOpt,'in')||strcmpi(cosimOpt,'Incisive'))
                error(message('hdlcoder:cosim:invalidcosimmodeloption'));
            end


            load_system(this.getLibraryName);
        end


        function cmd=getTclPreSimCommand(this)
            cmd=sprintf('puts "Running Simulink Cosimulation block.";\n');
            cmd=[cmd,' ',sprintf('puts "Chip Name: --> %s";\n',getGoldenMdlDutPath(this))];
            cmd=[cmd,' ',sprintf('puts "Target language: --> %s";\n',getTargetLanguage(this))];
            cmd=[cmd,' ',sprintf('puts "Target directory: --> %s";\n',getCodeGenDir(this))];
            cmd=[cmd,' ',sprintf('puts [clock format [clock seconds]];\n')];

            clkForce=getClockForceCommand(this);
            if~isempty(clkForce)
                cmd=[cmd,'# Clock force command;',char(10)];
                cmd=[cmd,clkForce,char(10)];
            end


            clkEnForce=getClockEnableForceCommand(this);
            if~isempty(clkEnForce)
                cmd=[cmd,'# Clock enable force command;',char(10)];
                cmd=[cmd,clkEnForce,char(10)];
            end


            resetForce=getResetForceCommand(this);
            if~isempty(resetForce)
                cmd=[cmd,'# Reset force command;',char(10)];
                cmd=[cmd,resetForce,char(10)];
            end

        end

        function cmd=getTclPostSimCommand(this)
            cmd='';
        end


        function cmd=getCosimLaunchCmd(~)
            cmd='nclaunch';
        end


        function str=getLaunchBoxDisplayStr(this)
            cmd2=sprintf('hdlsimulink %s',this.getDutName);
            msg='Double-click here to launch Incisive';
            str=sprintf('disp([''%s'' char(10) ''%s''])',cmd2,msg);
        end


        function cmdstr=getTclCmds(this,batch)

            cmds{1}='Comment: Compile the generated code';


            dutName=getDutName(this);
            if this.edaScriptsGenerated&&strcmpi(this.hSLHDLCoder.getParameter('SimulationTool'),'Cadence Incisive')
                compileScriptName=sprintf('%s%s',dutName,this.hSLHDLCoder.getParameter('hdlcompilefilepostfix'));
                cmds{end+1}=sprintf('exec sh %s',compileScriptName);
                cmds{end+1}='set INSTALL_DIR [exec ncroot]';
                cmds{end+1}='set ::env(INSTALL_DIR) $INSTALL_DIR';
            else
                fieNameList=getEntityFileNames(this);
                for ii=1:length(fieNameList)
                    cmds{end+1}=sprintf('%s %s',getCompileCmd(this),fieNameList{ii});%#ok<*AGROW>
                end



                ElaborationCmd='exec ncelab -64bit ';



                if this.IsCodeCoverageEnabled
                    ElaborationCmd=[ElaborationCmd,'-coverage A '];
                end
                cmds{end+1}=[[ElaborationCmd,'-access +wc '],dutName];
            end

            SimulationCmd='hdlsimulink';
            if this.IsCodeCoverageEnabled
                SimulationCmd=[SimulationCmd,' -covtest CodeCoverage'];
            end
            cmdstr='';
            for ii=1:length(cmds)
                cmd=cmds{ii};
                if(regexp(cmd,'^Comment: '))
                    comment=cmd(9:end);
                    continue;
                end

                if~isempty(comment)
                    cmdstr=[cmdstr,sprintf('%s''%s'',...%%%s\n','    ',cmd,comment)];
                    comment='';
                else
                    cmdstr=[cmdstr,sprintf('%s''%s'',...\n','    ',cmd)];
                end
            end

            comment='Comment: Initiate cosimulation';
            if batch
                ncsimcmd=sprintf([SimulationCmd,' %s'],dutName);
            else
                ncsimcmd=sprintf([SimulationCmd,' -gui %s'],dutName);
            end
            cmdstr=sprintf('%s    [''%s'',...%%%s\n',cmdstr,ncsimcmd,comment);
            siminputs={};

            if~batch

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
                    cmdstr=[cmdstr,sprintf('%s''%s'',...%%%s\n','    ',inp,comment)];
                    comment='';
                else
                    cmdstr=[cmdstr,sprintf('%s''%s'',...\n','    ',inp)];
                end
            end
            cmdstr=sprintf('%s   ]\n',cmdstr);
        end



        function crPaths=getClockResetPaths(~)
            crPaths='';
        end
        function crModes=getClockResetModes(~)
            crModes='[]';
        end
        function crTimes=getClockResetTimes(~)
            crTimes='[]';
        end
        function xsiData=getXSIData(~,~)
            xsiData='';
        end
        function str=getCustomCosimLaunchCmd(~)
            str='';
        end
    end



    methods

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
                low=getClockLow(this);
                high=getClockHigh(this);

                pattern=sprintf('%s -after %s %s -after %s -repeat %s',low,clockLowAt,high,clockHighAt,repeatEvery);
                clkName=getIncisiveName(this,clkName);
                cmd=sprintf('force %s %s;',clkName,pattern);
            end
        end


        function cmd=getClockEnableForceCommand(this)
            cmd='';
            if dutHasClockEnable(this)
                clkName=getClockEnableName(this);
                timeMode=getTimingUnit(this);

                clockEnHigh=uint64(getClockEnableHigh(this));


                clockEnLowAt=sprintf('%d%s',0,timeMode);
                clockEnHighAt=sprintf('%d%s',clockEnHigh,timeMode);
                low=getLevelLow(this);
                high=getLevelHigh(this);
                pattern=sprintf('%s -after %s %s -after %s',low,clockEnLowAt,high,clockEnHighAt);
                clkEnPath=getIncisiveName(this,clkName);
                cmd=sprintf('force %s %s;',clkEnPath,pattern);
            end
        end


        function cmd=getPreSimRunCommand(this)
            rLen=uint64(computeResetRunTime(this));
            cmd=sprintf(' -input "{@run %d%s}"',rLen,getTimingUnit(this));

        end


        function cmd=getResetForceCommand(this)
            cmd='';
            if dutHasReset(this)
                timeMode=getTimingUnit(this);







                resetLength=uint64(computeResetLength(this));

                if getResetAssertLevel(this)

                    resetHigh=getLevelHigh(this);
                    resetLow=getLevelLow(this);
                else

                    resetHigh=getLevelLow(this);
                    resetLow=getLevelHigh(this);
                end

                for rname=this.getResetNames()
                    pattern=sprintf('%s -after 0%s %s -after %d%s',resetHigh,timeMode,resetLow,resetLength,timeMode);
                    resetName=this.getIncisiveName(rname{1});
                    cmd=[cmd,sprintf('force %s %s;',resetName,pattern),newline];
                end
            end
        end


        function cmds=getAddWaveCommand(this)
            hN=getTopNetwork(this);
            pirInports=hN.PirInputPorts;
            pirOutports=hN.PirOutputPorts;

            cmds{1}='Comment: Add wave commands for chip input signals';
            cmds{end+1}=sprintf(' -input "{@simvision  {set w \\[waveform new\\]}}"');
            for ii=1:length(pirInports)
                cmds{end+1}=sprintf(' -input "{@simvision {waveform add -using \\$w -signals %s}}"',getIncisiveName(this,pirInports(ii).Name));
                cmds{end+1}=sprintf(' -input "{@probe -create -shm %s }"',pirInports(ii).Name);
            end

            cmds{end+1}='Comment: Add wave commands for chip output signals';
            for ii=1:length(pirOutports)
                cmds{end+1}=sprintf(' -input "{@simvision {waveform add -using \\$w -signals %s}}"',getIncisiveName(this,pirOutports(ii).Name));
                cmds{end+1}=sprintf(' -input "{@probe -create -shm %s }"',pirOutports(ii).Name);
            end
            cmds{end+1}=sprintf(' -input "{@database -open waves -into waves.shm -default}"');
        end


        function cmd=getCompileCmd(this)
            if isCodingForVhdl(this)
                cmd='exec ncvhdl -64bit -v93';
            else
                cmd='exec ncvlog -64bit';
            end
        end
    end




    methods(Access=private)

        function hl=hasLicense(~)
            tooldir=fullfile(matlabroot,'toolbox','edalink','extensions','incisive','incisive');
            if~(license('test','EDA_Simulator_Link')&&exist(tooldir,'dir'))
                error(message('hdlcoder:cosim:incisivenotinstalled'));
            end
            hl=true;
        end


        function n=getIncisiveName(this,name)
            dutName=getDutName(this);
            if isCodingForVhdl(this)
                n=sprintf(':%s',name);
            else
                n=sprintf('%s.%s',dutName,name);
            end
        end


        function lvl=getClockHigh(this)

            if isClockEdgeRising(this)
                clockHigh='1';
            else
                clockHigh='0';
            end

            if isCodingForVhdl(this)
                lvl=sprintf('{B"%s"}',clockHigh);
            else
                lvl=clockHigh;
            end
        end


        function lvl=getClockLow(this)

            if isClockEdgeRising(this)
                clockLow='0';
            else
                clockLow='1';
            end

            if isCodingForVhdl(this)
                lvl=sprintf('{B"%s"}',clockLow);
            else
                lvl=clockLow;
            end
        end


        function lvl=getLevelHigh(this)

            clockHigh='1';

            if isCodingForVhdl(this)
                lvl=sprintf('{B"%s"}',clockHigh);
            else
                lvl=clockHigh;
            end
        end


        function lvl=getLevelLow(this)

            clockLow='0';

            if isCodingForVhdl(this)
                lvl=sprintf('{B"%s"}',clockLow);
            else
                lvl=clockLow;
            end

        end




    end
end




classdef gencosimmq<cosimtb.gencosim







    methods






        function this=gencosimmq(varargin)
            this=this@cosimtb.gencosim(varargin{:});
        end
    end



    methods

        function linkSuffix=getCurrentLinkOpt(~)
            linkSuffix='mq';
        end

        function libName=getLibraryName(~)
            libName='modelsimlib';
        end

        function hl=checkEDALinkLicense(this)



            cosimOpt=this.getCurrentLinkOpt;
            hl=this.hasLicense;
            if~(strcmpi(cosimOpt,'mq')||strcmpi(cosimOpt,'ModelSim'))
                error(message('hdlcoder:cosim:invalidcosimmodeloption'));
            end


            load_system(this.getLibraryName);
        end

        function cmd=getTclPreSimCommand(this)
            cmd=sprintf('puts "Running Simulink Cosimulation block.";\n');
            cmd=[cmd,' ',sprintf('puts "Chip Name: --> %s";\n',this.getGoldenMdlDutPath)];
            cmd=[cmd,' ',sprintf('puts "Target language: --> %s";\n',this.getTargetLanguage)];
            cmd=[cmd,' ',sprintf('puts "Target directory: --> %s";\n',this.getCodeGenDir)];
            cmd=[cmd,' ',sprintf('puts [clock format [clock seconds]];\n')];


            clkForce=this.getClockForceCommand;
            if this.dutHasClock&&~isempty(clkForce)
                cmd=[cmd,'# Clock force command;',char(10)];
                cmd=[cmd,clkForce,char(10)];
            end


            clkEnForce=this.getClockEnableForceCommand;
            if~isempty(clkEnForce)
                cmd=[cmd,'# Clock enable force command;',char(10)];
                cmd=[cmd,clkEnForce,char(10)];
            end


            resetForce=this.getResetForceCommand;
            if~isempty(resetForce)
                cmd=[cmd,'# Reset force command;',char(10)];
                cmd=[cmd,resetForce,char(10)];
            end
        end

        function cmd=getTclPostSimCommand(this)
            cmd='';
            if this.IsCodeCoverageEnabled
                covcmd=['coverage report -html CodeCoverage.html\n',...
                'coverage save CodeCoverage.ucdb\n'];
                cmd=[cmd,covcmd];
            end
        end

        function cmd=getCosimLaunchCmd(~)
            cmd='vsim';
        end


        function str=getLaunchBoxDisplayStr(this)
            if(targetcodegen.targetCodeGenerationUtils.isALTERAFPFUNCTIONSMode)
                tStr='-t 1ps';
            else
                tStr='';
            end
            cmd2=sprintf('vsimulink %s -voptargs=+acc %s.%s',tStr,this.getTargetLibName,this.getDutName);
            msg='Double-click here to launch ModelSim';
            str=sprintf('disp([''%s'' char(10) ''%s''])',cmd2,msg);
        end


        function cmdstr=getTclCmds(this,batch)

            cmds{1}='Comment: Compile the generated code';


            dutName=this.getDutName;
            if this.edaScriptsGenerated&&strcmpi(this.hSLHDLCoder.getParameter('SimulationTool'),'Mentor Graphics Modelsim')
                compileScriptName=sprintf('%s%s',dutName,this.hSLHDLCoder.getParameter('hdlcompilefilepostfix'));
                cmds{end+1}=sprintf('do %s',compileScriptName);
            else
                gp=pir;
                if gp.getTargetCodeGenSuccess
                    if targetcodegen.targetCodeGenerationUtils.isAlteraMode()
                        target=hdlsynthtoolenum.Quartus;
                    elseif targetcodegen.targetCodeGenerationUtils.isXilinxMode()
                        tool=this.hSLHDLCoder.getParameter('SynthesisTool');
                        if strcmpi(tool,'Xilinx Vivado')
                            target=hdlsynthtoolenum.Vivado;
                        else

                            target=hdlsynthtoolenum.ISE;
                        end
                    else
                        target=hdlsynthtoolenum.None;
                    end

                    if this.isCodingForVhdl
                        language='vhdl';
                    else
                        language='verilog';
                    end
                    header=hdlprinttargetcodegenheaders(target,language,false,false);
                    if~isempty(header)
                        txt=sprintf(header);
                        tmp=textscan(txt,'%s','Delimiter',char(10));
                        for ii=1:numel(tmp{1})
                            cmds{end+1}=tmp{1}{ii};
                        end
                    end

                end

                fileNameList=this.getEntityFileNames;
                cmds{end+1}='vlib work';
                for ii=1:length(fileNameList)
                    cmds{end+1}=sprintf('%s %s',this.getCompileCmd,fileNameList{ii});%#ok<*AGROW>
                end
            end


            cmds{end+1}='Comment: Initiate cosimulation';
            cmds{end+1}=sprintf('%s %s.%s',this.getSimCmd,this.getTargetLibName,dutName);

            if~batch

                waveCmds=this.getAddWaveCommand;
                for ii=1:length(waveCmds)
                    cmds{end+1}=sprintf('%s',waveCmds{ii});
                end
            end

            cmds{end+1}='Comment: Set simulation time unit';
            cmds{end+1}=sprintf('set UserTimeUnit %s',this.getTimingUnit);

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
                    cmdstr=[cmdstr,sprintf('%s''%s'',...%%%s\n','    ',cmd,comment)];
                    comment='';
                else
                    cmdstr=[cmdstr,sprintf('%s''%s'',...\n','    ',cmd)];
                end
            end
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

        function cmd=getCompileCmd(this)
            if this.isCodingForVhdl
                cmd='vcom';
            else
                cmd='vlog';
            end
        end

        function cmd=getClockForceCommand(this)
            cmd='';
            if this.dutHasClock
                clkName=this.getClockName;
                timeMode=this.getTimingUnit;


                clkLowTime=uint64(this.getClockLowTime);
                clkPeriod=uint64(this.getClockPeriod);



                clockLowAt=sprintf('%d%s',0,timeMode);


                clockHighAt=sprintf('%d%s',clkLowTime,timeMode);

                repeatEvery=sprintf('%d%s',clkPeriod,timeMode);


                if this.isClockEdgeRising
                    clockLow='0';
                    clockHigh='1';
                else
                    clockLow='1';
                    clockHigh='0';
                end

                pattern=sprintf('%s %s, %s %s -r %s',clockLow,clockLowAt,clockHigh,clockHighAt,repeatEvery);

                cmd=sprintf('force /%s/%s %s;',this.getDutName,clkName,pattern);
            end
        end


        function cmd=getClockEnableForceCommand(this)
            cmd='';
            if this.dutHasClockEnable
                clkName=this.getClockEnableName;
                clkEnPath=sprintf('/%s/%s',this.getDutName,clkName);

                timeMode=this.getTimingUnit;

                clockEnHigh=uint64(this.getClockEnableHigh);


                clockEnLowAt=sprintf('%d%s',0,timeMode);
                clockEnHighAt=sprintf('%d%s',clockEnHigh,timeMode);
                pattern=sprintf('0 %s, 1 %s',clockEnLowAt,clockEnHighAt);
                cmd=sprintf('force %s %s;',clkEnPath,pattern);
            end
        end


        function cmd=getPreSimRunCommand(this)
            rLen=uint64(this.computeResetRunTime);
            cmd=sprintf('run %d%s;',rLen,this.getTimingUnit);
        end


        function cmd=getResetForceCommand(this)
            cmd='';
            if this.dutHasReset
                timeMode=this.getTimingUnit;







                resetLength=uint64(this.computeResetLength);

                if this.getResetAssertLevel
                    resetHigh=1;
                    resetLow=0;
                else
                    resetHigh=0;
                    resetLow=1;
                end

                for rname=this.getResetNames
                    name=rname{1};
                    pattern=sprintf('%d 0%s, %d %d%s',resetHigh,timeMode,resetLow,resetLength,timeMode);
                    a=sprintf('force /%s/%s %s;',this.getDutName,name,pattern);
                    cmd=[cmd,a,newline];
                end
            end
        end


        function cmds=getAddWaveCommand(this)
            hN=this.getTopNetwork;
            pirInports=hN.PirInputPorts;
            pirOutports=hN.PirOutputPorts;
            waveOpts='';

            cmds{1}='Comment: Add wave commands for chip input signals';
            for ii=1:length(pirInports)
                cmds{end+1}=sprintf('add wave %s /%s/%s',waveOpts,hN.Name,pirInports(ii).Name);
            end

            cmds{end+1}='Comment: Add wave commands for chip output signals';
            for ii=1:length(pirOutports)
                cmds{end+1}=sprintf('add wave %s /%s/%s',waveOpts,hN.Name,pirOutports(ii).Name);
            end
        end
    end



    methods(Access=private)

        function hl=hasLicense(~)
            tooldir=fullfile(matlabroot,'toolbox','edalink','extensions','modelsim','modelsim');
            if~(license('test','EDA_Simulator_Link')&&exist(tooldir,'dir'))
                error(message('hdlcoder:cosim:modelsimnotinstalled'));
            end
            hl=true;
        end

        function cmdstr=getSimCmd(this)

            cmdstr='vsimulink ';
            if this.IsCodeCoverageEnabled
                cmdstr=[cmdstr,'-coverage '];
            end

            if(targetcodegen.targetCodeGenerationUtils.isALTERAFPFUNCTIONSMode)
                cmdstr=[cmdstr,'-t 1ps -voptargs=+acc '];
            else
                cmdstr=[cmdstr,'-voptargs=+acc '];
            end


            if~isempty(this.hSLHDLCoder.SubModelData)
                if hdlgetparameter('use_single_library')
                    cmdstr=[cmdstr,' -L work'];
                else
                    for ii=1:numel(this.hSLHDLCoder.SubModelData)
                        cmdstr=[cmdstr,' -L ',this.hSLHDLCoder.SubModelData(ii).LibName];
                    end
                end
            end

            gp=pir;
            if gp.getTargetCodeGenSuccess

                if targetcodegen.targetCodeGenerationUtils.isAlteraMode()
                    if this.isCodingForVhdl
                        cmdstr=[cmdstr,' -L lpm -L altera_mf'];
                    else
                        cmdstr=[cmdstr,' -L lpm_ver -L altera_mf_ver'];
                    end
                end
                if targetcodegen.targetCodeGenerationUtils.isXilinxMode()
                    if this.isCodingForVhdl
                        cmdstr=[cmdstr,' -L xilinxcorelib -L simprim -L unisim'];
                    else
                        cmdstr=[cmdstr,' -L xilinxcorelib_ver -L simprims_ver -L unisims_ver work.glbl'];
                    end
                end
            end
        end
    end
end








function str=hdlprinttargetcodegenheaders(target,tlang,varargin)



    skipglbl=false;
    checkmodelsimcmd=true;
    lib='work';

    if(nargin>=3)
        skipglbl=varargin{1};
    end

    if(nargin>=4)
        checkmodelsimcmd=varargin{2};
    end

    if(nargin>=5)
        lib=varargin{3};
    end

    str='';
    if strcmpi(tlang,'vhdl')
        if checkmodelsimcmd
            warnNonModelsimCmd(hdlgetparameter('hdlcompilevhdlcmd'));
        end
        switch target
        case hdlsynthtoolenum.Quartus
            str=printVHDLTargetHeadersAltera(str,lib);
        case hdlsynthtoolenum.ISE
            str=printVHDLTargetHeadersXilinxISE(str);
        case hdlsynthtoolenum.Vivado
            str=printVHDLTargetHeadersXilinxVivado(str);
        otherwise
        end
    else
        if checkmodelsimcmd
            warnNonModelsimCmd(hdlgetparameter('hdlcompileverilogcmd'));
        end
        switch target
        case hdlsynthtoolenum.Quartus
            str=printVerilogTargetHeadersAltera(str);
        case hdlsynthtoolenum.ISE
            str=printVerilogTargetHeadersXilinxISE(str,skipglbl);
        case hdlsynthtoolenum.Vivado
            str=printVerilogTargetHeadersXilinxVivado(str);
        otherwise
        end
    end

    function warnNonModelsimCmd(cmd)
        cmd=strtrim(cmd);
        if(length(cmd)<4||(~strcmpi(cmd(1:4),'vcom')&&~strcmpi(cmd(1:4),'vlog')))
            msgObj=message('HDLShared:hdlshared:nonmodelsimcompcmd');

            report_to_filtercoder_or_hdlcoder(msgObj);
        end



        function s=printVHDLTargetHeadersAltera(s,~)
            if(targetcodegen.targetCodeGenerationUtils.isALTERAFPFUNCTIONSMode())
                alteraSimLibPath=strtrim(hdlgetparameter('SimulationLibPath'));
                if(isempty(alteraSimLibPath))
                    alteraSimLibPath='FILL_IN_SIMULATION_LIB_PATH';
                    warning(message('hdlcommon:targetcodegen:AlteraSimLibNotCompiled'));
                end
                alteraSimLibIniPath=strrep(fullfile(alteraSimLibPath,'modelsim.ini'),'\','/');
                s=sprintf('%svmap -c -modelsimini %s\n',s,alteraSimLibIniPath);
                if strcmpi(hdlgetparameter('SynthesisTool'),'Intel Quartus Pro')
                    pathToQuartusPro=hdlgetpathtoquartuspro;
                    [qproPath,~,~]=fileparts(pathToQuartusPro);
                    qshPath=fullfile(qproPath,'quartus_sh');
                    qproVersionCmd=sprintf('%s -v',qshPath);
                    [~,Ver]=system(qproVersionCmd);
                    quartusVer=regexp(Ver,'Version\s*([\d\.]*)\s*Build','tokens');
                    qVer=quartusVer{1}{:};
                    if(str2double(qVer(1:4))>20.2)
                        libName='altera_fp_functions_1911';
                    else
                        libName='altera_fp_functions_191';
                    end
                    s=sprintf('%svlib %s\n',s,libName);
                else
                    pathToAltera=hdlgetpathtoquartus;
                    s=sprintf('%sset path_to_quartus %s\n',s,pathToAltera);
                    str=['vlib work\n'...
                    ,'vmap work work\n'...
                    ,'vcom -work work -2002 -explicit $path_to_quartus/dspba/backend/Libraries/vhdl/base/dspba_library_package.vhd\n'...
                    ,'vcom -work work -2002 -explicit $path_to_quartus/dspba/backend/Libraries/vhdl/base/dspba_library.vhd\n'...
                    ];
                    s=sprintf('%s%s',s,str);
                end
            else
                pathToAltera=hdlgetpathtoquartus;
                s=sprintf('%sset path_to_quartus %s\n',s,pathToAltera);
                s=sprintf('%svlib lpm\n',s);
                s=sprintf('%svmap lpm lpm\n',s);
                s=sprintf('%svcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220pack.vhd\n',s);
                s=sprintf('%svcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220model.vhd\n',s);
                s=sprintf('%svlib altera_mf\n',s);
                s=sprintf('%svmap altera_mf altera_mf\n',s);
                s=sprintf('%svcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf_components.vhd\n',s);
                s=sprintf('%svcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf.vhd\n',s);
                s=sprintf('%svlib sgate\n',s);
                s=sprintf('%svmap sgate sgate\n',s);
                s=sprintf('%svcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate_pack.vhd\n',s);
                s=sprintf('%svcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate.vhd\n',s);
            end


            function s=printVerilogTargetHeadersAltera(s)
                pathToAltera=hdlgetpathtoquartus;
                s=sprintf('%sset path_to_quartus %s\n',s,pathToAltera);
                s=sprintf('%svlib lpm_ver\n',s);
                s=sprintf('%svmap lpm_ver lpm_ver\n',s);
                s=sprintf('%svlog -work lpm_ver $path_to_quartus/eda/sim_lib/220model.v\n',s);
                s=sprintf('%svlib altera_mf_ver\n',s);
                s=sprintf('%svmap altera_mf_ver altera_mf_ver\n',s);
                s=sprintf('%svlog -work altera_mf_ver $path_to_quartus/eda/sim_lib/altera_mf.v\n',s);
                s=sprintf('%svlib sgate_ver\n',s);
                s=sprintf('%svmap sgate_ver sgate_ver\n',s);
                s=sprintf('%svlog -work sgate_ver $path_to_quartus/eda/sim_lib/sgate.v\n',s);


                function s=printVHDLTargetHeadersXilinxISE(s)
                    [~,pathToCoreLib]=targetcodegen.xilinxdriver.getPathToXilinx('vhdl',hdlsynthtoolenum.ISE);
                    directory=fileparts(pathToCoreLib);
                    s=sprintf('%svmap -c\n',s);
                    s=sprintf('%svmap unisim %s/unisim\n',s,directory);
                    s=sprintf('%svmap simprim %s/simprim\n',s,directory);
                    s=sprintf('%svmap xilinxcorelib %s\n',s,pathToCoreLib);


                    function s=printVHDLTargetHeadersXilinxVivado(s)
                        [~,directory]=targetcodegen.xilinxdriver.getPathToXilinx('vhdl',hdlsynthtoolenum.Vivado);

                        s=sprintf('%svmap secureip %s/secureip\n',s,directory);
                        s=sprintf('%svmap unisim %s/unisim\n',s,directory);
                        s=sprintf('%svmap unisims_ver %s/unisims_ver\n',s,directory);
                        s=sprintf('%svmap unimacro %s/unimacro\n',s,directory);
                        s=sprintf('%svmap unimacro_ver %s/unimacro_ver\n',s,directory);
                        s=sprintf('%svmap unifast %s/unifast\n',s,directory);
                        s=sprintf('%svmap unifast_ver %s/unifast_ver\n',s,directory);



                        function s=printVerilogTargetHeadersXilinxISE(s,skipglbl)
                            [pathToXilinx,pathToCoreLib]=targetcodegen.xilinxdriver.getPathToXilinx('verilog',hdlsynthtoolenum.ISE);
                            directory=fileparts(pathToCoreLib);
                            s=sprintf('%svmap unisims_ver %s/unisims_ver\n',s,directory);
                            s=sprintf('%svmap simprims_ver %s/simprims_ver\n',s,directory);
                            s=sprintf('%svmap xilinxcorelib_ver %s\n',s,pathToCoreLib);
                            if(~skipglbl)
                                s=sprintf('%svlog %s/verilog/src/glbl.v\n',s,pathToXilinx);
                            end
                            if(hdlgetparameter('force_clock'))
                                resetDelay=(hdlgetparameter('force_clock_high_time')...
                                +hdlgetparameter('force_clock_low_time'))...
                                *hdlgetparameter('resetlength');
                                if(resetDelay<100)

                                    msgObj=message('HDLShared:hdlshared:xilinxglblvdelay','$XILINX/verilog/src/glbl.v',resetDelay);
                                    report_to_filtercoder_or_hdlcoder(msgObj);
                                end
                            end

                            function s=printVerilogTargetHeadersXilinxVivado(s)
                                [~,directory]=targetcodegen.xilinxdriver.getPathToXilinx('verilog',hdlsynthtoolenum.Vivado);

                                s=sprintf('%svmap secureip %s/secureip\n',s,directory);
                                s=sprintf('%svmap unisim %s/unisim\n',s,directory);
                                s=sprintf('%svmap unisims_ver %s/unisims_ver\n',s,directory);
                                s=sprintf('%svmap unimacro %s/unimacro\n',s,directory);
                                s=sprintf('%svmap unimacro_ver %s/unimacro_ver\n',s,directory);
                                s=sprintf('%svmap unifast %s/unifast\n',s,directory);
                                s=sprintf('%svmap unifast_ver %s/unifast_ver\n',s,directory);

                                if(hdlgetparameter('force_clock'))
                                    resetDelay=(hdlgetparameter('force_clock_high_time')...
                                    +hdlgetparameter('force_clock_low_time'))...
                                    *hdlgetparameter('resetlength');
                                    if(resetDelay<100)

                                        msgObj=message('HDLShared:hdlshared:xilinxglblvdelay','$XILINX/data/verilog/src/glbl.v',resetDelay);
                                        warning(msgObj);
                                    end
                                end




                                function report_to_filtercoder_or_hdlcoder(msgObj)
                                    if(strcmpi(hdlcodegenmode,'filtercoder'))
                                        warning(msgObj);
                                    else
                                        slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',msgObj,'log to terminal if required');
                                    end








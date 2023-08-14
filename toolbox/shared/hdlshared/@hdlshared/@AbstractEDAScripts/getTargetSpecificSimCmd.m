function newSimCmd=getTargetSpecificSimCmd(this,simCmd)


    newSimCmd=simCmd;
    gp=pir;
    if gp.getTargetCodeGenSuccess

        if targetcodegen.targetCodeGenerationUtils.isAlteraMode
            if strcmpi(this.getDUTLanguage,'vhdl')
                newSimCmd=strrep(simCmd,'vsim','vsim -t 1ps -L lpm -L altera_mf');
            else
                newSimCmd=strrep(simCmd,'vsim','vsim -t 1ps -L lpm_ver -L altera_mf_ver');
            end
        end
        if targetcodegen.targetCodeGenerationUtils.isXilinxMode
            if strcmpi(this.getDUTLanguage,'vhdl')
                newSimCmd=strrep(simCmd,'vsim','vsim -L xilinxcorelib -L simprim -L unisim');
            else
                newSimCmd=strrep(simCmd,'vsim','vsim -L xilinxcorelib_ver -L simprims_ver -L unisims_ver work.glbl');
            end
        end
    end


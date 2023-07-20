function targetCodegenSanityCheck(this)




    targetCodeGenMode=targetcodegen.targetCodeGenerationUtils.isFloatingPointMode();
    if~targetCodeGenMode
        return;
    end
    if(this.getParameter('clockedge')==1)
        if~targetcodegen.targetCodeGenerationUtils.isNFPMode()
            error(message('hdlcoder:validate:targetcodegennofallingedge'));
        end
    end


    if strcmpi(this.getParameter('generatecosimmodel'),'Incisive')...
        &&~targetcodegen.targetCodeGenerationUtils.isNFPMode()
        error(message('hdlcoder:validate:CosimNotSupported'));
    end
    targetLanguage=this.getParameter('target_language');
    ext=this.PirInstance.getHDLFileExtension;
    if strcmpi(targetLanguage,'vhdl')

        if~strcmpi(ext,'.vhd')
            error(message('hdlcoder:validate:UnsupportedVhdlExtension'));
        end
    elseif strcmpi(targetLanguage,'verilog')

        if~strcmpi(ext,'.v')
            error(message('hdlcoder:validate:UnsupportedVerilogExtension'));
        end
    end
end



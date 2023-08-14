
function insertXSGSynthesisScripts(this,fid)



    lang=hdlgetparameter('lasttopleveltargetlang');
    if isempty(lang)
        lang=hdlgetparameter('target_language');
    end

    isVivadoXSG=targetcodegen.xilinxvivadosysgendriver.hasXSG;
    isVivadoSynthScriptTool=strcmpi(this.HdlSynthTool,'Vivado');

    if isVivadoXSG&&~isVivadoSynthScriptTool
        error(message('hdlcoder:validate:xsgmixedsynthscriptstool'));
    end

    if isVivadoSynthScriptTool
        str=targetcodegen.xilinxvivadosysgendriver.getXSGSynthesisScriptsCustom(this.HdlSynthCmd,...
        strcmpi(lang,'VHDL'),this.TopLevelName);
    else
        str=targetcodegen.xilinxutildriver.getTclScriptsToAddAllTargetFiles(this.HdlSynthCmd);
        fprintf(fid,str);
        str=targetcodegen.xilinxisesysgendriver.getXSGSynthesisScripts(this.HdlSynthCmd,...
        this.codegendir,strcmpi(lang,'VHDL'));
    end
    fprintf(fid,'%s',str);
end


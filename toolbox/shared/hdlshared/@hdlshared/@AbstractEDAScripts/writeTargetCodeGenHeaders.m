function writeTargetCodeGenHeaders(this,fid)




    utilExist=(exist('targetcodegen.targetCodeGenerationUtils','class')==8);
    if utilExist
        if targetcodegen.targetCodeGenerationUtils.isAlteraMode
            target=hdlsynthtoolenum.Quartus;
        elseif targetcodegen.targetCodeGenerationUtils.isXilinxMode
            tool=hdlgetparameter('SynthesisTool');
            if strcmpi(tool,'Xilinx Vivado')
                target=hdlsynthtoolenum.Vivado;
            else

                target=hdlsynthtoolenum.ISE;
            end
        else
            target=hdlsynthtoolenum.None;
        end
    else
        target=hdlsynthtoolenum.None;
    end

    fprintf(fid,hdlprinttargetcodegenheaders(target,this.getDUTLanguage));



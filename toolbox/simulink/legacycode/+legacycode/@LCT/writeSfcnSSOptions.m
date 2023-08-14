function writeSfcnSSOptions(~,fid,infoStruct)




    fprintf(fid,'ssSetOptions(S,\n');

    if infoStruct.Specs.Options.useTlcWithAccel&&...
        infoStruct.canUseSFcnCGIRAPI==false
        fprintf(fid,'SS_OPTION_USE_TLC_WITH_ACCELERATOR |\n');
    end

    if infoStruct.Specs.Options.canBeCalledConditionally
        fprintf(fid,'SS_OPTION_CAN_BE_CALLED_CONDITIONALLY |\n');
    end

    if infoStruct.Specs.Options.isVolatile==false
        fprintf(fid,'SS_OPTION_NONVOLATILE |\n');
    end

    fprintf(fid,'SS_OPTION_EXCEPTION_FREE_CODE |\n');
    fprintf(fid,'SS_OPTION_WORKS_WITH_CODE_REUSE |\n');
    fprintf(fid,'SS_OPTION_SFUNCTION_INLINED_FOR_RTW |\n');
    fprintf(fid,'SS_OPTION_DISALLOW_CONSTANT_SAMPLE_TIME);\n');

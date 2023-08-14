



function randomFunction=generateWrappers(filePath,ccSettingsChecksum,ccSettings,...
    wrapperText,wrapperVars,ccVars)

    if~isfile(filePath)







        if ccSettings.isCpp
            lang='c++';
        else
            lang='c';
        end
        feOpts=CGXE.CustomCode.getFrontEndOptions(lang,ccSettings.userIncludeDirs);
        feOpts.DoGenOutput=true;
        feOpts.GenOutput=filePath;

        ccHeader=sprintf('#include <tmwtypes.h>\n%s',ccSettings.customCode);
        msgs=internal.cxxfe.FrontEnd.parseText(ccHeader,feOpts);
        if any(strcmp({msgs.kind},'error')|strcmp({msgs.kind},'fatal'))
            errMsg=strjoin({msgs.desc},'\n');
            sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:UnexpectedError',errMsg);
        end
    end


    writer=sldv.code.internal.CWriter(filePath,'at');

    writer.print('\n%s',wrapperText);


    randomizeVarFcn='__TMW_PS_RANDOMIZE';
    writer.print('\nextern void %s(void*);',randomizeVarFcn);

    if ccSettings.isCpp
        externC='extern "C"';
    else
        externC='extern';
    end


    randomFunction=sprintf('__TMW_RANDOM_%s',ccSettingsChecksum);

    writer.print('\n%s void %s(void);\n',externC,randomFunction);
    writer.beginBlock('\nvoid %s(void) {',randomFunction);
    for ii=1:numel(wrapperVars)
        writer.print('\n%s(&%s);',randomizeVarFcn,wrapperVars{ii});
    end


    for ii=1:numel(ccVars)
        writer.print('\n%s(&%s);',randomizeVarFcn,ccVars{ii});
    end

    writer.endBlock('\n}\n\n');


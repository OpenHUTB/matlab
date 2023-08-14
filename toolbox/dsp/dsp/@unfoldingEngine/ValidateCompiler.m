function ValidateCompiler(~)








    coder.internal.errorIf(isempty(which('emlcprivate'))||...
    isempty(which('coderprivate.compiler_supports_eml_openmp'))||...
    isempty(which('codegen')),'dsp:dspunfold:NoMATLABCoderInstalled');


    if~ismac
        cc=emlcprivate('compilerman',false,true);
        noOmp=(~coderprivate.compiler_supports_eml_openmp(cc.compilerName)||...
        strcmp(cc.compilerName,'mingw64'));
        coder.internal.errorIf(noOmp,'dsp:dspunfold:NoOpenMPError');
    end


    if ismac

        selectedCompiler=mex.getCompilerConfigurations('CPP','Selected');
        invalidSelectedCompilerName={''};
        invalidSelectedCompilerVersion={''};
        validSelectedCompiler=true;
        vIdx=1;
        for cidx=1:length(selectedCompiler)
            if strcmp(selectedCompiler.Name,'Xcode Clang++')
                if str2double(erase(selectedCompiler(cidx).Version,'.'))>=1200
                    invalidSelectedCompilerName{vIdx}=selectedCompiler(cidx).Name;
                    invalidSelectedCompilerVersion{vIdx}=selectedCompiler(cidx).Version;
                    validSelectedCompiler=false;
                    vIdx=vIdx+1;
                end
            end
        end
        coder.internal.errorIf(~validSelectedCompiler,'dsp:dspunfold:InvalidSelectedCompiler',...
        invalidSelectedCompilerName{1},...
        invalidSelectedCompilerVersion{1},...
        invalidSelectedCompilerName{1},...
        '12.0.0');
    end
end
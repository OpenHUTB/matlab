function checkAndWarnForHalfInput(classType,datatype,fcnName)
%#codegen



    coder.allowpcode('plain');

    if coder.const(strcmpi(classType,'half'))

        ctx=eml_option('CodegenBuildContext');

        if~isempty(ctx)

            targetlib=coder.const(coder.internal.coderNetworkUtils.getTargetLib);

            if strcmpi(targetlib,'tensorrt')&&~strcmpi(datatype,'fp16')
                coder.internal.compileWarning(eml_message(...
                'dlcoder_spkg:cnncodegen:UseFp16ForHalfInput',fcnName));
            end

        end

    end

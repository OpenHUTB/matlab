
function isHDLPrj=isHDLCoderProject(javaConfig)
    isHDLPrj=[];

    key=char(javaConfig.getTarget().getKey());
    switch lower(key)
    case char(com.mathworks.toolbox.coder.app.UnifiedTargetFactory.UNIFIED_TARGET_KEY)
        isHDLPrj=strcmp(char(javaConfig.getParamAsString('param.objective')),'option.objective.hdl');
    case 'target.matlab.coder'
        isHDLPrj=false;
    case 'target.matlab.ecoder'
        if coderprivate.hasEmbeddedCoder()
            isHDLPrj=false;
        end
    case 'target.matlab.hdlcoder'
        isHDLPrj=true;
    end

    if isempty(isHDLPrj)
        emlcprivate('ccdiagnosticid','Coder:configSet:UnrecognizedProject',...
        char(javaConfig.getProject().getFile().getAbsolutePath()));
    end
end
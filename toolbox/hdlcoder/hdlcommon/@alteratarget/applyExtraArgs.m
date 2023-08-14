function applyExtraArgs(fid,opInCLI,baseType)




    if baseType.isDoubleType
        dataType='Double';
    elseif baseType.isSingleType
        dataType='Single';
    else
        assert(0);
    end
    extraArgs=targetcodegen.targetCodeGenerationUtils.getExtraArgs(opInCLI,dataType);
    fprintf(fid,'%s\n',extraArgs);
end
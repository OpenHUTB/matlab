








function checksum=getModelChecksum(model,isTop)

    checksum=[];%#ok

    if nargin<1||~(ischar(model)||isdouble(model))
        DAStudio.error('Slci:slci:ERROR_GETMODELCHECKSUM_INPUT');
    end

    mm=slci.internal.ModelStateMgr(model);
    try
        if isTop
            if~mm.isCompiledForTop()
                mm.compileModelForTop
            end
        else
            if~mm.isCompiledForRef()
                mm.compileModelForRef
            end
        end
    catch E

        throw(E);
    end

    try
        checksum=Simulink.BlockDiagram.getChecksum(model);
    catch E
        modelName=get_param(model,'Name');
        DAStudio.error('Slci:slci:ERROR_GETMODELCHECKSUM',modelName);
    end


end


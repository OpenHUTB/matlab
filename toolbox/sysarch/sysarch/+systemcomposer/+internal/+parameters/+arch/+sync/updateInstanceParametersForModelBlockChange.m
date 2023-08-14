function updateInstanceParametersForModelBlockChange(mdlName,block)





    try
        zcMdl=get_param(mdlName,'SystemComposerModel');
    catch
        return;
    end

    if isempty(zcMdl)
        return;
    end

    if~blockisa(block,'ModelReference')

        return;
    end

    arch=zcMdl.Architecture;
    try
        comp=zcMdl.lookup('Path',block);
    catch ex

        comp=[];
    end

    if isempty(comp)
        return;
    end
    compImpl=comp.getImpl;

    systemcomposer.internal.parameters.arch.sync.syncInstanceParamsToComponent(block,comp.Name,compImpl,arch);

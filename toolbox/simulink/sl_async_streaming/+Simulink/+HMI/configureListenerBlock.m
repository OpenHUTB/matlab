



function configureListenerBlock(hBlk,params)
    assert(isstruct(params)&&isscalar(params));
    fnames=fieldnames(params);
    for idx=1:length(fnames)
        set_param(hBlk,fnames{idx},params.(fnames{idx}));
    end
end

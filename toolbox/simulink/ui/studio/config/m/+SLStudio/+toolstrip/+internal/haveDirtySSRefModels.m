function result=haveDirtySSRefModels(cbinfo)
    result=~isempty(slInternal('getAllDirtySSRefBDs',cbinfo.model.Handle));
end

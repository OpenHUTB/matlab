function dirty=areModelNamesDirty(varargin)



    modelNames=varargin;
    dirty=cellfun(@(name)bdIsLoaded(name)&&bdIsDirty(name),modelNames);

end


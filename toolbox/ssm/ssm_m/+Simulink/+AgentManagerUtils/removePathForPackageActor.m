function removePathForPackageActor(cachedPath)
    rmpath(strjoin(cachedPath,pathsep));
end

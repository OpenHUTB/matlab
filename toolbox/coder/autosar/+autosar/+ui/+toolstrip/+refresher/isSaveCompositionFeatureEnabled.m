function ret=isSaveCompositionFeatureEnabled()




    ret=slfeature('SaveAUTOSARCompositionAsArchModel')>0;
end

function removeCustomBasemapImpl(basemapName)




    basemapGroup=matlab.internal.maps.BasemapSettingsGroup;
    basemapGroup.FunctionName='removeCustomBasemap';
    try
        removeGroup(basemapGroup,basemapName)


        map.internal.basemaps.removeCustomBasemapIcon(basemapName)
    catch e
        throwAsCaller(e)
    end
end

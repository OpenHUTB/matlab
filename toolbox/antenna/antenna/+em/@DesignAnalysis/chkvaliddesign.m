function[]=chkvaliddesign(class_obj)





    excludelist={'customAntennaMesh','customAntennaGeometry','customArrayMesh',...
    'customArrayGeometry','pcbStack','birdcage','lpda','planeWaveExcitation',...
    'installedAntenna','customAntennaStl','monopoleCustom','eggCrate','customDualReflectors',...
    'em.internal.authoring.customAntenna'};
    tf=strcmpi(class_obj,excludelist);

    if any(tf)
        validStr=validatestring(class_obj,excludelist);
        error(message('antenna:antennaerrors:Unsupported',...
        'design',validStr));
    end
end

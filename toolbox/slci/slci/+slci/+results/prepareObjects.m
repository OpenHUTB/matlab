

function prepareObjects(aObj,verification_data,datamgr)

    ProfilePrepObjects=slci.internal.Profiler('SLCI','PrepareObjects',...
    aObj.getModelName(),...
    aObj.getTargetName());


    slci.results.writeCompiledMetaData(aObj,datamgr);

    slci.results.prepareModelObjects(aObj);

    pfiler=slci.internal.Profiler('SLCI','prepareCodeObjects','','');
    slci.results.prepareCodeObjects(verification_data,datamgr);
    pfiler.stop();

    ProfilePrepObjects.stop();

end

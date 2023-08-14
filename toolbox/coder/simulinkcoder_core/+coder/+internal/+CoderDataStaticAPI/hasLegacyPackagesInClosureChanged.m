function val=hasLegacyPackagesInClosureChanged(sourceDD)
    cdefSourcesNeedingUpdate=coder.internal.CoderDataStaticAPI.checkIfLegacyPackagesInClosureChanged(sourceDD);
    val=~isempty(cdefSourcesNeedingUpdate);
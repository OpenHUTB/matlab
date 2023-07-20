

function prepareModelObjects(Config,reader,mfModel)
    assert(nargin==1||nargin==3);


    isResultsMF=(nargin==3);

    pfiler=slci.internal.Profiler('SLCI','ConstructModelObjects','','');

    if isResultsMF
        keyToHandle=slci.results.constructModelObjects(Config,reader,mfModel);
    else
        keyToHandle=slci.results.constructModelObjects(Config);
    end
    pfiler.stop();


    pfiler=slci.internal.Profiler('SLCI','SetBlockProperty','','');


    if isResultsMF
        slci.results.setOriginalBlock(keyToHandle,reader);
    else
        slci.results.setOriginalBlock(keyToHandle,Config);
    end

    if isResultsMF
        slci.results.setBlockProperties(keyToHandle,Config,reader);
    else
        slci.results.setBlockProperties(keyToHandle,Config);
    end

    pfiler.stop();

end

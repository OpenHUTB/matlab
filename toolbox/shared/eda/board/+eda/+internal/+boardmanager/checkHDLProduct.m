function checkHDLProduct



    isHDLAvailable=...
    eda.internal.boardmanager.isHDLCoderAvailable||...
    eda.internal.boardmanager.isHDLVerifierAvailable;

    if~isHDLAvailable
        error(message('EDALink:boardmanager:HDLProductNotAvailable'));
    end


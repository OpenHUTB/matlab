


function helpview(anchor)
    if eda.internal.boardmanager.isHDLVerifierAvailable
        helpview(fullfile(docroot,'toolbox','hdlverifier','helptargets.map'),anchor);
    else
        helpview(fullfile(docroot,'toolbox','hdlcoder','helptargets.map'),anchor);
    end
end

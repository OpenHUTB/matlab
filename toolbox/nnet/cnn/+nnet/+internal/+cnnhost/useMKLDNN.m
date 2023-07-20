function tf=useMKLDNN(newstate)







    persistent mklLoaded
    if isempty(mklLoaded)
        matlab.internal.language.versionPlugins.lapack;
        mklLoaded=true;
    end
    if nargin<1
        tf=eval('nnet.internal.cnnhost.setMKLDNNState()');
    else
        tf=eval('nnet.internal.cnnhost.setMKLDNNState(newstate)');
    end
end
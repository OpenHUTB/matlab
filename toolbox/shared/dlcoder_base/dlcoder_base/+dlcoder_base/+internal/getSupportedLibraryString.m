



function supportedLibraryStr=getSupportedLibraryString(supportedLibraries)
    numSupportedLibraries=numel(supportedLibraries);
    assert(numSupportedLibraries>=1);

    supportedLibraryStr=supportedLibraries{1};
    for k=2:numSupportedLibraries
        supportedLibraryStr=[supportedLibraryStr,', ',supportedLibraries{k}];%#ok
    end
end
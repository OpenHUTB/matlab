function relealseStr=getCurrentRelease()
    relealseStr=getenv('SUPPORTPACKAGEROOT_MATLAB_RELEASE');

    if isempty(relealseStr)
        relealseStr=matlabshared.supportpkg.internal.util.getCurrentReleaseInternal();
    end

    token=regexpi(relealseStr,'R\d{4,4}[ab][^\)]*','match','once');
    relealseStr=['(',token,')'];

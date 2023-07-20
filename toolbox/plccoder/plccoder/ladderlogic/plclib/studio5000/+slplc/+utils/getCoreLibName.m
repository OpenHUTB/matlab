function coreLibName=getCoreLibName()
    target='studio5000';
    if plcfeature('PLCUseLinkedLDLib')
        coreLibName=[target,'_corelib_test'];
    else
        coreLibName=[target,'_corelib'];
    end
end
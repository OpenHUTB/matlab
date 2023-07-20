function unlinkAndUnmaskBlock(blockPath)





    referenceBlock=get_param(blockPath,'ReferenceBlock');
    assert(~isempty(referenceBlock),'Expected reference block');

    referenceRoot=bdroot(referenceBlock);
    assert(strcmp(get_param(referenceRoot,'LibraryType'),'BlockLibrary'),'Expected block library');


    load_system(referenceRoot);


    lockStatus=get_param(referenceRoot,'Lock');
    lockLinksStatus=get_param(referenceRoot,'LockLinksToLibrary');


    set_param(referenceRoot,'Lock','off');
    set_param(referenceRoot,'LockLinksToLibrary','off');


    set_param(blockPath,'LinkStatus','none');
    maskObj=Simulink.Mask.get(blockPath);
    maskObj.delete;


    set_param(referenceRoot,'LockLinksToLibrary',lockLinksStatus);
    set_param(referenceRoot,'Lock',lockStatus);

end

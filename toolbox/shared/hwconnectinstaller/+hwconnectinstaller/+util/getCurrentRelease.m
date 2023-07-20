function rel=getCurrentRelease()





















    rel=hwconnectinstaller.util.getCurrentReleaseInternal();



    token=regexpi(rel,'R\d{4,4}[ab][^\)]*','match','once');
    rel=['(',token,')'];

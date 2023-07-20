function closeExistingUI(hSetup)










    validateattributes(hSetup,{'hwconnectinstaller.Setup'},{'nonempty'},...
    'closeExistingUI','hSetup')
    if~isempty(hSetup.Explorer)
        hSetup.finish;
        hSetup.delete();
    end
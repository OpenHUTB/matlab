function openHelp(anchorID)




    if codertarget.internal.isSpPkgInstalled('xilinxsoc')
        spkgDocRoot=codertarget.internal.xilinxsoc.getDocRoot();
    elseif codertarget.internal.isSpPkgInstalled('intelsoc')
        spkgDocRoot=codertarget.internal.intelsoc.getDocRoot();
    end

    if isempty(spkgDocRoot)
        error(message('hwconnectinstaller:setup:HelpMissing'));
    end
    helpview(fullfile(spkgDocRoot,'helptargets.map'),anchorID);
end
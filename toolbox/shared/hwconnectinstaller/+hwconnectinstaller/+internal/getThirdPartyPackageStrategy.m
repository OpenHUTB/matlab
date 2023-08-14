function strategy=getThirdPartyPackageStrategy(tppkg)




    if isempty(tppkg.InstructionSet)

        strategy=hwconnectinstaller.internal.LegacyThirdPartyStrategy;
    else

        strategy=hwconnectinstaller.internal.InstructionSetThirdPartyStrategy;
    end
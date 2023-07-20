function showDialog(dialogType,systemUnderTest)



    dialogType=convertStringsToChars(dialogType);

    systemUnderTest=convertStringsToChars(systemUnderTest);

    try
        Simulink.harness.dialogs.showDialog(dialogType,systemUnderTest);
    catch ME
        throwAsCaller(ME);
    end
end

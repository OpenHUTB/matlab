function load(harnessOwner,harnessName)


















    harnessOwner=convertStringsToChars(harnessOwner);

    harnessName=convertStringsToChars(harnessName);

    try
        Simulink.harness.internal.load(harnessOwner,harnessName,true);
    catch ME
        throwAsCaller(ME);
    end
end

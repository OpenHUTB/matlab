function push(harnessOwner,harnessName)
























    harnessOwner=convertStringsToChars(harnessOwner);

    harnessName=convertStringsToChars(harnessName);

    try
        Simulink.harness.internal.push(harnessOwner,harnessName);
    catch ME
        throwAsCaller(ME);
    end

end


function delete(harnessOwner,harnessName)



















    harnessOwner=convertStringsToChars(harnessOwner);

    harnessName=convertStringsToChars(harnessName);

    try
        Simulink.harness.internal.delete(harnessOwner,harnessName);
    catch ME
        throwAsCaller(ME);
    end
end

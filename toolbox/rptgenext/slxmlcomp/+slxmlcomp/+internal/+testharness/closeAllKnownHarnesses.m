

function closeAllKnownHarnesses(modelFilePath)

    if(exist('slxmlcomp.internal.testharness.MemoryNames','class')==0)
        return;
    end

    harnesses=slxmlcomp.internal.testharness.MemoryNames.getAll(modelFilePath);

    for ii=1:numel(harnesses)
        close_system(harnesses{ii},0);
    end
    slxmlcomp.internal.testharness.MemoryNames.remove(modelFilePath);
end

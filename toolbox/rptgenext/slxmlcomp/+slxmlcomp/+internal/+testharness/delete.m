function delete(harnessOwner,harnessName)



    slxmlcomp.internal.testharness.closeAll(harnessOwner);

    Simulink.harness.delete(harnessOwner,harnessName);
end


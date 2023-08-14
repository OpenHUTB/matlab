function closeAndDeleteHarness(subsys,hrnsName)
    if~isempty(sltest.harness.find(subsys,'OpenOnly','on','Name',hrnsName))
        Simulink.harness.close(subsys,hrnsName);
    end
    Simulink.harness.delete(subsys,hrnsName);
end



function SimulinkTest(filename)
    tf=sltest.testmanager.TestFile(filename);
    tf.run();
    sltestmgr;
end

function tlmgenerator_checkresults(subsysPath,subsysName)





    tbobj=tlmg.TLMTestbench(subsysPath,subsysName);
    tbobj.checkResults();

end

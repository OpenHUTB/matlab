function saveDataDictionary(dictFilePath)




    ddConn=Simulink.dd.open(dictFilePath);
    ddConn.saveChanges();

end

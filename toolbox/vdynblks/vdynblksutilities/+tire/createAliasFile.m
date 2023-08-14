function createAliasFile
    fileMgr=matlab.alias.AliasFileManager;
    addAlias(fileMgr,NewName="tire.tire",OldNames="Tire");
    writeAliasFile(fileMgr);
end
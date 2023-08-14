function flag=isBlockCondCheckEnabled(checkName)



    testComp=Sldv.Token.get.getTestComponent;
    blockCondCheck=testComp.activeSettings.DetectBlockConditions;
    flag=contains(blockCondCheck,checkName);
end
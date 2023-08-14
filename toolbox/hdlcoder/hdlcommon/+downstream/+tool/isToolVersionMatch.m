function isMatch=isToolVersionMatch(ver1,ver2)




    verID1=downstream.tool.getToolVersionNumber(ver1);
    verID2=downstream.tool.getToolVersionNumber(ver2);
    isMatch=verID1==verID2;

end
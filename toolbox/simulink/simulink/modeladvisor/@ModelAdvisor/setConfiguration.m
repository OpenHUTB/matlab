function success=setConfiguration(filePath)






    am=Advisor.Manager.getInstance;
    am.slCustomizationDataStructure.APIConfigFilePath=filePath;
    success=true;

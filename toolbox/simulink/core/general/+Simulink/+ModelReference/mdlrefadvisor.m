




function mdlrefadvisor(subsys)
    subsys=Simulink.ModelReference.Conversion.Utilities.getHandles(subsys);
    topModel=getfullname(bdroot(subsys(1)));


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(...
    topModel,'new',Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorMainGroupId);
    mdladvObj.UserData.ModelRefAdvisor=Simulink.ModelReference.Conversion.ModelRefAdvisorData(mdladvObj,subsys);


    guiParamObj=Simulink.ModelReference.Conversion.GuiParameters.getGuiParameters(mdladvObj,topModel);
    guiParamObj.update;
    Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.reset(mdladvObj);
    mdladvObj.displayExplorer


    mdladvObj.ResetAfterAction=false;
    mdladvObj.ShowActionResultInRpt=true;
end


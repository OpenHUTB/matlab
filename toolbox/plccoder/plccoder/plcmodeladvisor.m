function plcmodeladvisor(blkH)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(blkH,'new','_SYSTEM_By Task_SimulinkPLCCoder');
    CustomObj=ModelAdvisor.Customization;

    CustomObj.GUITitle='plcmodeladvisor';
    CustomObj.GUICloseCallback={};
    CustomObj.MenuSettings.Visible=false;
    CustomObj.MenuHelp.Visible=false;

    mdladvObj.CustomObject=CustomObj;
    mdladvObj.displayExplorer();
    mdladvObj.MAExplorer.title=[DAStudio.message('plccoder:modeladvisor:ProductDescription'),' - ',getfullname(blkH)];

end
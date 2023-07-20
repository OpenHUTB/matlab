function[applicationData]=doBuild_OverwriteTLC(blockHandle,applicationData)




    sfunctionName=applicationData.SfunWizardData.SfunName;
    sfunctionTLCName=[sfunctionName,'.tlc'];
    sfbController=sfunctionbuilder.internal.sfunctionbuilderController.getInstance();

    if(sfcnbuilder.isFileInCurrentDir(sfunctionTLCName)&&~applicationData.rtwsimTest&&...
        ~(applicationData.SfunWizardData.UseSimStruct=='1')&&applicationData.SfunWizardData.GenerateTLC=='1')
        sfunctionTLCName=strrep(sfunctionTLCName,'\','\\');
        str=DAStudio.message('Simulink:blocks:SFunctionBuilderOverwritingTLC',sfunctionTLCName);


        applicationData=sfbController.refreshViews(blockHandle,'set sfunction tlc overwritable',str);
    else
        applicationData=sfcnbuilder.doFinish(blockHandle,applicationData);
    end

end

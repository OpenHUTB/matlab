function[applicationData]=doBuild_OverwriteSfunction(blockHandle,applicationData)




    sfunctionName=applicationData.SfunWizardData.SfunName;
    fileName=sfcnbuilder.addextension(sfunctionName,applicationData.LangExt);
    sfbController=sfunctionbuilder.internal.sfunctionbuilderController.getInstance();

    if(sfcnbuilder.isFileInCurrentDir(fileName)&&isempty(applicationData.Overwritable)&&~applicationData.rtwsimTest)
        fileName=which(fileName);

        fileName=strrep(fileName,'\','\\');
        str=DAStudio.message('Simulink:blocks:SFunctionBuilderOverwritingFile',fileName);
        sfbController.refreshViews(blockHandle,'set source file overwritable',str);
    else


        applicationData.Overwritable='Yes';
        applicationData=sfcnbuilder.doBuild_OverwriteTLC(blockHandle,applicationData);
    end

end

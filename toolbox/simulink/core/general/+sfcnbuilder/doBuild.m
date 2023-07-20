function doBuild(blockHandle,applicationData)




    sfunctionName=applicationData.SfunWizardData.SfunName;
    sfunctionTLCName=[sfunctionName,'.tlc'];
    sfbController=sfunctionbuilder.internal.sfunctionbuilderController.getInstance();
    if(~isvarname(deblank(sfunctionName)))
        InvalidSFunNameMsg=DAStudio.message('Simulink:blocks:SFunctionBuilderInvalidName',sfunctionName);
        sfbController.refreshViews(blockHandle,'invalid sfunction name',InvalidSFunNameMsg);
        return
    end

    if(exist(sfunctionName)==4)
        InvalidSFunNameMsg=sprintf(['Error: A block diagram was specified in ''',ad.blockName,'''',10...
        ,'Please make sure your S-function name is not a Simulink model',10...
        ,'or the name of the current model.']);
        sfbController.refreshViews(blockHandle,'invalid sfunction name',InvalidSFunNameMsg);
        return
    end
    applicationData=sfcnbuilder.sfunbuilderLangExt('ComputeLangExtFromWidget',applicationData);
    sfunctionName=sfcnbuilder.addextension(sfunctionName,applicationData.LangExt);

    if(sfcnbuilder.isFileInCurrentDir(sfunctionName)&&isempty(applicationData.Overwritable)&&~applicationData.rtwsimTest)
        sfunctionName=which(sfunctionName);

        sfunctionName=strrep(sfunctionName,'\','\\');
        str=DAStudio.message('Simulink:blocks:SFunctionBuilderOverwritingFile',sfunctionName);
        sfbController.refreshViews(blockHandle,'set source file overwritable',str);
    else


        applicationData.Overwritable='Yes';
    end

    if(sfcnbuilder.isFileInCurrentDir(sfunctionTLCName)&&~applicationData.rtwsimTest&&...
        ~(applicationData.SfunWizardData.UseSimStruct=='1')&&applicationData.SfunWizardData.GenerateTLC=='1')
        sfunctionTLCName=strrep(sfunctionTLCName,'\','\\');
        str=DAStudio.message('Simulink:blocks:SFunctionBuilderOverwritingTLC',sfunctionTLCName);
        sfbController.refreshViews(blockHandle,'set sfunction tlc overwritable',str);
    end

    applicationData=sfcnbuilder.doFinish(blockHandle,applicationData);
end

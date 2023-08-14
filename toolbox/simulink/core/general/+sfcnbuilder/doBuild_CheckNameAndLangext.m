function[applicationData,abortClose]=doBuild_CheckNameAndLangext(blockHandle,applicationData,saveCodeOnly)











    if nargin==2
        saveCodeOnly=false;
    end
    abortClose=false;
    sfunctionName=applicationData.SfunWizardData.SfunName;
    sfbController=sfunctionbuilder.internal.sfunctionbuilderController.getInstance();
    applicationData.buildLog='';
    if(~isvarname(deblank(sfunctionName)))
        InvalidSFunNameMsg=DAStudio.message('Simulink:blocks:SFunctionBuilderInvalidName',sfunctionName);
        sfbController.refreshViews(blockHandle,'invalid sfunction name',InvalidSFunNameMsg);
        abortClose=true;
        return
    end



    parameters=applicationData.SfunWizardData.Parameters;
    if~isempty(parameters.Name)&&~isempty(parameters.Name{1})
        try
            paramValueString=sfcnbuilder.getDelimitedParameterStr(parameters);


            set_param(getfullname(applicationData.inputArgs),'Parameters',paramValueString);
        catch

        end
    end



    if(exist(sfunctionName,'file')==4)


        potentialPackageFile=[sfunctionName,getSFcnPackageExtension];
        files=which(potentialPackageFile);
        if~isempty(files)
            if iscell(files)
                potentialPackageFile=files{1};
            else
                potentialPackageFile=files;
            end
        end

        try
            isSFcnPackage=Simulink.SFcnPackage.isSFcnPackage(sfunctionName,...
            potentialPackageFile);
        catch
            isSFcnPackage=false;
        end
        if~isSFcnPackage
            InvalidSFunNameMsg=DAStudio.message('Simulink:SFunctionBuilder:NameConflictWithAModel',applicationData.blockName);
            sfbController.refreshViews(blockHandle,'invalid sfunction name',InvalidSFunNameMsg);
            abortClose=true;
            return
        end
    end


    applicationData=ComputeLangExtFromGUI(blockHandle,applicationData);

    if(saveCodeOnly)
        [applicationData,abortClose]=sfcnbuilder.doFinish(blockHandle,applicationData,saveCodeOnly);
    else
        applicationData=sfcnbuilder.doBuild_OverwriteSfunction(blockHandle,applicationData);
    end

end

function applicationData=ComputeLangExtFromGUI(blockHandle,applicationData)
    langExt=applicationData.SfunWizardData.LangExt;
    assert(any(strcmpi(langExt,{'inherit','cpp','c'})));
    if strcmpi(langExt,'inherit')


        if~strcmp(get_param(bdroot(blockHandle),'BlockDiagramType'),'model')
            langExt='c';
        else
            genCPP=rtwprivate('rtw_is_cpp_build',bdroot(blockHandle));
            if genCPP
                langExt='cpp';
            else
                langExt='c';
            end
        end
    end
    applicationData.LangExt=langExt;
end

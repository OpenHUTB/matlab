function[ad,abortClose]=doFinish(blockHandle,applicationData,saveCodeOnlyFromAlert)




    abortClose=false;
    sfunctionName=applicationData.SfunWizardData.SfunName;

    if nargin==2
        saveCodeOnlyFromAlert=false;
    end
    sfunctionFullName=sfcnbuilder.addextension(sfunctionName,applicationData.LangExt);

    sfbController=sfunctionbuilder.internal.sfunctionbuilderController.getInstance();



    if(saveCodeOnlyFromAlert)


    end

    if~isfield(applicationData,'buildLog')
        applicationData.buildLog='';
    end

    [ad,isValid,errorMessage,p]=sfcnbuilder.sfbcheckports(applicationData);
    if(~isValid)
        sfbController.refreshViews(blockHandle,'refresh buildlog',errorMessage);
        abortClose=true;
        ad.buildLog=errorMessage;
        return
    end


    [ad,isValid,errorMessage,d]=sfcnbuilder.sfbcheckstates(ad);
    if(~isValid)
        sfbController.refreshViews(blockHandle,'refresh buildlog',errorMessage);
        abortClose=true;
        ad.buildLog=errorMessage;
        return
    end

    try
        ad=sfcnbuilder.createCompileCSfun(blockHandle,ad,sfunctionFullName,p,d,saveCodeOnlyFromAlert);
    catch exception
        cleanGeneratedFiles(ad);
        abortClose=true;
        errorMessage=exception.message;

        errorMessage=regexprep(errorMessage,'</?a(|\s+[^>]+)>','');
        sfbController.refreshViews(blockHandle,'refresh buildlog',errorMessage);
        ad.buildLog=errorMessage;
    end
end

function ad=cleanGeneratedFiles(ad)

    mexFileName=[ad.SfunWizardData.SfunName,'.',mexext];
    if exist(mexFileName,'file')
        delete(mexFileName);
    end
    tlcFileName=[ad.SfunWizardData.SfunName,'.tlc'];
    if exist(tlcFileName,'file')
        delete(tlcFileName);
    end
    cFileName=[ad.SfunWizardData.SfunName,'.',ad.LangExt];
    if exist(cFileName,'file')
        delete(cFileName);
    end
    cFileNameWrapper=[ad.SfunWizardData.SfunName,'_wrapper.',ad.LangExt];
    if exist(cFileNameWrapper,'file')
        delete(cFileNameWrapper);
    end
end

function[ad]=read_sfunction_code(ad)




    cmdToSetSfunWizardData='';
    sfunctionName=[ad.SfunWizardData.SfunName,'.',ad.LangExt];
    if(exist(sfunctionName,'file')==2)
        sfunctionName=which(sfunctionName);
        clear(sfunctionName);


        ad.Version='';
        try
            [cmdToSetSfunWizardData,cmdToSetADVer]=slprivate('read_sfunwiz',sfunctionName);
            eval(cmdToSetADVer);
        catch SFBException
            warning(SFBException.identifier,'%s',SFBException.getReport('basic'));
        end
        switch(ad.Version)
        case '1.0'
        case '2.0'
        case '3.0'
        otherwise
            disp(DAStudio.message('Simulink:blocks:SFunctionBuilderInvalidBuilderVersion',sfunctionName))
        end
    end

    try
        cmdToSetSfunWizardData=strrep(cmdToSetSfunWizardData,'"','');
        eval(cmdToSetSfunWizardData);
        ad.SfunWizardData.DiscreteStatesIC=strrep(ad.SfunWizardData.DiscreteStatesIC,'[','');
        ad.SfunWizardData.DiscreteStatesIC=strrep(ad.SfunWizardData.DiscreteStatesIC,']','');
        ad.SfunWizardData.ContinuousStatesIC=strrep(ad.SfunWizardData.ContinuousStatesIC,']','');
        ad.SfunWizardData.ContinuousStatesIC=strrep(ad.SfunWizardData.ContinuousStatesIC,'[','');
        if~isempty(strmatch('__SFB__',ad.SfunWizardData.LibraryFilesText))
            ad.SfunWizardData.LibraryFilesText=strrep(ad.SfunWizardData.LibraryFilesText,'__SFB__',newline);
        else

            if~isfield(ad.SfunWizardData,'LibraryFilesTable')

                ad.SfunWizardData.LibraryFilesText=regexprep(ad.SfunWizardData.LibraryFilesText,'(?<!((INC(LUDE)?_PATH)|(LIB(RARY)?_PATH)|ENV_PATH|SRC_PATH))\s+(?=\S+)','\n');
            end
        end
        if(strcmp(ad.Version,'1.0'))
            ad.SfunWizardData.InputPortWidth=strrep(ad.SfunWizardData.InputPortWidth,'DYNAMICALLY_SIZED','-1');
            ad.SfunWizardData.OutputPortWidth=strrep(ad.SfunWizardData.OutputPortWidth,'DYNAMICALLY_SIZED','-1');
        end
        if strcmp(ad.SfunWizardData.SampleTime,'INHERITED_SAMPLE_TIME')
            ad.SfunWizardData.SampleTime=getString(message('Simulink:dialog:inheritedLabel'));
        elseif strcmp(ad.SfunWizardData.SampleTime,'0')
            ad.SfunWizardData.SampleTime=getString(message('Simulink:dialog:continuousLabel'));
        end
        if(~strcmp(ad.SfunWizardData.GenerateTLC,'0')&&(~strcmp(ad.SfunWizardData.GenerateTLC,'1')))
            ad.SfunWizardData.GenerateTLC='0';
        end
    catch

    end
end

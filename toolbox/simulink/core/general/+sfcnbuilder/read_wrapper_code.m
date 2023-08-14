function[ad]=read_wrapper_code(ad)




    wrapper_sfunctionName=[ad.SfunWizardData.SfunName,'_wrapper.',ad.LangExt];

    if(exist(wrapper_sfunctionName,'file')==2)
        wrapper_sfunctionName=which(wrapper_sfunctionName);
        clear(wrapper_sfunctionName);

        startInfo.textMarker{1}='SFUNWIZ_wrapper_Start_Changes_BEGIN';
        startInfo.textMarker{2}='SFUNWIZ_wrapper_Start_Changes_END';
        startInfo.textMarker{3}=[ad.SfunWizardData.SfunName,'Start_wrapper'];
        startInfo.beginCode=0;
        startInfo.endCode=0;
        startInfo.functionSignature='';

        outputInfo.textMarker{1}='SFUNWIZ_wrapper_Outputs_Changes_BEGIN';
        outputInfo.textMarker{2}='SFUNWIZ_wrapper_Outputs_Changes_END';
        outputInfo.beginCode=0;
        outputInfo.endCode=0;

        updateInfo.textMarker{1}='SFUNWIZ_wrapper_Update_Changes_BEGIN';
        updateInfo.textMarker{2}='SFUNWIZ_wrapper_Update_Changes_END';
        updateInfo.beginCode=0;
        updateInfo.endCode=0;

        derivativesInfo.textMarker{1}='SFUNWIZ_wrapper_Derivatives_Changes_BEGIN';
        derivativesInfo.textMarker{2}='SFUNWIZ_wrapper_Derivatives_Changes_END';
        derivativesInfo.beginCode=0;
        derivativesInfo.endCode=0;

        terminateInfo.textMarker{1}='SFUNWIZ_wrapper_Terminate_Changes_BEGIN';
        terminateInfo.textMarker{2}='SFUNWIZ_wrapper_Terminate_Changes_END';
        terminateInfo.beginCode=0;
        terminateInfo.endCode=0;

        includesInfo.textMarker{1}='SFUNWIZ_wrapper_includes_Changes_BEGIN';
        includesInfo.textMarker{2}='SFUNWIZ_wrapper_includes_Changes_END';
        includesInfo.beginCode=0;
        includesInfo.endCode=0;

        externsInfo.textMarker{1}='SFUNWIZ_wrapper_externs_Changes_BEGIN';
        externsInfo.textMarker{2}='SFUNWIZ_wrapper_externs_Changes_END';
        externsInfo.beginCode=0;
        externsInfo.endCode=0;

        fid=fopen(wrapper_sfunctionName);
        if(fid==-1)
            MSLDiagnostic('Simulink:blocks:SFunctionBuilderCannotOpenFile',wrapper_sfunctionName).reportAsWarning;
            return;
        end
        UserCodeTextmdlStart='';
        UserCodeText='';
        UserCodeTextmdlUpdate='';
        UserCodeTextmdlDerivative='';
        UserCodeTextmdlTerminate='';
        IncludeHeadersText='';
        ExternalDeclaration='';




        try
            while 1
                tline=fgetl(fid);
                if~ischar(tline),break,end


                [IncludeHeadersText,includesInfo]=read_sections(IncludeHeadersText,tline,includesInfo);

                [ExternalDeclaration,externsInfo]=read_sections(ExternalDeclaration,tline,externsInfo);

                [UserCodeTextmdlStart,startInfo]=read_sections(UserCodeTextmdlStart,tline,startInfo);

                [UserCodeText,outputInfo]=read_sections(UserCodeText,tline,outputInfo);

                [UserCodeTextmdlUpdate,updateInfo]=read_sections(UserCodeTextmdlUpdate,tline,updateInfo);

                [UserCodeTextmdlDerivative,derivativesInfo]=read_sections(UserCodeTextmdlDerivative,tline,derivativesInfo);

                [UserCodeTextmdlTerminate,terminateInfo]=read_sections(UserCodeTextmdlTerminate,tline,terminateInfo);
            end
            if isempty(ad.SfunWizardData.UserCodeTextmdlStart)||startInfo.endCode==1
                ad.SfunWizardData.UserCodeTextmdlStart=UserCodeTextmdlStart;
            end
            if isempty(ad.SfunWizardData.UserCodeText)||outputInfo.endCode==1
                ad.SfunWizardData.UserCodeText=UserCodeText;
            end
            if isempty(ad.SfunWizardData.UserCodeTextmdlUpdate)||updateInfo.endCode==1
                ad.SfunWizardData.UserCodeTextmdlUpdate=UserCodeTextmdlUpdate;
            end
            if isempty(ad.SfunWizardData.UserCodeTextmdlDerivative)||derivativesInfo.endCode==1
                ad.SfunWizardData.UserCodeTextmdlDerivative=UserCodeTextmdlDerivative;
            end
            if isempty(ad.SfunWizardData.UserCodeTextmdlTerminate)||terminateInfo.endCode==1
                ad.SfunWizardData.UserCodeTextmdlTerminate=UserCodeTextmdlTerminate;
            end
            if isempty(ad.SfunWizardData.IncludeHeadersText)||includesInfo.endCode==1
                ad.SfunWizardData.IncludeHeadersText=IncludeHeadersText;
            end
            if isempty(ad.SfunWizardData.ExternalDeclaration)||externsInfo.endCode==1
                ad.SfunWizardData.ExternalDeclaration=ExternalDeclaration;
            end

        catch SFBException
            warning(SFBException.identifier,'%s',SFBException.getReport('basic'));
        end

        fclose(fid);
    end
end



function[textCode,infoCode]=read_sections(textCode,tline,infoCode)


    if(infoCode.beginCode&&isempty(strfind(tline,infoCode.textMarker{2}))&&~infoCode.endCode)
        textCode=[textCode,10,tline];
    end
    if~isempty(strfind(tline,infoCode.textMarker{1}))
        infoCode.beginCode=1;
    end

    if~isempty(strfind(tline,infoCode.textMarker{2}))
        infoCode.endCode=1;
    end
end

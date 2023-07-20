function ad=createCompileCSfun(blockHandle,ad,sfunctionName,p,d,saveCodeOnlyFromAlert)





    if(saveCodeOnlyFromAlert)
        ad.SfunWizardData.SaveCodeOnly='1';
    end


    set_param(ad.inputArgs,'WizardData',ad.SfunWizardData)

    set_param(bdroot(getfullname(ad.inputArgs)),'Dirty','on');

    sfbController=sfunctionbuilder.internal.sfunctionbuilderController.getInstance();


    libTextCode=ad.SfunWizardData.LibraryFilesText;
    [libFileList,srcFileList,objFileList,...
    addIncPaths,addLibPaths,addSrcPaths,...
    preProcList,preProcUndefList]=...
    slprivate('parseLibCodePaneText',libTextCode,ad.inputArgs);

    ad.SfunWizardData.LibraryFilesText=libTextCode;



    SFBInfoStruct.includePath=addIncPaths;
    SFBInfoStruct.sourcePath=addSrcPaths;
    sfBuilderBlockNameMATFile=['.',filesep,'SFB__'...
    ,ad.SfunWizardData.SfunName...
    ,'__SFB.mat'];
    libAndObjFilesWithFullPath=slprivate('locateFileInPath',{libFileList{:},objFileList{:}},...
    {addLibPaths{:},addSrcPaths{:},pwd},...
    filesep);
    srcFilesSearchPaths={addSrcPaths{:},'./'};
    srcFilesWithFullPath=slprivate('locateFileInPath',srcFileList,srcFilesSearchPaths,filesep);
    if~isempty(libFileList)||~isempty(objFileList)
        SFBInfoStruct.additionalLibraries={libAndObjFilesWithFullPath{:}};
        for nAddLib=1:length(SFBInfoStruct.additionalLibraries)
            SFBInfoStruct.additionalLibraries{nAddLib}=rtw_alt_pathname(SFBInfoStruct.additionalLibraries{nAddLib});
        end
    end
    if exist(sfBuilderBlockNameMATFile)%#ok
        delete(sfBuilderBlockNameMATFile);
    end
    try
        eval(['save ',sfBuilderBlockNameMATFile,' ','SFBInfoStruct']);
    catch SFBException
        newExc=MException(message('Simulink:SFunctionBuilder:CouldNotCreateMATFileForCodeGen',sfBuilderBlockNameMATFile));
        newExc=newExc.addCause(SFBException);
        warning(newExc.identifier,'%s',newExc.getReport('basic'));
    end
    clear SFBInfoStruct;
    currentArgs=get_param(bdroot,'RTWMakeCommand');
    preprocUpdatedMakeCmd=UpdatePreProcDefsInMakeCmd(currentArgs,preProcList,preProcUndefList);
    preprocWarningMsg=[];
    if(~strcmp(currentArgs,preprocUpdatedMakeCmd))
        try
            set_param(bdroot,'RTWMakeCommand',preprocUpdatedMakeCmd);
        catch SFBException
            preprocWarningMsg=DAStudio.message('Simulink:blocks:SFunctionBuilderReferenceConfigSetWarning',preprocUpdatedMakeCmd);
            callDiagnosticViewer(ad,preprocWarningMsg,'Warning');
        end
    end
    methodsFlags=['0';'0'];
    if(~isempty(ad.SfunWizardData.UserCodeTextmdlStart)&&...
        ~strcmp(ad.SfunWizardData.UserCodeTextmdlStart,strtrim(DAStudio.message('Simulink:SFunctionBuilder:SampleCodeStart'))))
        methodsFlags(1)='1';
    end
    if(~isempty(ad.SfunWizardData.UserCodeTextmdlTerminate)&&...
        ~strcmp(ad.SfunWizardData.UserCodeTextmdlTerminate,strtrim(DAStudio.message('Simulink:SFunctionBuilder:SampleCodeTerminate'))))
        methodsFlags(2)='1';
    end






    libTextCodeForTempFile=regexprep(libTextCode,sprintf('\n'),'__SFB__');
    libTextCodeForTempFile=['__SFB__',libTextCodeForTempFile];
    wizardParamsTempFile=tempname;

    [busUsed,busHeader]=busInfo(ad.SfunWizardData.InputPorts,ad.SfunWizardData.OutputPorts,bdroot(ad.inputArgs));
    busHeaderFile=tempname;
    busInfoStruct=generateFileParams(wizardParamsTempFile,busHeaderFile,p.NumberOfInputs,p.NumberOfOutputs,...
    ad.SfunWizardData.DirectFeedThrough,p.SampleTime,p.NumberOfParameters,...
    d.NumDStates,d.DStatesIC,d.NumCStates,d.CStatesIC,d.NumPWorks,d.NumDWorks,...
    ad.SfunWizardData.GenerateTLC,libTextCodeForTempFile,'N/A',...
    ad.SfunWizardData.SfunName,...
    ad.SfunWizardData.Majority,...
    ad.SfunWizardData.InputPorts,...
    ad.SfunWizardData.OutputPorts,...
    busUsed,busHeader,...
    ad.SfunWizardData.Parameters,methodsFlags,...
    ad.SfunWizardData.UseSimStruct,...
    ad.SfunWizardData.ShowCompileSteps,...
    ad.SfunWizardData.CreateDebugMex,...
    ad.SfunWizardData.SaveCodeOnly,...
    i_getCoverageSupport(ad.SfunWizardData),...
    i_getSldvSupport(ad.SfunWizardData),...
    ad.SfunWizardData.SupportForEach,...
    ad.SfunWizardData.EnableMultiThread,...
    ad.SfunWizardData.EnableCodeReuse,...
    bdroot(ad.inputArgs));
    if isequal(busInfoStruct,-1)
        return;
    end





    [mdlStartTempFile,mdlStartTextCode]=CreateTempFile(ad.SfunWizardData.UserCodeTextmdlStart,'tfmdlStart');
    ad.SfunWizardData.UserCodeTextmdlStart=mdlStartTextCode;

    [mdlOutputTempFile,mdlOutputTextCode]=CreateTempFile(ad.SfunWizardData.UserCodeText,'tfmdlOutput');
    ad.SfunWizardData.UserCodeText=mdlOutputTextCode;

    [mdlUpdateTempFile,mdlUpdateTextCode,...
    flagDeletemdlUpdate]=CreateTempFile(ad.SfunWizardData.UserCodeTextmdlUpdate,'tfmdlUpdate');
    ad.SfunWizardData.UserCodeTextmdlUpdate=mdlUpdateTextCode;
    if(isempty(mdlUpdateTextCode))
        mdlUpdateTempFile='NO_USER_DEFINED_DISCRETE_STATES';
    end

    [mdlDerivativeTempFile,mdlDerivativeTextCode,...
    flagDeletemdlDerivative]=CreateTempFile(ad.SfunWizardData.UserCodeTextmdlDerivative,'tfmdlDerivative');
    ad.SfunWizardData.UserCodeTextmdlDerivative=mdlDerivativeTextCode;
    if(isempty(mdlDerivativeTextCode))
        mdlDerivativeTempFile='NO_USER_DEFINED_CONTINUOS_STATES';
    end

    [mdlTerminateTempFile,mdlTerminateTextCode]=CreateTempFile(ad.SfunWizardData.UserCodeTextmdlTerminate,'tfmdlTerminate');
    ad.SfunWizardData.UserCodeTextmdlTerminate=mdlTerminateTextCode;

    [externDeclarationTempFile,externDeclarationTextCode,...
    flagDeleteexternDeclaration]=CreateTempFile(ad.SfunWizardData.ExternalDeclaration,'fExternTextArea');
    ad.SfunWizardData.ExternalDeclaration=externDeclarationTextCode;
    if(isempty(externDeclarationTextCode))
        externDeclarationTempFile='NO_USER_DEFINED_C_CODE';
    end

    [headersTempFile,headersTextCode,...
    flagDeleteHeader]=CreateTempFile(ad.SfunWizardData.IncludeHeadersText,'fIncludeHeaders');
    ad.SfunWizardData.IncludeHeadersText=headersTextCode;
    if(isempty(headersTextCode))
        headersTempFile='NO_USER_DEFINED_HEADER_CODE';
    end




    [~,sfunctionNameWrapper]=fileparts(ad.SfunWizardData.SfunName);
    sfunctionNameWrapper=[sfunctionNameWrapper,'_wrapper.',ad.LangExt];
    escApostrophe=@(x)regexprep(x,'''','''''');
    customSrcAndLibAndObj=[''''...
    ,slprivate('joinCellToStr',...
    escApostrophe(...
    {sfunctionNameWrapper,...
    libAndObjFilesWithFullPath{:},...
    srcFilesWithFullPath{:}}...
    ),...
    ''',''')...
    ,''''];

    pathFcnCall=fullfile(matlabroot,'toolbox','simulink','core','sfunctionwizard');
    [createmessagecli,createmessage,~]=generateFormatedMessage(ad,sfunctionName,busHeader,ad.SfunWizardData.GenerateTLC=='1');

    wizData=i_removeFieldFromWizData(ad);

    if(ad.CreateCompileMexFileFlag)
        str=DAStudio.message('Simulink:blocks:SFunctionBuilderGenerateMsg',sfunctionName);
        sfbController.refreshViews(blockHandle,'refresh buildlog',str);
        ad.buildLog=strcat(ad.buildLog,str);

        if(strcmp(ad.Version,''))
            ad.Version='3.0';
        end

        slVer=ver('Simulink');

        try
            slprivate('sfunctionwizardhelper',...
            sfunctionName,sfunctionNameWrapper,...
            mdlStartTempFile,mdlOutputTempFile,mdlUpdateTempFile,mdlDerivativeTempFile,mdlTerminateTempFile,headersTempFile,externDeclarationTempFile,pathFcnCall,wizardParamsTempFile,busHeaderFile,slVer.Version,ad.Version,busInfoStruct);
        catch SFBException

            str=SFBException.getReport('basic');
            sfbController.refreshViews(blockHandle,'refresh buildlog',str);
            ad.buildLog=str;
            return
        end


        sldvInfo=[];
        if i_getSldvSupport(ad.SfunWizardData)=='1'
            try
                sldvInfo=sldv.code.sfcn.internal.getSFcnInfoFromSfunWizard(ad);
            catch exception
                str=exception.message;
                sfbController.refreshViews(blockHandle,'refresh buildlog',str);
                ad.buildLog=str;
                return
            end
        end


        if(ad.SfunWizardData.SaveCodeOnly=='1')
            sfbController.refreshViews(blockHandle,'refresh buildlog',createmessagecli,createmessage);
            ad.buildLog=strcat(ad.buildLog,createmessagecli);
            deleteTempFiles(mdlOutputTempFile);
            deleteTempFiles(wizardParamsTempFile);

            if(flagDeletemdlUpdate)
                deleteTempFiles(mdlUpdateTempFile);
            end
            if(flagDeleteHeader)
                deleteTempFiles(headersTempFile);
            end

            if(flagDeleteexternDeclaration)
                deleteTempFiles(externDeclarationTempFile);
            end

            if(flagDeletemdlDerivative)
                deleteTempFiles(mdlDerivativeTempFile);
            end
            set_param(getfullname(ad.inputArgs),'FunctionName',regexprep(sfunctionName,'\.c.*','','ignorecase'));

            filesForSFunctionModules='';
            for nS=1:length(srcFileList)
                [srcFulPath,srcNameOnly]=fileparts(srcFileList{nS});
                filesForSFunctionModules=[filesForSFunctionModules,' ',srcNameOnly];
            end
            if isempty(filesForSFunctionModules)
                filesForSFunctionModules=' ';
            else
                filesForSFunctionModules=strtrim(filesForSFunctionModules);
            end
            set_param(getfullname(ad.inputArgs),'SFunctionModules',...
            [regexprep(sfunctionName,'\.c.*','','ignorecase'),['_wrapper.',ad.LangExt],' ',...
            filesForSFunctionModules]);

            set_param(getfullname(ad.inputArgs),'WizardData',wizData);
            slblocksetdesignerHelper(ad,sfunctionName,sfunctionNameWrapper,0,'');
            return
        end


        sfbController.refreshViews(blockHandle,'refresh buildlog','');
        str=DAStudio.message('Simulink:blocks:SFunctionBuilderCompileMsg',sfunctionName);
        sfbController.refreshViews(blockHandle,'refresh buildlog',str);
        ad.buildLog=strcat(ad.buildLog,str);
        try
            [mexVerboseText,errorOccurred]=slprivate('sfbuilder_mexbuild',ad,sfunctionName,customSrcAndLibAndObj,...
            addIncPaths,preProcList,sldvInfo,ad.SfunWizardData.ShowCompileSteps=='1',...
            ad.SfunWizardData.CreateDebugMex=='1');
        catch ex
            errorOccurred=1;
            mexVerboseText=slprivate('getExceptionMsgReport',ex);
            if(isempty(mexVerboseText))
                mexVerboseText=sprintf(['\n\n\n\t\tAn unexpected error occurred during compilation. Please'...
                ,' verify the following:\n'...
                ,'\t\t -The MEX command is configured correctly. Type ''mex -setup'' at \n',...
                '\t\t  MATLAB command prompt to configure this command.\n',...
                '\t\t -The S-function settings in the Initialization or Libraries tab were entered incorrectly.\n',...
                '\t\t  (i.e. use comma separated list for the library/source files)\n',...
'\t\t -If S-Function Builder dialog box in an invalid state, please restart\n'...
                ,'\t\t  MATLAB before using this dialog further.']);
            end
        end
        sfbController.refreshViews(blockHandle,'refresh buildlog','');
        diagnosticMessage=[];

        if~errorOccurred
            textDisp=[DAStudio.message('Simulink:blocks:SFunctionBuilderCreation',getFileName(sfunctionName)),preprocWarningMsg];

            if ad.SfunWizardData.ShowCompileSteps=='1'
                textDisp=mexVerboseText;
                diagnosticMessage=[createmessage,mexVerboseText];
            else
                textDisp=[DAStudio.message('Simulink:blocks:SFunctionBuilderCreation',getFileName(sfunctionName)),preprocWarningMsg];
            end
            rtwsimTestDiagnostics(ad,textDisp);
        else
            if ad.SfunWizardData.ShowCompileSteps=='1'
                textDisp=mexVerboseText;
            else
                textDisp=sprintf('\nCompile of ''%s'' failed.\n\n',sfunctionName);
            end
            rtwsimTestDiagnostics(ad,mexVerboseText);
            diagnosticMessage=mexVerboseText;
        end




        textDisp=regexprep(textDisp,'</?a(|\s+[^>]+)>','');
        aFullMsgText=[createmessage,textDisp,'<br>'];
        aFullMsgTextcli=[createmessagecli,textDisp,newline];
        sfbController.refreshViews(blockHandle,'refresh buildlog',aFullMsgTextcli,aFullMsgText);
        ad.buildLog=strcat(ad.buildLog,aFullMsgTextcli);
        if~isempty(diagnosticMessage)
            if errorOccurred
                callDiagnosticViewer(ad,diagnosticMessage,'Error');
            else
                callDiagnosticViewer(ad,diagnosticMessage,'Info');
            end
        end
        ad.compileSuccess=~errorOccurred;

    end


    ad.AlertOnClose=1;
    if(ad.compileSuccess)
        if(ishandle(ad.inputArgs))
            if(~ad.isSimulink3)

                parameters=ad.SfunWizardData.Parameters;
                if nnz(parameters.Name~="")>0
                    paramValueString=sfcnbuilder.getDelimitedParameterStr(parameters);
                    set_param(getfullname(ad.inputArgs),'Parameters',paramValueString);
                else
                    set_param(getfullname(ad.inputArgs),'Parameters','');
                end
                set_param(getfullname(ad.inputArgs),'FunctionName',regexprep(sfunctionName,'\.c.*','','ignorecase'));

                set_param(bdroot(getfullname(ad.inputArgs)),'Dirty','on');
                setPortLabels(ad.inputArgs,ad.SfunWizardData.InputPorts,ad.SfunWizardData.OutputPorts);

                filesForSFunctionModules='';
                for nS=1:length(srcFileList)
                    [srcFulPath,srcNameOnly]=fileparts(srcFileList{nS});
                    filesForSFunctionModules=[filesForSFunctionModules,' ',srcNameOnly];
                end
                if isempty(filesForSFunctionModules)
                    filesForSFunctionModules=' ';
                else
                    filesForSFunctionModules=strtrim(filesForSFunctionModules);
                end

                set_param(getfullname(ad.inputArgs),'SFunctionModules',...
                [regexprep(sfunctionName,'\.c.*','','ignorecase'),['_wrapper.',ad.LangExt],' ',...
                filesForSFunctionModules]);
                set_param(getfullname(ad.inputArgs),'WizardData',wizData);
            else

            end
        end

        slblocksetdesignerHelper(ad,sfunctionName,sfunctionNameWrapper,errorOccurred,mexVerboseText);

        ad.AlertOnClose=0;
    elseif(~ad.isSimulink3)

        set_param(getfullname(ad.inputArgs),'WizardData',wizData);
    end




    deleteTempFiles(mdlOutputTempFile);
    deleteTempFiles(wizardParamsTempFile);
    if(flagDeletemdlUpdate)
        deleteTempFiles(mdlUpdateTempFile);
    end

    if(flagDeleteHeader)
        deleteTempFiles(headersTempFile);
    end

    if(flagDeleteexternDeclaration)
        deleteTempFiles(externDeclarationTempFile);
    end
    if(flagDeletemdlDerivative)
        deleteTempFiles(mdlDerivativeTempFile);
    end


    try
        evalin('base','rehash path')
    catch exception
        str=exceptionn.getReport('basic');
        sfbController.refreshViews(blockHandle,'refresh buildlog',str);
        ad.buildLog=str;
        return
    end

end


function val=i_getCoverageSupport(dataStruct)

    if isfield(dataStruct,'SupportCoverage')
        val=dataStruct.SupportCoverage;
    else
        val='0';
    end
end


function val=i_getSldvSupport(dataStruct)
    if isfield(dataStruct,'SupportSldv')
        val=dataStruct.SupportSldv;
    else
        val='0';
    end
end


function makeCmdStr=UpdatePreProcDefsInMakeCmd(currentMakeCmdStr,preProcList,preProcUndefList)
    makeCmdStr=currentMakeCmdStr;

    if~isempty(preProcList)
        preprocListStr='';
        for idx=1:length(preProcList)
            if isempty(preProcList{idx})
                continue
            end
            if isempty(regexp(currentMakeCmdStr,preProcList{idx}))
                preprocListStr=[preprocListStr,' -D',preProcList{idx},' '];
            end
        end
        if~isempty(preprocListStr)
            makeCmdStr=[makeCmdStr,' OPTS="',preprocListStr,'"'];
        end
    end

    if~isempty(preProcUndefList)
        for idx=1:length(preProcUndefList)
            if isempty(preProcUndefList{idx})
                continue
            end
            makeCmdStr=regexprep(makeCmdStr,['-D',preProcUndefList{idx}],'');
        end
    end
end


function callDiagnosticViewer(aSFuncWizardObj,aMsgText,aMsgType)
    aFullName=getfullname(aSFuncWizardObj.inputArgs);
    aModelName=strtok(aFullName,'/');
    aStageName='S-function Builder';
    aComponent='S-function Builder';
    aCategory='Build';
    aObjects={aFullName};


    aStageObj=Simulink.output.Stage(aStageName,'ModelName',aModelName,'UIMode',true);

    switch(lower(aMsgType))
    case 'error'
        Simulink.output.error(aMsgText,'Component',aComponent,'Category',aCategory,'Objects',aObjects);
    case 'info'
        Simulink.output.info(aMsgText,'Component',aComponent,'Category',aCategory,'Objects',aObjects);
    case 'warning'
        Simulink.output.warning(aMsgText,'Component',aComponent,'Category',aCategory,'Objects',aObjects);
    otherwise
        assert(false);
    end
end

function[busUsed,busHeader]=busInfo(iP,oP,model)
    busHeader=0;
    busUsed=0;

    for i=1:length(iP.Name)
        if strcmp(iP.Bus{i},'on')
            busUsed=1;
            slObj=evalinGlobalScope(model,iP.Busname{i});
            if isempty(strtrim(slObj.HeaderFile))
                busHeader=1;
            end
        end
    end

    for i=1:length(oP.Name)
        if strcmp(oP.Bus{i},'on')
            busUsed=1;
            slObj=evalinGlobalScope(model,oP.Busname{i});
            if isempty(strtrim(slObj.HeaderFile))
                busHeader=1;
            end
        end
    end
end

function busInfoStruct=generateFileParams(fileName,busHeaderFile,NumberOfInputs,NumberOfOutputs,directFeed,...
    SampleTime,NumberOfParameters,NumDStates,DStatesIC,...
    NumCStates,CStatesIC,NumPWorks,NumDWorks,CreateWrapperTLC,LibList,...
    PanelIndex,Sfunname,Majority,iP,oP,busUsed,busHeader,paramsList,methodsFlags,UseSimStructVal,...
    ShowCompileStepsVal,DebugMexVal,SaveCodeVal,SupportCoverageVal,SupportSldvVal,SupportForEachVal,EnableMultiThread,EnableCodeReuse,model)

    n1=['NumOfCStates=',NumCStates];
    n2=['CStatesIC=',CStatesIC];
    n3=['NumOfDStates=',NumDStates];
    n4=['DStatesIC=',DStatesIC];
    n5=['NumPWorks=',NumPWorks];
    n6=['NumDWorks=',NumDWorks];
    n7=['NumberOfParameters=',NumberOfParameters];
    n8=['SampleTime=',SampleTime];
    n9=['SFcnMajority=',Majority];
    n10=['CreateWrapperTLC=',CreateWrapperTLC];
    n11=['directFeed=',directFeed];
    n12=['LibList=',LibList];
    n13=['PanelIndex=',PanelIndex];
    n14=['UseSimStruct=',UseSimStructVal];
    n15=['ShowCompileSteps=',ShowCompileStepsVal];
    n16=['CreateDebugMex=',DebugMexVal];
    n17=['SaveCodeOnly=',SaveCodeVal];
    n18=['SupportCoverage=',SupportCoverageVal];
    n19=['SupportSldv=',SupportSldvVal];
    n20=['SupportForEach=',SupportForEachVal];
    n21=['EnableMultiThread=',EnableMultiThread];
    n22=['EnableCodeReuse=',EnableCodeReuse];

    iP.Dimensions{1}=NumberOfInputs;
    oP.Dimensions{1}=NumberOfOutputs;
    fidExtern=fopen(fileName,'w');
    fprintf(fidExtern,'%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',...
    n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20,n21,n22);

    if strcmp(iP.Name{1},'ALLOW_ZERO_PORTS')
        fprintf(fidExtern,'%s\n',['NumberOfInputPorts= 0']);
    else
        fprintf(fidExtern,'%s\n',['NumberOfInputPorts=',num2str(length(iP.Name))]);
    end
    if strcmp(oP.Name{1},'ALLOW_ZERO_PORTS')
        fprintf(fidExtern,'%s\n',['NumberOfOutputPorts= 0']);
    else
        fprintf(fidExtern,'%s\n',['NumberOfOutputPorts=',num2str(length(oP.Name))]);
    end

    fprintf(fidExtern,'%s\n',['GenerateStartFunction= ',methodsFlags(1)]);
    fprintf(fidExtern,'%s\n',['GenerateTerminateFunction= ',methodsFlags(2)]);

    for i=1:length(iP.Name)
        fprintf(fidExtern,'%s\n',['InPort',num2str(i),'{']);
        fprintf(fidExtern,'%s\n',['inPortName',num2str(i),'=',iP.Name{i}]);
        fprintf(fidExtern,'%s\n',['inDataType',num2str(i),'=',iP.DataType{i}]);
        fprintf(fidExtern,'%s\n',['inDims',num2str(i),'=',iP.Dims{i}]);
        fprintf(fidExtern,'%s\n',['inDimensions',num2str(i),'=',iP.Dimensions{i}]);
        fprintf(fidExtern,'%s\n',['inComplexity',num2str(i),'=',iP.Complexity{i}]);
        fprintf(fidExtern,'%s\n',['inBusBased',num2str(i),'=',iP.Bus{i}]);
        fprintf(fidExtern,'%s\n',['inBusname',num2str(i),'=',iP.Busname{i}]);
        fprintf(fidExtern,'%s\n',['inIsSigned',num2str(i),'=',iP.IsSigned{i}]);
        fprintf(fidExtern,'%s\n',['inWordLength',num2str(i),'=',iP.WordLength{i}]);
        fprintf(fidExtern,'%s\n',['inFractionLength',num2str(i),'=',iP.FractionLength{i}]);
        fprintf(fidExtern,'%s\n',['inFixPointScalingType',num2str(i),'=',iP.FixPointScalingType{i}]);
        fprintf(fidExtern,'%s\n',['inSlope',num2str(i),'=',iP.Slope{i}]);
        fprintf(fidExtern,'%s\n',['inBias',num2str(i),'=',iP.Bias{i}]);
        fprintf(fidExtern,'%s\n','}');
    end

    for i=1:length(oP.Name)
        fprintf(fidExtern,'%s\n',['OutPort',num2str(i),'{']);
        fprintf(fidExtern,'%s\n',['outPortName',num2str(i),'=',oP.Name{i}]);
        fprintf(fidExtern,'%s\n',['outDataType',num2str(i),'=',oP.DataType{i}]);
        fprintf(fidExtern,'%s\n',['outDims',num2str(i),'=',oP.Dims{i}]);
        fprintf(fidExtern,'%s\n',['outDimensions',num2str(i),'=',oP.Dimensions{i}]);
        fprintf(fidExtern,'%s\n',['outComplexity',num2str(i),'=',oP.Complexity{i}]);
        fprintf(fidExtern,'%s\n',['outBusBased',num2str(i),'=',oP.Bus{i}]);
        fprintf(fidExtern,'%s\n',['outBusname',num2str(i),'=',oP.Busname{i}]);
        fprintf(fidExtern,'%s\n',['outIsSigned',num2str(i),'=',oP.IsSigned{i}]);
        fprintf(fidExtern,'%s\n',['outWordLength',num2str(i),'=',oP.WordLength{i}]);
        fprintf(fidExtern,'%s\n',['outFractionLength',num2str(i),'=',oP.FractionLength{i}]);
        fprintf(fidExtern,'%s\n',['outFixPointScalingType',num2str(i),'=',oP.FixPointScalingType{i}]);
        fprintf(fidExtern,'%s\n',['outSlope',num2str(i),'=',oP.Slope{i}]);
        fprintf(fidExtern,'%s\n',['outBias',num2str(i),'=',oP.Bias{i}]);
        fprintf(fidExtern,'%s\n','}');
    end

    for i=1:length(paramsList.Name)
        fprintf(fidExtern,'%s\n',['Parameter',num2str(i),'{']);
        fprintf(fidExtern,'%s\n',['parameterName',num2str(i),'=',paramsList.Name{i}]);
        fprintf(fidExtern,'%s\n',['parameterDataType',num2str(i),'=',paramsList.DataType{i}]);
        fprintf(fidExtern,'%s\n',['parameterComplexity',num2str(i),'=',paramsList.Complexity{i}]);
        fprintf(fidExtern,'%s\n','}');
    end

    if busUsed
        try
            busInfoStruct=slprivate('sfbWriteBusInfo',...
            iP,oP,paramsList,fidExtern,busHeaderFile,busHeader,Sfunname,model);
        catch SFBException
            busInfoStruct=-1;
            str=SFBException.getReport('basic');
            sfbController.refreshViews(blockHandle,'refresh buildlog',str);
            ad.buildLog=str;
            return;
        end

    else
        busInfoStruct=[];
    end

    fclose(fidExtern);
end


function tempFileName=CreateTempFileFromText(tf)
    if isempty(tf)
        tf=' ';
    end


    tempFileName=tempname;
    fid=fopen(tempFileName,'w');
    fprintf(fid,'%s',tf);
    fclose(fid);
end

function[tempFileName,tf,delFlag]=CreateTempFile(ad,adField)

    tempFileName='';
    tf=ad;


    tf=char(tf);
    if isempty(tf)
        tf=' ';
    end

    if(~isempty(tf))
        delFlag=1;
        tempFileName=tempname;
        fid=fopen(tempFileName,'w');
        fprintf(fid,'%s',tf);
        fclose(fid);
    else
        delFlag=0;
    end
end

function[createmessagecli,createmessage,ad]=generateFormatedMessage(ad,sfunctionName,busHeader,generateTLC)

    textWidth=500;
    wrapperFile=[strtok(sfunctionName,'.'),'_wrapper.',ad.LangExt];



    str1=DAStudio.message('Simulink:SFunctionBuilder:CreationWithHyperlinks',sfunctionName,sfunctionName);
    str1cli=DAStudio.message('Simulink:blocks:SFunctionBuilderCreationWithHyperlinks',sfunctionName,sfunctionName);
    str2=DAStudio.message('Simulink:SFunctionBuilder:CreationWithHyperlinks',wrapperFile,wrapperFile);
    str2cli=DAStudio.message('Simulink:blocks:SFunctionBuilderCreationWithHyperlinks',wrapperFile,wrapperFile);

    space=blanks(textWidth);
    newLineSymbol='<br>';
    newLineSymbolcli=newline;

    createmessage=[space,str1,newLineSymbol,str2,newLineSymbol];
    createmessagecli=[space,str1cli,newLineSymbolcli,str2cli,newLineSymbolcli];

    if(generateTLC)
        sfunctionNameTLC=strrep(sfunctionName,['.',ad.LangExt],'.tlc');
        str3=DAStudio.message('Simulink:SFunctionBuilder:CreationWithHyperlinks',sfunctionNameTLC,sfunctionNameTLC);
        createmessage=[createmessage,str3,newLineSymbol];
        str3cli=DAStudio.message('Simulink:blocks:SFunctionBuilderCreationWithHyperlinks',sfunctionNameTLC,sfunctionNameTLC);
        createmessagecli=[createmessagecli,str3cli,newLineSymbolcli];
    end
    if(busHeader)
        sfunbusheaderName=[strrep(sfunctionName,['.',ad.LangExt],''),'_bus.h'];
        str4=DAStudio.message('Simulink:SFunctionBuilder:CreationWithHyperlinks',sfunbusheaderName,sfunbusheaderName);
        createmessage=[createmessage,str4,newLineSymbol];
        str4cli=DAStudio.message('Simulink:blocks:SFunctionBuilderCreationWithHyperlinks',sfunbusheaderName,sfunbusheaderName);
        createmessagecli=[createmessagecli,str4cli,newLineSymbolcli];
    end
end

function wizData=i_removeFieldFromWizData(ad)

    wizData=ad.SfunWizardData;
    try
        wizData=rmfield(wizData,{'InputDataType0','OutputDataType0','InputSignalType0','Input0DimsCol','Output0DimsCol',...
        'OutputSignalType0','InFrameBased0','OutFrameBased0','InBusBased0','OutBusBased0','OutBusname0','InBusname0','TemplateType','SignPackage','CertificateName'});
    end
end

function name=getFileName(name)
    name=strtok(name,'.');

    try
        clear(name);
        nameWithPath=which(name);
        p=filesep;
        indexp=findstr(nameWithPath,p);
        name=nameWithPath(1+indexp(end):end);
    end
end

function rtwsimTestDiagnostics(ad,textDisp)
    if ad.rtwsimTest
        disp(textDisp);
    end
end

function slblocksetdesignerHelper(ad,sfunctionName,sfunctionWrapperName,errorOccurred,mexVerboseText)
    isBlockSetSDK=ad.SfunWizardData.BlockSetSDK;
    if(isBlockSetSDK)
        blockRootDir=ad.SfunWizardData.BlockRootDir;
        moveToBlockSDK(sfunctionName,sfunctionWrapperName,blockRootDir,errorOccurred,mexVerboseText,ad);
    end
end


function setPortLabels(blkHandle,iP,oP)

    defaultMaskString=sprintf(['plot(val(:,1),val(:,2))','\n','disp(sys)']);
    inportString='';
    if~strcmp(iP.Name{1},'ALLOW_ZERO_PORTS')
        for k=1:length(iP.Name)
            portName=iP.Name{k};
            inportString=sprintf([inportString,'\n','port_label(''input'',',num2str(k),',','''',portName,''')']);
        end
    end
    defaultMaskString=[defaultMaskString,inportString];

    outportString='';
    if~strcmp(oP.Name{1},'ALLOW_ZERO_PORTS')
        for k=1:length(oP.Name)
            portName=oP.Name{k};
            outportString=sprintf([outportString,'\n','port_label(''output'',',num2str(k),',','''',portName,''')']);
        end
    end
    defaultMaskString=[defaultMaskString,outportString];

    set_param(blkHandle,'MaskDisplay',defaultMaskString);
end

function deleteTempFiles(name)

    name=strrep(name,'"','');
    delete(name);
end

function moveToBlockSDK(sfunctionName,sfunctionNameWrapper,blockRootDir,errorOccurred,mexVerboseText,ad)
    if exist(blockRootDir,'dir')
        srcFolder=fullfile(blockRootDir,'src');
        incFolder=fullfile(blockRootDir,'src');
        binFolder=fullfile(blockRootDir,'mex');
        tlcFolder=binFolder;
        [~,sfcnName,~]=fileparts(sfunctionName);
        sfBuilderBlockNameMATFile=['SFB__',sfcnName,'__SFB.mat'];
        if exist(fullfile(pwd,sfBuilderBlockNameMATFile),'file')&&~isequal(pwd,binFolder)
            newMATFile=Simulink.BlocksetDesigner.internal.updateRTWMATFile(sfBuilderBlockNameMATFile,srcFolder,incFolder);
            movefile(newMATFile,binFolder);
        end
        if exist(fullfile(pwd,sfunctionName),'file')&&~isequal(pwd,srcFolder)
            movefile(sfunctionName,srcFolder);
        end
        if exist(fullfile(pwd,sfunctionNameWrapper),'file')&&~isequal(pwd,srcFolder)
            movefile(sfunctionNameWrapper,srcFolder);
        end
        generatedBusFile=[sfcnName,'_bus.h'];
        if exist(fullfile(pwd,generatedBusFile),'file')&&~isequal(pwd,srcFolder)
            movefile(generatedBusFile,srcFolder);
        end
        sfunNameWrapperTLC=[sfcnName,'.tlc'];
        if exist(fullfile(pwd,sfunNameWrapperTLC),'file')&&~isequal(pwd,tlcFolder)
            movefile(sfunNameWrapperTLC,tlcFolder);
        end
        makeConfigFile='rtwmakecfg.m';
        if exist(fullfile(pwd,makeConfigFile),'file')&&~isequal(pwd,binFolder)
            movefile(makeConfigFile,binFolder);
        end
        mexFile=[sfcnName,'.',mexext];
        if exist(fullfile(pwd,mexFile),'file')&&~isequal(pwd,binFolder)
            movefile(mexFile,binFolder);
        end
        sfa=Simulink.BlocksetDesigner.Sfunction();
        if isfield(ad.SfunWizardData,'BlockSetSDKWithPackaging')&&...
            isequal(ad.SfunWizardData.BlockSetSDKWithPackaging,1)
            [~,projectRoot]=Simulink.BlocksetDesigner.internal.isBlockSDKEnabled();


            ad.SfunWizardData.PackAction='BSDAuthor';
            ad.PathName=projectRoot;


            existingPackageFile=fullfile(blockRootDir,'package',[sfcnName,'.zip']);
            if isfile(existingPackageFile)
                delete(existingPackageFile);
            end
            ad=sfcnbuilder.doPackage(ad);

            sfa.importSfunctionFromBuilder(sfunctionName,errorOccurred,mexVerboseText);
        else
            sfa.importSfbuilder(sfunctionName,errorOccurred,mexVerboseText);
        end
    end
end

function ad=setupSfunWizardData(ad)




    ad.SfunWizardData.SfunName='';
    ad.SfunWizardData.InputPortWidth='1';
    ad.SfunWizardData.OutputPortWidth='1';
    ad.SfunWizardData.SfunctionParameters='';
    ad.SfunWizardData.NumberOfParameters='0';
    ad.SfunWizardData.DirectFeedThrough='1';
    ad.SfunWizardData.SampleTime=getString(message('Simulink:dialog:inheritedLabel'));
    ad.SfunWizardData.NumberOfDiscreteStates='0';
    ad.SfunWizardData.DiscreteStatesIC='0';
    ad.SfunWizardData.NumberOfContinuousStates='0';
    ad.SfunWizardData.ContinuousStatesIC='0';
    ad.SfunWizardData.NumberOfPWorks='0';
    ad.SfunWizardData.NumberOfDWorks='0';
    ad.SfunWizardData.ExternalDeclaration='/* extern double func(double a); */';
    ad.SfunWizardData.IncludeHeadersText='#include <math.h>';
    ad.SfunWizardData.LibraryFilesText='';

    ad.SfunWizardData.UserCodeTextmdlStart=DAStudio.message('Simulink:SFunctionBuilder:SampleCodeStart');
    ad.SfunWizardData.UserCodeText=DAStudio.message('Simulink:SFunctionBuilder:SampleCodeOutput');
    ad.SfunWizardData.UserCodeTextmdlUpdate=DAStudio.message('Simulink:SFunctionBuilder:SampleCodeUpdate');
    ad.SfunWizardData.UserCodeTextmdlDerivative=DAStudio.message('Simulink:SFunctionBuilder:SampleCodeDerivatives');
    ad.SfunWizardData.UserCodeTextmdlTerminate=DAStudio.message('Simulink:SFunctionBuilder:SampleCodeTerminate');

    ad.SfunWizardData.GenerateTLC='1';
    ad.SfunWizardData.PanelIndex='0';
    ad.SfunWizardData.InputDataType0='double';
    ad.SfunWizardData.OutputDataType0='double';
    ad.SfunWizardData.InputSignalType0='real';
    ad.SfunWizardData.OutputSignalType0='real';
    ad.SfunWizardData.InFrameBased0='off';
    ad.SfunWizardData.InBusBased0='off';
    ad.SfunWizardData.InBusname0=' ';
    ad.SfunWizardData.OutFrameBased0='off';
    ad.SfunWizardData.OutBusBased0='off';
    ad.SfunWizardData.OutBusname0=' ';
    ad.SfunWizardData.TemplateType='1';
    ad.SfunWizardData.Input0DimsCol='1';
    ad.SfunWizardData.Output0DimsCol='1';
    ad.SfunWizardData.UseSimStruct='0';
    ad.SfunWizardData.SupportForEach='0';
    ad.SfunWizardData.EnableMultiThread='0';
    ad.SfunWizardData.EnableCodeReuse='0';
    ad.SfunWizardData.SupportCoverage='0';
    ad.SfunWizardData.SupportSldv='0';
    ad.SfunWizardData.ShowCompileSteps='0';
    ad.SfunWizardData.CreateDebugMex='0';
    ad.SfunWizardData.SaveCodeOnly='0';
    ad.SfunWizardData.LangExt='inherit';



    ad.SfunWizardData.Majority='Column';

    ad.SfunWizardData.InputPorts.Name={'u0'};
    ad.SfunWizardData.InputPorts.Dimensions={'[1,1]'};
    ad.SfunWizardData.InputPorts.DataType={'real_T'};
    ad.SfunWizardData.InputPorts.Complexity={'real'};
    ad.SfunWizardData.InputPorts.Frame={'off'};
    ad.SfunWizardData.InputPorts.Dims={'1-D'};
    ad.SfunWizardData.InputPorts.Bus={'off'};
    ad.SfunWizardData.InputPorts.Busname={''};

    ad.SfunWizardData.OutputPorts.Name={'y0'};
    ad.SfunWizardData.OutputPorts.Dimensions={'[1,1]'};
    ad.SfunWizardData.OutputPorts.DataType={'real_T'};
    ad.SfunWizardData.OutputPorts.Complexity={'real'};
    ad.SfunWizardData.OutputPorts.Frame={'off'};
    ad.SfunWizardData.OutputPorts.Dims={'1-D'};
    ad.SfunWizardData.OutputPorts.Bus={'off'};
    ad.SfunWizardData.OutputPorts.Busname={''};

    ad.SfunWizardData.Parameters.Name={};
    ad.SfunWizardData.Parameters.DataType={};
    ad.SfunWizardData.Parameters.Complexity={};
    ad.SfunWizardData.Parameters.Value={};
    ad.Version='';


    ad.SfunWizardData.LibraryFilesTable.SrcPaths={};
    ad.SfunWizardData.LibraryFilesTable.LibPaths={};
    ad.SfunWizardData.LibraryFilesTable.IncPaths={};
    ad.SfunWizardData.LibraryFilesTable.Entries={};
    ad.SfunWizardData.LibraryFilesTable.EnvPaths={};

    mdlWizardData='';

    ad.SfunWizardData.SfunName=get_param(getfullname(ad.inputArgs),'FunctionName');

    ad.SfunWizardData.SfunctionParameters=get_param(getfullname(ad.inputArgs),'Parameters');


    if(~strcmp(ad.SfunWizardData.SfunName,'system'))
        try
            if ishandle(ad.inputArgs)
                mdlWizardData=get_param(getfullname(ad.inputArgs),'WizardData');
            end



            if~isempty(mdlWizardData)


                fieldsToRemove={'Row','Col'};
                if isfield(mdlWizardData,'InputPorts')&&~isempty(mdlWizardData.InputPorts)
                    if~isfield(mdlWizardData.InputPorts,'Dimensions')
                        numPorts=numel(mdlWizardData.InputPorts.Name);
                        dimsCell=cell(1,numPorts);
                        for i=1:numPorts

                            currDims='';
                            if isfield(mdlWizardData.InputPorts,'Row')
                                currDims=['[',mdlWizardData.InputPorts.Row{i}];
                            end

                            if isfield(mdlWizardData.InputPorts,'Col')
                                currDims=[currDims,',',mdlWizardData.InputPorts.Col{i},']'];
                            end



                            if~isempty(currDims)
                                currDims=strrep(currDims,'DYNAMICALLY_SIZED','-1');
                            end
                            dimsCell{i}=currDims;
                        end
                        mdlWizardData.InputPorts.Dimensions=dimsCell;
                        mdlWizardData.InputPorts=rmfield(mdlWizardData.InputPorts,fieldsToRemove);
                    end
                end

                if isfield(mdlWizardData,'OutputPorts')&&~isempty(mdlWizardData.OutputPorts)
                    if~isfield(mdlWizardData.OutputPorts,'Dimensions')
                        numPorts=numel(mdlWizardData.OutputPorts.Name);
                        dimsCell=cell(1,numPorts);
                        for i=1:numPorts
                            currDims='[';
                            if isfield(mdlWizardData.OutputPorts,'Row')
                                currDims=['[',mdlWizardData.OutputPorts.Row{i}];
                            end

                            if isfield(mdlWizardData.OutputPorts,'Col')
                                currDims=[currDims,',',mdlWizardData.OutputPorts.Col{i},']'];
                            end



                            if~isempty(currDims)
                                currDims=strrep(currDims,'DYNAMICALLY_SIZED','-1');
                            end
                            dimsCell{i}=currDims;
                        end
                        mdlWizardData.OutputPorts.Dimensions=dimsCell;
                        mdlWizardData.OutputPorts=rmfield(mdlWizardData.OutputPorts,fieldsToRemove);
                    end
                end
            end


            if(isfield(mdlWizardData,'IgnoreMdlWizardData')&&...
                isequal(mdlWizardData.IgnoreMdlWizardData,1))



            else
                if(~isempty(mdlWizardData))
                    mdlWizardData=i_addFields(mdlWizardData,ad.inputArgs);
                    ad.SfunWizardData=mdlWizardData;
                else
                    ad.SfunWizardData=i_addFields(ad.SfunWizardData,ad.inputArgs);
                end
            end
        catch

        end
        ad=sfcnbuilder.sfunbuilderLangExt('ComputeLangExtFromWizardData',ad);

        if(exist([ad.SfunWizardData.SfunName,'.',ad.LangExt],'file')==2)
            ad=sfcnbuilder.read_sfunction_code(ad);
        end


        if(exist([ad.SfunWizardData.SfunName,'_wrapper.',ad.LangExt],'file')==2)
            ad=sfcnbuilder.read_wrapper_code(ad);
        end
        try
            set_param(ad.inputArgs,'SfunBuilderFcnName',ad.SfunWizardData.SfunName);
        catch

        end
    else
        try
            set_param(ad.inputArgs,'SfunBuilderFcnName',ad.SfunWizardData.SfunName);
        catch

        end

        ad.SfunWizardData.SfunName='';
    end


    ad.SfunWizardData.SignPackage='0';
    ad.SfunWizardData.CertificateName='';
    ad.SfunWizardData.BeginPackaging='0';

    isBlockSDKSfbuilder=get_param(getfullname(ad.inputArgs),'WizardData');
    if isBlockSDKConfigured(isBlockSDKSfbuilder)
        [ad.SfunWizardData.BlockSetSDK,projectRoot]=Simulink.BlocksetDesigner.internal.isBlockSDKEnabled();
        ad.SfunWizardData.BlockRootDir=fullfile(projectRoot,ad.SfunWizardData.SfunName);

        if isBlockSDKWithPackaging(isBlockSDKSfbuilder,ad.SfunWizardData)
            ad.SfunWizardData.BlockSetSDKWithPackaging=1;
            ad.DefaultTitle=['Author S-Function: ',ad.SfunWizardData.SfunName];
            ad.SfunWizardData.BSDMetaModel=isBlockSDKSfbuilder.BSDMetaModel;
            ad.SfunWizardData.PackAction='BSDAuthor';




            if isfield(isBlockSDKSfbuilder,'IgnoreMdlWizardData')&&...
                isequal(isBlockSDKSfbuilder.IgnoreMdlWizardData,1)

                ad.SfunWizardData.UserCodeText=sprintf('\n    y0[0] = u0[0];\n');
                if isfield(isBlockSDKSfbuilder,'NumberOfDiscreteStates')
                    ad.SfunWizardData.NumberOfDiscreteStates=...
                    isBlockSDKSfbuilder.NumberOfDiscreteStates;
                    ad.SfunWizardData.UserCodeText=sprintf('\n    y0[0] = xD[0] + u0[0];\n');
                    ad.SfunWizardData.UserCodeTextmdlUpdate=sprintf('\n    xD[0] = u0[0];\n');
                end
                if isfield(isBlockSDKSfbuilder,'NumberOfContinuousStates')
                    ad.SfunWizardData.NumberOfContinuousStates=...
                    isBlockSDKSfbuilder.NumberOfContinuousStates;
                    ad.SfunWizardData.UserCodeText=sprintf('\n    y0[0] = xC[0] + u0[0];\n');
                    ad.SfunWizardData.UserCodeTextmdlDerivative=sprintf('\n    dx[0] = xC[0] + u0[0];\n');
                end
            end
        else
            ad.SfunWizardData.BlockSetSDKWithPackaging=0;
            ad.SfunWizardData.PackAction='';
        end
    else
        ad.SfunWizardData.BlockSetSDK=0;
        ad.SfunWizardData.BlockSetSDKWithPackaging=0;
        ad.SfunWizardData.PackAction='';
    end

    try
        if(~strcmp(get_param(bdroot(ad.inputArgs),'Name'),'simulink3')||...
            ~strcmp(get_param(bdroot(ad.inputArgs),'Name'),'simulink'))

            set_param(getfullname(ad.inputArgs),'WizardData',ad.SfunWizardData);
        end
    catch

    end
end


function result=isBlockSDKConfigured(isBlockSDKSfbuilder)
    result=isequal(isBlockSDKSfbuilder,'IsBlockSDKSfBuilder')||...
    (isfield(isBlockSDKSfbuilder,'BlockSetSDK')&&...
    isequal(isBlockSDKSfbuilder.BlockSetSDK,1))||...
    isfield(isBlockSDKSfbuilder,'BSDMetaModel')||...
    (isfield(isBlockSDKSfbuilder,'BlockSetSDKWithPackaging')&&...
    isequal(isBlockSDKSfbuilder.BlockSetSDKWithPackaging,1));
end

function result=isBlockSDKWithPackaging(isBlockSDKSfbuilder,wizData)
    result=(isfield(isBlockSDKSfbuilder,'BSDMetaModel')||...
    (isfield(wizData,'BlockSetSDKWithPackaging')&&...
    isequal(wizData.BlockSetSDKWithPackaging,1)))&&...
    isequal(wizData.BlockSetSDK,1);
end

function S=i_addFields(S,blockHandle)


    if(~isfield(S,'Majority'))
        S=setfield(S,'Majority','Column');
    end
    if(~isfield(S,'InputDataType0'))
        S=setfield(S,'InputDataType0','double');
        S=setfield(S,'OutputDataType0','double');
        S=setfield(S,'InputSignalType0','real');
        S=setfield(S,'OutputSignalType0','real');
        S=setfield(S,'InFrameBased0','off');
        S=setfield(S,'InBusBased0','off');
        S=setfield(S,'InBusname0',' ');
        S=setfield(S,'OutFrameBased0','off');
        S=setfield(S,'OutBusBased0','off');
        S=setfield(S,'OutBusname0',' ');
        S=setfield(S,'TemplateType','1');
    end
    if(~isfield(S,'InBusBased0'))
        S=setfield(S,'InBusBased0','off');
        S=setfield(S,'InBusname0',' ');
        S=setfield(S,'OutBusBased0','off');
        S=setfield(S,'OutBusname0',' ');
    end
    if(~isfield(S,'Parameters'))
        S.Parameters.Name={''};
        S.Parameters.DataType={''};
        S.Parameters.Complexity={''};
    end
    if(~isfield(S,'UseSimStruct'))
        S.UseSimStruct='0';
        S.ShowCompileSteps='0';
        S.CreateDebugMex='0';
        S.SaveCodeOnly='0';
    end
    if~isfield(S,'SupportCoverage')
        S.SupportCoverage='0';
    end
    if~isfield(S,'SupportSldv')
        S.SupportSldv='0';
    end

    if(~isfield(S,'UserCodeTextmdlStart')||isempty(S.UserCodeTextmdlStart))
        S.UserCodeTextmdlStart=DAStudio.message('Simulink:SFunctionBuilder:SampleCodeStart');
    end
    if(~isfield(S,'UserCodeTextmdlTerminate')||isempty(S.UserCodeTextmdlTerminate))
        S.UserCodeTextmdlTerminate=DAStudio.message('Simulink:SFunctionBuilder:SampleCodeTerminate');
    end
    if(~isfield(S,'UserCodeTextmdlUpdate')||isempty(S.UserCodeTextmdlUpdate))
        S.UserCodeTextmdlUpdate=DAStudio.message('Simulink:SFunctionBuilder:SampleCodeUpdate');
    end
    if(~isfield(S,'UserCodeTextmdlDerivative')||isempty(S.UserCodeTextmdlDerivative))
        S.UserCodeTextmdlDerivative=DAStudio.message('Simulink:SFunctionBuilder:SampleCodeDerivatives');
    end

    if(~isfield(S,'NumberOfPWorks'))
        S.NumberOfPWorks='0';
    end
    if(~isfield(S,'NumberOfDWorks'))
        S.NumberOfDWorks='0';
    end
    if(~isfield(S,'LangExt'))
        S.LangExt='inherit';
    end
    if(~isfield(S,'SupportForEach'))
        S.SupportForEach='0';
    end
    if(~isfield(S,'EnableMultiThread'))
        S.EnableMultiThread='0';
    end
    if(~isfield(S,'EnableCodeReuse'))
        S.EnableCodeReuse='0';
    end



    if(isfield(S,'LibraryFilesText'))

        libTextCode=S.LibraryFilesText;
        [libFileList,srcFileList,objFileList,...
        addIncPaths,addLibPaths,addSrcPaths,...
        preProcList,preProcUndefList,envPathList,unrecogList]=...
        read_librarytext(libTextCode,blockHandle);



        preProcList=append('-D',preProcList);
        preProcUndefList=append('-U',preProcUndefList);

        addSrcPaths(strcmp(addSrcPaths,pwd))=[];

        S.LibraryFilesTable.SrcPaths=addSrcPaths;
        S.LibraryFilesTable.LibPaths=addLibPaths;
        S.LibraryFilesTable.IncPaths=addIncPaths;
        S.LibraryFilesTable.EnvPaths=envPathList;
        S.LibraryFilesTable.Entries=[libFileList,srcFileList,objFileList,preProcList,preProcUndefList,unrecogList];
    end

end



function[libFileList,srcFileList,objFileList,...
    addIncPaths,addLibPaths,addSrcPaths,...
    preProcDefList,preProcUndefList,envPathList,...
    unrecognizedInfo]=read_librarytext(libTextCode,blockHandle)


















    current_dir=pwd;
    if~isempty(blockHandle)
        mdlName=get_param(bdroot(blockHandle),'Name');
        mdlFullPathName=which(mdlName);
        idx=strfind(mdlFullPathName,mdlName);
        mdlFullPath=mdlFullPathName(1:idx-1);
        if(strcmp(current_dir,mdlFullPath)==0)
            addSrcPaths={current_dir};
        else
            addSrcPaths={};
        end

    else
        addSrcPaths={};
    end

    srcFileList={};
    libFileList={};
    objFileList={};
    addIncPaths={};
    addLibPaths={};
    envPathList={};

    preProcDefList={};
    preProcUndefList={};
    unrecognizedInfo={};

    libTextCode=[libTextCode,newline];
    newLineIdx=regexp(libTextCode,newline);
    if isempty(newLineIdx)
        newLineIdx=length(libTextCode)+1;
    end

    startLineIdx=1;

    for endLineIdx=newLineIdx
        if startLineIdx==endLineIdx
            startLineIdx=endLineIdx+1;
            continue;
        end
        codeLine=libTextCode(startLineIdx:endLineIdx-1);
        if isempty(strtrim(codeLine))
            startLineIdx=endLineIdx+1;
            continue;
        end
        [featureType,parseList]=parseLibCodePaneTextLine(...
        codeLine);

        switch(featureType)
        case 'libFile',libFileList={libFileList{:},parseList{:}};
        case 'srcFile',srcFileList={srcFileList{:},parseList{:}};
        case 'envPath',envPathList={envPathList{:},parseList{:}};
        case 'objFile',objFileList={objFileList{:},parseList{:}};
        case 'libPath',addLibPaths={addLibPaths{:},parseList{:}};
        case 'srcPath',addSrcPaths={addSrcPaths{:},parseList{:}};
        case 'incPath',addIncPaths={addIncPaths{:},parseList{:}};
        case 'preProc',preProcDefList={preProcDefList{:},parseList{:}};
        case 'prePrcU',preProcUndefList={preProcUndefList{:},parseList{:}};
        otherwise,unrecognizedInfo={unrecognizedInfo{:},parseList{:}};
        end

        startLineIdx=endLineIdx+1;

    end

end


function[featureType,parseList]=parseLibCodePaneTextLine(lineStr)


    splittingStr='\,|\;';
    retStr=' ';

    if~isempty(regexpi(lineStr,'^\s*INC(LUDE)?_PATH'))
        featureType='incPath';
        retStr=regexprep(lineStr,'INC(LUDE)?_PATH','','ignorecase');
        parseList=slprivate('splitText',retStr,splittingStr);
    elseif~isempty(regexpi(lineStr,'^\s*LIB(RARY)?_PATH'))
        featureType='libPath';
        retStr=regexprep(lineStr,'^\s*LIB(RARY)?_PATH','','ignorecase');
        parseList=slprivate('splitText',retStr,splittingStr);
    elseif~isempty(regexpi(lineStr,'^\s*ENV_PATH'))
        featureType='envPath';
        retStr=regexprep(lineStr,'^\s*ENV_PATH','','ignorecase');
        parseList=slprivate('splitText',retStr,splittingStr);
    elseif~isempty(regexpi(lineStr,'^\s*SRC_PATH'))
        featureType='srcPath';
        retStr=regexprep(lineStr,'^\s*SRC_PATH','','ignorecase');
        parseList=slprivate('splitText',retStr,splittingStr);
    elseif~isempty(regexpi(lineStr,'^\s*\-D'))
        featureType='preProc';
        parseList=slprivate('splitText',lineStr,[splittingStr,'|\-(D|d)']);
    elseif~isempty(regexpi(lineStr,'^\s*\-U'))
        featureType='prePrcU';
        parseList=slprivate('splitText',lineStr,[splittingStr,'|\-(U|u)']);
    elseif~isempty(regexpi(lineStr,'\.o(bj)?\s*$'))
        featureType='objFile';
        parseList=slprivate('splitText',lineStr,splittingStr);
    elseif~isempty(regexpi(lineStr,'\.c(pp)?\s*$'))
        featureType='srcFile';
        parseList=slprivate('splitText',lineStr,splittingStr);
    elseif~isempty(regexpi(lineStr,'\.((lib)|(a)|(so))\s*$'))
        featureType='libFile';
        parseList=slprivate('splitText',lineStr,splittingStr);
    else
        featureType='';
        retStr=lineStr;
        parseList={retStr};
    end

    if isempty(parseList)
        retStr=lineStr;
        parseList={retStr};
    end


    parseList(strcmp(parseList,''))=[];
end





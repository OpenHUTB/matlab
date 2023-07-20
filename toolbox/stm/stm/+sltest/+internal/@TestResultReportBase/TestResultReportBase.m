classdef TestResultReportBase<handle














    properties(Abstract)
        CustomTemplateFile;
        LaunchReport;
        IncludeTestResults;
    end

    properties(Abstract,Hidden,GetAccess=public,SetAccess=protected)
        IconFileTestFileResult;
        IconFileTestSuiteResult;
        IconFileTestCaseResult;
        IconFileTestIterationResult;
        IconFileOutcomePassed;
        IconFileOutcomeFailed;
        IconFileOutcomeIncomplete;
        IconFileOutcomeMisaligned;
        IconFileOutcomeUntested;
        IconFileOutcomeDisabled;
        IconTopLevelModel;
        IconModelReference;
        IconFileScriptedTestFileResult;
        IconFileScriptedTestSuiteResult;
        IconFileScriptedTestCaseResult;
    end

    properties(Abstract,GetAccess=public,SetAccess=protected)
        BodyFontName;
        BodyFontColor;
        BodyFontSize;
    end

    properties(Hidden,GetAccess=public,SetAccess=private)
        outputFile='';
        reportType='';
        workingPath='';
        tocLinkTargetName;
    end

    properties(GetAccess=protected,SetAccess=protected)
        TitlePart;
        TOCPart;
        BodyPart;


        ReportGenStatus=0;
    end

    properties(GetAccess=protected,SetAccess=private)




        ResultObjList={};


        Doc;
    end

    properties(Access=private)
        workingName='';
        outputFileType='';
        fromCMD=true;
        reportGenProgressDlgShown=false;
        useTemplate=true;
        templatePath='';

        errorMSGID='';
        errors={};
        content={};
        reportGenerationSuccess=-1;
        hasReqirements=false;
        pdfFromDocx=false;
    end

    methods(Abstract,Access=protected)
        layoutReport(obj);
    end


    methods
        function this=TestResultReportBase(resultObjects,reportFilePath)
            this.content=resultObjects;
            this.outputFile=reportFilePath;
        end
    end


    methods(Sealed=true)
        function createReport(obj)
            noRet=onCleanup(@()obj.reportGenerationIsDone());
            obj.reportGenerationSuccess=0;
            obj.setReportGenerationEnviroment();
            obj.layoutReport();
            obj.finalizeReport();

            if(obj.LaunchReport&&obj.ReportGenStatus<=2&&obj.reportGenerationSuccess==2)
                obj.viewReport();
            end
            obj.reportGenerationSuccess=-1;
        end


        function viewReport(obj)
            import mlreportgen.dom.*;
            rptgen.rptview(obj.outputFile,obj.outputFileType);
        end

        function docPart=lineSeparator(obj)
            docPart=mlreportgen.dom.DocumentPart(obj.Doc,'ReportLine');
        end
    end


    methods(Access=private,Sealed=true)
        flatAndFilterReportData(obj);
        sendPostGeneartionMessage(obj,fromCMD,requirementDataRejected);

        function finalizeReport(obj)
            import mlreportgen.dom.*;

            if(isempty(obj.CustomTemplateFile))

                str=getString(message('stm:ReportContent:ReportTitle'));
                text1=Text(str);
                text1.FontSize='30px';
                text1.Bold=true;
                append(obj.Doc,text1);
                append(obj.Doc,obj.lineSeparator);
            end

            if(obj.useTemplate)
                while~strcmp(obj.Doc.CurrentHoleId,'#end#')
                    switch obj.Doc.CurrentHoleId
                    case 'ChapterTitle'
                        append(obj.Doc,obj.TitlePart);
                    case 'ChapterBody'
                        append(obj.Doc,obj.BodyPart);
                    case 'ChapterTOC'
                        if(obj.ReportGenStatus>=2)
                            str=getString(message('stm:ReportContent:WarningForIncompleteReport'));
                            text1=Text(str);
                            sltest.testmanager.ReportUtility.setTextStyle(text1,obj.BodyFontName,...
                            obj.BodyFontSize,'red',false,false);

                            p=Paragraph(text1);
                            p.Style={OuterMargin('0mm','0mm','0mm',obj.SectionSpacing)};
                            append(obj.Doc,p);
                        end
                        append(obj.Doc,obj.TOCPart);
                    end
                    moveToNextHole(obj.Doc);
                end
            else
                append(obj.Doc,obj.TitlePart);
                append(obj.Doc,obj.TOCPart);
                append(obj.Doc,obj.BodyPart);
            end
            close(obj.Doc);


            if(strcmp(obj.outputFileType,'html'))
                tmpFile=fullfile(obj.workingPath,[obj.workingName,'.htmx']);
            elseif(strcmp(obj.outputFileType,'docx'))
                tmpFile=fullfile(obj.workingPath,[obj.workingName,'.docx']);
            elseif(strcmp(obj.outputFileType,'pdf'))
                if(obj.pdfFromDocx)
                    if(ispc)
                        tmpFile=fullfile(obj.workingPath,[obj.workingName,'.docx']);
                        rptgen.docview(tmpFile,'convertdocxtopdf');
                        tmpFile=fullfile(obj.workingPath,[obj.workingName,'.pdf']);
                    end
                else
                    tmpFile=fullfile(obj.workingPath,[obj.workingName,'.pdf']);
                end

            end
            if(exist(tmpFile,'file'))
                movefile(tmpFile,obj.outputFile,'f');
            end


            rmdir(obj.workingPath,'s');
            obj.reportGenerationSuccess=2;
            obj.sendPostGeneartionMessage(obj.fromCMD,false);
        end
    end


    methods(Static,Access=private)
        oTree=filterResultSet(inTree,resultSetCoverage);


        [ResultObjList,parentIndexList,depthList]=flatResultObject(resultObj);
        filePath=validateFilePath(filePath,defaultExtension,isReport);
    end


    methods(Access=protected,Sealed=true)
        addPartToHTMLReport(obj,outputPath,fileName)
        updateReportGenStatus(obj);
    end


    methods(Static,Access=protected,Sealed=true)
        [ReportGenStatus,reportGenProgressDlgShown]=getReportGenerationStatus();
        ret=getCountMetricsOfResult(resultObj);
        ret=hasCoverageResults(resultObj);
        cvFile=saveCoverageToFile(cvData);
        cvReportFile=createCoverageReport(cvFile,topModel);
    end

    methods(Static,Sealed=true)
        plotEnum(ts,pHandle);
    end


    methods(Access=protected,Sealed=true,Hidden)
        reportGenerationIsDone(obj);
    end

    methods(Static,Access=protected,Sealed=true,Hidden)
        sendMSGToUI(value,msg,replaceLastLine);
        entries=getArchiveEntries(basepath,files);
    end

    methods(Sealed=true,Access=protected,Hidden)
        function setReportGenerationEnviroment(obj)
            obj.errors.ReportTemplateNotFound='stm:reportOptionDialogText:ReportTemplateNotFound';
            obj.errors.EmptyDataForReport='stm:reportOptionDialogText:EmptyDataForReport';
            obj.errors.UnsupportedFileType='stm:reportOptionDialogText:UnsupportedFileType';
            obj.errors.MustCallCreateReportMethod='stm:ReportContent:MustCallCreateReportMethod';
            obj.errors.InvalidTemplatePath='stm:reportOptionDialogText:InvalidTemplatePath';
            obj.errors.TemplateFileMismatch='stm:reportOptionDialogText:TemplateFileMismatch';
            obj.tocLinkTargetName=getString(message('stm:ReportContent:Label_Summary'));

            if(obj.reportGenerationSuccess~=0)
                error(message(obj.errors.MustCallCreateReportMethod));
            end
            obj.reportGenerationSuccess=1;

            iconPath=fullfile(matlabroot,'toolbox','stm','stm','+stm','+internal','+report','Icons');
            if(isempty(obj.IconFileTestFileResult))
                obj.IconFileTestFileResult=fullfile(iconPath,'Tree_Test_File_15.png');
            end
            if(isempty(obj.IconFileTestSuiteResult))
                obj.IconFileTestSuiteResult=fullfile(iconPath,'Tree_Test_Suite_15.png');
            end
            if(isempty(obj.IconFileTestCaseResult))
                obj.IconFileTestCaseResult=fullfile(iconPath,'Tree_Test_Case_15.png');
            end
            if(isempty(obj.IconFileTestIterationResult))
                obj.IconFileTestIterationResult=fullfile(iconPath,'Tree_Test_Case_Iter_15.png');
            end
            if(isempty(obj.IconFileOutcomePassed))
                obj.IconFileOutcomePassed=fullfile(iconPath,'ResultsStatusIconPassed.png');
            end
            if(isempty(obj.IconFileOutcomeFailed))
                obj.IconFileOutcomeFailed=fullfile(iconPath,'ResultsStatusIconFailed.png');
            end
            if(isempty(obj.IconFileOutcomeIncomplete))
                obj.IconFileOutcomeIncomplete=fullfile(iconPath,'ResultsStatusIconIncomplete.png');
            end
            if(isempty(obj.IconFileOutcomeDisabled))
                obj.IconFileOutcomeDisabled=fullfile(iconPath,'ResultsStatusIconDisabled.png');
            end
            if(isempty(obj.IconFileOutcomeMisaligned))
                obj.IconFileOutcomeMisaligned=fullfile(iconPath,'status_misaligned.png');
            end
            if(isempty(obj.IconTopLevelModel))
                obj.IconTopLevelModel=fullfile(iconPath,'Top_model_16.png');
            end
            if(isempty(obj.IconModelReference))
                obj.IconModelReference=fullfile(iconPath,'ModelReferenced_norm_16.png');
            end
            if(isempty(obj.IconFileOutcomeUntested))
                obj.IconFileOutcomeUntested=fullfile(iconPath,'ResultsStatusIconUntested.png');
            end
            if(isempty(obj.IconFileScriptedTestFileResult))
                obj.IconFileScriptedTestFileResult=fullfile(iconPath,'MATLAB_Test_File_16.png');
            end
            if(isempty(obj.IconFileScriptedTestSuiteResult))
                obj.IconFileScriptedTestSuiteResult=fullfile(iconPath,'MATLAB_Test_Suite_16.png');
            end
            if(isempty(obj.IconFileScriptedTestCaseResult))
                obj.IconFileScriptedTestCaseResult=fullfile(iconPath,'MATLAB_Test_Case_16.png');
            end


            files=cell(1,15);
            files{1}=obj.IconFileTestFileResult;
            files{2}=obj.IconFileTestSuiteResult;
            files{3}=obj.IconFileTestCaseResult;
            files{4}=obj.IconFileOutcomePassed;
            files{5}=obj.IconFileOutcomeFailed;
            files{6}=obj.IconFileOutcomeIncomplete;
            files{7}=obj.IconFileOutcomeDisabled;
            files{8}=obj.IconFileOutcomeMisaligned;
            files{9}=obj.IconFileTestIterationResult;
            files{10}=obj.IconTopLevelModel;
            files{11}=obj.IconModelReference;
            files{12}=obj.IconFileOutcomeUntested;
            files{13}=obj.IconFileScriptedTestFileResult;
            files{14}=obj.IconFileScriptedTestSuiteResult;
            files{15}=obj.IconFileScriptedTestCaseResult;


            for k=1:length(files)
                if(exist(files{k},'file')==0)
                    warning(message('stm:reportOptionDialogText:IconFilesNotFound'));
                end
            end

            obj.ReportGenStatus=0;
            stm.internal.setReportGenerationStatus(1,-1);

            if(~strcmp(class(obj),'sltest.internal.TestResultReport'))%#ok<STISA>
                if(~isa(obj,'sltest.testmanager.TestResultReport'))
                    error(message('stm:ReportContent:InvalidClassName'));
                end
                if(~license('checkout','MATLAB_Report_Gen'))
                    error(message('stm:ReportContent:ReportGeneratorLicenseError'));
                end
            end

            if(isempty(obj.content))
                obj.errorMSGID=obj.errors.EmptyDataForReport;
                error(message(obj.errorMSGID));
            end

            OSTempDir=tempdir();
            obj.workingPath=tempname(OSTempDir);
            mkdir(obj.workingPath);

            tmpStr=tempname(obj.workingPath);
            [~,tmpName,~]=fileparts(tmpStr);
            obj.workingName=tmpName;

            obj.outputFile=obj.validateFilePath(obj.outputFile,'.pdf',true);
            [~,~,outputExt]=fileparts(obj.outputFile);
            if(strcmp(outputExt,'.zip'))
                obj.reportType='html';
                obj.outputFileType='html';
            elseif(strcmp(outputExt,'.pdf'))
                obj.reportType='pdf';
                obj.outputFileType='pdf';
            elseif(strcmp(outputExt,'.docx'))
                obj.reportType='docx';
                obj.outputFileType='docx';
            else
                obj.errorMSGID=obj.errors.UnsupportedFileType;
                error(message(obj.errorMSGID));
            end


            obj.pdfFromDocx=false;
            if strlength(obj.CustomTemplateFile)>0
                if(strcmp(obj.reportType,'html'))
                    obj.CustomTemplateFile=obj.validateFilePath(obj.CustomTemplateFile,'.htmtx',false);
                elseif(strcmp(obj.reportType,'docx'))
                    obj.CustomTemplateFile=obj.validateFilePath(obj.CustomTemplateFile,'.dotx',false);
                elseif(strcmp(obj.reportType,'pdf'))
                    if(ispc)
                        [~,~,tmpExt]=fileparts(obj.CustomTemplateFile);
                        if strlength(tmpExt)==0
                            obj.CustomTemplateFile=obj.validateFilePath(obj.CustomTemplateFile,'.pdftx',false);
                        else
                            if(strcmp(tmpExt,'.dotx'))
                                obj.CustomTemplateFile=obj.validateFilePath(obj.CustomTemplateFile,'.dotx',false);
                                obj.pdfFromDocx=true;
                            else
                                obj.CustomTemplateFile=obj.validateFilePath(obj.CustomTemplateFile,'.pdftx',false);
                            end
                        end
                    else
                        obj.CustomTemplateFile=obj.validateFilePath(obj.CustomTemplateFile,'.pdftx',false);
                    end
                end
                [~,~,tmpExt]=fileparts(obj.CustomTemplateFile);
                templateMatch=true;
                if(strcmp(obj.reportType,'html')&&~strcmp(tmpExt,'.htmtx'))
                    templateMatch=false;
                end
                if(strcmp(obj.reportType,'docx')&&~strcmp(tmpExt,'.dotx'))
                    templateMatch=false;
                end
                if(strcmp(obj.reportType,'pdf'))
                    if(~strcmp(tmpExt,'.dotx')&&~strcmp(tmpExt,'.pdftx'))
                        templateMatch=false;
                    end
                end
                if(templateMatch==false)
                    error(message(obj.errors.TemplateFileMismatch));
                end
            elseif(obj.useTemplate)
                if(isempty(obj.templatePath))
                    obj.templatePath=fullfile(matlabroot,'toolbox','stm','stm','+stm','+internal','+report','ReportTemplate');
                end

                if(strcmp(obj.reportType,'html')==1)
                    templateFile=fullfile(obj.templatePath,'mainTemplate.htmtx');
                elseif(strcmp(obj.reportType,'docx')==1)
                    templateFile=fullfile(obj.templatePath,'mainTemplate.dotx');
                elseif(strcmp(obj.reportType,'pdf')==1)
                    templateFile=fullfile(obj.templatePath,'mainTemplate.pdftx');
                end
                if(exist(templateFile,'file')==0)
                    obj.errorMSGID=obj.errors.ReportTemplateNotFound;
                    error(message(obj.errorMSGID));
                end
            end


            obj.flatAndFilterReportData();


            tmpOutputFile=fullfile(obj.workingPath,obj.workingName);
            if(~isempty(obj.CustomTemplateFile))
                try
                    if(~license('checkout','MATLAB_Report_Gen'))
                        error(message('stm:ReportContent:ReportGeneratorLicenseError'));
                    end
                    obj.Doc=stm.internal.report.STMReportLicense(tmpOutputFile,obj.reportType,obj.CustomTemplateFile);
                catch err
                    throw(err);
                end
            elseif(obj.useTemplate)
                if(strcmp(obj.reportType,'html'))
                    templateFile=fullfile(obj.templatePath,'mainTemplate.htmtx');
                elseif(strcmp(obj.reportType,'docx'))
                    templateFile=fullfile(obj.templatePath,'mainTemplate.dotx');
                elseif(strcmp(obj.reportType,'pdf'))
                    templateFile=fullfile(obj.templatePath,'mainTemplate.pdftx');
                end

                try
                    obj.Doc=stm.internal.report.STMReportLicense(tmpOutputFile,obj.reportType,templateFile);
                catch err
                    throw(err);
                end
            else
                obj.Doc=Document(tmpOutputFile,obj.reportType);
                open(obj.Doc);
            end
            obj.TitlePart=mlreportgen.dom.Group();
            obj.BodyPart=mlreportgen.dom.Group();
            obj.TOCPart=mlreportgen.dom.Group();
        end
    end

    methods(Sealed=true,Hidden)
        function setReportGenerationType(obj,fromCMD)
            obj.fromCMD=fromCMD;
        end
    end
end

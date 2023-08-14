


classdef slcoderPublishCode<mlreportgen.dom.Document
    properties
        modelName=''
        reportInfo=[]
        stdRptConfig=[]
    end
    methods
        function rpt=slcoderPublishCode(aStdRpt,aReportInfo)
            filename=fullfile(aStdRpt.outputDir,aStdRpt.outputName);
            [p,f]=fileparts(aStdRpt.templateFile);
            template=fullfile(p,f);
            aModelName=aStdRpt.rootSystem;
            type=aStdRpt.getOutputFormat();
            rpt=rpt@mlreportgen.dom.Document(filename,type,template);
            rpt.reportInfo=aReportInfo;
            rpt.modelName=aModelName;
            rpt.stdRptConfig=aStdRpt;

            linkManager=Simulink.report.HTMLLinkManager;

            linkManager.HTMLEscape=false;
            linkManager.SystemMap=aReportInfo.SystemMap;
            linkManager.IncludeHyperlinkInReport=false;
            linkManager.ModelName=aReportInfo.ModelName;
            linkManager.BuildDir=aReportInfo.getBuildDir();
            if~isempty(aReportInfo.SourceSubsystem)
                linkManager.SourceSubsystem=aReportInfo.SourceSubsystem;
            end
            for k=1:length(aReportInfo.Pages)
                p=aReportInfo.Pages{k};
                p.setLinkManager(linkManager);
                p.IsEnMessage=false;
            end
        end

        function fillTitle(rpt)
            import mlreportgen.dom.*
            if~isempty(rpt.stdRptConfig.title)
                title=Text(rpt.stdRptConfig.title);
                title.StyleName='ReportStyle';
                rpt.append(title);
            end
        end
        function fillSubtitle(rpt)
            import mlreportgen.dom.*
            if~isempty(rpt.stdRptConfig.subtitle)
                subtitle=Text(rpt.stdRptConfig.subtitle);
                subtitle.StyleName='Subtitle';
                rpt.append(subtitle);
            end
        end

        function fillModelName(rpt)
            import mlreportgen.dom.*
            t=Text(rpt.modelName);
            rpt.append(t);
        end
        function fillLegalNotices(rpt)
            import mlreportgen.dom.*
            t=rpt.stdRptConfig.legalNotice;
            if~isempty(t)
                l=textscan(t,'%s','Delimiter','\n');
                l=l{1};
                for i=1:length(l)
                    t=Text(l{i});
                    p=Paragraph;
                    p.append(t);
                    p.StyleName='LegalNoticesStyle';
                    rpt.append(p);
                end
            end
        end
        function fillReportFileName(rpt)
            import mlreportgen.dom.*


            if strcmp(rpt.stdRptConfig.getOutputFormat,'pdf')
                [~,fname]=fileparts(rpt.FileName);
                t=Text([fname,'.pdf']);
            else
                t=Text(rpt.FileName);
            end
            rpt.append(t);
        end
        function fillAuthorName(rpt)
            rpt.append(rpt.stdRptConfig.authorNames);
        end
        function fillLogo(rpt)
            import mlreportgen.dom.*
            fileName=rpt.stdRptConfig.titleImgPath;
            if exist(fileName,'file')&&~exist(fileName,'dir')
                image=Image(fileName);
                rpt.append(image);
            end
        end
        function fillModelInformation(rpt)
            if rpt.stdRptConfig.modelInformation
                templatePath=coder.report.internal.slcoderPublishCode.getPrivateTemplatePath();
                template=fullfile(templatePath,'ModelInfoTemplate');
                type=rpt.stdRptConfig.getOutputFormat;
                part=coder.report.internal.slcoderPublishModelInformation(type,template,rpt.reportInfo);
                part.fill();
                rpt.append(part);
            end
        end
        function fillConfigurationParameters(rpt)
            templatePath=coder.report.internal.slcoderPublishCode.getPrivateTemplatePath();
            template=fullfile(templatePath,'Configset');
            type=rpt.stdRptConfig.getOutputFormat;
            part=coder.report.internal.slcoderPublishConfigset(type,template,rpt.reportInfo);
            part.fill();
            rpt.append(part);
        end
        function fillSummaryReport(rpt)
            summary=rpt.reportInfo.getPage('Summary');
            templatePath=coder.report.internal.slcoderPublishCode.getPrivateTemplatePath();
            template=fullfile(templatePath,'Summary');
            type=rpt.stdRptConfig.getOutputFormat;
            summary.emit(rpt,type,template);
        end
        function fillSubsystemReport(rpt)
            subsystem=rpt.reportInfo.getPage('Subsystem');
            templatePath=coder.report.internal.slcoderPublishCode.getPrivateTemplatePath();
            template=fullfile(templatePath,'Subsystem');
            type=rpt.stdRptConfig.getOutputFormat;
            subsystem.emit(rpt,type,template);
        end
        function fillCodeInterfaceReport(rpt)
            dataObj=rpt.reportInfo.getPage('CodeInterface');
            if~isempty(dataObj)
                templatePath=coder.report.internal.slcoderPublishCode.getPrivateTemplatePath();
                template=fullfile(templatePath,'CodeInterface');
                type=rpt.stdRptConfig.getOutputFormat;
                dataObj.emit(rpt,type,template);
            end
        end
        function fillTraceabilityReport(rpt)
            dataObj=rpt.reportInfo.getPage('Traceability');
            if~isempty(dataObj)
                templatePath=coder.report.internal.slcoderPublishCode.getPrivateTemplatePath();
                template=fullfile(templatePath,'Traceability');
                type=rpt.stdRptConfig.getOutputFormat;
                dataObj.emit(rpt,type,template,rpt.reportInfo);
            end
        end
        function fillStaticCodeMetricsReport(rpt)
            dataObj=rpt.reportInfo.getPage('CodeMetrics');
            if~isempty(dataObj)
                templatePath=coder.report.internal.slcoderPublishCode.getPrivateTemplatePath();
                template=fullfile(templatePath,'CodeMetrics');
                type=rpt.stdRptConfig.getOutputFormat;
                dataObj.emit(rpt,type,template,rpt.reportInfo);
            end
        end
        function fillCodeReplacementsReport(rpt)
            dataObj=rpt.reportInfo.getPage('CodeReplacements');
            if~isempty(dataObj)
                templatePath=coder.report.internal.slcoderPublishCode.getPrivateTemplatePath();
                template=fullfile(templatePath,'CodeReplacements');
                type=rpt.stdRptConfig.getOutputFormat;
                dataObj.emit(rpt,type,template);
            end
        end
        function fillInsertedBlocksReport(rpt)
            dataObj=rpt.reportInfo.getPage('InsertedBlocks');
            if~isempty(dataObj)
                templatePath=coder.report.internal.slcoderPublishCode.getPrivateTemplatePath();
                template=fullfile(templatePath,'InsertedBlocks');
                type=rpt.stdRptConfig.getOutputFormat;
                dataObj.emit(rpt,type,template);
            end
        end
        function fillReducedBlocksReport(rpt)
            dataObj=rpt.reportInfo.getPage('ReducedBlocks');
            if~isempty(dataObj)
                templatePath=coder.report.internal.slcoderPublishCode.getPrivateTemplatePath();
                template=fullfile(templatePath,'ReducedBlocks');
                type=rpt.stdRptConfig.getOutputFormat;
                dataObj.emit(rpt,type,template);
            end
        end
        function fillGeneratedCode(rpt)
            if rpt.stdRptConfig.generatedCodeListings
                templatePath=coder.report.internal.slcoderPublishCode.getPrivateTemplatePath();
                template=fullfile(templatePath,'GeneratedCodeTemplate');
                type=rpt.stdRptConfig.getOutputFormat;
                part=coder.report.internal.slcoderPublishGeneratedCode(type,template,rpt.reportInfo);
                part.fill();
                rpt.append(part);
            end
        end
    end
    methods(Static=true)
        function out=getTemplatePath()
            out=fullfile(matlabroot,'toolbox','coder','simulinkcoder','+coder','+report','resources','templates');
        end
        function out=getPrivateTemplatePath()
            out=fullfile(matlabroot,'toolbox','coder','simulinkcoder','+coder','+report','+internal','resources','templates');
        end
        function out=getDefaultTemplate()
            out=fullfile(coder.report.internal.slcoderPublishCode.getTemplatePath(),'default_template');
        end
        function publish(aStdRpt,reportInfo)
            if aStdRpt.isDebug
                dispatcher=mlreportgen.dom.MessageDispatcher.getTheDispatcher;
                l=addlistener(dispatcher,'Message',@handler);
            end
            type=aStdRpt.getOutputFormat;
            if isempty(aStdRpt.outputDir)||~exist(aStdRpt.outputDir,'dir')
                aStdRpt.outputDir=pwd;
            end
            if isempty(aStdRpt.outputName)
                aStdRpt.outputName=aStdRpt.rootSystem;
            end
            fileName=fullfile(aStdRpt.outputDir,aStdRpt.outputName);
            rpt=coder.report.internal.slcoderPublishCode(aStdRpt,reportInfo);

            [~,attr]=fileattrib(aStdRpt.outputDir);
            if~attr.UserWrite
                DAStudio.error('CoderFoundation:report:ReadOnlyFolder',aStdRpt.outputDir);
            end
            if exist([fileName,'.docx'],'file')
                [~,attr]=fileattrib([fileName,'.docx']);
                if~attr.UserWrite
                    DAStudio.error('CoderFoundation:report:ReadOnlyFile',[fileName,'.docx']);
                end
                coder.report.internal.slcoderPublishCode.closeDoc(fileName);
            end
            if exist([rpt.TemplatePath,'.dotx'],'file')
                coder.report.internal.slcoderPublishCode.closeDoc([rpt.TemplatePath,'.dotx']);
            else
                DAStudio.error('RTW:report:TemplateNotExist',[rpt.TemplatePath,'.dotx']);
            end
            try
                rpt.fill();
            catch ME
                if aStdRpt.isDebug
                    delete(l);
                end
                if strcmp(ME.identifier,'mlreportgen:dom_error:pkgCloseError')
                    DAStudio.error('CoderFoundation:report:docFillError',[fileName,'.docx']);
                else
                    rethrow(ME);
                end
            end
            if aStdRpt.isDebug
                delete(l);
            end

            if~rtwprivate('rtwinbat')
                coder.report.internal.slcoderPublishCode.openDoc(fileName,type);
                disp(DAStudio.message('RTW:report:PrintableReportDesktopMessage',[fileName,'.',type]));
            end

            function handler(~,evtdata)
                msg=evtdata.Message;
                disp(msg.formatAsText);
            end
        end
        function openDoc(fileName,type)
            try
                if ispc

                    docview([fileName,'.docx'],'updatedocxfields');
                    docview([fileName,'.docx'],'updatedocxfields');

                    docview([fileName,'.docx'],'savedoc');
                end
                rptview(fileName,type);
            catch ME %#ok<*NASGU>
                if strcmp(type,'pdf')
                    if~coder.report.internal.slcoderPublishCode.hasWordApp
                        disp(DAStudio.message('RTW:report:PrintableReportDesktopMessage',[fileName,'.docx']));
                        DAStudio.error('rptgen:rptgenrptgen:cannotConvertToPDF',[fileName,'.docx'],...
                        DAStudio.message('CoderFoundation:report:NoWordApp'));
                    elseif strcmp(ME.identifier,'rptgen:rptgenrptgen:cannotConvertToPDF')
                        DAStudio.error('CoderFoundation:report:docFillError',[fileName,'.',type]);
                    end
                end
            end
        end
        function closeDoc(fileName)
            if~rtwprivate('rtwinbat')&&ispc
                try

                    docview(fileName,'closedoc');


                catch ex
                end
            end
        end
        function out=hasWordApp()
            persistent cachedHasWordApp
            if isempty(cachedHasWordApp)
                if~ispc
                    cachedHasWordApp=false;
                else
                    try
                        hWord=actxserver('word.application');
                        try %#ok

                            invoke(hWord,'Quit',false);


                            pause(1);
                        end
                        cachedHasWordApp=true;
                    catch ME
                        cachedHasWordApp=false;
                    end
                end
            end
            out=cachedHasWordApp;
        end
    end
end



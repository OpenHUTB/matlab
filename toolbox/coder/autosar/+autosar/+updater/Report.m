classdef Report<handle




    properties(Access=private,Transient=true)
        ReportObj;
    end

    methods(Access=public)
        function this=Report()
        end

        function build(this,autosarComparatorChangeLogger,builderChangeLogger,modelName,componentQualifiedName,modelNameForBackup)


            this.ReportObj=rtw.report.Report(autosar.updater.Report.getHTMLFilename(modelName),...
            autosar.updater.Report.getDir(),false);

            this.ReportObj.Doc.addHeadItem('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />');


            this.overrideStylesheet()


            this.setTitle(message('RTW:autosar:updateReportTitle',modelName).getString());


            this.addItem(autosar.updater.Report.getSubheadingElement(...
            {message('RTW:autosar:updateReportSWC',componentQualifiedName).getString(),...
            message('RTW:autosar:updateReportOriginalModel',modelNameForBackup).getString()}));


            cmdToLaunchVisdiff=['matlab:save_system(''',modelName,''');visdiff(''',modelName,''', ''',modelNameForBackup,''')'];
            this.addItem(autosar.updater.Report.getParagraphElement(...
            message('RTW:autosar:updateReportIntro',modelName,modelNameForBackup,cmdToLaunchVisdiff).getString()));


            this.addItem(autosar.updater.Report.getProductElement('Simulink'));


            slChanges=builderChangeLogger.getLog('Automatic');
            this.addItem(autosar.updater.Report.getH2Element(message('RTW:autosar:updateReportAutomaticModelChanges').getString()));
            this.addItem(autosar.updater.Report.getChangeList(slChanges));


            wsChanges=builderChangeLogger.getLog('WorkSpace');
            this.addItem(autosar.updater.Report.getH2Element(message('RTW:autosar:updateReportAutomaticWorkspaceChanges').getString()));
            this.addItem(autosar.updater.Report.getChangeList(wsChanges));

            ddFileName=get_param(modelName,'DataDictionary');
            if~isempty(ddFileName)
                cmdToViewGlobalDesignData=['matlab:Simulink.dd.open(''',ddFileName,''').explore()'];
                this.addItem(autosar.updater.Report.getParagraphElement(...
                message('RTW:autosar:updateReportViewGlobalDesignData',cmdToViewGlobalDesignData).getString()));
            end


            manualChanges=builderChangeLogger.getLog('Manual');
            this.addItem(autosar.updater.Report.getH2Element(message('RTW:autosar:updateReportManualModelChanges').getString()));
            this.addItem(autosar.updater.Report.getChangeList(manualChanges));


            recomChanges={};
            this.addItem(autosar.updater.Report.getH2Element(message('RTW:autosar:updateReportManualWorkspaceChanges').getString()));
            this.addItem(autosar.updater.Report.getChangeList(recomChanges));


            this.addItem(autosar.updater.Report.getProductElement('AUTOSAR'));


            m3iChanges=autosarComparatorChangeLogger.getLog('MetaModel');
            this.addItem(autosar.updater.Report.getH2Element(message('RTW:autosar:updateReportAutomaticAUTOSARChanges').getString()));
            this.addItem(autosar.updater.Report.getChangeList(m3iChanges));



            if autosar.api.Utils.isMappedToComposition(modelName)
                this.addCompositionSection(modelName,slChanges);
            end


            autosar.updater.Report.copyResources();
            this.writeHTML();
        end



        function buildForAutoConfigAndMap(this,slChangeLogger,modelName)


            this.ReportObj=rtw.report.Report(autosar.updater.Report.getHTMLFilename(modelName),...
            autosar.updater.Report.getDir(),false);
            this.ReportObj.Doc.addHeadItem('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />');


            this.overrideStylesheet()


            this.setTitle(message('RTW:autosar:updateReportTitle',modelName).getString());
            this.addItem(autosar.updater.Report.getParagraphElement(...
            message('RTW:autosar:updateReportIntroForAutoConfigAndMap',modelName).getString()));


            this.addItem(autosar.updater.Report.getProductElement('Simulink'));


            slChanges=slChangeLogger.getLog('Automatic');
            this.addItem(autosar.updater.Report.getH2Element(message('RTW:autosar:updateReportAutomaticModelChanges').getString()));
            this.addItem(autosar.updater.Report.getChangeList(slChanges));


            autosar.updater.Report.copyResources();
            this.writeHTML();
        end



        function buildForPackage(this,autosarComparatorChangeLogger,pkgFileName)

            [~,pkgFileNameNoExt]=fileparts(pkgFileName);

            this.ReportObj=rtw.report.Report(autosar.updater.Report.getHTMLFilename(pkgFileNameNoExt),...
            autosar.updater.Report.getDir(),false);

            this.ReportObj.Doc.addHeadItem('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />');


            this.overrideStylesheet()


            this.setTitle(message('RTW:autosar:updateReportTitle',pkgFileName).getString());


            this.addItem(autosar.updater.Report.getParagraphElement(...
            message('autosarstandard:report:updateDictionaryReportIntro',pkgFileName).getString()));


            this.addItem(autosar.updater.Report.getProductElement('AUTOSAR'));


            m3iChanges=autosarComparatorChangeLogger.getLog('MetaModel');
            this.addItem(autosar.updater.Report.getH2Element(message('RTW:autosar:updateReportAutomaticAUTOSARChanges').getString()));
            this.addItem(autosar.updater.Report.getChangeList(m3iChanges));


            autosar.updater.Report.copyResources();
            this.writeHTML();
        end

    end

    methods(Access=private)

        function overrideStylesheet(this)
            this.ReportObj.Doc.addHeadItem('<link rel="stylesheet" type="text/css" href="autosarreport.css" />');
        end

        function setTitle(this,title)


            this.ReportObj.setTitle(title);
            titleText=ModelAdvisor.Element;
            titleText.setContent(title);
            titleText.setTag('h1');
            this.ReportObj.addItem(titleText);
        end

        function addItem(this,itemHtml)
            this.ReportObj.addItem(itemHtml);
        end

        function writeHTML(this)


            workDir=autosar.updater.Report.getDir();
            fid=fopen(fullfile(workDir,this.ReportObj.ReportFileName),'w','n','utf-8');
            fwrite(fid,this.ReportObj.emitHTML(),'char');
            fclose(fid);
        end

        function addCompositionSection(this,modelName,slChanges)


            refComponentsUpdateModelReports=[];
            refComponentsNewlyAdded=[];

            blockType='ModelReference';
            modelBlocks=autosar.mm.mm2sl.SLModelBuilder.findSimulinkBlock(...
            modelName,blockType,'');
            for mdlBlkIdx=1:length(modelBlocks)
                modelBlockName=getfullname(modelBlocks(mdlBlkIdx));
                refModel=get_param(modelBlocks(mdlBlkIdx),'ModelName');




                isNewComponent=any(strcmp(slChanges,message('RTW:autosar:logAdditionAutomatic',...
                [blockType,' block'],...
                autosar.updater.Report.getBlkHyperlink(modelBlockName)).getString()));
                if isNewComponent
                    cmdToLaunchReport=['open_system(''',refModel,''')'];
                    refComponentsNewlyAdded{end+1}=autosar.updater.Report.getMATLABHyperlink(cmdToLaunchReport,refModel);%#ok<AGROW>
                else
                    cmdToLaunchReport=['autosar.updater.Report.launchReportNow(''',...
                    autosar.updater.Report.getHTMLFilename(refModel),''', ''',autosar.updater.Report.getDir(),''')'];
                    refComponentsUpdateModelReports{end+1}=autosar.updater.Report.getMATLABHyperlink(cmdToLaunchReport,refModel);%#ok<AGROW>
                end
            end


            if~isempty(refComponentsUpdateModelReports)||~isempty(refComponentsNewlyAdded)
                this.addItem(autosar.updater.Report.getProductElement(message('RTW:autosar:updateReportRefComponentsTitle').getString()));
            end


            if~isempty(refComponentsUpdateModelReports)
                refComponentsUpdateModelReports=unique(refComponentsUpdateModelReports);
                this.addItem(autosar.updater.Report.getH2Element(message('RTW:autosar:updateReportRefComponentsUpdated').getString()));
                this.addItem(autosar.updater.Report.getChangeList(refComponentsUpdateModelReports));
            end

            if~isempty(refComponentsNewlyAdded)
                refComponentsNewlyAdded=unique(refComponentsNewlyAdded);
                this.addItem(autosar.updater.Report.getH2Element(message('RTW:autosar:updateReportRefComponentsAdded').getString()));
                this.addItem(autosar.updater.Report.getChangeList(refComponentsNewlyAdded));
            end
        end
    end

    methods(Static)

        function dispHelpLine(modelName)

            cmdToLaunchReport=['matlab:autosar.updater.Report.launchReportNow(''',...
            autosar.updater.Report.getHTMLFilename(modelName),''', ''',autosar.updater.Report.getDir(),''')'];
            autosar.mm.util.MessageReporter.print(message('RTW:autosar:creatingReport',cmdToLaunchReport,...
            autosar.updater.Report.getHTMLFilename(modelName)).getString());
        end


        function launchReport(modelName)
            if rtwprivate('rtwinbat')
                autosar.mm.util.MessageReporter.print(...
                [autosar.updater.Report.getHTMLFilename(modelName),'  is not launched in BaT or during test execution.']);
            else
                autosar.updater.Report.launchReportNow(autosar.updater.Report.getHTMLFilename(modelName),autosar.updater.Report.getDir());
            end
        end

        function launchReportNow(reportFileName,workDir)
            rpt=autosar.updater.Report.createNewReportDialog(...
            fullfile(workDir,reportFileName),...
            'AUTOSAR Update Report',...
            'helpview([docroot ''/autosar/autosar/arxml.importer.updatemodel.html''],''slWebView'')');


            rpt.evalBrowserJS('Tag_Coder_Report_Dialog','top.location.reload();');


            rpt.showNormal;
            rpt.show;
        end

        function blkHyperlink=getBlkHyperlink(blkPath)
            blkPath=strrep(blkPath,newline,' ');
            blkHyperlink=sprintf('<a href="matlab:hilite_system(''%s'')">%s</a>',...
            blkPath,blkPath);

        end

        function hyperlink=getMATLABHyperlink(cmd,label)
            hyperlink=sprintf('<a href="matlab:%s">%s</a>',cmd,label);
        end
    end

    methods(Static,Access=private)
        function rpt=createNewReportDialog(url,title,helpMethod)
            src=Simulink.document(url,title);
            src.ExplicitShow=true;
            src.Title=title;
            src.HelpMethod=helpMethod;
            src.IsCodeReportDocumentStyle=true;

            rpt=DAStudio.Dialog(src);
            rpt.position=[50,50,950,700];
        end

        function reportDir=getDir()
            fileGenCfg=Simulink.fileGenControl('getConfig');
            rootBDir=fileGenCfg.CacheFolder;
            reportDir=rtwprivate('rtw_create_directory_path',rootBDir,'slprj','autosarupdater');
        end

        function htmlFilename=getHTMLFilename(modelName)
            htmlFilename=[modelName,'_update_report.html'];
        end

        function copyResources()
            resourcesBuild={'autosarreport.css'};
            resourceDir=fullfile(autosarroot,'resources');

            for k=1:length(resourcesBuild)
                copyfile(fullfile(resourceDir,resourcesBuild{k}),...
                autosar.updater.Report.getDir(),'f');
                fileattrib(fullfile(autosar.updater.Report.getDir(),resourcesBuild{k}),'+w');
            end
        end


        function element=getSubheadingElement(contentCellStr)
            content='';
            sep='';
            for ii=1:length(contentCellStr)
                content=sprintf('%s%s%s',content,sep,contentCellStr{ii});
                sep='<br>';
            end

            element=Advisor.Element;
            element.setContent(content);
            element.setTag('h3');
            element.setAttribute('class','subhead');
        end

        function element=getParagraphElement(content)
            element=Advisor.Element;
            element.setContent(content);
            element.setTag('p');
        end

        function element=getProductElement(content)
            element=Advisor.Element;
            element.setContent(content);
            element.setTag('h2');
            element.setAttribute('class','product');
        end

        function element=getH2Element(content)
            element=Advisor.Element;
            element.setContent(content);
            element.setTag('h2');
        end

        function list=getChangeList(changeStr)
            list=Advisor.List();
            list.addItem(changeStr);
        end

    end
end



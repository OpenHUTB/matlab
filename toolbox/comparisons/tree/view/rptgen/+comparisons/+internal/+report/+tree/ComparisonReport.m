classdef ComparisonReport<mlreportgen.dom.LockedDocument





    properties(Access=private)
MCOSView
ComparisonSources
ReportConfig
ReportTempDir
    end

    properties(Access=public)
        FileInfoRetrievers={...
        @comparisons.internal.report.fileinfo.getFileName,...
        @comparisons.internal.report.fileinfo.getFilePath,...
        @comparisons.internal.report.fileinfo.getLastModified...
        }
        Products="MATLAB"
        SectionFactories cell={...
        comparisons.internal.report.tree.sections.TreeSectionFactory()...
        }
        GetNameOfFilter(1,1)function_handle=@(filterName)filterName
    end

    methods(Access=public)

        function report=ComparisonReport(mcosView,sources,reportLocation,rptFormat)
            report@mlreportgen.dom.LockedDocument(reportLocation,rptFormat.RPTGenType,rptFormat.RPTGenReportTemplate);

            report.MCOSView=mcosView;
            report.ComparisonSources=cellfun(@checkFileSource,sources,UniformOutput=false);
            function s=checkFileSource(source)
                if isa(source,'comparisons.internal.FileSource')
                    s=source;
                else
                    s=comparisons.internal.FileSource(comparisons.internal.resolvePath(source));
                end
            end

            config.ReportFormat=rptFormat;
            config.RPTGenTemplateKey=comparisons.internal.report.tree.key.(rptFormat.getFileExtension);
            report.ReportConfig=config;

            report.ReportTempDir=tempname;
            mkdir(report.ReportTempDir);
            report.StreamOutput=true;

            report.open(report.ReportConfig.RPTGenTemplateKey);
        end

        function fillReportTitle(report)
            import mlreportgen.dom.Text;
            titleString=message('comparisons:rptgen:ReportTitle').getString;
            text=Text(titleString,'ReportTitle');
            report.append(text);
        end

        function fillReportSubtitle(report)
            titleString=message('comparisons:commonweb:WindowTitle',...
            report.ComparisonSources{1}.Path,...
            report.ComparisonSources{2}.Path).getString;
            report.append(titleString);
        end

        function fillReportCreator(report)



            import comparisons.internal.isMOTW
            if~isMOTW
                username=comparisons.internal.report.tree.sections.Utils.getUsername();
                report.append(username);
            end
        end

        function fillReportDate(report)
            report.append(string(datetime('today')));
        end

        function fillFileInformation(report)
            import mlreportgen.dom.FormalTable
            import mlreportgen.dom.Width
            import mlreportgen.dom.ResizeToFitContents
            import mlreportgen.dom.TableRow
            import mlreportgen.dom.TableEntry

            table=FormalTable(numel(report.ComparisonSources)+1);
            table.Style={Width('100%'),ResizeToFitContents(false)};
            table.StyleName='FileInfoTable';

            headerRow=TableRow();
            headerRow.append(TableEntry(''));
            headerRow.append(TableEntry(message('comparisons:rptgen:LeftFile').getString));
            headerRow.append(TableEntry(message('comparisons:rptgen:RightFile').getString));
            table.appendHeaderRow(headerRow);

            for infoIndex=1:numel(report.FileInfoRetrievers)
                report.addEntriesForFileInfoProvider(...
                table,report.FileInfoRetrievers{infoIndex},report.ComparisonSources...
                );
            end

            report.append(table);
        end

        function fillEnvironmentInformation(report)
            import mlreportgen.dom.Table

            table=Table(2);
            table.StyleName='EnvironmentInfoTable';

            for infoIndex=1:numel(report.Products)
                report.addEntriesForEnvironmentInfoProvider(...
                table,report.Products(infoIndex)...
                );
            end

            report.append(table);
        end

        function fillFiltersSummary(report)
            import mlreportgen.dom.Italic
            import mlreportgen.dom.Paragraph
            import mlreportgen.dom.Text
            import mlreportgen.dom.WhiteSpace

            if report.areFiltersApplicable()
                filters=report.MCOSView.getFilters();

                if isempty(filters)
                    noFiltersText=message('comparisons:rptgen:NoBuiltInFilters').getString();
                    text=Text(noFiltersText);
                    text.Style=[text.Style,{Italic()}];
                else
                    filterNames=cellfun(report.GetNameOfFilter,filters,'UniformOutput',false);
                    filtersText=sprintf('%s\n',filterNames{:});
                    filtersText=filtersText(1:end-1);
                    text=Text(filtersText);
                end

                text.Style=[text.Style,{WhiteSpace('preserve')}];
                text.StyleName='FilterSummarySectionContent';
                paragraph=Paragraph(text);
                paragraph.WhiteSpace='pre';
                report.append(paragraph);
            end
        end

        function fillComparisonDiffs(report)
            import comparisons.internal.report.tree.sections.RootNodeSectionsFactory
            sectionsFactory=RootNodeSectionsFactory(...
            report.MCOSView,report.ComparisonSources,report.ReportTempDir,report.SectionFactories...
            );
            sections=sectionsFactory.create(report.ReportConfig);

            containsDiffs=false;

            import comparisons.internal.report.tree.sections.Utils
            for sectionIndex=1:numel(sections)
                section=sections{sectionIndex};
                section.TemplateName=Utils.getTemplateName(section);
                section.open(report.ReportConfig.RPTGenTemplateKey);
                section.fill();
                report.append(section);

                if section.SectionConfig.ContainsDiffs
                    containsDiffs=true;
                end
            end

            import mlreportgen.dom.Italic
            import mlreportgen.dom.Text
            if~containsDiffs
                noDiffsString=message('comparisons:rptgen:NoChangesDetected').getString();
                noDiffsText=Text(noDiffsString);
                noDiffsText.Style=[noDiffsText.Style,{Italic()}];
                report.append(noDiffsText);
            end
        end

        function fillFiltersAppendix(~)

        end

        function fillFileInfoTitle(report)
            titleString=message('comparisons:rptgen:FilesTitle').getString();
            report.appendSectionTitle(titleString);
        end

        function fillEnvironmentInfoTitle(report)
            titleString=message('comparisons:rptgen:EnvironmentTitle').getString();
            report.appendSectionTitle(titleString);
        end

        function fillFiltersSummaryTitle(report)
            if report.areFiltersApplicable
                titleString=message('comparisons:rptgen:FiltersSummaryTitle').getString();
                report.appendSectionTitle(titleString);
            end
        end

        function fillDifferencesTitle(report)
            titleString=message('comparisons:rptgen:ResultsTitle').getString();
            report.appendSectionTitle(titleString);
        end

        function fillFiltersAppendixTitle(report)

        end

        function delete(report)
            if exist(report.ReportTempDir,'file')~=0
                rmdir(report.ReportTempDir,'s');
            end
        end

    end


    methods(Access=private)

        function appendSectionTitle(report,titleString)
            import mlreportgen.dom.Text
            text=Text(titleString,'ReportSectionHeading');
            report.append(text);
        end

        function addEntriesForFileInfoProvider(~,table,fileInfoProvider,sources)
            import mlreportgen.dom.TableEntry
            import mlreportgen.dom.TableRow

            [infoType,~]=fileInfoProvider(sources{1});


            row=TableRow();
            row.append(...
            TableEntry(infoType,'FileInfoName')...
            );
            table.append(row);


            for fileIndex=1:numel(sources)
                file=sources{fileIndex};
                [~,value]=fileInfoProvider(file);
                row(1).append(TableEntry(value));
            end
        end

        function addEntriesForEnvironmentInfoProvider(~,table,product)
            import mlreportgen.dom.TableEntry
            import mlreportgen.dom.TableRow
            import comparisons.internal.report.envinfo.getProductVersion

            row=TableRow();
            row.append(TableEntry(product,'EnvironmentName'));
            row.append(TableEntry(getProductVersion(product)));
            table.append(row);
        end

        function bool=areFiltersApplicable(report)
            bool=ismethod(report.MCOSView,'getFilters');
        end

    end

end


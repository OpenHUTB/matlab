classdef ComparisonReport<mlreportgen.dom.LockedDocument




    properties(Access=private)
        JDriverFacade;
        DiffsGraphModel;
        ReportFormat;
        FileInfoRetrievers={...
        slxmlcomp.internal.report.fileinfo.FileName(),...
        slxmlcomp.internal.report.fileinfo.FilePath(),...
        slxmlcomp.internal.report.fileinfo.LastModified(),...
        slxmlcomp.internal.report.fileinfo.MD5Checksum(),...
        slxmlcomp.internal.report.fileinfo.MDLInfo()...
        };
        EnvironmentInfoRetrievers={...
        slxmlcomp.internal.report.envinfo.ProductVersion('MATLAB'),...
        slxmlcomp.internal.report.envinfo.ProductVersion('Simulink')...
        };
        ComparisonSources;
        ReportTempDir;
        HexGray='#808080';
    end

    methods(Access=public)

        function report=ComparisonReport(driverFacade,reportLocation,rptFormat)
            report@mlreportgen.dom.LockedDocument(reportLocation,rptFormat.RPTGenType,rptFormat.RPTGenReportTemplate);

            report.JDriverFacade=driverFacade;
            report.ReportFormat=rptFormat;

            report.DiffsGraphModel=report.JDriverFacade.getResult().getDifferenceGraphModel();

            report.ComparisonSources={report.JDriverFacade.getLeftSource(),...
            report.JDriverFacade.getRightSource()};

            report.ReportTempDir=tempname;
            mkdir(report.ReportTempDir);
            report.StreamOutput=true;

            report.open(rptFormat.RPTGenTemplateKey);

            for loadIndex=1:numel(report.ComparisonSources)
                jSrc=report.ComparisonSources{loadIndex};
                jFile=jSrc.getModelData().getFileToUseInMemory();
                load_system(char(jFile.getPath()));
            end
        end

        function fillReportTitle(report)
            import mlreportgen.dom.Text;
            titleString=report.getResourceString('report.title');
            text=Text(titleString,'ReportTitle');
            report.append(text);
        end

        function fillReportSubtitle(report)
            import mlreportgen.dom.Text;
            titleProperty=com.mathworks.comparisons.source.property.CSPropertyTitle.getInstance();
            title=char(com.mathworks.comparisons.util.ResourceManager.format(...
            'comparisonreport.title.two',...
            {char(report.JDriverFacade.getLeftSource().getPropertyValue(titleProperty,[])),...
            char(report.JDriverFacade.getRightSource().getPropertyValue(titleProperty,[]))}...
            ));

            subtitleElement=Text(title);
            report.append(subtitleElement);
        end

        function fillReportCreator(report)
            if ispc
                username=getenv('USERNAME');
            else
                username=getenv('USER');
            end
            report.append(username);
        end

        function fillReportDate(report)
            report.append(date);
        end

        function fillFileInformation(report)
            import mlreportgen.dom.TableEntry;
            import mlreportgen.dom.TableRow;
            import mlreportgen.dom.FormalTable;
            import mlreportgen.dom.Width;
            import mlreportgen.dom.ResizeToFitContents;

            table=FormalTable(numel(report.ComparisonSources)+1);
            table.Style={Width('100%'),ResizeToFitContents(false)};
            table.StyleName='FileInfoTable';

            headerRow=TableRow();
            headerRow.append(TableEntry(''));
            headerRow.append(TableEntry(report.getResourceString('report.info.leftfile')));
            headerRow.append(TableEntry(report.getResourceString('report.info.rightfile')));
            table.appendHeaderRow(headerRow);

            for infoIndex=1:numel(report.FileInfoRetrievers)
                report.addEntriesForFileInfoProvider(...
                table,report.FileInfoRetrievers{infoIndex},report.ComparisonSources...
                );
            end

            report.append(table);
        end

        function fillEnvironmentInformation(report)
            import mlreportgen.dom.TableEntry;
            import mlreportgen.dom.TableRow;
            import mlreportgen.dom.Table;

            table=Table(2);
            table.StyleName='EnvironmentInfoTable';

            for infoIndex=1:numel(report.EnvironmentInfoRetrievers)
                report.addEntriesForEnvironmentInfoProvider(...
                table,report.EnvironmentInfoRetrievers{infoIndex}...
                );
            end

            report.append(table);
        end

        function fillFiltersSummary(report)
            import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.filter.SLXFilterUtils;
            import com.mathworks.comparisons.filter.user.FilterMode;
            import mlreportgen.dom.*;

            uiFilterState=report.JDriverFacade.getFilters();

            if FilterMode.SHOW.equals(uiFilterState.getFilterMode())
                showHideMessageId='report.filters.show.description';
            else
                showHideMessageId='report.filters.hide.description';
            end
            showHideMessage=Paragraph(getTreeFilterString(showHideMessageId));
            report.append(showHideMessage);

            text=Text(getTreeFilterString('filter.category.built-in'));
            text.StyleName='FilterSummarySectionHeader';
            report.append(text);

            builtInFilters=SLXFilterUtils.getVisibleBuiltInFilters(uiFilterState);
            report.addAppliedFilterList(...
            uiFilterState,...
            builtInFilters,...
            report.getResourceString('report.filters.builtin.none')...
            );

            text=Text(getTreeFilterString('filter.category.user'));
            text.StyleName='FilterSummarySectionHeader';
            report.append(Paragraph(text));

            userFilters=SLXFilterUtils.getVisibleUserFilters(uiFilterState);
            report.addAppliedFilterList(...
            uiFilterState,...
            userFilters,...
            report.getResourceString('report.filters.user.none')...
            );
        end


        function fillComparisonDiffs(report)

            import slxmlcomp.internal.report.sections.RootNodeSectionsFactory;
            sectionsFactory=RootNodeSectionsFactory(...
            report.JDriverFacade,report.ReportTempDir,report.ComparisonSources...
            );
            sections=sectionsFactory.create(report.ReportFormat);

            for sectionIndex=1:numel(sections)
                section=sections{sectionIndex};
                if strcmp(section.Type,'PDF')
                    section.open(report.ReportFormat.RPTGenTemplateKey);
                else
                    section.TemplateName='';
                    section.open(report.ReportFormat.RPTGenTemplateKey);
                end
                section.fill();
                report.append(section);
            end

        end

        function fillFiltersAppendix(report)
            import mlreportgen.dom.*;

            userFilters=report.getCustomFilters();
            filterIterator=userFilters.iterator();

            if(~filterIterator.hasNext())
                noFiltersMessage=Text(...
                report.getResourceString('report.filters.user.none')...
                );

                noFiltersMessage.Style={Italic()};
                report.append(Paragraph(noFiltersMessage));
            end

            while(filterIterator.hasNext())
                filter=filterIterator.next;

                text=Text(char(filter.getName()));
                text.StyleName='FilterAppendixFilterName';
                report.append(text);

                report.addFilterDetailsTable(filter);
                report.append(Paragraph(newline));
            end

        end


        function fillFileInfoTitle(report)
            report.appendSectionTitle('report.fileinfo.heading');
        end

        function fillEnvironmentInfoTitle(report)
            report.appendSectionTitle('report.env.heading');
        end

        function fillFiltersSummaryTitle(report)
            report.appendSectionTitle('report.summary.filters');
        end

        function fillDifferencesTitle(report)
            report.appendSectionTitle('report.details.title');
        end

        function fillFiltersAppendixTitle(report)
            report.appendSectionTitle('report.filters.appendix.title');
        end

        function delete(report)
            if exist(report.ReportTempDir,'file')~=0
                rmdir(report.ReportTempDir,'s');
            end
        end

    end


    methods(Access=private)

        function addEntriesForFileInfoProvider(~,table,fileInfoProvider,sources)
            import mlreportgen.dom.TableEntry;
            import mlreportgen.dom.TableRow;


            names=fileInfoProvider.Names;
            for rowIndex=1:numel(names)
                rows(rowIndex)=TableRow();%#ok<AGROW>
                rows(rowIndex).append(...
                TableEntry(names{rowIndex},'FileInfoName')...
                );
                table.append(rows(rowIndex));
            end


            for fileIndex=1:numel(sources)
                import slxmlcomp.internal.report.sections.Util;
                file=Util.getOriginalFileFromSource(sources{fileIndex});
                fileValues=fileInfoProvider.getValuesForFile(file);
                for rowIndex=1:numel(names)
                    rows(rowIndex).append(TableEntry(fileValues{rowIndex}));
                end
            end
        end

        function appendSectionTitle(report,stringID)
            import mlreportgen.dom.Text;
            titleString=report.getResourceString(stringID);
            text=Text(titleString,'ReportSectionHeading');
            report.append(text);
        end

        function addEntriesForEnvironmentInfoProvider(~,table,envInfoProvider)
            import mlreportgen.dom.TableEntry;
            import mlreportgen.dom.TableRow;
            import mlreportgen.dom.Text;

            names=envInfoProvider.Names;
            values=envInfoProvider.Values;
            for rowIndex=1:numel(names)
                rows(rowIndex)=TableRow();%#ok<AGROW>
                rows(rowIndex).append(TableEntry(names{rowIndex},'EnvironmentName'));
                rows(rowIndex).append(TableEntry(values{rowIndex}));
                table.append(rows(rowIndex));
            end

        end

        function row=createFileInfoTableRow(~,property,value)
            import mlreportgen.dom.*;
            row=TableRow;

            propertyEntry=TableEntry([property,': ']);
            propertyEntry.StyleName='fileInfoPropertyName';

            row.append(propertyEntry);

            if isnumeric(value)||islogical(value)
                value=num2str(value);
            end
            row.append(TableEntry(value));
        end

        function string=getResourceString(~,id)
            import slxmlcomp.internal.report.getXMLResourceString;
            string=getXMLResourceString(id);
        end

        function addAppliedFilterList(report,uiFilterState,filterList,noFiltersMessage)
            import mlreportgen.dom.*;

            filtersIterator=filterList.iterator;
            filtersText='';
            while(filtersIterator.hasNext())
                filter=filtersIterator.next;
                if uiFilterState.isEnabled(filter)
                    import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.filter.SLXFilterUtils;
                    filterName=char(SLXFilterUtils.getShortName(filter));
                    filtersText=sprintf('%s%s\n',filtersText,filterName);
                end
            end

            if(isempty(filtersText))
                text=Text(noFiltersMessage);
                text.Style=[text.Style,{Italic()}];
            else

                filtersText=filtersText(1:end-1);
                text=Text(filtersText);
            end

            text.Style=[text.Style,{WhiteSpace('preserve')}];
            text.StyleName='FilterSummarySectionContent';
            paragraph=Paragraph(text);
            paragraph.WhiteSpace='pre';
            report.append(paragraph);
        end

        function filters=getCustomFilters(report)
            import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.filter.SLXFilterUtils;

            uiFilterState=report.JDriverFacade.getFilters();
            filters=SLXFilterUtils.getVisibleUserFilters(uiFilterState);
        end

        function addFilterDetailsTable(report,userFilter)
            import com.mathworks.toolbox.rptgenslxmlcomp.report.ReportTableModel;
            import mlreportgen.dom.*;

            reportTableModel=ReportTableModel(userFilter);

            table=FormalTable(1);
            table.Style={Width('100%'),ResizeToFitContents(false)};
            table.StyleName='FilterDetailsTable';

            row=TableRow;
            row.append(TableEntry(getTreeFilterString('ui.newfilter.nodetype')));
            row.append(TableEntry(getTreeFilterString('ui.newfilter.parname')));
            row.append(TableEntry(getTreeFilterString('ui.newfilter.parvalue')));
            table.appendHeaderRow(row);

            rowColors={'#eeeeee','#ffffff'};
            rowColorIndex=1;

            for rowIndex=1:reportTableModel.getRowCount()
                row=TableRow;

                if reportTableModel.isNodeConditionRow(rowIndex-1)
                    row.StyleName='FilterNodeConditionRow';
                    rowColorIndex=mod(rowColorIndex+1,2);
                else
                    row.StyleName='FilterParameterConditionRow';
                end

                row.Style={BackgroundColor(rowColors{rowColorIndex+1})};

                for colIndex=1:reportTableModel.getColumnCount()
                    value=reportTableModel.getMLString(rowIndex-1,colIndex-1);



                    if(colIndex>1&&isempty(value))
                        entryText=Text(getTreeFilterString('ui.filterhint.any'));
                        entryText.Italic=true;
                        entryText.Color=report.HexGray;
                    else
                        entryText=Text(value);
                    end

                    entry=TableEntry(entryText);
                    row.append(entry);
                end

                table.append(row);
            end
            report.append(table);
        end

    end

end

function str=getTreeFilterString(resourceKey)
    import com.mathworks.comparisons.filter.resources.TreeFilterResources;
    str=char(TreeFilterResources.getString(resourceKey,{}));
end

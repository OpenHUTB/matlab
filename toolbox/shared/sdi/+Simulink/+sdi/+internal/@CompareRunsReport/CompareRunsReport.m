classdef CompareRunsReport<Simulink.sdi.internal.ReportBase
























    properties
        SignalsToReport='ReportAllSignals';
        ReportStyle='Printable';
        ReportTitle='Default';
        ReportAuthor='Default';
    end

    properties(Access=private)

        HPlot;
        HFig;
        ColumnDataMap;
        SignalList;
        Table;
        ColAlign;
        ActualColumnsInReport;
    end

    properties(Constant=true,Hidden=true)

        PassedIcon='task_passed.png';
        FailedIcon='task_failed.png';
        WarningIcon='task_warning.png';
    end

    methods

        function obj=CompareRunsReport(sdiEngine)
            obj=obj@Simulink.sdi.internal.ReportBase(sdiEngine);
            obj.initHashMapColName2Method();
        end


        function delete(obj)
            if~isempty(obj.HFig)&&ishandle(obj.HFig)&&strcmpi(get(obj.HFig,'BeingDeleted'),'off')
                close(obj.HFig);
            end
        end

        function create(obj)
            obj.setOutputDirFileName();
            obj.checkDependencies();
            Simulink.sdi.internal.createComparisonReport(...
            obj.OutputFolder,obj.OutputFile,...
            obj.SignalsToReport,obj.Columns,...
            obj.ReportTitle,obj.ReportAuthor);
        end
    end

    methods(Access=protected)
        function populateReport(obj)


            obj.insertTitle();

            obj.insertDescription();

            obj.initSignalList();

            obj.insertTable();

            obj.insertPlot();
        end

        function checkDependencies(obj)




            recentComparisonRunID=Simulink.sdi.getRecentValidComparisonRunID();
            if recentComparisonRunID~=0
                obj.SdiEngine.setDiffRunResult(recentComparisonRunID);
            else
                runID1=obj.SdiEngine.comparedRun1();
                runID2=obj.SdiEngine.comparedRun2();
                if((~isempty(runID1))&&(~isempty(runID2)))
                    isValidRunIDToCompare=runID1~=runID2;
                    isValidRunID=(obj.SdiEngine.isValidRunID(int32(runID1))...
                    &&obj.SdiEngine.isValidRunID(int32(runID2)));
                else
                    error(message('SDI:sdi:ReportNotEnoughRuns'));
                end

                if(~(isValidRunIDToCompare)||~(isValidRunID))
                    error(message('SDI:sdi:InvalidRunID'));
                else

                    Simulink.sdi.compareRuns(runID1,runID2);
                end
            end





            obj.Columns=...
            Simulink.sdi.internal.CompareRunsReport.validateColumns(obj.Columns,obj.ColumnDataMap);
        end

        function columns=getReportedColumns(obj)
            if isempty(obj.MetaDataInReport)
                relTolCol=Simulink.sdi.SignalMetaData.RelTol;
                columns=[Simulink.sdi.SignalMetaData.Result,...
                Simulink.sdi.SignalMetaData.BlockPath1,...
                relTolCol,...
                Simulink.sdi.SignalMetaData.LinkToPlot];
            elseif any(obj.MetaDataInReport==Simulink.sdi.SignalMetaData.LinkToPlot)
                columns=obj.MetaDataInReport;
            else
                columns=[obj.MetaDataInReport,Simulink.sdi.SignalMetaData.LinkToPlot];
            end
        end
    end


    methods(Access=private)

        function insertTitle(obj)
            import mlreportgen.*;

            titleStr=sprintf('%s%s\t%s',obj.StringDict.MGTitle,...
            obj.StringDict.Colon,getString(message('SDI:sdi:mgCompare')));
            section=dom.Group();
            p=dom.Paragraph(titleStr,'Heading1');
            append(section,p);


            insertTimestamp(obj,section);
            obj.addLineBreak(section);


            insertComparisonTitle(obj,section);
            obj.addLineBreak(section);


            addNode(obj,section);
        end

        function insertTimestamp(obj,section)
            import mlreportgen.*;

            timestampString=sprintf('%s\t%s',obj.StringDict.rgReportTimeStamp,datestr(now));
            append(section,dom.Paragraph(timestampString,'TimeStamp'));
        end

        function insertComparisonTitle(obj,section)
            import mlreportgen.*;



            [lRunName,rRunName]=obj.getRunName();
            lRunID=obj.SdiEngine.diffRunsID1();
            rRunID=obj.SdiEngine.diffRunsID2();
            p=dom.Paragraph();
            p.StyleName='Heading3';
            str=lRunName;
            run1=dom.Text([str,newline]);
            p.append(run1);
            if~isempty(obj.SdiEngine.getRunDescription(lRunID))
                str=sprintf('%s\t%s\t',obj.StringDict.Colon,obj.SdiEngine.getRunDescription(lRunID));
                run1Description=dom.Text([str,newline]);
                p.append(run1Description);
            end


            metaData1=obj.SdiEngine.getRunHarnessModelMetaData(lRunID);
            metaData2=obj.SdiEngine.getRunHarnessModelMetaData(rRunID);
            showVersionDetails=false;
            if obj.isValidMetaData(metaData1)&&obj.isValidMetaData(metaData2)

                if strcmp(metaData1.testUnit.name,metaData2.testUnit.name)&&...
                    strcmp(metaData1.testHarness.name,metaData2.testHarness.name)
                    showVersionDetails=true;
                end
            end


            if showVersionDetails
                obj.putVersionDetails(p,metaData1);
            end

            str=rRunName;
            run2=dom.Text([str,newline]);
            p.append(run2);
            if~isempty(obj.SdiEngine.getRunDescription(rRunID))
                str=sprintf('%s\t%s\t',obj.StringDict.Colon,obj.SdiEngine.getRunDescription(rRunID));
                run2Description=dom.Text([str,newline]);
                p.append(run2Description);
            end


            if showVersionDetails
                sd=Simulink.sdi.internal.StringDict;
                p.append(dom.Text(newline));

                testUnitLabel=dom.Text([sd.testUnit,sprintf('\n\n')]);
                testUnitLabel.Style='TestUnitLabel';
                p.append(testUnitLabel);
                obj.helperPutVersionDetails(p,metaData2.testUnit);
                p.append(dom.Text(newline));

                testHarnessLabel=dom.Text([sd.testHarness,sprintf('\n\n')]);
                p.append(testHarnessLabel);
                obj.helperPutVersionDetails(p,metaData2.testHarness);
            end

            append(section,p);
        end

        function insertDescription(obj)
            import mlreportgen.*;

            if~isempty(obj.Description)

                section=dom.Group();
                sectionTitle=dom.Paragraph(obj.StringDict.mgDescription,...
                'DescriptionTitle');
                append(section,sectionTitle);
                description=dom.Text(obj.Description,'Description');
                append(section,description);
                obj.addLineBreak(section);

                addNode(obj,section);
            end
        end

        function insertTable(obj)
            import mlreportgen.*;
            if~isempty(obj.SignalList)

                section=dom.Group();


                linkTarget=dom.LinkTarget('summary');
                append(section,linkTarget);


                sectionTitle=obj.StringDict.rgReportSummary;
                append(section,dom.Paragraph(sectionTitle,'Heading2'));



                if obj.IsColumnDefault

                    isDataTrivial=obj.IsColumnDefault&([0,1,1,0]);


                else
                    isDataTrivial=zeros(1,length(obj.Columns));
                end
                obj.ActualColumnsInReport=obj.Columns;


                numRows=length(obj.SignalList)+1;
                obj.Table=cell(numRows,length(obj.Columns));
                obj.ColAlign=cell(1,length(obj.Columns));
                i=1;


                obj.Table(i,:)=getHeader(obj);

                i=i+1;

                signalListIdx=1;


                while(i<=numRows)

                    for j=1:length(obj.Columns)
                        [dataNode,alignment]=obj.getTableData(obj.SignalList(signalListIdx),...
                        obj.Columns(j));
                        obj.Table{i,j}=dataNode;
                        obj.ColAlign{j}=alignment;
                        if isDataTrivial(j)



                            isDataTrivial(j)=isDataTrivial(j)&...
                            obj.checkIfDataIsTrivial(dataNode);
                        end

                    end
                    i=i+1;
                    signalListIdx=signalListIdx+1;
                end


                obj.Table=obj.removeUnnecessaryColumns(obj.Table,isDataTrivial);

                obj.ActualColumnsInReport=obj.Columns(:,logical(~isDataTrivial));
                obj.ColAlign=obj.ColAlign(:,logical(~isDataTrivial));


                domTable=dom.Table(obj.Table);
                domTable.StyleName='SummaryTable';
                obj.alignTableColumns(domTable,obj.ColAlign);


                append(section,domTable);
                obj.addLineBreak(section);
                obj.addNode(section);
            end
        end

        function insertPlot(obj)
            import mlreportgen.*;
            if~isempty(obj.SignalList)

                section=dom.Group();


                sectionTitle=obj.StringDict.rgReportTitleSigCompDiffPlots;
                append(section,dom.Paragraph(sectionTitle,'Heading2'));


                obj.setupPlottingObjects();


                for i=1:length(obj.SignalList)


                    obj.addLineBreak(section);
                    obj.addLineBreak(section);


                    obj.insertDataFromTable(i,section);
                    obj.addLineBreak(section);


                    obj.populateFigure(i);


                    fileName=[obj.OutputFileName,'_compareRunsPlot_',num2str(i),'.png'];
                    fullFileName=fullfile(obj.OutputFolder,fileName);
                    print(obj.HFig,'-dpng',fullFileName);


                    obj.addImage(fullFileName,section);





                    cacheImageToDelete(obj,fullFileName);

                    obj.addLineBreak(section);
                    obj.addLinkToSummary(section);
                    obj.addLineBreak(section);
                end

                obj.addNode(section);
            end
        end
    end

    methods(Access=private,Static=true)
        function copyIcon(iconName,destination)
            iconSrc=fullfile(...
            matlabroot,...
            'toolbox',...
            'shared',...
            'sdi',...
            '+Simulink',...
            '+sdi',...
            'Icons',...
            iconName);
            copyfile(iconSrc,destination,'f');
        end
    end

    methods(Access=private)

        function setupPlottingObjects(obj)

            plotSize=[200,200,350,250];

            if isempty(obj.HFig)||~ishandle(obj.HFig)
                obj.HFig=figure('Visible','off','HandleVisibility',...
                'off','Position',plotSize,'PaperPositionMode',...
                'auto');
            end

            if isempty(obj.HPlot)

                obj.HPlot=Simulink.sdi.internal.Plot(obj.SdiEngine);
            end
        end

        function populateFigure(obj,resultIdx)
            obj.HPlot.plotCompareRunsFigure(obj.SignalList(resultIdx).signalID1,obj.HFig);
            ax=findobj(obj.HFig,'Type','Axes');
            for i=1:length(ax)
                set(ax(i),'FontSize',6,'FontWeight','Bold');
                t=get(ax(i),'title');
                set(t,'FontSize',6,'FontWeight','Bold');
            end
        end

        function insertDataFromTable(obj,tableRow,section)
            import mlreportgen.*;


            table=obj.Table(1,:);


            table=[table;obj.Table(tableRow+1,:)];



            columnIdx=obj.findColumnIdx(Simulink.sdi.SignalMetaData.LinkToPlot);




            anchor=table{2,columnIdx}.Children(1).Target;
            p=dom.Paragraph(dom.LinkTarget(anchor));
            append(p,clone(table{1,1}));
            table{1,1}=p;

            table(:,columnIdx)=[];

            caTableSize=size(table);
            ncols=caTableSize(2);
            domTable=dom.Table(ncols);
            domTable.StyleName='SignalTable';


            domRow=dom.TableRow();
            for col=1:ncols
                entryObj=table{1,col};
                if isa(entryObj,'mlreportgen.dom.Object')
                    entryObj=clone(entryObj);
                end
                if~isa(entryObj,'mlreportgen.dom.Paragraph')
                    entryObj=dom.Paragraph(entryObj);
                end
                domTableEntry=dom.TableEntry(entryObj);
                append(domRow,domTableEntry);
            end
            append(domTable,domRow);


            domRow=dom.TableRow();
            for col=1:caTableSize(2)
                entryObj=table{2,col};
                if isa(entryObj,'mlreportgen.dom.Object')
                    entryObj=clone(entryObj);
                end
                if~isa(entryObj,'mlreportgen.dom.Paragraph')
                    if~isempty(entryObj)
                        entryObj=dom.Paragraph(entryObj);
                    else
                        entryObj=dom.Paragraph();
                    end
                end
                domTableEntry=dom.TableEntry(entryObj);
                append(domRow,domTableEntry);
            end
            append(domTable,domRow);

            obj.alignTableColumns(domTable,obj.ColAlign);

            append(section,domTable);
        end

        function addLinkToSummary(obj,section)
            import mlreportgen.*;

            lnkText=dom.Text(obj.StringDict.rgReportLinkToSummary);
            lnkText.StyleName='LinkText';
            lnk=dom.InternalLink('summary',lnkText);

            section.append(lnk);

        end

        function columnIdx=findColumnIdx(obj,item)

            columnIdx=find(obj.ActualColumnsInReport==item);
        end

        function headerRow=getHeaderForPlotSummary(obj)
            import mlreportgen.*;
            tableHeader=obj.getHeader();
            tempTable=dom.Table(tableHeader);
            headerRow=tempTable.Children(1);


        end

        function tableHeader=getHeader(obj)
            import mlreportgen.*;

            tableHeader=cell(1,length(obj.ActualColumnsInReport));
            for i=1:length(obj.ActualColumnsInReport)
                tableHeader{i}=dom.Text(obj.ActualColumnsInReport(i).getName());
            end
        end

        function[lRunName,rRunName]=getRunName(obj)

            lRun=obj.SdiEngine.diffRunsID1();
            lRunName=obj.SdiEngine.getRunName(lRun);

            rRun=obj.SdiEngine.diffRunsID2();
            rRunName=obj.SdiEngine.getRunName(rRun);
        end

        function initHashMapColName2Method(obj)


            obj.ColumnDataMap=Simulink.sdi.Map(0,?handle);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Result),@obj.getResult);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.BlockPath1),@obj.getBlockPath1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.BlockPath2),@obj.getBlockPath2);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.DataSource1),@obj.getDataSource1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.DataSource2),@obj.getDataSource2);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SignalName),@obj.getSignalName1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SignalName1),@obj.getSignalName1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SignalName2),@obj.getSignalName2);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SignalDescription),@obj.getSignalDescription);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.AbsTol),@obj.getAbsTol1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.RelTol),@obj.getRelTol1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SyncMethod),@obj.getSyncMethod1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.InterpMethod),@obj.getInterpMethod1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Run1),@obj.getRun1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Run2),@obj.getRun2);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Channel2),@obj.getChannel2);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Model1),@obj.getModel1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Model2),@obj.getModel2);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.BlockName1),@obj.getBlockName1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.BlockName2),@obj.getBlockName2);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Dimensions1),@obj.getDimensions1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Dimensions2),@obj.getDimensions2);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.TimeSeriesRoot1),@obj.getTimeSeriesRoot1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.TimeSeriesRoot2),@obj.getTimeSeriesRoot2);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.TimeSource1),@obj.getTimeSource1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.TimeSource2),@obj.getTimeSource2);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Line1),@obj.getLine1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Line2),@obj.getLine2);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Port1),@obj.getPort1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Port2),@obj.getPort2);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Channel1),@obj.getChannel1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.AlignedBy),@obj.getAlignType);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.LinkToPlot),@obj.getPlotLink);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Units1),@obj.getUnit1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Units2),@obj.getUnit2);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SigDataType1),@obj.getSigDataType1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SigDataType2),@obj.getSigDataType2);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SigSampleTime1),@obj.getSigSampleTime1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SigSampleTime2),@obj.getSigSampleTime2);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.MaxDifference),@obj.getMaxDifference1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.TimeTol),@obj.getTimeTol1);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.OverrideGlobalTol),@obj.getOverrideGlobalTol1);
        end

        function initSignalList(obj)


            obj.SignalList=struct('resultIdx',{},'signalID1',...
            {},'signalID2',{},'taskResult',{});


            numSignals=obj.SdiEngine.DiffRunResult.count;

            for i=1:numSignals

                result=obj.SdiEngine.DiffRunResult.getResultByIndex(i);
                match=result.Match;

                obj.SignalList(i).resultIdx=i;
                obj.SignalList(i).signalID1=result.signalID1;
                obj.SignalList(i).signalID2=result.signalID2;

                if match

                    obj.SignalList(i).taskResult=1;
                elseif~isempty(result.signalID2)

                    obj.SignalList(i).taskResult=0;
                else

                    obj.SignalList(i).taskResult=-1;
                end
            end

            signalsToReport=obj.SignalsToReport;

            switch signalsToReport
            case 'ReportAllSignals'

            case 'ReportOnlyMismatchedSignals'

                idx=[obj.SignalList(:).taskResult];
                obj.SignalList=obj.SignalList(idx==0);
            otherwise


                idx=[obj.SignalList(:).taskResult];
                obj.SignalList=obj.SignalList(idx~=-1);
            end
        end

        function[dataNode,alignment]=getTableData(obj,signalListItem,columnName)


            hmethod=obj.ColumnDataMap.getDataByKey(double(columnName));
            [dataNode,alignment]=hmethod(signalListItem);
        end

        function[dataNode,alignment]=getResult(obj,signalListItem)
            import mlreportgen.*;
            alignment='center';

            switch signalListItem.taskResult
            case 1
                iconName=obj.PassedIcon;
            case 0
                iconName=obj.FailedIcon;
            case-1
                iconName=obj.WarningIcon;
            end

            iconPath=fullfile(obj.OutputFolder,iconName);
            Simulink.sdi.CompareRunsReport.copyIcon(iconName,iconPath);


            dataNode=dom.Paragraph(dom.Image(iconPath));
            cacheImageToDelete(obj,iconPath);
        end

        function[dataNode,alignment]=getBlockPath1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getBlockPath(sigID);
            end
        end

        function[dataNode,alignment]=getBlockPath2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getBlockPath(sigID);
            end
        end

        function[dataNode,alignment]=getSignalName1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getSignalName(sigID);
            end
        end

        function[dataNode,alignment]=getSignalName2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getSignalName(sigID);
            end
        end

        function[dataNode,alignment]=getDataSource1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getDataSource(sigID);
            end
        end

        function[dataNode,alignment]=getDataSource2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getDataSource(sigID);
            end
        end

        function[dataNode,alignment]=getSID1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getSID(sigID);
            end
        end

        function[dataNode,alignment]=getSID2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getSID(sigID);
            end
        end

        function[dataNode,alignment]=getSigDataType1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getSigDataType(sigID);
            end
        end

        function[dataNode,alignment]=getSigDataType2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getSigDataType(sigID);
            end
        end

        function[dataNode,alignment]=getSigSampleTime1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getSigSampleTime(sigID);
            end
        end

        function[dataNode,alignment]=getSigSampleTime2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getSigSampleTime(sigID);
            end
        end

        function[dataNode,alignment]=getMaxDifference1(obj,signalListItem)
            dataNode=[];
            alignment='right';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getMaxDifference(sigID);
            end
        end

        function[dataNode,alignment]=getUnit1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getUnit(sigID);
            end
        end

        function[dataNode,alignment]=getUnit2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getUnit(sigID);
            end
        end

        function[dataNode,alignment]=getAbsTol1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getAbsTol(sigID);
            end
        end

        function[dataNode,alignment]=getRelTol1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getRelTol(sigID);
            end
        end

        function[dataNode,alignment]=getTimeTol1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getTimeTol(sigID);
            end
        end

        function[dataNode,alignment]=getOverrideGlobalTol1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getOverrideGlobalTol(sigID);
            end
        end

        function[dataNode,alignment]=getSyncMethod1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getSyncMethod(sigID);
            end
        end

        function[dataNode,alignment]=getInterpMethod1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getInterpMethod(sigID);
            end
        end

        function[dataNode,alignment]=getChannel1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getChannel(sigID);
            end
        end

        function[dataNode,alignment]=getChannel2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getChannel(sigID);
            end
        end

        function[dataNode,alignment]=getRun1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getRun(sigID);
            end
        end

        function[dataNode,alignment]=getRun2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getRun(sigID);
            end
        end

        function[dataNode,alignment]=getModel1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getModel(sigID);
            end
        end

        function[dataNode,alignment]=getModel2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getModel(sigID);
            end
        end

        function[dataNode,alignment]=getBlockName1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getBlockName(sigID);
            end
        end

        function[dataNode,alignment]=getBlockName2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getBlockName(sigID);
            end
        end

        function[dataNode,alignment]=getDimensions1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getDimensions(sigID);
            end
        end

        function[dataNode,alignment]=getDimensions2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getDimensions(sigID);
            end
        end

        function[dataNode,alignment]=getTimeSeriesRoot1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getTimeSeriesRoot(sigID);
            end
        end

        function[dataNode,alignment]=getTimeSeriesRoot2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getTimeSeriesRoot(sigID);
            end
        end

        function[dataNode,alignment]=getTimeSource1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getTimeSource(sigID);
            end
        end

        function[dataNode,alignment]=getTimeSource2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getTimeSource(sigID);
            end
        end

        function[dataNode,alignment]=getLine1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getLine(sigID);
            end
        end

        function[dataNode,alignment]=getLine2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getLine(sigID);
            end
        end


        function[dataNode,alignment]=getPort1(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getPort(sigID);
            end
        end

        function[dataNode,alignment]=getPort2(obj,signalListItem)
            dataNode=[];
            alignment='center';
            sigID=signalListItem.signalID2;
            if~isempty(sigID)
                [dataNode,alignment]=obj.getPort(sigID);
            end
        end

        function[dataNode,alignment]=getAlignType(obj,signalListItem)
            alignment='left';
            dataNode=[];
            sigID=signalListItem.signalID1;
            if~isempty(sigID)
                dataNode=obj.SdiEngine.sigRepository.getSignalAlignedBy(sigID);
                if isempty(dataNode)
                    dataNode='Unset';
                end
            end
        end

        function[dataNode,alignment]=getPlotLink(~,signalListItem)
            import mlreportgen.*;
            alignment='center';
            link=dom.InternalLink(['plot_',num2str(signalListItem.resultIdx)],...
            dom.Text('Link'));
            dataNode=dom.Paragraph(link);
        end

    end

    methods(Static)

        function ret=validateColumns(columns,columnDataMap)
            ret=Simulink.sdi.SignalMetaData.empty();
            for idx=1:length(columns)


                colKey=double(columns(idx));
                if columnDataMap.isKey(colKey)
                    ret(end+1)=columns(idx);%#ok<*AGROW>
                else


                    switch(colKey)
                    case Simulink.sdi.SignalMetaData.AbsTol1
                        ret(end+1)=Simulink.sdi.SignalMetaData.AbsTol;
                    case Simulink.sdi.SignalMetaData.RelTol1
                        ret(end+1)=Simulink.sdi.SignalMetaData.RelTol;
                    case Simulink.sdi.SignalMetaData.TimeTol1
                        ret(end+1)=Simulink.sdi.SignalMetaData.TimeTol;
                    case Simulink.sdi.SignalMetaData.OverrideGlobalTol1
                        ret(end+1)=Simulink.sdi.SignalMetaData.OverrideGlobalTol;
                    case Simulink.sdi.SignalMetaData.SyncMethod1
                        ret(end+1)=Simulink.sdi.SignalMetaData.SyncMethod;
                    case Simulink.sdi.SignalMetaData.InterpMethod1
                        ret(end+1)=Simulink.sdi.SignalMetaData.InterpMethod;
                    case{Simulink.sdi.SignalMetaData.SignalName1,...
                        Simulink.sdi.SignalMetaData.SignalName2}



                        ret(end+1)=Simulink.sdi.SignalMetaData.SignalName;


                    case Simulink.sdi.SignalMetaData.Line1
                        ret(end+1)=Simulink.sdi.SignalMetaData.Line;
                    case Simulink.sdi.SignalMetaData.BlockPath1
                        ret(end+1)=Simulink.sdi.SignalMetaData.BlockPath;
                    case Simulink.sdi.SignalMetaData.Units1
                        ret(end+1)=Simulink.sdi.SignalMetaData.Units;
                    case Simulink.sdi.SignalMetaData.SigDataType1
                        ret(end+1)=Simulink.sdi.SignalMetaData.SigDataType;
                    case Simulink.sdi.SignalMetaData.SigSampleTime1
                        ret(end+1)=Simulink.sdi.SignalMetaData.SigSampleTime;
                    case Simulink.sdi.SignalMetaData.BlockName1
                        ret(end+1)=Simulink.sdi.SignalMetaData.BlockName;
                    case Simulink.sdi.SignalMetaData.Port1
                        ret(end+1)=Simulink.sdi.SignalMetaData.Port;
                    case Simulink.sdi.SignalMetaData.Model1
                        ret(end+1)=Simulink.sdi.SignalMetaData.Model;
                    case Simulink.sdi.SignalMetaData.TimeSeriesRoot1
                        ret(end+1)=Simulink.sdi.SignalMetaData.TimeSeriesRoot;
                    case Simulink.sdi.SignalMetaData.DataSource1
                        ret(end+1)=Simulink.sdi.SignalMetaData.DataSource;
                    case Simulink.sdi.SignalMetaData.TimeSource1
                        ret(end+1)=Simulink.sdi.SignalMetaData.TimeSource;
                    case Simulink.sdi.SignalMetaData.Run1
                        ret(end+1)=Simulink.sdi.SignalMetaData.Run;
                    case Simulink.sdi.SignalMetaData.Dimensions1
                        ret(end+1)=Simulink.sdi.SignalMetaData.Dimensions;
                    case Simulink.sdi.SignalMetaData.Channel1
                        ret(end+1)=Simulink.sdi.SignalMetaData.Channel;
                    otherwise



                        continue
                    end
                end
            end
        end
    end
end


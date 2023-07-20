classdef InspectSignalsReport<Simulink.sdi.internal.ReportBase























    properties
        ColumnDataMap;
        ReportStyle='Printable';
        ReportTitle='Default';
        ReportAuthor='Default';
    end

    properties(Access=private,Hidden=true)
        HPlot;
        HFig;
        DefaultFigSize;
    end

    methods


        function obj=InspectSignalsReport(sdiEngine)
            obj=obj@Simulink.sdi.internal.ReportBase(sdiEngine);
            obj.initHashMapColName2Method();
        end


        function delete(obj)
            if~isempty(obj.HFig)&&ishandle(obj.HFig)&&strcmpi(get(obj.HFig,'BeingDeleted'),'off')
                close(obj.HFig);
            end
        end

    end

    methods(Access=protected)

        function populateReport(obj)


            obj.insertTitle();

            obj.insertDescription();

            obj.insertTable();

            obj.insertPlot();
        end

        function checkDependencies(obj)
            validatedColumns=Simulink.sdi.SignalMetaData.empty(0);
            j=1;
            for i=1:length(obj.Columns)


                colKey=double(obj.Columns(i));
                if obj.ColumnDataMap.isKey(colKey)
                    validatedColumns(j)=obj.Columns(i);%#ok<*AGROW>
                    j=j+1;
                elseif(obj.Columns(i)~=Simulink.sdi.SignalMetaData.SID)


                    error(message('SDI:sdi:InvalidColumnName'));
                end
            end
            if strcmp(obj.ReportStyle,'Interactive')
                error(message('SDI:sdi:InvalidReportStyle','Interactive','Inspect'));
            end




            obj.Columns=validatedColumns;
        end

        function columns=getReportedColumns(obj)
            if isempty(obj.MetaDataInReport)
                columns=[Simulink.sdi.SignalMetaData.BlockPath,...
                Simulink.sdi.SignalMetaData.SignalName,...
                Simulink.sdi.SignalMetaData.Line,...
                Simulink.sdi.SignalMetaData.DataSource];
            else
                columns=obj.MetaDataInReport;
            end
        end

        function insertTitle(obj)
            import mlreportgen.*;

            titleStr=sprintf('%s%s\t%s',obj.StringDict.MGTitle,...
            obj.StringDict.Colon,getString(message('SDI:sdi:mgInspect')));
            section=dom.Group();
            p=dom.Paragraph(titleStr,'Heading1');
            append(section,p);

            obj.insertTimestamp(section);
            obj.addLineBreak(section);

            obj.addNode(section);
        end

        function insertTimestamp(obj,section)

            import mlreportgen.*;
            timestampString=sprintf('%s\t%s',obj.StringDict.rgReportTimeStamp,datestr(now));
            append(section,dom.Paragraph(timestampString,'TimeStamp'));
        end

        function insertDescription(obj)
            import mlreportgen.*;


            if~isempty(obj.Description)
                section=dom.Group();
                sectionTitle=obj.StringDict.mgDescription;
                append(section,dom.Paragraph(sectionTitle,'Heading2'));
                append(section,dom.Paragraph(obj.Description,'Description'));

                obj.addNode(section);
            end
        end

        function insertTable(obj)
            import mlreportgen.*;


            signalList=obj.findRunsAndSignalsToReport();



            if obj.IsColumnDefault

                isDataTrivial=obj.IsColumnDefault&([1,1,0,0]);


            else
                isDataTrivial=zeros(1,length(obj.Columns));
            end

            table=[];
            alignType=[];
            for signal=1:length(signalList)

                if signalList(signal).isHeaderRequired

                    if~isempty(table)
                        domTable=dom.Table(table);
                        domTable.StyleName='SummaryTable';
                        obj.alignTableColumns(domTable,alignType);
                        section=dom.Group();
                        section.append(domTable);
                        obj.addLineBreak(section);
                        obj.addNode(section);
                    end

                    table=cell(1,length(obj.Columns));
                    alignType=cell(1,length(obj.Columns));
                    groupHeader=getGroupHeader(obj,signalList(signal).runID);
                    addNode(obj,groupHeader);

                    table(1,:)=obj.getHeader();
                    row=2;
                end

                for col=1:length(obj.Columns)
                    [dataNode,alignment]=getTableData(obj,signalList(signal).runID,...
                    signalList(signal).signalIdx,obj.Columns(col));
                    table{row,col}=dataNode;
                    alignType{col}=alignment;
                    if isDataTrivial(col)



                        isDataTrivial(col)=isDataTrivial(col)&...
                        obj.checkIfDataIsTrivial(dataNode);
                    end
                end

                row=row+1;

            end

            if~isempty(table)
                domTable=dom.Table(table);
                domTable.StyleName='SummaryTable';
                obj.alignTableColumns(domTable,alignType);
                section=dom.Group();
                section.append(domTable);
                obj.addLineBreak(section);
                obj.addNode(section);
            end

        end

        function insertPlot(obj)
            import mlreportgen.*

            section=dom.Group();


            if isempty(obj.HFig)||~ishandle(obj.HFig)

                obj.HFig=figure('Visible','off','HandleVisibility',...
                'off');
            end
            if isempty(obj.HPlot)

                obj.HPlot=Simulink.sdi.internal.Plot(obj.SdiEngine);
            end



            plotSize=[200,200,350,250];
            set(obj.HFig,'Position',plotSize,'PaperPositionMode','auto');


            obj.HPlot.plotInspectorFigure(obj.HFig);


            ax=findobj(get(obj.HFig,'Children'),'Type','Axes');
            for i=1:length(ax)
                set(ax(i),'FontSize',6,'FontWeight','Bold');
            end

            fileName=[obj.OutputFileName,'_inspectSignalsPlot_signalOverlay.png'];
            fullFileName=fullfile(obj.OutputFolder,fileName);
            print(obj.HFig,'-dpng',fullFileName);

            addImage(obj,fullFileName,section);
            cacheImageToDelete(obj,fullFileName);

            obj.addNode(section);
        end
    end

    methods(Access=private)

        function[dataNode,alignment]=getTableData(obj,runID,signalCnt,columnName)



            hmethod=obj.ColumnDataMap.getDataByKey(double(columnName));
            [dataNode,alignment]=hmethod(runID,signalCnt);
        end

        function isVisible=checkSignalVisibility(obj,runID,signalIdx)
            signalID=obj.SdiEngine.getSignalIDByIndex(runID,signalIdx);
            isVisible=obj.SdiEngine.getSignalChecked(signalID);
        end

        function groupHeader=getGroupHeader(obj,runID)





            import mlreportgen.*;


            groupHeader=dom.Paragraph(obj.SdiEngine.getRunName(runID),'GroupHeader');




            metaData=obj.SdiEngine.getRunHarnessModelMetaData(runID);
            if~isempty(metaData)
                obj.putVersionDetails(p,metaData);
            end






        end

        function tableHeader=getHeader(obj)
            import mlreportgen.*;

            tableHeader=cell(1,length(obj.Columns));
            for i=1:length(obj.Columns)
                tableHeader{i}=dom.Text(obj.Columns(i).getName());
            end
        end

        function signalList=findRunsAndSignalsToReport(obj)


            signalList=struct('runID',{},'signalIdx',{},'isHeaderRequired',{});

            allRuns=obj.SdiEngine.getAllRunIDs();
            for runCnt=1:length(allRuns)
                runID=int32(allRuns(runCnt));

                signalCnt=obj.SdiEngine.getSignalCount(runID);
                for i=1:signalCnt

                    isVisible=obj.checkSignalVisibility(runID,int32(i));
                    if isVisible
                        idx=length(signalList)+1;
                        signalList(idx).runID=runID;
                        signalList(idx).signalIdx=int32(i);


                        if(idx==1)||...
                            (signalList(idx-1).runID~=signalList(idx).runID)
                            signalList(idx).isHeaderRequired=1;
                        else
                            signalList(idx).isHeaderRequired=0;
                        end
                    end
                end
            end
        end

        function initHashMapColName2Method(obj)


            obj.ColumnDataMap=Simulink.sdi.Map(0,?handle);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Line),@obj.getLine);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SignalName),@obj.getSignalName);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SignalDescription),@obj.getSignalDescription);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.AbsTol),@obj.getAbsTol);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SyncMethod),@obj.getSyncMethod);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.BlockPath),@obj.getBlockPath);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.BlockName),@obj.getBlockName);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.RelTol),@obj.getRelTol);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.DataSource),@obj.getDataSource);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SID),@obj.getSID);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.TimeSeriesRoot),@obj.getTimeSeriesRoot);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.TimeSource),@obj.getTimeSource);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.InterpMethod),@obj.getInterpMethod);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Port),@obj.getPort);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Dimensions),@obj.getDimensions);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Channel),@obj.getChannel);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Units),@obj.getUnit);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SigDataType),@obj.getSigDataType);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SigComplexity),@obj.getSigComplexity);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SigComplexFormat),@obj.getSigComplexFormat);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SigDisplayScaling),@obj.getSigDisplayScaling);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SigDisplayOffset),@obj.getSigDisplayOffset);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SigSampleTime),@obj.getSigSampleTime);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Run),@obj.getRun);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Model),@obj.getModel);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.TimeTol),@obj.getTimeTol);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.OverrideGlobalTol),@obj.getOverrideGlobalTol);
        end

    end

end


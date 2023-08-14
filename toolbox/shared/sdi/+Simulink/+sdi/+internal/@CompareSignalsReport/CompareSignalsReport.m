classdef CompareSignalsReport<Simulink.sdi.internal.ReportBase























    properties
        ReportStyle='Printable';
        ReportTitle='Default';
        ReportAuthor='Default';
    end

    properties(Access=private)

        Signal1;
        Signal2;
        HPlot;
        HFig;
        ColumnDataMap;

    end

    methods

        function obj=CompareSignalsReport(sdiEngine)
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



            insertTitle(obj);

            insertDescription(obj);

            insertTable(obj);

            insertPlot(obj);

        end

        function checkDependencies(obj)



            obj.Signal1=obj.SdiEngine.comparedSignal1;
            obj.Signal2=obj.SdiEngine.comparedSignal2;
            if isempty(obj.Signal1)||isempty(obj.Signal2)
                error(message('SDI:sdi:ReportNotEnoughSignals'));
            end
            if~obj.SdiEngine.isValidSignalID(obj.Signal1)||...
                ~obj.SdiEngine.isValidSignalID(obj.Signal2)
                error(message('SDI:sdi:InvalidSignalID'));
            end




            obj.Columns=...
            Simulink.sdi.internal.CompareRunsReport.validateColumns(obj.Columns,obj.ColumnDataMap);
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

    end

    methods(Access=private)

        function insertTitle(obj)
            import mlreportgen.*;

            titleStr=sprintf('%s%s\t%s',obj.StringDict.MGTitle,...
            obj.StringDict.Colon,obj.StringDict.MGCompareSignals);
            section=dom.Group();
            p=dom.Paragraph(titleStr,'Heading1');
            append(section,p);


            insertTimestamp(obj,section);
            obj.addLineBreak(section);

            addNode(obj,section);
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
                append(section,dom.Paragraph(sectionTitle,'DescriptionTitle'));
                append(section,dom.Paragraph(obj.Description,'Description'));

                obj.addNode(section);
            end
        end

        function insertTable(obj)
            import mlreportgen.*;

            section=dom.Group();


            signalList=obj.findRunsAndSignalsToReport();



            if obj.IsColumnDefault

                isDataTrivial=obj.IsColumnDefault&([1,1,0,0]);


            else
                isDataTrivial=zeros(1,length(obj.Columns));
            end


            numRows=length(signalList)+1;
            table=cell(numRows,length(obj.Columns));
            alignType=cell(1,length(obj.Columns));
            i=1;

            table(i,:)=obj.getHeader();
            i=i+1;

            signalListIdx=1;


            while(i<=numRows)

                for j=1:length(obj.Columns)
                    [dataNode,alignment]=getTableData(obj,signalList(signalListIdx).signalID,...
                    obj.Columns(j));
                    table{i,j}=dataNode;
                    alignType{j}=alignment;
                    if isDataTrivial(j)



                        isDataTrivial(j)=isDataTrivial(j)&...
                        obj.checkIfDataIsTrivial(dataNode);
                    end

                end
                signalListIdx=signalListIdx+1;
                i=i+1;
            end


            table=obj.removeUnnecessaryColumns(table,isDataTrivial);



            domTable=dom.Table(table);
            domTable.StyleName='SummaryTable';
            obj.alignTableColumns(domTable,alignType);


            append(section,domTable);
            obj.addLineBreak(section);
            obj.addLineBreak(section);
            obj.addLineBreak(section);
            obj.addNode(section);

        end

        function insertPlot(obj)
            import mlreportgen.*;

            section=dom.Group();



            plotSize=[200,200,350,300];

            if isempty(obj.HFig)||~ishandle(obj.HFig)
                obj.HFig=figure('Visible','off','HandleVisibility',...
                'off','Position',plotSize,'PaperPositionMode',...
                'auto');
            end

            if isempty(obj.HPlot)

                obj.HPlot=Simulink.sdi.internal.Plot(obj.SdiEngine);
            end

            obj.HPlot.plotCompareSignalsFigure(obj.HFig);

            ax=findobj(obj.HFig,'Type','Axes');
            for i=1:length(ax)
                set(ax(i),'FontSize',6,'FontWeight','Bold');
                t=get(ax(i),'title');
                set(t,'FontSize',6,'FontWeight','Bold');
            end


            fileName=[obj.OutputFileName,'_compareSignalsPlot.png'];
            fullFileName=fullfile(obj.OutputFolder,fileName);
            print(obj.HFig,'-dpng',fullFileName);


            obj.addImage(fullFileName,section);
            cacheImageToDelete(obj,fullFileName);

            obj.addLineBreak(section);

            obj.addNode(section);
        end

    end

    methods(Access=private)

        function[s1,s2,diffTol]=getSDIInfo(obj)


            s1=obj.SdiEngine.getSignal(int32(obj.Signal1));
            s2=obj.SdiEngine.getSignal(int32(obj.Signal2));


            runID=Simulink.sdi.internal.compareSignalsAndAddToRun(...
            obj.SdiEngine.sigRepository,int32(obj.Signal1),int32(obj.Signal2),[]);
            obj.SdiEngine.setDiffRunResult(runID);
            diffTol=obj.SdiEngine.DiffRunResult.getLastDiffSignalResult();
        end
    end

    methods(Access=private)

        function[dataNode,alignment]=getTableData(obj,signalID,columnName)



            hmethod=obj.ColumnDataMap.getDataByKey(double(columnName));
            [dataNode,alignment]=hmethod(signalID);
        end

        function tableHeader=getHeader(obj)
            import mlreportgen.*;

            tableHeader=cell(1,length(obj.Columns));
            for i=1:length(obj.Columns)
                tableHeader{i}=dom.Text(obj.Columns(i).getName());
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
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Run),@obj.getRun);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Model),@obj.getModel);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.Units),@obj.getUnit);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SigDataType),@obj.getSigDataType);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.SigSampleTime),@obj.getSigSampleTime);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.MaxDifference),@obj.getMaxDifference);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.TimeTol),@obj.getTimeTol);
            obj.ColumnDataMap.insert(double(Simulink.sdi.SignalMetaData.OverrideGlobalTol),@obj.getOverrideGlobalTol);
        end

        function signalList=findRunsAndSignalsToReport(obj)




            [s1,s2]=obj.getSDIInfo();

            signalList=struct('runID',{s1.RunID,s1.RunID},...
            'signalID',{s1.DataID,s2.DataID});

        end

    end


end


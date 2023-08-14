classdef SLReqRTMXTableData<handle
    properties(Access=private)
        RawData;
        RawDataAfterJSONDecode;
        RTMXTable;
        ColData;
        RowData;
        LinkData;
        ConfigData;
        ExcelDocH;
        CurrentWorkingSheet;
        CurrentSheetName='RTMX';
        CurrentExcelFileName;
        NumOfColumns;
        NumOfRows;
        ExcelTableStartIndexForRows=1;
        ExcelTableStartIndexForColumns=1;
        AllExcelRows;
        AllExcelColumns;



        HIGHLIGHT_COLOR_INDEX_FOR_MISSING_LINKS=36;




        HIGHLIGHT_COLOR_INDEX_FOR_CHANGED_LINKS=22

        BACKGROUND_COLOR_FOR_HEADERS=15329769;

        HTMLTableCells;
        HTMLTableStrings;
        HTMLConfigStr;
    end

    properties
        HTMLFile;
    end

    methods(Access=private)


        function importJSONData(this,jsonData)
            this.RawData=jsonData;
            sourceData=jsondecode(jsonData);
            this.RawDataAfterJSONDecode=sourceData;


            this.RTMXTable=struct2table(sourceData.content);


            colHeaderNames=struct2cell(sourceData.colInfo);
            colVariables=containers.Map;
            headerNames=cell(size(colHeaderNames));
            for index=1:length(colHeaderNames)
                cHeaderName=colHeaderNames{index};
                if length(cHeaderName)>20

                    headerName=['...',cHeaderName(end-20:end)];
                else
                    headerName=cHeaderName;
                end

                if isKey(colVariables,headerName)
                    headerName=[headerName,'_col',num2str(index)];
                end
                colVariables(headerName)=true;

                headerNames{index}=headerName;
            end


            rowHeaderNames=struct2cell(sourceData.rowInfo);
            rowNames=cell(size(rowHeaderNames));
            rowVariables=containers.Map;
            for index=1:length(rowHeaderNames)
                cHeaderName=rowHeaderNames{index};
                if length(cHeaderName)>20
                    headerName=['...',cHeaderName(end-20:end)];
                else
                    headerName=cHeaderName;
                end
                if isKey(rowVariables,headerName)
                    headerName=[headerName,'_col',num2str(index)];%#ok<AGROW>
                end
                rowVariables(headerName)=true;

                rowNames{index}=headerName;
            end

            this.RTMXTable.Properties.RowNames=rowNames;
            this.RTMXTable.Properties.VariableNames=headerNames;
            this.RTMXTable.Properties.UserData=sourceData;
            this.setupData();
        end


        function importMATLABTable(this,matlabTable)
            this.RTMXTable=matlabTable;
            this.setupData();
        end


        function setupData(this)
            this.ColData=this.RTMXTable.Properties.UserData.colData;
            this.RowData=this.RTMXTable.Properties.UserData.rowData;
            this.LinkData=this.RTMXTable.Properties.UserData.linkData;
            this.ConfigData=this.RTMXTable.Properties.UserData.config;
            this.NumOfColumns=length(this.RTMXTable.Properties.VariableNames);
            this.NumOfRows=length(this.RTMXTable.Row);
        end




        function formatExcel(this)
            this.getCorrectSheet();

            this.instertConfigurationDataIntoExcel();
            this.formatExcelTable();
        end


        function instertConfigurationDataIntoExcel(this)
            this.ExcelTableStartIndexForColumns=1;
            this.ExcelTableStartIndexForRows=1;
        end


        function formatExcelTable(this)
            this.formattingExcelTableHeaders();
            this.groupAndFormattingHeaderCells();
            this.formattingExcelTableLinkCells();
            this.formattingSheet();
        end


        function out=getCorrectSheet(this)
            this.ExcelDocH=rmicom.excelApp('dispdoc',this.CurrentExcelFileName);
            allSheets=this.ExcelDocH.Sheets;
            sheet=[];
            for index=1:allSheets.Count
                cSheet=allSheets.Item(index);
                if strcmpi(cSheet.Name,this.CurrentSheetName)
                    sheet=cSheet;
                end
            end

            if~isempty(sheet)
                out=true;
                this.CurrentWorkingSheet=sheet;
                this.AllExcelRows=sheet.Rows;
                this.AllExcelColumns=sheet.Columns;
            else
                out=false;
            end

        end


        function formattingExcelTableLinkCells(this)
            linkData=this.LinkData;
            allLinks=fieldnames(linkData);
            for index=1:length(allLinks)
                cLinkField=allLinks{index};
                cLinkData=this.LinkData.(cLinkField);
                rowKey=getIDKeyFromFullID(cLinkData.rowID);
                colKey=getIDKeyFromFullID(cLinkData.colID);

                rowIndex=str2double(strrep(this.RowData.id2Index.(rowKey),'row',''));
                colIndex=str2double(strrep(this.ColData.id2Index.(colKey),'col',''));

                linkCell=this.getExcelCell(rowIndex,colIndex);

                if this.isFiltered('row',rowKey)||this.isFiltered('col',colKey)
                    linkCell.Font.Italic=true;
                    linkCell.Font.ColorIndex=16;
                end
                if cLinkData.hasChangeIssue

                    linkCell.Interior.ColorIndex=this.HIGHLIGHT_COLOR_INDEX_FOR_CHANGED_LINKS;
                end
            end


        end

        function formattingExcelTableHeaders(this)
            endColumnNum=this.NumOfColumns;
            endColumnName=this.getColumnNameFromIndex(endColumnNum);
            firstColumnName=this.getColumnNameFromIndex(this.ExcelTableStartIndexForColumns-1);
            secondColumnName=this.getColumnNameFromIndex(this.ExcelTableStartIndexForColumns);
            endRowNum=this.NumOfRows+this.ExcelTableStartIndexForRows;


            headerRow=this.getExcelRow(0);
            firstRowExceptFirstCell=headerRow.Range(secondColumnName+"1:"+endColumnName+"1");


            firstRowExceptFirstCell.ColumnWidth=2;

            firstRowExceptFirstCell.Interior.Color=this.BACKGROUND_COLOR_FOR_HEADERS;

            firstRowExceptFirstCell.Borders.Color=0;
            firstRowExceptFirstCell.Borders.LineStyle=1;

            firstRowExceptFirstCell.Orientation=90;



            headerColumn=this.getExcelColumn(0);

            firstColumnExceptFirstCell=headerColumn.Range(firstColumnName+"1:"+firstColumnName+string(endRowNum));



            firstColumnExceptFirstCell.Interior.Color=this.BACKGROUND_COLOR_FOR_HEADERS;
            firstColumnExceptFirstCell.Borders.Color=0;
            firstColumnExceptFirstCell.ColumnWidth=50;
        end


        function out=getExcelRow(this,rowIndex)

            out=this.AllExcelRows.Item(rowIndex+this.ExcelTableStartIndexForRows);
        end


        function out=getExcelColumn(this,columnIndex)
            out=this.AllExcelColumns.Item(columnIndex+this.ExcelTableStartIndexForColumns);
        end


        function groupAndFormattingHeaderCells(this)
            this.AllExcelColumns.ClearOutline;
            this.AllExcelRows.ClearOutline;
            this.groupItems(this.RowData.hierarchy,'row',0);
            this.groupItems(this.ColData.hierarchy,'col',0);
        end


        function formattingSheet(this)


            this.CurrentWorkingSheet.Outline.SummaryColumn='xlSummaryOnLeft';
            this.CurrentWorkingSheet.Outline.SummaryRow='xlSummaryAbove';
            thisCell=this.getExcelCell(this.ExcelTableStartIndexForRows,this.ExcelTableStartIndexForRows);
            thisCell.Worksheet.Activate;
            thisCell.Select();
            excelDoc=this.ExcelDocH;
            allWindows=excelDoc.Windows;
            currentWind=allWindows.Item(1);
            currentWind.set('FreezePanes',true)
        end


        function columnIndex=getColumnIndexFromName(this,colName)
            range=this.CurrentWorkingSheet.Range(colName+"1");
            columnIndex=range.Column;
        end


        function columnName=getColumnNameFromIndex(this,colIndex)
            columnObj=this.getExcelColumn(colIndex);
            columnAddress=columnObj.Address;
            columnName=regexp(columnAddress,'\$(\w+)\:','tokens');
            columnName=string(columnName{1}{1});
        end

        function out=getExcelItem(this,rowOrColumn,index)
            if strcmpi(rowOrColumn,'row')
                out=this.getExcelRow(index);
            else
                out=this.getExcelColumn(index);
            end
        end











        function out=getExcelCell(this,rowIndex,colIndex)
            rowItem=this.getExcelRow(rowIndex);
            allCells=rowItem.Cells;
            out=allCells.Item(colIndex+this.ExcelTableStartIndexForColumns);
        end


        function out=getHighlightColor(this,rowOrColumn,idKey)
            if strcmpi(rowOrColumn,'row')
                data=this.RowData;
            else
                data=this.ColData;
            end

            if isfield(data.withMissingLinks,idKey)
                out=this.HIGHLIGHT_COLOR_FOR_MISSING_LINKS;
                return;
            end

            if isfield(data.withChangedLinks,idKey)
                out=this.HIGHLIGHT_COLOR_FOR_CHANGED_LINKS;
                return;
            end

            out=[];
        end


        function out=isHighlightedByMissingLinks(this,rowOrColumn,idKey)
            if strcmpi(rowOrColumn,'row')
                data=this.RowData;
            else
                data=this.ColData;
            end
            out=isfield(data,'withMissingLinks')&&isfield(data.withMissingLinks,idKey);
        end


        function out=isHighlightedByChangedLink(this,rowOrColumn,idKey)
            if strcmpi(rowOrColumn,'row')
                data=this.RowData;
            else
                data=this.ColData;
            end
            out=isfield(data,'withChangedLinks')&&isfield(data.withChangedLinks,idKey);
        end

        function out=isFiltered(this,rowOrColumn,idKey)
            if strcmpi(rowOrColumn,'row')
                data=this.RowData;
            else
                data=this.ColData;
            end

            if~isfield(data,'scopedList')||isempty(fieldnames(data.scopedList))
                out=false;
                return;
            end

            out=~isfield(data.scopedList,idKey);
        end


        function out=getHighlightColorIndex(this,rowOrColumn,idKey)
            if strcmpi(rowOrColumn,'row')
                data=this.RowData;
            else
                data=this.ColData;
            end

            if isfield(data,'withMissingLinks')&&isfield(data.withMissingLinks,idKey)
                out=this.HIGHLIGHT_COLOR_INDEX_FOR_MISSING_LINKS;
                return;
            end

            if isfield(data,'withChangedLinks')&&isfield(data.withChangedLinks,idKey)
                out=this.HIGHLIGHT_COLOR_INDEX_FOR_CHANGED_LINKS;
                return;
            end

            out=[];
        end


        function out=getContentFromIdKey(this,rowOrColumn,idKey)
            if strcmp(rowOrColumn,'row')
                itemData=this.RowData;
            else
                itemData=this.ColData;
            end
            out=itemData.index2Desc.(itemData.id2Index.(idKey));
        end


        function lastIndexNumber=groupItems(this,itemHierarchy,rowOrColumn,levelNum)
            idKey=getIDKeyFromFullID(itemHierarchy.FullID);

            if strcmpi(rowOrColumn,'row')
                currentIndexNumber=str2double(strrep(this.RowData.id2Index.(idKey),rowOrColumn,''));
                firstCell=this.getExcelCell(currentIndexNumber,0);
            else
                currentIndexNumber=str2double(strrep(this.ColData.id2Index.(idKey),rowOrColumn,''));
                firstCell=this.getExcelCell(0,currentIndexNumber);
            end

            if~isempty(itemHierarchy.Children)
                childrenIndicator='- ';
                indentLevel=levelNum-1;
                extraSpaceDueToIndicator=2;
            else
                childrenIndicator='';
                indentLevel=levelNum;
                extraSpaceDueToIndicator=0;
            end
            if strcmpi(rowOrColumn,'row')
                firstCell.Value=[childrenIndicator,this.getContentFromIdKey(rowOrColumn,idKey)];
                firstCell.IndentLevel=min(indentLevel+1,10);
            else
                extraSpace=repmat(' ',[1,(indentLevel+1)*4+extraSpaceDueToIndicator]);
                firstCell.Value=[extraSpace,childrenIndicator,this.getContentFromIdKey(rowOrColumn,idKey)];
            end

            if this.isFiltered(rowOrColumn,idKey)

                firstCell.Font.Italic=true;
                firstCell.Font.ColorIndex=16;
            else


                color=this.getHighlightColorIndex(rowOrColumn,idKey);
                if~isempty(color)
                    firstCell.Interior.ColorIndex=color;
                end
            end
            if isempty(itemHierarchy.Children)
                lastIndexNumber=currentIndexNumber;
                return;
            end


            for index=1:length(itemHierarchy.Children)
                cChild=itemHierarchy.Children(index);
                lastIndexNumber=groupItems(this,cChild,rowOrColumn,levelNum+1);
            end

            if strcmp(rowOrColumn,'row')
                allTargets=this.AllExcelRows;
                range=string(currentIndexNumber+this.ExcelTableStartIndexForRows+1)+":"+string(lastIndexNumber+this.ExcelTableStartIndexForRows);
            else
                allTargets=this.AllExcelColumns;
                startColName=this.getColumnNameFromIndex(currentIndexNumber+1);
                endColName=this.getColumnNameFromIndex(lastIndexNumber);
                range=startColName+":"+endColName;
            end

            try
                targets2Group=allTargets.Range(range);
                targets2Group.Group;
            catch ex
                warning(ex.message);
            end
        end

        function writeConfigToExcel(this)
            exApp=this.CurrentWorkingSheet.Application;

            configSheetName=['Legend_for_',this.CurrentSheetName];
            this.CurrentSheetName=configSheetName;
            out=this.getCorrectSheet();

            if out
                orig=exApp.DisplayAlerts;
                try
                    exApp.DisplayAlerts=false;
                    this.CurrentWorkingSheet.Delete();
                    exApp.DisplayAlerts=orig;
                catch
                    exApp.DisplayAlerts=orig;
                end
            end
            allSheets=exApp.Sheets;
            configSheet=allSheets.Add;
            configSheet.Name=configSheetName;

            this.CurrentWorkingSheet=configSheet;
            this.AllExcelColumns=configSheet.Columns;
            this.AllExcelRows=configSheet.Rows;




            this.writeAndFormatConfigDataToExcel();
        end


        function writeAndFormatConfigDataToExcel(this)













            thisCell=this.getExcelCell(0,0);
            thisCell.Value=getString(message('Slvnv:slreq_rtmx:ExportHTMLFilterStatus'));
            thisCell.Font.Bold=true;
            thisCell.Font.Size=16;

            thisCell=this.getExcelCell(1,1);
            thisCell.Value=[getString(message('Slvnv:slreq_rtmx:Top')),':'];
            thisCell.Font.Bold=true;
            thisCell.Font.Size=14;

            thisCell=this.getExcelCell(2,2);
            thisCell.Value=getString(message('Slvnv:slreq_rtmx:ExportHTMLFocusedScope'));
            thisCell.Font.Bold=true;
            thisCell.Interior.Color=this.BACKGROUND_COLOR_FOR_HEADERS;
            thisCell.Font.Size=14;

            thisCell=this.getExcelCell(2,3);

            thisCell.Value=strjoin(this.ConfigData.scope.col,', ');
            lastIndex=writeConfigDataToExcel(this,[this.ConfigData.col;this.ConfigData.matrix],2);

            thisCell=this.getExcelCell(lastIndex+1,1);
            thisCell.Value=[getString(message('Slvnv:slreq_rtmx:Left')),':'];
            thisCell.Font.Bold=true;
            thisCell.Font.Size=14;

            thisCell=this.getExcelCell(lastIndex+2,2);
            thisCell.Value=getString(message('Slvnv:slreq_rtmx:ExportHTMLFocusedScope'));
            thisCell.Font.Bold=true;
            thisCell.Interior.Color=this.BACKGROUND_COLOR_FOR_HEADERS;
            thisCell.Font.Size=14;

            thisCell=this.getExcelCell(lastIndex+2,3);

            thisCell.Value=strjoin(this.ConfigData.scope.row,',');

            lastIndex=writeConfigDataToExcel(this,[this.ConfigData.row;this.ConfigData.matrix],lastIndex+2);

            if~isempty(this.ConfigData.highlight)
                thisCell=this.getExcelCell(lastIndex+1,1);
                thisCell.Value=[getString(message('Slvnv:slreq_rtmx:ToolstripGroupHighlighting')),':'];
                thisCell.Font.Bold=true;
                thisCell.Font.Size=14;

                lastIndex=writeConfigDataToExcel(this,this.ConfigData.highlight,lastIndex+1,true);
            end

            this.CurrentWorkingSheet.Columns.AutoFit();
        end

        function[configByQueryNameMapping,...
            configNameByQueryNameMapping,...
            propNameByPropLabelMapping]=...
            organizeConfigData(this,configData)

            configByQueryNameMapping=containers.Map();
            configNameByQueryNameMapping=containers.Map();
            propNameByPropLabelMapping=containers.Map();
            for index=1:length(configData)
                cConfig=configData(index);
                propNameByPropLabelMapping(cConfig.PropLabel)=cConfig.Prop;
                if isKey(configByQueryNameMapping,cConfig.QueryName)
                    currentLabels=configByQueryNameMapping(cConfig.QueryName);
                else
                    currentLabels={};
                    configNameByQueryNameMapping(cConfig.QueryName)=cConfig.Name;
                end

                currentLabels{end+1}=cConfig.PropLabel;
                configByQueryNameMapping(cConfig.QueryName)=currentLabels;
            end
        end

        function lastIndex=writeConfigDataToExcel(this,configData,startIndex,needColor)
            if nargin<4
                needColor=false;
            end
            [configByQueryNameMapping,configNameByQueryNameMapping,...
            propNameByPropLabelMapping]=...
            this.organizeConfigData(configData);

            allQueryNames=configByQueryNameMapping.keys;
            currentIndex=startIndex;
            for index=1:configByQueryNameMapping.Count
                cQueryName=allQueryNames{index};
                currentIndex=currentIndex+1;
                cell=this.getExcelCell(currentIndex,2);
                cell.Value=[configNameByQueryNameMapping(cQueryName),':'];
                cell.Font.Bold=true;
                cell.Interior.Color=this.BACKGROUND_COLOR_FOR_HEADERS;
                cell.Font.Size=16;

                allPropLabels=configByQueryNameMapping(cQueryName);
                for pIndex=1:length(allPropLabels)
                    cPropLabel=allPropLabels{pIndex};
                    currentIndex=currentIndex+pIndex-1;
                    cell=this.getExcelCell(currentIndex,3);
                    cell.Value=cPropLabel;
                    if needColor
                        if strcmp(propNameByPropLabelMapping(cPropLabel),'HasNoLink')
                            cell.Interior.ColorIndex=this.HIGHLIGHT_COLOR_INDEX_FOR_MISSING_LINKS;
                        end

                        if strcmp(propNameByPropLabelMapping(cPropLabel),'HasChangedLink')
                            cell.Interior.ColorIndex=this.HIGHLIGHT_COLOR_INDEX_FOR_CHANGED_LINKS;
                        end
                    end
                end
            end
            lastIndex=currentIndex;
        end
    end

    methods(Access=public)
        function this=SLReqRTMXTableData(data,sourceType)
            if nargin<2
                sourceType='matlabtable';
            end

            switch sourceType
            case 'json'
                this.importJSONData(data)
            case 'matlabtable'
                this.importMATLABTable(data)
            end

        end


        function exportToTable(this,fileName)
            rtmxTableData=this.RTMXTable;
            save(fileName,'rtmxTableData');
        end

        function exportedFileName=exportToExcel(this,filename,sheetname)

            if nargin<3
                sheetname='Matrix';
            end

            if nargin<2
                filename='slrtmx.xlsx';
            end

            this.CurrentExcelFileName=slreq.cpputils.getCanonicalPath(filename);
            this.CurrentSheetName=sheetname;
            try
                writetable(this.RTMXTable,...
                this.CurrentExcelFileName,'FileType','spreadsheet',...
                'UseExcel',true,...
                'WriteRowNames',true,...
                'WriteVariableNames',true,...
                'WriteMode','overwritesheet',...
                'Sheet',this.CurrentSheetName);

                this.formatExcel();
                this.writeConfigToExcel();
                this.saveExcel();
                exportedFileName=this.CurrentExcelFileName;
            catch ex
                try
                    invoke(this.ExcelDocH,'Close',false);
                catch EX
                    warning(message('SimulinkBlocks:docblock:CloseFile',EX.message));
                end
                rethrow(ex);

            end
        end

        function saveExcel(this)
            this.ExcelDocH.Save();
        end

        function exportdFileName=exportToHTML(this,fileName)



            if nargin<2
                fileName='slreqrtmx.html';
            end

            this.generateConfigHTMLTable();

            this.HTMLFile=slreq.cpputils.getCanonicalPath(fileName);
            this.HTMLTableCells=cell(this.NumOfRows+1,this.NumOfColumns+1);
            info.id='';
            info.classList=containers.Map;
            info.classList('slreqrtmxFirstCell')=true;
            info.spanClassList=containers.Map;
            info.divClassList=containers.Map;
            info.tag='th';
            info.innerText='';
            this.HTMLTableCells{1,1}=info;
            for index=1:this.NumOfColumns
                info.id=['col',num2str(index)];
                info.classList=containers.Map;
                info.classList('slreqrtmxColHeader')=true;
                info.spanClassList=containers.Map;
                info.divClassList=containers.Map;
                info.tag='th';
                info.innerText=this.ColData.index2Desc.(info.id);
                this.HTMLTableCells{1,index+1}=info;
            end

            for rIndex=1:this.NumOfRows
                info.id=['row',num2str(rIndex)];
                info.classList=containers.Map;
                info.spanClassList=containers.Map;
                info.divClassList=containers.Map;

                info.classList('slreqrtmxRowHeader')=true;
                info.tag='th';
                info.innerText=this.RowData.index2Desc.(info.id);
                this.HTMLTableCells{rIndex+1,1}=info;

                for cIndex=1:this.NumOfColumns
                    info.id='';
                    info.classList=containers.Map;
                    info.spanClassList=containers.Map;
                    info.divClassList=containers.Map;
                    info.tag='td';
                    info.innerText='';
                    this.HTMLTableCells{rIndex+1,cIndex+1}=info;
                end
            end


            this.traverseHierarchy(this.RowData.hierarchy,'row',0);
            this.traverseHierarchy(this.ColData.hierarchy,'col',0);
            this.traverseLinks();


            this.generateHTMLTable();
            this.writeToHTMLFile();

            exportdFileName=this.HTMLFile;
        end


        function writeToHTMLFile(this)
            templateFile=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','slrtmx_exported_from_tabledata');
            jsFile=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','slrtmx_exported_from_tabledata_js');
            templateContent=fileread(templateFile);
            jsContent=fileread(jsFile);
            fid=fopen(this.HTMLFile,'w');
            htmlStringSurfix='</body></html>';
            fprintf(fid,'%s\n%s\n%s\n%s\n%s',templateContent,this.HTMLConfigStr,this.HTMLTableStrings,jsContent,htmlStringSurfix);

            fclose(fid);
        end

        function generateConfigHTMLTable(this)
            this.HTMLConfigStr=sprintf('%s\n','<div id="hide_show_config-col">&#9664;</div>');
            this.HTMLConfigStr=sprintf('%s%s\n',this.HTMLConfigStr,'<div class="config-col">');
            htmlStr=this.writeAndFormatConfigDataToHTML();
            this.HTMLConfigStr=sprintf('%s%s\n',this.HTMLConfigStr,htmlStr);
            this.HTMLConfigStr=sprintf('%s%s\n',this.HTMLConfigStr,'</div>');
        end

        function htmlStr=writeAndFormatConfigDataToHTML(this)















            htmlStr=sprintf('%s%s%s\n','<h2>',getString(message('Slvnv:slreq_rtmx:ExportHTMLFilterStatus')),'</h2>');


            htmlStr=sprintf('%s%s\n',htmlStr,'<table class="slreqrtmxConfigTable">');

            htmlStr=sprintf('%s%s\n',htmlStr,'<tr class="slreqrtmxConfigNameRow">');

            htmlStr=sprintf('%s%s%s%s\n',htmlStr,...
            '<th class="slreqrtmxConfigNameHeader" colspan="2">',...
            getString(message('Slvnv:slreq_rtmx:Top')),':</th>');

            htmlStr=sprintf('%s%s\n',htmlStr,'</tr>');


            htmlStr=sprintf('%s%s\n',htmlStr,'<tr class="slreqrtmxConfigNameRow">');

            htmlStr=sprintf('%s%s%s%s\n',htmlStr,...
            '<th class="slreqrtmxConfigNameCell">',...
            getString(message('Slvnv:slreq_rtmx:ExportHTMLFocusedScope')),':</th>');

            htmlStr=sprintf('%s%s%s%s\n',htmlStr,...
            '<td class="slreqrtmxConfigValueCell Focused_ScopeScope">',...
            strjoin(this.ConfigData.scope.col,', '),'</td>');

            htmlStr=sprintf('%s%s\n',htmlStr,'</tr>');

            configStr=this.writeConfigDataToHTML([this.ConfigData.col;this.ConfigData.matrix]);
            htmlStr=sprintf('%s%s\n',htmlStr,configStr);


            htmlStr=sprintf('%s%s\n',htmlStr,...
            '<tr class="slreqrtmxConfigNameRow">');
            htmlStr=sprintf('%s%s%s%s\n',htmlStr,...
            '<th class="slreqrtmxConfigNameHeader" colspan="2">',...
            getString(message('Slvnv:slreq_rtmx:Left')),':</th>');
            htmlStr=sprintf('%s%s\n',htmlStr,'</tr>');
            htmlStr=sprintf('%s%s\n',htmlStr,'<tr class="slreqrtmxConfigNameRow">');
            htmlStr=sprintf('%s%s%s%s\n',htmlStr,...
            '<th class="slreqrtmxConfigNameCell">',...
            getString(message('Slvnv:slreq_rtmx:ExportHTMLFocusedScope')),':</th>');
            htmlStr=sprintf('%s%s%s%s\n',htmlStr,...
            '<td class="slreqrtmxConfigValueCell Focused_ScopeScope">',...
            strjoin(this.ConfigData.scope.row,', '),'</td>');
            htmlStr=sprintf('%s%s\n',htmlStr,'</tr>');
            configStr=this.writeConfigDataToHTML([this.ConfigData.row;this.ConfigData.matrix]);
            htmlStr=sprintf('%s%s\n',htmlStr,configStr);


            if~isempty(this.ConfigData.highlight)

                htmlStr=sprintf('%s%s\n',htmlStr,...
                '<tr class="slreqrtmxConfigNameRow">');
                htmlStr=sprintf('%s%s%s%s\n',htmlStr,...
                '<th class="slreqrtmxConfigNameHeader" colspan="2">',...
                getString(message('Slvnv:slreq_rtmx:ToolstripGroupHighlighting')),':</th>');
                htmlStr=sprintf('%s%s\n',htmlStr,'</tr>');
                configStr=this.writeConfigDataToHTML(this.ConfigData.highlight);
                htmlStr=sprintf('%s%s\n',htmlStr,configStr);
            end

            htmlStr=sprintf('%s%s\n',htmlStr,'</table>');



        end

        function htmlStr=writeConfigDataToHTML(this,configData)

            [configByQueryNameMapping,configNameByQueryNameMapping,...
            propNameByPropLabelMapping]=...
            this.organizeConfigData(configData);

            allQueryNames=configByQueryNameMapping.keys;









            htmlStr='';
            for index=1:configByQueryNameMapping.Count
                htmlStr=sprintf('%s%s\n',htmlStr,...
                '<tr class="slreqrtmxConfigDetailRow">');
                cQueryName=allQueryNames{index};

                content=[configNameByQueryNameMapping(cQueryName),':'];
                htmlStr=sprintf('%s%s%s%s\n',htmlStr,...
                '<th class="slreqrtmxConfigNameCell">',...
                content,'</th>');

                allPropLabels=configByQueryNameMapping(cQueryName);
                for pIndex=1:length(allPropLabels)
                    cPropLabel=allPropLabels{pIndex};


                    if pIndex>1
                        htmlStr=sprintf('%s%s\n',htmlStr,...
                        '<tr class="slreqrtmxConfigDetailRow">');
                        htmlStr=sprintf('%s%s\n',htmlStr,...
                        '<th class="slreqrtmxConfigNameCell"></th>');
                    end
                    htmlStr=sprintf('%s%s%s%s%s%s\n',htmlStr,...
                    '<td class="slreqrtmxConfigValueCell ',...
                    [configNameByQueryNameMapping(cQueryName),propNameByPropLabelMapping(cPropLabel)],...
                    '">',cPropLabel,'</td>');

                    htmlStr=sprintf('%s%s\n',htmlStr,...
                    '</tr>');
                end
            end
        end


        function htmlStr=generateHTMLTable(this)

            htmlStr=sprintf('<div class="table-col">%s\n','<table class="slreqrtmxTable">');
            cellSize=size(this.HTMLTableCells);
            for rIndex=1:cellSize(1)

                if rIndex==1
                    htmlStr=sprintf('%s%s\n',htmlStr,'<thead>');
                    htmlStr=sprintf('%s%s\n',htmlStr,'<tr class="slreqrtmxColHeaderRow">');
                elseif rIndex==2
                    htmlStr=sprintf('%s%s\n',htmlStr,'<tbody>');
                    htmlStr=sprintf('%s%s\n',htmlStr,'<tr class="slreqrtmxColContentRow">');
                else
                    htmlStr=sprintf('%s%s\n',htmlStr,'<tr class="slreqrtmxColContentRow">');
                end
                for cIndex=1:cellSize(2)
                    cCell=this.HTMLTableCells{rIndex,cIndex};
                    cellHtmlStr=this.getCellString(cCell);
                    htmlStr=sprintf('%s%s\n',htmlStr,cellHtmlStr);
                end

                htmlStr=sprintf('%s%s\n',htmlStr,'</tr>');
                if rIndex==1
                    htmlStr=sprintf('%s%s\n',htmlStr,'</thead>');
                end

                if rIndex==cellSize(1)&&rIndex~=1
                    htmlStr=sprintf('%s%s\n',htmlStr,'</tbody>');
                end
            end

            this.HTMLTableStrings=sprintf('%s%s\n',htmlStr,'</table></div>');
        end


        function out=getCellString(this,cCell)
            allCellClasses=cCell.classList.keys;
            allSpanClasses=cCell.spanClassList.keys;
            allDivClasses=cCell.divClassList.keys;

            classStr=strjoin(allCellClasses,' ');
            spanClassStr=strjoin(allSpanClasses,' ');
            divClassStr=strjoin(allDivClasses,' ');
            if isempty(divClassStr)
                out=sprintf(...
                '<%s class="%s"><div><span class="%s">%s</span></div></%s>',...
                cCell.tag,classStr,spanClassStr,...
                cCell.innerText,cCell.tag);
            else
                out=sprintf(...
                '<%s class="%s"><div class="%s"><span class="%s">%s</span></div></%s>',...
                cCell.tag,classStr,divClassStr,spanClassStr,...
                cCell.innerText,cCell.tag);
            end
        end

        function traverseLinks(this)
            linkData=this.LinkData;
            allLinks=fieldnames(linkData);
            for index=1:length(allLinks)
                cLinkField=allLinks{index};
                cLinkData=this.LinkData.(cLinkField);
                rowKey=getIDKeyFromFullID(cLinkData.rowID);
                colKey=getIDKeyFromFullID(cLinkData.colID);

                rowIndex=str2double(strrep(this.RowData.id2Index.(rowKey),'row',''));
                colIndex=str2double(strrep(this.ColData.id2Index.(colKey),'col',''));

                linkCell=this.HTMLTableCells{rowIndex+1,colIndex+1};
                linkCell.divClassList(cLinkData.cellClass)=true;
                if this.isFiltered('row',rowKey)||this.isFiltered('col',colKey)
                    linkCell.classList('cellWithFilteredColOrRow')=true;
                end

                if cLinkData.hasChangeIssue
                    linkCell.classList('changedLinkCell')=true;
                end
                this.HTMLTableCells{rowIndex+1,colIndex+1}=linkCell;
            end
        end

        function traverseHierarchy(this,itemHierarchy,rowOrColumn,levelNum)
            idKey=getIDKeyFromFullID(itemHierarchy.FullID);

            if strcmpi(rowOrColumn,'row')
                currentIndexNumber=str2double(strrep(this.RowData.id2Index.(idKey),rowOrColumn,''));
                firstIndex=currentIndexNumber+1;
                secondIndex=1;
                indentPrefix='rowHeaderIndent';
            else
                currentIndexNumber=str2double(strrep(this.ColData.id2Index.(idKey),rowOrColumn,''));
                firstIndex=1;
                secondIndex=currentIndexNumber+1;
                indentPrefix='colHeaderIndent';
            end

            cellInfo=this.HTMLTableCells{firstIndex,secondIndex};


            indentClass=[indentPrefix,num2str(levelNum)];
            cellInfo.spanClassList(indentClass)=true;
            if~isempty(itemHierarchy.Children)
                cellInfo.innerText=sprintf('%s%s','<div class="parentNode expandedNode"></div>',cellInfo.innerText);

            else
                cellInfo.innerText=sprintf('%s%s','<div class="leafNode"></div>',cellInfo.innerText);

            end

            if this.isFiltered(rowOrColumn,idKey)
                if strcmp(rowOrColumn,'row')
                    cellInfo.classList('filteredColumn')=true;
                else
                    cellInfo.classList('filteredRow')=true;
                end
            else
                if this.isHighlightedByChangedLink(rowOrColumn,idKey)
                    cellInfo.classList('withChangedLink')=true;
                end

                if this.isHighlightedByMissingLinks(rowOrColumn,idKey)
                    cellInfo.classList('withMissingLink')=true;
                end
            end

            this.HTMLTableCells{firstIndex,secondIndex}=cellInfo;
            for index=1:length(itemHierarchy.Children)
                cChild=itemHierarchy.Children(index);
                traverseHierarchy(this,cChild,rowOrColumn,levelNum+1);
            end
        end

        function displayTable(this)

        end

        function saveTableToMAT(this,matFile)
        end
    end

    methods(Static)

        function loadTableDataFromMAT(matFile)

        end

    end
end


function fullID=getIDKeyFromFullID(IDKey)





    dummyJsonStr=['{"',strrep(IDKey,'\','_'),'": false}'];

    structFromJSON=jsondecode(dummyJsonStr);

    fields=fieldnames(structFromJSON);
    fullID=fields{1};

end


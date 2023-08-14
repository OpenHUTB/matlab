


classdef Table<hdlhtmlreporter.html.EmissionContainer
    properties
id
numRows
numCols
entries
hasHeading
tableSection
    end
    methods
        function obj=Table(numRows,numCols,hasHeading,id,cssStyles)
            obj=obj@hdlhtmlreporter.html.EmissionContainer();
            obj.entries=cell(numRows,numCols);
            obj.id=id;
            obj.numRows=numRows;
            obj.numCols=numCols;
            obj.hasHeading=hasHeading;

            obj.tableSection=hdlhtmlreporter.html.GenericSection('table',id,cssStyles);
            obj.processGroupCssStyles(cssStyles);
        end
        function createEntry(obj,rowNum,colNum,cssStyles,id)
            if nargin<5
                id='';
            end

            if nargin<4
                cssStyles={};
            end

            newEntry=hdlhtmlreporter.html.GenericSection('td',id,cssStyles);
            newEntry.setDisableNewLineOnBeginTag(true);
            obj.entries{rowNum,colNum}=newEntry;
            obj.processGroupCssStyles(cssStyles);
            obj.setupEmissionState(newEntry);
        end

        function addPlainText(obj,text)
            obj.activeSection.addContentStr(text);
        end

        function emitStr=emitHTML(obj)
            emitStr=obj.tableSection.emitHTML;
        end
        function table=getTableElement(obj)
            table=obj.tableSection;
        end
        function commitTable(obj)
            obj.compileTableStructure;
        end
    end
    methods(Access=protected)
        function compileTableStructure(obj)
            tableGroupCssStylesInfo=obj.tableSection.groupCssStylesInfo;

            tbodySection=hdlhtmlreporter.html.GenericSection('tbody','',{});
            tbodySection.groupCssStylesInfo=tableGroupCssStylesInfo;

            if obj.hasHeading
                theadSection=hdlhtmlreporter.html.GenericSection('thead','',{});
                theadSection.groupCssStylesInfo=tableGroupCssStylesInfo;
                rowSection=hdlhtmlreporter.html.GenericSection('tr','',{});
                rowSection.groupCssStylesInfo=tableGroupCssStylesInfo;

                for ci=1:obj.numCols
                    theadCell=obj.entries{1,ci};
                    if isempty(theadCell)
                        theadCell=hdlhtmlreporter.html.GenericSection('td','',{});
                        theadCell.setDisableNewLineOnBeginTag(true);
                    end
                    rowSection.addElement(theadCell);
                end
                theadSection.addElement(rowSection);
                obj.tableSection.addElement(theadSection);


                for ri=2:obj.numRows
                    rowSection=hdlhtmlreporter.html.GenericSection('tr','',{});
                    rowSection.groupCssStylesInfo=tableGroupCssStylesInfo;
                    for ci=1:obj.numCols
                        tbodyCell=obj.entries{ri,ci};
                        if isempty(tbodyCell)
                            tbodyCell=hdlhtmlreporter.html.GenericSection('td','',{});
                            tbodyCell.setDisableNewLineOnBeginTag(true);
                        end
                        rowSection.addElement(tbodyCell);
                    end
                    tbodySection.addElement(rowSection);
                end
            else

                for ri=1:obj.numRows
                    rowSection=hdlhtmlreporter.html.GenericSection('tr','',{});
                    rowSection.groupCssStylesInfo=tableGroupCssStylesInfo;
                    for ci=1:obj.numCols
                        tbodyCell=obj.entries{ri,ci};
                        if isempty(tbodyCell)
                            tbodyCell=hdlhtmlreporter.html.GenericSection('td','',{});
                            tbodyCell.setDisableNewLineOnBeginTag(true);
                        end
                        rowSection.addElement(tbodyCell);
                    end
                    tbodySection.addElement(rowSection);
                end
            end
            obj.tableSection.addElement(tbodySection);
        end

    end
end

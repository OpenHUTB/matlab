classdef TableSlicer<handle












































    properties











        Table{mlreportgen.utils.validators.mustBeTable(Table)}=[];














        MaxCols{mlreportgen.utils.validators.mustBePositiveNumber(MaxCols),mustBeNonempty(MaxCols)}=Inf;








        RepeatCols{mlreportgen.utils.validators.mustBeZeroOrPositiveNumber(RepeatCols),mustBeNonempty(RepeatCols)}=0;
    end

    properties(Access=private,Hidden)


        NumberOfColumns=[];
    end

    methods
        function this=TableSlicer(varargin)

            if(rem(nargin,2)~=0)
                error(message("mlreportgen:utils:error:invalidTableSlicerConstructor"));
            end

            p=inputParser;


            p.KeepUnmatched=false;


            addParameter(p,"Table",[]);
            addParameter(p,"MaxCols",this.MaxCols);
            addParameter(p,"RepeatCols",this.RepeatCols);


            parse(p,varargin{:});

            this.Table=p.Results.Table;
            this.MaxCols=p.Results.MaxCols;
            this.RepeatCols=p.Results.RepeatCols;

        end

        function slices=slice(this)








            if~isempty(this.Table)


                setNumberOfColumns(this);


                verifyInputTableColumnSize(this);


                if this.MaxCols==Inf||this.NumberOfColumns<=this.MaxCols
                    if isa(this.Table,"mlreportgen.dom.Table")||isa(this.Table,"mlreportgen.dom.FormalTable")
                        slices=mlreportgen.utils.TableSlice("Table",clone(this.Table),"StartCol",1,"EndCol",this.NumberOfColumns);
                    end
                elseif this.RepeatCols>=this.MaxCols
                    error(message("mlreportgen:utils:error:incorrectRetainColsValue"));
                else


                    slices=createTableSlices(this);

                end
            else
                error(message("mlreportgen:utils:error:emptyTable"));
            end
        end

    end

    methods(Access=private)



        function setNumberOfColumns(this)
            if isa(this.Table,"mlreportgen.dom.Table")
                if~isempty(this.Table.Children)
                    this.NumberOfColumns=length(this.Table.Children(1).Children);
                end
            elseif isa(this.Table,"mlreportgen.dom.FormalTable")
                if~isempty(this.Table.Body.Children)
                    this.NumberOfColumns=length(this.Table.Body.Children(1).Children);
                end
            end

            if isempty(this.NumberOfColumns)
                error(message("mlreportgen:utils:error:emptyTableColumns"));
            end
        end







        function slicedData=createTableSlices(this)


            tablePrototype=createTableSlicePrototype(this);

            maxTableColumn=(this.MaxCols-this.RepeatCols);
            nCols=this.NumberOfColumns-this.RepeatCols;

            r=rem(nCols,maxTableColumn);
            if(r>0)
                totalSlicedTables=idivide(int32(nCols),maxTableColumn)+1;
            else
                totalSlicedTables=idivide(int32(nCols),maxTableColumn);
            end

            slicedTables=cell(totalSlicedTables,1);

            for i=1:totalSlicedTables
                slicedTables{i}=clone(tablePrototype);
            end

            if isa(tablePrototype,'mlreportgen.dom.Table')
                slicedData=sliceTable(this,slicedTables);
            elseif isa(tablePrototype,'mlreportgen.dom.FormalTable')
                slicedData=sliceFormalTable(this,slicedTables);
            end
        end

        function tableSlicePrototype=createTableSlicePrototype(this)
            tableStyles={"ColSpecGroups","StyleName","Style","CustomAttributes","TableEntriesStyle"};
            FormalTableStyles={'StyleName','Style','CustomAttributes','TableEntriesStyle'};
            tableData=this.Table;
            if isa(tableData,"mlreportgen.dom.Table")
                tableSlicePrototype=mlreportgen.dom.Table();
                mlreportgen.utils.TableSlicer.addTableRows(tableSlicePrototype,tableData);
                mlreportgen.utils.TableSlicer.addTableStyles(tableSlicePrototype,tableData,tableStyles);

            elseif isa(tableData,"mlreportgen.dom.FormalTable")

                tableSlicePrototype=mlreportgen.dom.FormalTable();

                mlreportgen.utils.TableSlicer.addTableRows(tableSlicePrototype.Header,tableData.Header);
                mlreportgen.utils.TableSlicer.addTableRows(tableSlicePrototype.Body,tableData.Body);
                mlreportgen.utils.TableSlicer.addTableRows(tableSlicePrototype.Footer,tableData.Footer);

                mlreportgen.utils.TableSlicer.addTableStyles(tableSlicePrototype,tableData,tableStyles);
                mlreportgen.utils.TableSlicer.addTableStyles(tableSlicePrototype.Header,tableData.Header,FormalTableStyles);
                mlreportgen.utils.TableSlicer.addTableStyles(tableSlicePrototype.Body,tableData.Body,FormalTableStyles);
                mlreportgen.utils.TableSlicer.addTableStyles(tableSlicePrototype.Footer,tableData.Footer,FormalTableStyles);

            else
                error(message("mlreportgen:utils:error:invalidTable"));
            end
        end





        function slicedData=sliceTable(this,slicedTable)
            inputTable=this.Table;

            maxTableCols=this.MaxCols-this.RepeatCols;
            sz=inputTable.NCols;

            slicedTable=retainTableCols(this,slicedTable);
            startIdx=this.RepeatCols+1;
            len=length(slicedTable);
            slicedData=mlreportgen.utils.TableSlice.empty(0,len);

            if sz<maxTableCols
                endIdx=sz;
            else





                endIdx=startIdx+(maxTableCols-1);
            end

            rowIdx=1;

            while(endIdx<=sz)&&(startIdx<=sz)

                for row=1:slicedTable{rowIdx}.NRows
                    for entry=startIdx:endIdx
                        tableEntryClone=clone(inputTable.Children(row).Children(entry));
                        append(slicedTable{rowIdx}.Children(row),tableEntryClone);
                    end
                end
                slicedData(rowIdx)=mlreportgen.utils.TableSlice("Table",slicedTable{rowIdx},...
                "StartCol",double(startIdx),"EndCol",double(endIdx));

                startIdx=endIdx+1;
                endIdx=startIdx+(maxTableCols-1);
                if sz<endIdx
                    endIdx=sz;
                end
                rowIdx=rowIdx+1;
            end

        end



        function slicedTable=retainTableCols(this,slicedTable)

            inputTable=this.Table;

            retainCols=this.RepeatCols;



            for rowIdx=1:length(slicedTable)
                noOfRows=slicedTable{rowIdx}.NRows;
                for row=1:noOfRows
                    for entry=1:retainCols
                        tableEntryClone=clone(inputTable.Children(row).Children(entry));
                        append(slicedTable{rowIdx}.Children(row),tableEntryClone);
                    end

                end
            end

        end




        function slicedTable=retainFormalTableCols(this,slicedTable)

            inputTable=this.Table;
            retainCols=this.RepeatCols;
            formalTableStructure=["Header","Footer","Body"];



            for rowIdx=1:length(slicedTable)
                for tableStructure=formalTableStructure
                    if(slicedTable{rowIdx}.(tableStructure).NRows>0)
                        noOfRows=slicedTable{rowIdx}.(tableStructure).NRows;
                        for row=1:noOfRows
                            for entry=1:retainCols
                                tableEntryClone=clone(inputTable.(tableStructure).Children(row).Children(entry));
                                append(slicedTable{rowIdx}.(tableStructure).Children(row),tableEntryClone);
                            end
                        end

                    end
                end
            end
        end


        function slicedData=sliceFormalTable(this,slicedTable)

            slicedTable=retainFormalTableCols(this,slicedTable);
            maxTableColumn=this.MaxCols-this.RepeatCols;
            inputTable=this.Table;
            len=length(slicedTable);
            sz=this.NumberOfColumns;
            slicedData=mlreportgen.utils.TableSlice.empty(0,len);
            formalTableStructure=["Header","Footer","Body"];
            for tableStructure=formalTableStructure


                startIdx=this.RepeatCols+1;

                if sz<maxTableColumn
                    endIdx=sz;
                else





                    endIdx=startIdx+(maxTableColumn-1);
                end

                rowIdx=1;
                while(endIdx<=sz)&&(startIdx<=sz)

                    for row=1:slicedTable{rowIdx}.(tableStructure).NRows
                        for entry=startIdx:endIdx
                            tableEntryClone=clone(inputTable.(tableStructure).Children(row).Children(entry));
                            append(slicedTable{rowIdx}.(tableStructure).Children(row),tableEntryClone);
                        end
                    end

                    if strcmp(tableStructure,'Body')
                        slicedData(rowIdx)=mlreportgen.utils.TableSlice("Table",slicedTable{rowIdx},...
                        "StartCol",double(startIdx),"EndCol",double(endIdx));
                    end

                    startIdx=endIdx+1;
                    endIdx=startIdx+(maxTableColumn-1);
                    if sz<endIdx
                        endIdx=sz;
                    end

                    rowIdx=rowIdx+1;
                end
            end
        end

        function verifyInputTableColumnSize(this)
            inputTable=this.Table;
            if isa(inputTable,"mlreportgen.dom.Table")
                verifyTableColsSizeUtil(this,inputTable);
            elseif isa(inputTable,"mlreportgen.dom.FormalTable")
                verifyTableColsSizeUtil(this,inputTable.Body);
                verifyTableColsSizeUtil(this,inputTable.Header);
                verifyTableColsSizeUtil(this,inputTable.Footer);
            end
        end

        function verifyTableColsSizeUtil(this,inputTable)
            for eachRow=inputTable.Children
                columnLength=length(eachRow.Children);
                if(this.NumberOfColumns~=columnLength)
                    error(message("mlreportgen:utils:error:unEqualColumns"));
                end
                for eachEntry=eachRow.Children
                    if(~isempty(eachEntry.ColSpan)&&eachEntry.ColSpan>1)||...
                        (~isempty(eachEntry.RowSpan)&&eachEntry.RowSpan>1)
                        error(message("mlreportgen:utils:error:invalidRowSpanColSpanValue"));
                    end
                end
            end
        end
    end

    methods(Static,Access=private)
        function addTableRows(tableSlicePrototype,inputTable)
            rowProperties={"StyleName","Style","CustomAttributes"};
            if~isempty(inputTable.Children)
                for j=1:inputTable.NRows
                    tableRow=mlreportgen.dom.TableRow();
                    for k=1:length(rowProperties)
                        tableRow.(rowProperties{k})=inputTable.Children(j).(rowProperties{k});
                    end
                    append(tableSlicePrototype,tableRow);
                end
            end
        end


        function addTableStyles(tableSlicePrototype,inputTable,tableStyles)
            for i=1:length(tableStyles)
                tableSlicePrototype.(tableStyles{i})=inputTable.(tableStyles{i});
            end
        end
    end
end

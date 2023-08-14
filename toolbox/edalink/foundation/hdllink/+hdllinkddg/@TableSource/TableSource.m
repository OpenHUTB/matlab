classdef TableSource<matlab.mixin.SetGet&matlab.mixin.Copyable



































    properties(SetObservable)

        TableName{matlab.internal.validation.mustBeASCIICharRowVector(TableName,'TableName')}='';

        TableOpsTag{matlab.internal.validation.mustBeASCIICharRowVector(TableOpsTag,'TableOpsTag')}='';

        AddRowTag{matlab.internal.validation.mustBeASCIICharRowVector(AddRowTag,'AddRowTag')}='';

        DeleteRowTag{matlab.internal.validation.mustBeASCIICharRowVector(DeleteRowTag,'DeleteRowTag')}='';

        MoveRowUpTag{matlab.internal.validation.mustBeASCIICharRowVector(MoveRowUpTag,'MoveRowUpTag')}='';

        MoveRowDownTag{matlab.internal.validation.mustBeASCIICharRowVector(MoveRowDownTag,'MoveRowDownTag')}='';

        UddUtil=[];

        NumRows(1,1)int16{mustBeReal}=0;

        NumCols(1,1)int16{mustBeReal}=0;

        CurrRow(1,1)int16{mustBeReal}=0;

        MaxPathLength(1,1)int16{mustBeReal}=0;

        RowSources=[];

        LastUninheritedValues=[];

        colPos=[];

        colName=[];
    end

    methods
        function this=TableSource

        end

    end

    methods
        function set.TableName(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','TableName')
            obj.TableName=value;
        end

        function set.TableOpsTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','TableOpsTag')
            obj.TableOpsTag=value;
        end

        function set.AddRowTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','AddRowTag')
            obj.AddRowTag=value;
        end

        function set.DeleteRowTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','DeleteRowTag')
            obj.DeleteRowTag=value;
        end

        function set.MoveRowUpTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','MoveRowUpTag')
            obj.MoveRowUpTag=value;
        end

        function set.MoveRowDownTag(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','MoveRowDownTag')
            obj.MoveRowDownTag=value;
        end

        function set.UddUtil(obj,value)

            validateattributes(value,{'handle'},{'scalar'},'','UddUtil')
            obj.UddUtil=value;
        end

        function set.NumRows(obj,value)

            validateattributes(value,{'numeric'},{'scalar'},'','NumRows')
            value=round(value);
            obj.NumRows=value;
        end

        function set.NumCols(obj,value)

            validateattributes(value,{'numeric'},{'scalar'},'','NumCols')
            value=round(value);
            obj.NumCols=value;
        end

        function set.CurrRow(obj,value)

            validateattributes(value,{'numeric'},{'scalar'},'','CurrRow')
            value=round(value);
            obj.CurrRow=value;
        end

        function set.MaxPathLength(obj,value)

            validateattributes(value,{'numeric'},{'scalar'},'','MaxPathLength')
            value=round(value);
            obj.MaxPathLength=value;
        end

        function set.RowSources(obj,value)

            validateattributes(value,{'handle'},{'vector'},'','RowSources')
            obj.RowSources=value;
        end

        function set.LastUninheritedValues(obj,value)

            validateattributes(value,{'handle'},{'scalar'},'','LastUninheritedValues')
            obj.LastUninheritedValues=value;
        end
    end

    methods

        h=CreateNewRow(this,currRowH)
        td=CreateTableData(this)
        enables=GetColEnables(~,~)
        [widths,headings,height]=GetColInfo(~)
        srcData=GetSourceData(this)
        opsEns=GetTableOperationsEnables(this)
        MoveRowDown(this,dialog)
        MoveRowUp(this,dialog)
        OnTableValueChangeCB(this,dlg,trow,tcol,value)
        RefreshRow(this,dlg,row)
        SetLastUninheritedValues(this)
        SetSourceData(this,srcData)
    end


    methods(Hidden)

        AddRow(this,dialog)
        widget=CreateTableCell(this,typeName,objProp)
        widget=CreateTableOperationsWidget(this)
        widget=CreateTableWidget(this)
        DeleteRow(this,dialog)
        maxPathLength=GetMaxPathLength(this)
        OnTableFocusChangeCB(this,dlg,trow,col)
        RefreshTable(this,dlg)
    end
end


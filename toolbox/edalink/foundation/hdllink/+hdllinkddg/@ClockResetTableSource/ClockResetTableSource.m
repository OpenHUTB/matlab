classdef ClockResetTableSource<hdllinkddg.TableSource



























    methods
        function this=ClockResetTableSource(tableName,srcData)
            this.TableName=tableName;
            this.TableOpsTag=[this.TableName,'.TableOps'];
            this.AddRowTag=[this.TableOpsTag,'.AddRow'];
            this.DeleteRowTag=[this.TableOpsTag,'.DeleteRow'];
            this.MoveRowUpTag=[this.TableOpsTag,'.MoveRowUp'];
            this.MoveRowDownTag=[this.TableOpsTag,'.MoveRowDown'];
            this.UddUtil=hdllinkddg.UddUtil;
            this.colPos=this.UddUtil.EnumByStrStruct('CoSimClockTableColEnum');
            this.colName=this.UddUtil.EnumByPosArray('CoSimClockTableColEnum');
            this.SetSourceData(srcData,1);
        end
    end

    methods

        srcData=GetSourceData(this)
        OnTableValueChangeCB(this,dlg,trow,tcol,value)
        RefreshRow(this,dlg,row)
        SetSourceData(this,srcData,rowSelect)
    end


    methods(Hidden)

        h=CreateNewRow(this,currRowH)
        cellD=CreateTableData(this)
        enables=GetColEnables(this,srow)
        [widths,headings,height]=GetColInfo(this)
        opsEns=GetTableOperationsEnables(this)
    end
end


function this=FPGAProjectPropTableSource(tableName,srcData)



    this=tdkfpgacc.FPGAProjectPropTableSource;

    this.TableName=tableName;
    this.TableOpsTag=[this.TableName,'.TableOps'];
    this.AddRowTag=[this.TableOpsTag,'.AddRow'];
    this.DeleteRowTag=[this.TableOpsTag,'.DeleteRow'];
    this.MoveRowUpTag=[this.TableOpsTag,'.MoveRowUp'];
    this.MoveRowDownTag=[this.TableOpsTag,'.MoveRowDown'];

    this.UddUtil=tdkfpgacc.UddUtil;

    this.colPos=this.UddUtil.EnumByStrStruct('FPGAProjectPropTableColEnum');
    this.colName=this.UddUtil.EnumByPosArray('FPGAProjectPropTableColEnum');

    this.SetSourceData(srcData,1);


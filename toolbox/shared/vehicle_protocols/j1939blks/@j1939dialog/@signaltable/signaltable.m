function this=signaltable(obj,tableData)











    this=j1939dialog.signaltable;


    this.Name=tableData.Name;
    this.StartBit=tableData.StartBit;
    this.Length=tableData.Length;
    this.ByteOrder=tableData.ByteOrder;
    this.DataType=tableData.DataType;
    this.MultiplexType=tableData.MultiplexType;
    this.MultiplexValue=tableData.MultiplexValue;
    this.Factor=tableData.Factor;
    this.Offset=tableData.Offset;
    this.Min=tableData.Min;
    this.Max=tableData.Max;
    this.Unit=tableData.Unit;
    this.SPN=tableData.SPN;

function loadFromBlock(this)







    this.NumPorts=this.Block.NumPorts;
    this.DeviceCirculator=this.Block.DeviceCirculator;
    this.DeviceDivider=this.Block.DeviceDivider;
    this.DeviceCoupler=this.Block.DeviceCoupler;
    this.Phase12=this.Block.Phase12;
    this.Phase33=this.Block.Phase33;
    this.Alpha=this.Block.Alpha;
    this.NumberDividerOutports=this.Block.NumberDividerOutports;
    this.Coupling=this.Block.Coupling;
    this.Directivity=this.Block.Directivity;
    this.InsertionLoss=this.Block.InsertionLoss;
    this.ReturnLoss=this.Block.ReturnLoss;
    this.SparamZ0=this.Block.SparamZ0;
    this.InternalGrounding=strcmpi(this.Block.InternalGrounding,'on');


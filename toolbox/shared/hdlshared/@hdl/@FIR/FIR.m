function this=FIR(varargin)





    this=hdl.FIR;
    this.init(varargin{:});








    hTDatapipe=pirelab.createPirArrayType(this.datain.Type,this.length);
    this.data_pipe=this.hN.addSignal2('Type',hTDatapipe,'Name','data_pipeline',...
    'SimulinkRate',this.slrate);


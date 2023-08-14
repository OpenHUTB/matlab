function dlgStruct=dlgTimespan(this,varargin)




    dlgStruct=this.dlgContainer({
    this.dlgWidget('UseMdlTimespan',...
    'DialogRefresh',1)
    this.dlgWidget('StartTime',...
    'Enabled',~this.UseMdlTimespan)
    this.dlgWidget('EndTime',...
    'Enabled',~this.UseMdlTimespan)
    },getString(message('RptgenSL:rsl_csl_mdl_sim:timespanLabel')),...
    varargin{:});


function out=execute(this,d,varargin)








    out=d.createDocumentFragment;
    context=get(rptgen_sf.appdata_sf,'CurrentObject');
    if isempty(context)
        this.reportEMLBlocks(d,out);
    else
        this.reportStateflowEMLFcns(d,context,out);
    end










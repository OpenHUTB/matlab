function out=execute(this,d,varargin)







    adSL=rptgen_sl.appdata_sl;
    objH=adSL.getContextObject;

    if isempty(objH)

        this.status('No current object for snapshot');
        out=[];
        return;
    end

    objH=get_param(objH,'Object');


    out=this.captureDialog(d,objH);


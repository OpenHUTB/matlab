function out=execute(this,d,varargin)







    adSF=rptgen_sf.appdata_sf;
    objH=adSF.getContextObject;


    out=this.captureDialog(d,objH);


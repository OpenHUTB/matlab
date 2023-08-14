function[success,msg]=isGenSLTBsupported(this)





    if isa(this.Stage(end),'hdlfilter.farrowsrc')
        success=false;
        msg='Generation of cosimulation model is not supported for cascaded filters with Farrow SRC.';
    else
        success=true;
        msg='';
    end
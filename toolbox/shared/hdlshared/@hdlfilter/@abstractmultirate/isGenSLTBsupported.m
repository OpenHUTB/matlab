function[success,msg]=isGenSLTBsupported(this)





    if~strcmpi(this.Implementation,'parallel')
        success=false;
        msg=['Generation of cosimulation model is not supported for ''',...
        this.Implementation,''' implementation for this filter.'];
    else
        success=true;
        msg='';
    end

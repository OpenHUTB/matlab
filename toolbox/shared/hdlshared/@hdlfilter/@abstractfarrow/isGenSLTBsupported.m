function[success,msg]=isGenSLTBsupported(this)





    success=false;
    msg=['Generation of cosimulation model is not supported for ''',...
    this.FilterStructure,''' filter structure.'];
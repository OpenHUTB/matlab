function ret=compatibleWith(varargin)






    this=varargin{1};
    oldToCopyFrom=varargin{2};




    set_param(oldToCopyFrom,'CompOptLevelCompliant',get_param(this,'CompOptLevelCompliant'));


    ret=true;

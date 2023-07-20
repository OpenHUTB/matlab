function obj=StylesheetRoot(varargin)











    mlock;
    persistent STYLESHEET_ROOT_OBJ;

    if isa(STYLESHEET_ROOT_OBJ,mfilename('class'))
        obj=STYLESHEET_ROOT_OBJ;
    else
        obj=feval(mfilename('class'));
        STYLESHEET_ROOT_OBJ=obj;
    end


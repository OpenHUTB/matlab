function obj=Root(varargin)











    mlock;
    persistent ROOT_OBJ;

    if isempty(ROOT_OBJ)
        obj=feval(mfilename('class'));
        ROOT_OBJ=obj;
    else
        obj=ROOT_OBJ;
    end


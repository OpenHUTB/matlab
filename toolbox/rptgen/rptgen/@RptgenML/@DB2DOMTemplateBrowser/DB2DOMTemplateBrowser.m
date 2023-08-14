function obj=DB2DOMTemplateBrowser(varargin)










    mlock;
    persistent TEMPLATE_ROOT_OBJ;

    if isa(TEMPLATE_ROOT_OBJ,mfilename('class'))
        obj=TEMPLATE_ROOT_OBJ;
    else
        obj=feval(mfilename('class'));
        TEMPLATE_ROOT_OBJ=obj;
    end


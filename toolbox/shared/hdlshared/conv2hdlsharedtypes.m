function[vtype,sltype]=conv2hdlsharedtypes(arith,varargin)












    arithisdouble=strcmpi(arith,'double');

    if arithisdouble
        vtype='real';
        sltype='double';
    else
        [vtype,sltype]=hdlgettypesfromsizes(varargin{1},varargin{2},varargin{3});
    end



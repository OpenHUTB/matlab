%#codegen

function fival=f2f_fi_constructor(fcn,fcnPath,exprStart,exprLength,val,varargin)
    coder.inline('always');
    coder.extrinsic('f2f_overflow_lib');

    fival=fi(val,varargin{:});
    if~isempty(fival)
        f2f_fi_like(fcn,fcnPath,exprStart,exprLength,val,fival(1));
    end
end
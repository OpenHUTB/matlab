%#codegen

function o=coder__log(id,expr)
    coder.allowpcode('plain');
    assert(ischar(id));
    assert(2==nargin)
    o=expr;
end
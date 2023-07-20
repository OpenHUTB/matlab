%#codegen

function out=singleToFi(x)
    coder.allowpcode('plain');

    out=fi(reshape(typecast(reshape(x,[1,numel(x)]),'uint32'),size(x)),0,32,0);
end
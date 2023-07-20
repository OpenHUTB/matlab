%#codegen

function out=uint64ToDouble(x)
    coder.allowpcode('plain');

    out=reshape(typecast(reshape(x,[1,numel(x)]),'double'),size(x));
end
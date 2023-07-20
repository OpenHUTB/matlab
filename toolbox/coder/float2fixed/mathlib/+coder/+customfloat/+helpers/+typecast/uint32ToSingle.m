%#codegen

function out=uint32ToSingle(x)
    coder.allowpcode('plain');

    out=reshape(typecast(reshape(x,[1,numel(x)]),'single'),size(x));
end
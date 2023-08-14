%#codegen

function out=doubleToFi(x)
    coder.allowpcode('plain');

    out=fi(reshape(typecast(reshape(x,[1,numel(x)]),'uint64'),size(x)),0,64,0);
end
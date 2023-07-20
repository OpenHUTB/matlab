%#codegen

function out=int16ToUint16(x)
    coder.allowpcode('plain');

    out=reshape(typecast(reshape(x,[1,numel(x)]),'uint16'),size(x));
end
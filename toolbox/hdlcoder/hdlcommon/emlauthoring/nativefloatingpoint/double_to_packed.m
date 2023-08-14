%#codegen
function I=double_to_packed(X)


    coder.allowpcode('plain')

    I=typecast(double(X),'uint64');
end

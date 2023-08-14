function I=single_to_packed(X)
%#codegen


    coder.allowpcode('plain')

    I=typecast(single(X),'uint32');
end

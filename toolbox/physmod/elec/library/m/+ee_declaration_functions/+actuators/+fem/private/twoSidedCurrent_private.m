function[xM,xI]=twoSidedCurrent_private(M,I,sgn)%#codegen
















    coder.allowpcode('plain');

    xI=[sort(-I),I(2:end)];
    [ni,nx]=size(M);
    M_neg=zeros(ni-1,nx);
    for i=1:ni-1
        M_neg(i,:)=sgn*M(ni-i+1,:);
    end
    xM=[M_neg;M];

end
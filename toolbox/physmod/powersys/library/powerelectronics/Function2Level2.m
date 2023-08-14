function[Idc]=Function2Level2(g,I1,I2)
%#codegen
    coder.allowpcode('plain');

    I=zeros(3,1,'double');

    I(1)=(g(2)-1)*I1(1)+g(1)*I2(1);
    I(2)=(g(4)-1)*I1(2)+g(3)*I2(2);
    I(3)=(g(6)-1)*I1(3)+g(5)*I2(3);
    Idc=I(1)+I(2)+I(3);



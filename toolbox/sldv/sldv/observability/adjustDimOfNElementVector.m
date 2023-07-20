function[in1,in2]=adjustDimOfNElementVector(input1,input2)



















    coder.inline('always');
    coder.allowpcode('plain');

    sizeIn1=size(input1);
    sizeIn2=size(input2);

    if numel(sizeIn1)==2&&numel(sizeIn2)==2
        if sizeIn1(1)==1&&sizeIn1(2)~=1
            if sizeIn2(1)==sizeIn1(2)&&sizeIn2(2)==1
                in2=input2';
            else
                in2=input2;
            end
            in1=input1;
        elseif sizeIn1(1)~=1&&sizeIn1(2)==1
            if sizeIn2(1)==1&&sizeIn2(2)==sizeIn1(1)
                in1=input1';
            else
                in1=input1;
            end
            in2=input2;
        else
            in1=input1;
            in2=input2;
        end
    else
        in1=input1;
        in2=input2;
    end
end

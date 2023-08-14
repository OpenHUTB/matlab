





Matrix_Size=64;
Matrix_Multiplication_On=false;


Vector_Matrix_Length=Matrix_Size^2+Matrix_Size;
Burst_Length=Vector_Matrix_Length;
DDR_Depth=(Matrix_Size^2)*2;
Duty_Cycle=0.5;
Single_Tolerance=10e-5;


maskDataType=get_param('loopback_external_memory/DDR','OutDataTypeStr');


if strcmp(maskDataType(1:4),'uint')||strcmp(maskDataType(1:3),'int')
    ddrInitData=fi((randi([1,100],1,DDR_Depth)),numerictype(maskDataType));
else
    ddrInitData=single((rand(1,DDR_Depth)));
end

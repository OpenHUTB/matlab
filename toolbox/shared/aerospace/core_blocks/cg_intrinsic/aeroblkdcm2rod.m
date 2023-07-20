function rod=aeroblkdcm2rod(dcm)


%#codegen
    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');


    rod=zeros(3,1);
    sx=0;
    sy=0;
    sz=0;

    th=acos((trace(dcm)-1)/2);
    if th~=0

        sy=(dcm(3,1)-dcm(1,3))/(2*sin(th));
        sx=(dcm(2,3)-dcm(3,2))/(2*sin(th));
        sz=(dcm(1,2)-dcm(2,1))/(2*sin(th));

        rod=tan(th/2)*[sx;sy;sz];
    end

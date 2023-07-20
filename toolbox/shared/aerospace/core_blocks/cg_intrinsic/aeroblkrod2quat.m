function quat=aeroblkrod2quat(rod)




%#codegen
    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');


    quat=zeros(4,1);
    thalf=0;
    n=norm(rod);
    if n~=0

        thalf=atan(n);

        quat(1)=cos(thalf);
        quat(2)=rod(1)*sin(thalf)/n;
        quat(3)=rod(2)*sin(thalf)/n;
        quat(4)=rod(3)*sin(thalf)/n;
    end

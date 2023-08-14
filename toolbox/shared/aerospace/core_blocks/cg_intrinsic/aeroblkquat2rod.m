function rod=aeroblkquat2rod(qin)




%#codegen
    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');


    rod=zeros(3,1);
    qinn=aeroblkquatnormalize(qin);

    thalf=acos(qinn(1));
    if thalf~=0

        rod=qinn(2:4)/cos(thalf);
    end
end

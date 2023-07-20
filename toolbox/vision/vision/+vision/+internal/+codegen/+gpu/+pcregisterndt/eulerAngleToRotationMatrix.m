

function[rotationMatrix,translationVector]=eulerAngleToRotationMatrix(inpPoseMat,type)
%#codegen















    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');


    poseMat=cast(inpPoseMat,type);


    thetaX=poseMat(4);
    thetaY=poseMat(5);
    thetaZ=poseMat(6);


    cx=cos(thetaX);sx=sin(thetaX);
    cy=cos(thetaY);sy=sin(thetaY);
    cz=cos(thetaZ);sz=sin(thetaZ);


    rotationMatrix=coder.nullcopy(zeros(3,'like',poseMat));
    rotationMatrix(1)=cy*cz;
    rotationMatrix(2)=(cx*sz)+(sx*sy*cz);
    rotationMatrix(3)=(sx*sz)-(cx*sy*cz);
    rotationMatrix(4)=-cy*sz;
    rotationMatrix(5)=(cx*cz)-(sx*sy*sz);
    rotationMatrix(6)=(sx*cz)+(cx*sy*sz);
    rotationMatrix(7)=sy;
    rotationMatrix(8)=-sx*cy;
    rotationMatrix(9)=cx*cy;


    translationVector=[poseMat(1),poseMat(2),poseMat(3)];
end

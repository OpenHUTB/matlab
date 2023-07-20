

















function[R,Ja,Ha]=computeJaHa(poseMat)
%#codegen




    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');

    [R,~]=vision.internal.codegen.gpu.pcregisterndt.eulerAngleToRotationMatrix(poseMat,class(poseMat));
    [Ja,Ha]=computeAngleDerivatives(poseMat);
end

function[Ja,Ha]=computeAngleDerivatives(poseMat)









    thetaX=poseMat(4);
    thetaY=poseMat(5);
    thetaZ=poseMat(6);



    if abs(thetaX)<0.1745
        thetaX=0;
    end
    if abs(thetaY)<0.1745
        thetaY=0;
    end
    if abs(thetaZ)<0.1745
        thetaZ=0;
    end


    cx=cos(thetaX);sx=sin(thetaX);
    cy=cos(thetaY);sy=sin(thetaY);
    cz=cos(thetaZ);sz=sin(thetaZ);






    Ja=coder.nullcopy(zeros(3,3,3,'like',poseMat));
    Ja(1,1,1)=0;Ja(1,2,1)=-sy*cz;Ja(1,3,1)=-cy*sz;
    Ja(2,1,1)=-sx*sz+cx*sy*cz;Ja(2,2,1)=sx*cy*cz;Ja(2,3,1)=cx*cz-sx*sy*sz;
    Ja(3,1,1)=cx*sz+sx*sy*cz;Ja(3,2,1)=-cx*cy*cz;Ja(3,3,1)=sx*cz+cx*sy*sz;

    Ja(1,1,2)=0;Ja(1,2,2)=sy*sz;Ja(1,3,2)=-cy*cz;
    Ja(2,1,2)=-sx*cz-cx*sy*sz;Ja(2,2,2)=-sx*cy*sz;Ja(2,3,2)=-cx*sz-sx*sy*cz;
    Ja(3,1,2)=cx*cz-sx*sy*sz;Ja(3,2,2)=cx*cy*sz;Ja(3,3,2)=-sx*sz+cx*sy*cz;

    Ja(1,1,3)=0;Ja(1,2,3)=cy;Ja(1,3,3)=0;
    Ja(2,1,3)=-cx*cy;Ja(2,2,3)=sx*sy;Ja(2,3,3)=0;
    Ja(3,1,3)=-sx*cy;Ja(3,2,3)=-cx*sy;Ja(3,3,3)=0;












    Ha=coder.nullcopy(zeros(3,3,6,'like',poseMat));


    Ha(1,1,1)=0;Ha(1,2,1)=0;Ha(1,3,1)=0;
    Ha(2,1,1)=-cx*sz-sx*sy*cz;Ha(2,2,1)=-cx*cz+sx*sy*sz;Ha(2,3,1)=sx*cy;
    Ha(3,1,1)=-sx*sz+cx*sy*cz;Ha(3,2,1)=-sx*cz-cx*sy*sz;Ha(3,3,1)=-cx*cy;


    Ha(1,1,2)=0;Ha(1,2,2)=0;Ha(1,3,2)=0;
    Ha(2,1,2)=cx*cy*cz;Ha(2,2,2)=-cx*cy*sz;Ha(2,3,2)=cx*sy;
    Ha(3,1,2)=sx*cy*cz;Ha(3,2,2)=-sx*cy*sz;Ha(3,3,2)=sx*sy;


    Ha(1,1,3)=0.0;Ha(1,2,3)=0.0;Ha(1,3,3)=0.0;
    Ha(2,1,3)=-sx*cz-cx*sy*sz;Ha(2,2,3)=sx*sz-cx*sy*cz;Ha(2,3,3)=0.0;
    Ha(3,1,3)=cx*cz-sx*sy*sz;Ha(3,2,3)=-sx*sy*cz-cx*sz;Ha(3,3,3)=0.0;


    Ha(1,1,4)=-cy*cz;Ha(1,2,4)=cy*sz;Ha(1,3,4)=-sy;
    Ha(2,1,4)=-sx*sy*cz;Ha(2,2,4)=sx*sy*sz;Ha(2,3,4)=sx*cy;
    Ha(3,1,4)=cx*sy*cz;Ha(3,2,4)=-cx*sy*sz;Ha(3,3,4)=-cx*cy;


    Ha(1,1,5)=sy*sz;Ha(1,2,5)=sy*cz;Ha(1,3,5)=0.0;
    Ha(2,1,5)=-sx*cy*sz;Ha(2,2,5)=-sx*cy*cz;Ha(2,3,5)=0.0;
    Ha(3,1,5)=cx*cy*sz;Ha(3,2,5)=cx*cy*cz;Ha(3,3,5)=0.0;


    Ha(1,1,6)=-cy*cz;Ha(1,2,6)=cy*sz;Ha(1,3,6)=0.0;
    Ha(2,1,6)=-cx*sz-sx*sy*cz;Ha(2,2,6)=-cx*cz+sx*sy*sz;Ha(2,3,6)=0.0;
    Ha(3,1,6)=-sx*sz+cx*sy*cz;Ha(3,2,6)=-cx*sy*sz-sx*cz;Ha(3,3,6)=0.0;

end

function quat=rpyToQuaternion(rpy)





    r=rpy(1);p=rpy(2);y=rpy(3);

    cy=cos(y/2);
    sy=sin(y/2);

    cr=cos(r/2);
    sr=sin(r/2);

    cp=cos(p/2);
    sp=sin(p/2);

    quat(1)=cy*cr*cp+sy*sr*sp;
    quat(2)=cy*sr*cp-sy*cr*sp;
    quat(3)=cy*cr*sp+sy*sr*cp;
    quat(4)=sy*cr*cp-cy*sr*sp;


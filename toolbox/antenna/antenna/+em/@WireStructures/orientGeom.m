function pnew=orientGeom(obj,p)

    tempTilt=obj.Tilt;
    numTilt=numel(obj.Tilt);
    tempAxis=obj.TiltAxis;


    checkTiltAxisConsistency(obj,tempAxis);

    pnew=em.internal.orientgeom(p,tempTilt,numTilt,tempAxis);




















































end

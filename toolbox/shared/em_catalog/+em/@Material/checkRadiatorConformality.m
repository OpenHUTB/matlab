function checkRadiatorConformality(p,h,tol)



    if~all(abs(p(3,:)-h)<=tol)
        error(message('antenna:antennaerrors:RadiatorNotConformalOnSubstrate'));
    end

end
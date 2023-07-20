function checkRadiatorBounds(pGP,pP)



    xGP_max=max(pGP(1,:));
    yGP_max=max(pGP(2,:));

    xP_max=max(pP(1,:));
    yP_max=max(pP(2,:));

    if(xGP_max<xP_max)||(yGP_max<yP_max)
        error(message('antenna:antennaerrors:RadiatorSizeCrossesSubstrate'));
    end

end
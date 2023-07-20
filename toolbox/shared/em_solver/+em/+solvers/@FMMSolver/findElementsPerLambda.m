function findElementsPerLambda(obj)




    spacing=mean(obj.Geom.RWGDistance);
    lambda=2*pi/obj.Wavenumber;

    obj.ElemsPerWavelength=lambda/spacing;

end
function proceed=hideLobesAndMarkers(p)







    proceed=removeAngleMarkersWithDialog(p);
    if proceed
        hideLobes(p);
    end

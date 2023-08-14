function setMobilePreferences(clientType)
    if contains(clientType,'mobile')
        set(groot,'DefaultFigureToolbar','none');
        set(groot,'DefaultFigureToolbarMode','manual');
    end
end

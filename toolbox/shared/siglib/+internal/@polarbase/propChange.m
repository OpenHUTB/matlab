function propChange(p)


    if ishghandle(p.hAxes)
        lis=p.hListeners;
        lis.PropertyChanges.Enabled=false;

        p.pPublicPropertiesDirty=true;
        plot(p);

        lis.PropertyChanges.Enabled=true;
    end

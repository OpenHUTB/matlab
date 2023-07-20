function isLicensePresent=licenseCheck(isAppContainer,LibraryObjectName)





    isInstalled=ver('radar');
    if nargin==1
        if~isempty(isInstalled)

            [isLicensePresent,~]=builtin('license','checkout','Radar_Toolbox');
        else

            isLicensePresent=false;
        end
    else

        if isempty(isInstalled)
            if~isAppContainer
                h=errordlg(getString(message('phased:apps:waveformapp:radarnotinstalled',LibraryObjectName)));
                uiwait(h);
            else
                uialert(isAppContainer,getString(message('phased:apps:waveformapp:radarnotinstalled',LibraryObjectName)));
            end
            return;
        else
            if~isAppContainer
                h=errordlg(getString(message('phased:apps:waveformapp:radarLicenseUnavailable',LibraryObjectName)));
                uiwait(h);
            else
                uialert(isAppContainer,getString(message('phased:apps:waveformapp:radarLicenseUnavailable',LibraryObjectName)));
            end
            return;
        end
    end
end
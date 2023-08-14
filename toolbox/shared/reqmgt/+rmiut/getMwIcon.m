function iconFile=getMwIcon(linkSettings)

    if nargin<1
        linkSettings=rmi.settings_mgr('get','linkSettings');
    end

    if linkSettings.slrefCustomized
        iconFile=linkSettings.slrefUserBitmap;
    else
        iconFile=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','mwlink_24.bmp');
    end
end


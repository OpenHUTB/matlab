function available=isDesktopAvailable()



    available=isempty(javachk('swing'))&&~isdeployed();

end